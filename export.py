import glob
import os
import shutil
import sqlite3
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from typing import List

import pandas as pd


def load_config() -> SimpleNamespace:
    """Load configuration from config files and set globals."""
    from config_default import config as cfg_default
    if Path("config.py").exists():
        from config import config as cfg_user
    else:
        cfg_user = {}

    cfg2 = cfg_default | cfg_user
    cfg2 = (cfg2 | cfg2["windows_settings"]) if cfg2["windows"] else (cfg2 | cfg2["linux_settings"])

    # Version of this script
    cfg2["script_version"] = "2.6.0"
    # Path to scripts
    cfg2["script_root"] = Path("./Edit scripts").resolve()
    # Path to exported dumps
    cfg2["dump_root"] = Path(cfg2["script_root"], "dumps")
    # Path to store SQLite database at
    cfg2["db_path"] = Path(cfg2["dump_root"], f"fo76-dumps-v{cfg2['script_version']}-v{cfg2['game_version']}.db")
    # Path to `_done.txt`
    cfg2["done_path"] = Path(cfg2["dump_root"], "_done.txt")

    return SimpleNamespace(**cfg2)


def prompt_confirmation(message: str) -> bool:
    # Prompts the user to confirm `message`, returning `True` if the user inputs `"y"`, returning `False` if the user
    # inputs `"n"`, and repeating the prompt otherwise.
    while True:
        result = input(message).lower()
        if result == "y":
            return True
        elif result == "n":
            return False
        else:
            continue


def run_executable(command: str, compatdata_path: str):
    """Runs the executable with parameters defined in `command`. On Windows, the command is executed normally. On Linux,
    the command is executed in a Proton instance using `compatdata_path`."""
    if cfg.windows:
        os.system(command)
    else:
        os.system(
            f"STEAM_COMPAT_CLIENT_INSTALL_PATH='{cfg.steam_path}' "
            f"STEAM_COMPAT_DATA_PATH='{compatdata_path}' "
            f"'{cfg.proton_path}' run {command} "
            f">/dev/null"
        )


def concat_parts_of(input_paths: List[str], output_path: str):
    """Concatenates the contents of all files in `input_paths` and writes the output to `output_path`."""
    if len(input_paths) == 0:
        return

    input_paths.sort()

    with open(output_path, "wb") as f_out:
        for input_path in input_paths:
            with open(input_path, "rb") as f_in:
                shutil.copyfileobj(f_in, f_out)


def xedit():
    """Runs xEdit and waits until it closes.

    Tries to detect whether the script ran successfully by checking if `_done.txt` was created or modified."""
    print("> Running xEdit.\nBe sure to double-check version information in the xEdit window!")

    # Check for existing files
    if Path(cfg.done_path).exists():
        if not prompt_confirmation("WARNING: '_done.txt' already exists, indicating a dump already exists in the "
                                   "target folder. Continue anyway? (y/n) "):
            return
        os.remove(cfg.done_path)

    # Create ini if it does not exist
    if not cfg.windows:
        config_dir = Path(cfg.xedit_compatdata_path, "pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/")
        config_dir.mkdir(exist_ok=True, parents=True)
        Path(config_dir, "Fallout76.ini").touch(exist_ok=True)

    # Store initial `_done.txt` modification time
    done_file = Path(cfg.done_path)
    done_time = done_file.stat().st_mtime if done_file.exists() else None

    # Actually run xEdit
    cwd = os.getcwd()
    os.chdir(cfg.script_root)
    run_executable(f"'{cfg.xedit_path}' ExportAll.fo76pas", cfg.xedit_compatdata_path)
    os.chdir(cwd)

    # Check if `_done.txt` changed
    new_done_time = done_file.stat().st_mtime if done_file.exists() else None
    if new_done_time is None or done_time == new_done_time:
        if not prompt_confirmation("WARNING: xEdit did not create or update '_done.txt'. Continue anyway? (y/n) "):
            return

    # Post-processing
    xedit_prefix_outputs()
    xedit_concat_parts()
    xedit_create_db()

    print("> Done running xEdit.\n")


def xedit_prefix_outputs():
    """Renames the exported files so that they have a prefix `tabular.` or `wiki.` depending on the file type.

    Files that already have the appropriate prefix are unaffected."""
    print(">> Prefixing files.")

    for filename in glob.glob(f"{cfg.dump_root}/*.csv") + glob.glob(f"{cfg.dump_root}/*.wiki"):
        path = Path(filename)
        prefix = "tabular." if path.suffix == ".csv" else "wiki."

        if path.stem.startswith(prefix):
            # Skip already-prefixed files
            return

        path.rename(Path(path.parent, f"{prefix}{path.name}"))

    print(">> Done prefixing files.\n")


def xedit_concat_parts():
    """Concatenates files that have been dumped in parts by the xEdit script."""
    print(">> Combining dumped CSV parts.")

    print(">>> Combining 'tabular.IDs.csv'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/IDs.csv.*"), f"{cfg.dump_root}/tabular.IDs.csv")

    print(">>> Combining 'wiki.TERM.wiki'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/TERM.wiki.*"), f"{cfg.dump_root}/wiki.TERM.wiki")

    print(">> Done combining dumped CSV parts.\n")


