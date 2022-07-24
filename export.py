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

    my_cfg = cfg_default | cfg_user
    if not my_cfg["windows"]:
        if ("linux_settings" in cfg_default.keys()) and ("linux_settings" in cfg_user.keys()):
            my_cfg["linux_settings"] = cfg_default["linux_settings"] | cfg_user["linux_settings"]
        my_cfg = my_cfg | my_cfg["linux_settings"]
    my_cfg = SimpleNamespace(**my_cfg)

    # Version of this script
    my_cfg.script_version = "3.0.0"
    # Path to scripts
    my_cfg.script_root = f"{my_cfg.game_root}/Edit scripts"
    # Path to exported dumps
    my_cfg.dump_root = f"{my_cfg.script_root}/dumps"
    # Path to store SQLite database at
    my_cfg.db_path = f"{my_cfg.dump_root}/fo76-dumps-v{my_cfg.script_version}-v{my_cfg.game_version}.db"
    # Path to `_done.txt`
    my_cfg.done_path = f"{my_cfg.dump_root}/_done.txt"

    return my_cfg


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
        subprocess.call(command, stdout=subprocess.DEVNULL)
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
    print("> Running xEdit.\n> Be sure to double-check version information in the xEdit window!")

    # Check for existing files
    if Path(cfg.done_path).exists():
        if not prompt_confirmation("> WARNING: '_done.txt' already exists, indicating a dump already exists in the "
                                   "target folder. Continue anyway? (y/n) "):
            print("")
            return
        os.remove(cfg.done_path)

    # Create ini if it does not exist
    config_dir = \
        f"{Path.home()}/Documents/My Games/Fallout 76/" if cfg.windows \
        else f"{cfg.xedit_compatdata_path}/pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/"
    Path(config_dir).mkdir(exist_ok=True, parents=True)
    Path(f"{config_dir}/Fallout76.ini").touch(exist_ok=True)

    # Store initial `_done.txt` modification time
    done_file = Path(cfg.done_path)
    done_time = done_file.stat().st_mtime if done_file.exists() else None

    # Actually run xEdit
    cwd = os.getcwd()
    os.chdir(cfg.script_root)
    run_executable(f"\"{cfg.xedit_path}\" -D:\"{cfg.game_root}/Data/\" ExportAll.fo76pas",
                   cfg.xedit_compatdata_path if not cfg.windows else "")
    os.chdir(cwd)

    # Check if `_done.txt` changed
    new_done_time = done_file.stat().st_mtime if done_file.exists() else None
    if new_done_time is None or done_time == new_done_time:
        if not prompt_confirmation("> WARNING: xEdit did not create or update '_done.txt'. Continue anyway? (y/n) "):
            print()
            return

    # Post-processing
    xedit_prefix_outputs()
    xedit_concat_parts()
    xedit_create_db()
    if cfg.enable_archive_xedit:
        archive_xedit_start()

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

        path.rename(f"{path.parent}/{prefix}{path.name}")

    print(">> Done prefixing files.")


def xedit_concat_parts():
    """Concatenates files that have been dumped in parts by the xEdit script."""
    print(">> Combining dumped CSV parts.")

    print(">>> Combining 'tabular.IDs.csv'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/IDs.csv.*"), f"{cfg.dump_root}/tabular.IDs.csv")

    print(">>> Combining 'wiki.TERM.wiki'.")
    concat_parts_of(glob.glob(f"{cfg.dump_root}/TERM.wiki.*"), f"{cfg.dump_root}/wiki.TERM.wiki")

    print(">> Done combining dumped CSV parts.")


def xedit_create_db():
    """Imports the dumped CSVs into an SQLite database."""
    print(f">> Importing CSVs into SQLite database at '{cfg.db_path}'.")

    # Check for existing files
    if Path(cfg.db_path).exists():
        if not prompt_confirmation(f">> WARNING: '{Path(cfg.db_path).name}' already exists and will be deleted. "
                                   f"Continue anyway? (y/n) "):
            return
        os.remove(cfg.db_path)

    # Import into database
    with sqlite3.connect(cfg.db_path) as con:
        for file in glob.glob(f"{cfg.dump_root}/*.csv"):
            path = Path(file)
            table_name = path.stem.split('.', 1)[1]
            print(f">>> Importing '{path.name}' into table '{table_name}'.")

            df = pd.read_csv(file, quotechar='"', doublequote=True, skipinitialspace=True, dtype="string")
            df.columns = df.columns.str.replace(" ", "_")
            df.to_sql(table_name, con, index=False)

    print(f">> Done importing CSVs into SQLite database at '{cfg.db_path}'.")


