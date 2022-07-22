import glob
import os
import shutil
import sqlite3
import subprocess
from pathlib import Path
from types import SimpleNamespace

import pandas as pd

from config_default import config as cfg_default


# TODO: Allow toggle for main vs PTS
# TODO: Make more features toggleable (enable/disable xEdit, ba2, etc.)
# TODO: Use absolute paths
# TODO: Move Proton invocations to separate function to reduce duplication
# TODO: Move config loading to special function, then add cfg as param to other functions

# xedit_path = f"{Path.home()}/.steam/steam/steamapps/common/Fallout 76 Playtest/FO76Edit64.exe"  # Path to xEdit
# game_root = f"{Path.home()}/.steam/steam/steamapps/common/Fallout 76 Playtest/"  # Path to game files


# Load configuration and set globals
if Path("config.py").exists():
    from config import config as cfg_user
else:
    cfg_user = {}

cfg = cfg_default | cfg_user
cfg = (cfg | cfg["windows_settings"]) if cfg["windows"] else (cfg | cfg["linux_settings"])

# Version of this script
cfg["script_version"] = "2.6.0"
# Relative path to scripts
cfg["script_root"] = "./Edit scripts"
# Relative path to exported dumps
cfg["dump_root"] = f"{cfg['script_root']}/dumps/"
# Relative path to store SQLite database at
cfg["db_path"] = f"{cfg['dump_root']}/fo76-dumps-v{cfg['script_version']}-v{cfg['game_version']}.db"
# Relative path to `_done.txt`
cfg["done_path"] = f"{cfg['dump_root']}/_done.txt"

cfg = SimpleNamespace(**cfg)


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
    """Cleans up files from a previous run."""
    print("> Checking for files to clean up.")

    if Path(cfg.done_path).exists():
        prompt_confirmation("WARNING: '_done.txt' already exists, indicating a dump already exists in the target "
                            "folder. Continue anyway? (y/n) ")

    if Path(cfg.db_path).exists():
        prompt_confirmation(f"WARNING: '{Path(cfg.db_path).name}' already exists and will be deleted. Continue? (y/n) ")
        os.remove(cfg.db_path)

    print("> Done checking for files to clean up.\n")


def run_xedit():
    """Runs xEdit by launching xEdit using its default file association, and waits until it closes.

    Tries to detect whether the script ran successfully by checking if `_done.txt` was created or modified."""
    print("> Running xEdit.\nBe sure to check version information in the xEdit window!")

    # Create ini if it does not exist
    if not cfg.windows:
        Path(cfg.xedit_compatdata_path, "pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/").mkdir(
            exist_ok=True,
            parents=True)
        Path(cfg.xedit_compatdata_path,
             "pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/Fallout76.ini").touch()

    # Store initial `_done.txt` modification time
    done_file = Path(cfg.done_path)
    done_time = done_file.stat().st_mtime if done_file.exists() else None

    # Actually run xEdit
    cwd = os.getcwd()
    os.chdir(cfg.script_root)
    if cfg.windows:
        os.system(f"{cfg.xedit_path} ExportAll.fo76pas")
    else:
        os.system(
            f"STEAM_COMPAT_CLIENT_INSTALL_PATH='{cfg.steam_path}' "
            f"STEAM_COMPAT_DATA_PATH='{cfg.xedit_compatdata_path}' "
            f"'{cfg.proton_path}' run '{cfg.xedit_path}' ExportAll.fo76pas"
        )
    os.chdir(cwd)

    # Check if `_done.txt` changed
    new_done_time = done_file.stat().st_mtime if done_file.exists() else None
    if new_done_time is None or done_time == new_done_time:
        prompt_confirmation("WARNING: xEdit did not create or update '_done.txt'. Continue anyway? (y/n) ")

    print("> Done running xEdit.\n")


def prefix_files():
    """Renames the exported files so that they have a prefix `tabular.` or `wiki.` depending on the file type.

    Files that already have the appropriate prefix are unaffected."""
    print("> Prefixing files.")

    for filename in glob.glob(f"{cfg.dump_root}/*.csv") + glob.glob(f"{cfg.dump_root}/*.wiki"):
        path = Path(filename)
        prefix = "tabular." if path.suffix == ".csv" else "wiki."

        if path.stem.startswith(prefix):
            return

        path.rename(Path(path.parent, f"{prefix}{path.name}"))

    print("> Done prefixing files.\n")


def concat_parts_of(input_paths, output_path):
    """Concatenates the contents of all files in `input_paths` and writes the output to `output_path`."""
    if len(input_paths) == 0:
        return

    input_paths.sort()

    with open(output_path, "wb") as f_out:
        for input_path in input_paths:
            with open(input_path, "rb") as f_in:
                shutil.copyfileobj(f_in, f_out)


