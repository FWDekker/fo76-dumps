import fileinput
import glob
import os
import sqlite3
import subprocess
from pathlib import Path
import pandas as pd


xedit_script = "ExportAll.fo76pas"
# xedit_script = "ExportAll.fo76ptspas"  # Uncomment to run PTS dumps
archiver_path = "7z.exe"  # Path to 7z executable

script_root = "./Edit scripts"  # Relative path to scripts
dump_root = f"{script_root}/dumps/pts"  # Relative path to exported dumps
db_path = f"{dump_root}/fo76-dumps-vSCRIPT-vGAME.db"  # Relative path to store SQLite database at


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

    if Path(f"{dump_root}/_done.txt").exists():
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
    print("> Running xEdit.")

    done_file = Path(f"{dump_root}/_done.txt")
    done_time = done_file.stat().st_mtime if done_file.exists() else None

    cwd = os.getcwd()
    os.chdir(script_root)
    subprocess.call(["start", "", "/wait", f"{xedit_script}"], stderr=subprocess.STDOUT, shell=True)
    os.chdir(cwd)

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

    with open(output_path, "w") as f_out:
        f_in = fileinput.input(input_paths)
        for line in f_in:
            f_out.write(line)
        f_in.close()


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
    print(f"Creating fo76-dumps using '{xedit_script}'. "
          "Be sure to check version information in the xEdit window.")
    print()

    clean_up()
    run_xedit()
    prefix_files()
    concat_parts()
    import_in_sqlite()
    archive_files()

    print("Done!")