def ba2extract():
    """Creates raw dumps using ba2extract."""
    print("> Extracting Bethesda archives.")

    # Extract archives
    for target, files in cfg.ba2extract_targets.items():
        print(f">> Extracting {target}.")
        temp_dir = TemporaryDirectory(prefix=f"fo76-dumps-{target}")

        run_executable(f"\"{cfg.ba2extract_path}\" \"{cfg.game_root}/Data/{target}\" \"{temp_dir.name}\"",
                       cfg.ba2extract_compatdata_path if not cfg.windows else "")

        for archive_path, desired_path in files.items():
            desired_path_abs = Path(f"{cfg.dump_root}/raw.{desired_path}")

            if desired_path_abs.exists() and desired_path_abs.is_dir():
                shutil.rmtree(desired_path_abs)

            shutil.move(f"{temp_dir.name}/{archive_path}", desired_path_abs)

            if cfg.ba2extract_zip_dirs and desired_path_abs.is_dir():
                shutil.make_archive(str(desired_path_abs), "zip", desired_path_abs)

        print(f">> Done extracting {target}.")

    print("> Done extracting Bethesda archives.\n")


def archive_esms_start():
    print("> Archiving ESMs in the background.")
    cwd = os.getcwd()
    os.chdir(cfg.dump_root)

    with open(os.devnull, "wb") as devnull:
        archive_children["ESMs"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                     f"SeventySix.esm.v{cfg.game_version}.7z",
                                                     f"{cfg.game_root}/Data/SeventySix.esm",
                                                     f"{cfg.game_root}/Data/NW.esm"],
                                                    stdout=devnull, stderr=subprocess.STDOUT)

    os.chdir(cwd)
    print("")


def archive_xedit_start():
    """Archives all xEdit dumps that are larger than 10MB."""
    print(">> Archiving large xEdit dumps in the background.")
    cwd = os.getcwd()
    os.chdir(cfg.dump_root)

    with open(os.devnull, "wb") as devnull:
        for dump in glob.glob(f"*.csv") + glob.glob(f"*.wiki") + glob.glob(f"*.db"):
            csv_path = Path(dump)

            if csv_path.stat().st_size < 10000000:
                continue

            print(f">> Starting archiving of '{csv_path.name}'.")
            archive_children[f"'{csv_path.name}'"] = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4",
                                                                       f"{csv_path.name}.7z",
                                                                       csv_path.name],
                                                                      stdout=devnull, stderr=subprocess.STDOUT)

    os.chdir(cwd)


def archive_join():
    print("> Waiting for background archiving processes.")

    for csv_path, child in archive_children.items():
        print(f">> Waiting for archiving of {csv_path}.")
        child.wait()

    print("> Done waiting for background archiving processes.\n")


def main():
    """The main function."""
    print(f"Creating fo76-dumps using '{cfg.xedit_path}'.")
    if cfg.game_version == "x.y.z.w":
        if not prompt_confirmation("WARNING: The game version is set to 'x.y.z.w' in the configuration, which is "
                                   "probably incorrect. If you continue, some dumps will have incorrect names. Do you "
                                   "want to continue anyway? (y/n) "):
            exit()
    if not cfg.windows and ("INSERT NUMBER HERE" in cfg.xedit_compatdata_path or
                            "INSERT NUMBER HERE" in cfg.ba2extract_compatdata_path):
        if not prompt_confirmation("WARNING: You did not adjust the compatdata path for xEdit or for ba2extract. This "
                                   "might cause issues when launching xEdit or ba2extract. Check the dump scripts wiki "
                                   "at https://github.com/FWDekker/fo76-dumps/wiki/Generating-dumps/ for more "
                                   "information. Continue anyway? (y/n) "):
            exit()
    if Path(cfg.dump_root).exists() and len(os.listdir(cfg.dump_root)) != 0:
        if prompt_confirmation("INFO: The dump output directory exists and is not empty. Do you want to remove the "
                               "directory and its contents? This is optional. (y/n) "):
            shutil.rmtree(cfg.dump_root)
    print("")

    # Create dumps output dir
    Path(cfg.dump_root).mkdir(parents=True, exist_ok=True)

    # Archiving
    if cfg.enable_archive_esms:
        archive_esms_start()

    # xEdit
    if cfg.enable_xedit:
        xedit()

    # ba2extract
    if cfg.enable_ba2extract:
        ba2extract()

    # Archiving
    archive_join()

    print("Done!")


if __name__ == "__main__":
    archive_children = {}
    cfg = load_config()

    main()