def concat_parts():
    """Concatenates files that have been dumped in parts by the xEdit script."""
    print("> Combining dumped CSV parts.")

    print(">> Combining 'tabular.IDs.csv'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/IDs.csv.*"), f"{cfg.dump_root}/tabular.IDs.csv")

    print(">> Combining 'wiki.TERM.wiki'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/TERM.wiki.*"), f"{cfg.dump_root}/wiki.TERM.wiki")

    print("> Done combining dumped CSV parts.\n")


def import_in_sqlite():
    """Imports the dumped CSVs into an SQLite database."""
    print(f"> Importing CSVs into SQLite database at '{cfg.db_path}'.")

    with sqlite3.connect(cfg.db_path) as con:
        for file in glob.glob(f"{cfg.dump_root}/*.csv"):
            path = Path(file)
            table_name = path.stem.split('.', 1)[1]
            print(f">> Importing '{path.name}' into table '{table_name}'.")

            df = pd.read_csv(file, quotechar='"', doublequote=True, skipinitialspace=True, dtype="string")
            df.columns = df.columns.str.replace(" ", "_")
            df.to_sql(table_name, con, index=False)

    print(f"> Done importing CSVs into SQLite database at '{cfg.db_path}'.\n")


def run_ba2extract():
    # TODO: Make this configurable
    # TODO: Use temp dir for program's output
    # TODO: Suppress output!
    """Creates raw dumps using ba2extract."""
    print("> Extracting interface BA2.")
    if cfg.windows:
        os.system(
            f"{cfg.ba2extract_path} '{cfg.game_root}/Data/SeventySix - Interface.ba2' '{cfg.dump_root}/ba2_interface/'")
    else:
        os.system(
            f"STEAM_COMPAT_CLIENT_INSTALL_PATH='{cfg.steam_path}' "
            f"STEAM_COMPAT_DATA_PATH='{cfg.ba2extract_compatdata_path}' "
            f"'{cfg.proton_path}' run '{cfg.ba2extract_path}' '{cfg.game_root}/Data/SeventySix - Interface.ba2' '{cfg.dump_root}/ba2_interface/'"
        )

    os.rename(f"{cfg.dump_root}/ba2_interface/interface/credits.txt", f"{cfg.dump_root}/credits.txt")

    print("> Cleaning up interface BA2 extraction.")
    shutil.rmtree(f"{cfg.dump_root}/ba2_interface/")

    print("> Done extracting interface BA2.")


def archive_files():
    """Archives all `.csv`, `.wiki`, and `.db` dumps that are larger than 10MB."""
    print("> Archiving files larger than 10MB.")
    cwd = os.getcwd()
    os.chdir(cfg.dump_root)

    children = {}
    with open(os.devnull, "wb") as devnull:
        if cfg.enable_archive_esms:
            print(f">> Starting archiving of ESMs.")
            children["ESMs"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                 f"SeventySix.esm.v{cfg.game_version}.7z",
                                                 f"{cfg.game_root}/Data/SeventySix.esm",
                                                 f"{cfg.game_root}/Data/NW.esm"],
                                                stdout=devnull, stderr=subprocess.STDOUT)

        for dump in glob.glob(f"*.csv") + glob.glob(f"*.wiki") + glob.glob(f"*.db"):
            csv_path = Path(dump)

            if csv_path.stat().st_size < 10000000:
                continue

            print(f">> Starting archiving of '{csv_path.name}'.")
            children[f"'{csv_path.name}'"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                               f"{csv_path.name}.7z",
                                                               csv_path.name],
                                                              stdout=devnull, stderr=subprocess.STDOUT)

    for csv_path, child in children.items():
        print(f">> Waiting for archiving of {csv_path}.")
        child.wait()

    os.chdir(cwd)
    print("> Done archiving files larger than 10MB.\n")


if __name__ == "__main__":
    print(f"Creating fo76-dumps using '{cfg.xedit_path}'.\n")

    if cfg.game_version == "x.y.z.w":
        prompt_confirmation("WARNING: The game version is set to `x.y.z.w` in the configuration, which is probably "
                            "incorrect. If you continue, some dumps will have incorrect names. Do you want to continue "
                            "anyway? (y/n) ")

    # Preparation
    clean_up()

    # xEdit
    run_xedit()
    prefix_files()
    concat_parts()
    import_in_sqlite()

    # ba2extract
    run_ba2extract()

    # Archival
    archive_files()

    print("Done!")
