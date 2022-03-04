import glob
import os
import shutil
import sqlite3
import subprocess
from pathlib import Path
import pandas as pd


# Configuration - Change these to your liking
game_version = "x.y.z.w"  # Visible in-game in bottom-left corner in settings menu

windows = True
if windows:
    archiver_path = "7z.exe"  # Path to 7z executable
    xedit_path = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout76\FO76Edit64.exe"  # Path to xEdit
else:
    archiver_path = "7z"  # Path to 7z executable
    compatdata_path = f"{Path.home()}/.steam/steam/steamapps/compatdata/xxxxxxxxxx/"  # Path to xEdit compatdata
    proton_path = f"{Path.home()}/.local/share/Steam/steamapps/common/Proton - Experimental/proton"  # Path to Proton
    steam_path = f"{Path.home()}/.steam/steam/"  # Steam installation path
    xedit_path = f"{Path.home()}/.steam/steam/steamapps/common/Fallout76/FO76Edit64.exe"  # Path to xEdit

# Utility - No need to change these
script_version = "2.5.1"
script_root = "./Edit scripts"  # Relative path to scripts
dump_root = f"{script_root}/dumps/"  # Relative path to exported dumps
db_path = f"{dump_root}/fo76-dumps-v{script_version}-v{game_version}.db"  # Relative path to store SQLite database at
done_path = f"{dump_root}/_done.txt"  # Relative path to `_done.txt`


def prompt_confirmation(message):
    # Prompts the user for confirmation, returning once the user inputs 'y', exiting the program if the user inputs 'n',
    # and repeating the prompt otherwise.
    while True:
        result = input(message).lower()
        if result == "y":
            return
        elif result == "n":
            exit()
        else:
            continue


def clean_up():
    # Cleans up files from a previous run.
    print("> Checking for files to clean up.")

    if Path(done_path).exists():
        prompt_confirmation("WARNING: '_done.txt' already exists, indicating a dump already exists in the target "
                            "folder. Continue anyway? (y/n) ")

    if Path(db_path).exists():
        prompt_confirmation(f"WARNING: '{Path(db_path).name}' already exists and will be deleted. Continue? (y/n) ")
        os.remove(db_path)

    print("> Done checking for files to clean up.\n")


def run_xedit():
    # Runs xEdit by launching `xedit_script` using its default file association, and waits until it closes.
    #
    # Tries to detect whether the script ran successfully by checking if '_done.txt' has been created or modified.
    print("> Running xEdit.\nBe sure to check version information in the xEdit window!")

    # Create ini if it does not exist
    if not windows:
        Path(compatdata_path, "pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/Fallout76.ini").touch()

    # Store initial `_done.txt` modification time
    done_file = Path(done_path)
    done_time = done_file.stat().st_mtime if done_file.exists() else None

    # Actually run xEdit
    cwd = os.getcwd()
    os.chdir(script_root)
    if windows:
        os.system(f"{xedit_path} ExportAll.fo76pas")
    else:
        os.system(
            f"STEAM_COMPAT_CLIENT_INSTALL_PATH='{steam_path}' "
            f"STEAM_COMPAT_DATA_PATH='{compatdata_path}' "
            f"'{proton_path}' run '{xedit_path}' ExportAll.fo76pas"
        )
    os.chdir(cwd)

    # Check if `_done.txt` changed
    new_done_time = done_file.stat().st_mtime if done_file.exists() else None
    if new_done_time is None or done_time == new_done_time:
        prompt_confirmation("WARNING: xEdit did not create or update '_done.txt'. Continue anyway? (y/n) ")

    print("> Done running xEdit.\n")


def prefix_files():
    # Renames the exported files so that they have a prefix `tabular.` or `wiki.` depending on the file type.
    #
    # Files that already have the appropriate prefix are unaffected.
    print("> Prefixing files.")

    for filename in glob.glob(f"{dump_root}/*.csv") + glob.glob(f"{dump_root}/*.wiki"):
        path = Path(filename)
        prefix = "tabular." if path.suffix == ".csv" else "wiki."

        if path.stem.startswith(prefix):
            return

        path.rename(Path(path.parent, f"{prefix}{path.name}"))

    print("> Done prefixing files.\n")


def concat_parts_of(input_paths, output_path):
    # Concatenates the contents of all files `input_paths` and writes the output to `output_path`.
    if len(input_paths) == 0:
        return

    input_paths.sort()

    with open(output_path, "wb") as f_out:
        for input_path in input_paths:
            with open(input_path, "rb") as f_in:
                shutil.copyfileobj(f_in, f_out)


def concat_parts():
    # Concatenates files that have been dumped in parts by the xEdit script.
    print("> Combining dumped CSV parts.")

    print(">> Combining 'tabular.IDs.csv'.")
    concat_parts_of(glob.glob(f"{dump_root}/IDs.csv.*"), f"{dump_root}/tabular.IDs.csv")

    print(">> Combining 'wiki.TERM.wiki'.")
    concat_parts_of(glob.glob(f"{dump_root}/TERM.wiki.*"), f"{dump_root}/wiki.TERM.wiki")

    print("> Done combining dumped CSV parts.\n")


def import_in_sqlite():
    # Imports the dumped CSVs into an SQLite database.
    print(f"> Importing CSVs into SQLite database at '{db_path}'.")

    with sqlite3.connect(db_path) as con:
        for file in glob.glob(f"{dump_root}/*.csv"):
            path = Path(file)
            table_name = path.stem.split('.', 1)[1]
            print(f">> Importing '{path.name}' into table '{table_name}'.")

            df = pd.read_csv(file, quotechar='"', doublequote=True, skipinitialspace=True, dtype="string")
            df.columns = df.columns.str.replace(" ", "_")
            df.to_sql(table_name, con, index=False)

    print(f"> Done importing CSVs into SQLite database at '{db_path}'.\n")


def archive_files():
    # Archives all files (except parts) that are larger than 10MB
    print("> Archiving files larger than 10MB.")
    children = {}

    for dump in glob.glob(f"{dump_root}/*.csv") + glob.glob(f"{dump_root}/*.wiki") + glob.glob(f"{dump_root}/*.db"):
        csv_path = Path(dump)

        if csv_path.stat().st_size < 10000000:
            continue

        print(f">> Starting archiving of '{csv_path.name}'.")
        with open(os.devnull, "wb") as devnull:
            cwd = os.getcwd()
            os.chdir(csv_path.parent)
            child = subprocess.Popen([archiver_path, "a", "-mx9", "-mmt4", f"{csv_path.name}.7z", csv_path.name],
                                     stdout=devnull, stderr=subprocess.STDOUT)
            children[f"{csv_path.name}"] = child
            os.chdir(cwd)

    for csv_path, child in children.items():
        print(f">> Waiting for archiving of '{csv_path}'.")
        child.wait()

    print("> Done archiving files larger than 10MB.\n")


if __name__ == "__main__":
    print(f"Creating fo76-dumps using '{xedit_path}'.")
    print()

    clean_up()
    run_xedit()
    prefix_files()
    concat_parts()
    import_in_sqlite()
    archive_files()

    print("Done!")