def xedit_create_db():
    """Imports the dumped CSVs into an SQLite database."""
    print(f">> Importing CSVs into SQLite database at '{cfg.db_path}'.")

    # Check for existing files
    if Path(cfg.db_path).exists():
        if not prompt_confirmation(f"WARNING: '{Path(cfg.db_path).name}' already exists and will be deleted. Continue? "
                                   f"(y/n) "):
            return
        os.remove(cfg.db_path)

    # Import into database
    with sqlite3.connect(cfg.db_path) as con:
        for file in glob.glob(f"{cfg.dump_root}/*.csv"):
            path = Path(file)
            table_name = path.stem.split('.', 1)[1]
            print(f">> Importing '{path.name}' into table '{table_name}'.")

            df = pd.read_csv(file, quotechar='"', doublequote=True, skipinitialspace=True, dtype="string")
            df.columns = df.columns.str.replace(" ", "_")
            df.to_sql(table_name, con, index=False)

    print(f">> Done importing CSVs into SQLite database at '{cfg.db_path}'.\n")


def ba2extract():
    """Creates raw dumps using ba2extract."""
    print("> Extracting Bethesda archives.")
    temp_dir = TemporaryDirectory(prefix="fo76-dumps-")

    # Check for existing files
    existing_outputs = sum([Path(f"{cfg.dump_root}/{it}").exists() for it in cfg.ba2extract_files.values()])
    if existing_outputs > 0:
        if not prompt_confirmation(f"WARNING: {existing_outputs} output file(s) already exist(s) and will be "
                                   f"overwritten. Continue anyway? (y/n) "):
            exit()

    # Extract archives
    targets_string = " ".join([f"'{cfg.game_root}/Data/{it}'" for it in cfg.ba2extract_archives])
    run_executable(f"'{cfg.ba2extract_path}' {targets_string} '{temp_dir.name}'", cfg.ba2extract_compatdata_path)

    # Move extracted files
    for archive_path, desired_path in cfg.ba2extract_files.items():
        shutil.move(f"{temp_dir.name}/{archive_path}", f"{cfg.dump_root}/{desired_path}")

    print("> Done extracting Bethesda archives.\n")


def archive_dumps():
    """Archives all `.csv`, `.wiki`, and `.db` dumps that are larger than 10MB."""
    print("> Archiving dumps.")
    cwd = os.getcwd()
    os.chdir(cfg.dump_root)

    # Fork
    children = {}
    with open(os.devnull, "wb") as devnull:
        if cfg.enable_archive_esms:
            print(f">> Starting archiving of ESMs.")
            children["ESMs"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                 f"SeventySix.esm.v{cfg.game_version}.7z",
                                                 f"{cfg.game_root}/Data/SeventySix.esm",
                                                 f"{cfg.game_root}/Data/NW.esm"],
                                                stdout=devnull, stderr=subprocess.STDOUT)

        if cfg.enable_archive_large:
            for dump in glob.glob(f"*.csv") + glob.glob(f"*.wiki") + glob.glob(f"*.db"):
                csv_path = Path(dump)

                if csv_path.stat().st_size < 10000000:
                    continue

                print(f">> Starting archiving of '{csv_path.name}'.")
                children[f"'{csv_path.name}'"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                                   f"{csv_path.name}.7z",
                                                                   csv_path.name],
                                                                  stdout=devnull, stderr=subprocess.STDOUT)

    # Join
    for csv_path, child in children.items():
        print(f">> Waiting for archiving of {csv_path}.")
        child.wait()

    os.chdir(cwd)
    print("> Done archiving dumps.\n")


def main():
    """The main function."""
    print(f"Creating fo76-dumps using '{cfg.xedit_path}'.")
    if cfg.game_version == "x.y.z.w":
        if not prompt_confirmation("WARNING: The game version is set to 'x.y.z.w' in the configuration, which is "
                                   "probably incorrect. If you continue, some dumps will have incorrect names. Do you "
                                   "want to continue anyway? (y/n) "):
            exit()
    if Path.exists(cfg.dump_root) and len(os.listdir(cfg.dump_root)) != 0:
        if prompt_confirmation("INFO: The dump output directory exists and is not empty. Do you want to remove the "
                               "directory and its contents? This is optional. (y/n) "):
            shutil.rmtree(cfg.dump_root)
    print("")

    # Create dumps output dir, just in case
    Path(cfg.dump_root).mkdir(parents=True, exist_ok=True)

    # xEdit
    if cfg.enable_xedit:
        xedit()
        xedit_prefix_outputs()
        xedit_concat_parts()
        xedit_create_db()

    # ba2extract
    if cfg.enable_ba2extract:
        ba2extract()

    # Archival
    if cfg.enable_archive_large or cfg.enable_archive_esms:
        archive_dumps()

    print("Done!")


if __name__ == "__main__":
    cfg = load_config()
    main()
