import shutil
import sqlite3
import subprocess
from pathlib import Path
from typing import List

import pandas as pd

import Files
from IO import prompt_confirmation, run_executable
from State import cfg, subprocesses


def xedit() -> None:
    """
    Runs xEdit and waits until it closes.
    
    :return: `None`
    """

    print(f"> Running xEdit using '{cfg.xedit_path}'.\n"
          f"> Be sure to double-check version information in the xEdit window!")

    # Check for existing files
    if cfg.done_path.exists():
        if not prompt_confirmation(f"> WARNING: "
                                   f"'{cfg.done_path.name}' already exists and must be deleted. "
                                   f"Do you want to DELETE '{cfg.done_path}' and continue? (y/n) "):
            exit()
        Files.delete(cfg.done_path)

    # Create ini if it does not exist
    config_dir = (Path.home() / "Documents/My Games/Fallout 76/" if cfg.windows
                  else cfg.xedit_compatdata_path / "pfx/drive_c/users/steamuser/Documents/My Games/Fallout 76/")
    config_dir.mkdir(exist_ok=True, parents=True)
    (config_dir / "Fallout76.ini").touch(exist_ok=True)

    # Store initial `_done.txt` modification time
    done_time = cfg.done_path.stat().st_mtime if cfg.done_path.exists() else None

    # Actually run xEdit
    run_executable(args=[cfg.xedit_path, f"-D:{cfg.game_root / 'Data/'}", "ExportAll.fo76pas"],
                   compatdata_path=cfg.xedit_compatdata_path if not cfg.windows else "",
                   cwd=cfg.script_root)

    # Check if `_done.txt` changed
    new_done_time = cfg.done_path.stat().st_mtime if cfg.done_path.exists() else None
    if new_done_time is None or done_time == new_done_time:
        if not prompt_confirmation(f"> WARNING: "
                                   f"xEdit did not create or update '{cfg.done_path.name}', indicating that the dump "
                                   f"scripts may have failed. "
                                   f"Continue anyway? (y/n) "):
            exit()

    # Post-processing
    prefix_outputs()
    concat_parts()
    create_db()
    if cfg.enable_archive_xedit:
        archive_start()

    print("> Done running xEdit.\n")


def concat_parts_of(input_paths: List[Path], target: Path) -> None:
    """
    Concatenates the contents of all files in `input_paths` and writes the output to `target`.

    :return: `None`
    """
    if len(input_paths) == 0:
        return

    input_paths.sort()

    with target.open("wb") as f_out:
        for input_path in input_paths:
            with input_path.open("rb") as f_in:
                shutil.copyfileobj(f_in, f_out)


def prefix_outputs() -> None:
    """
    Prefixes the exported files with `"tabular."` or `"wiki."` depending on the file type, ignoring files that already
    have the appropriate prefix.

    :return: `None`
    """

    print(">> Prefixing files.")

    for file in list(cfg.dump_root.glob("*.csv")) + list(cfg.dump_root.glob("*.wiki")):
        prefix = "tabular." if file.suffix == ".csv" else "wiki."

        # Skip already-prefixed files
        if not file.stem.startswith(prefix):
            file.rename(file.parent / f"{prefix}{file.name}")

    print(">> Done prefixing files.")


def concat_parts() -> None:
    """
    Concatenates files that have been dumped in parts by the xEdit script, and moves parts to the `"_parts"`
    subdirectory.

    :return: `None`
    """

    print(">> Combining dumped CSV parts.")

    print(">>> Combining 'tabular.IDs.csv'.")
    parts = list(cfg.dump_root.glob("IDs.csv.*"))
    concat_parts_of(parts, cfg.dump_root / "tabular.IDs.csv")
    [Files.move_into(part, cfg.dump_parts) for part in parts]

    print(">>> Combining 'wiki.TERM.wiki'.")
    parts = list(cfg.dump_root.glob("TERM.wiki.*"))
    concat_parts_of(parts, cfg.dump_root / "wiki.TERM.wiki")
    [Files.move_into(part, cfg.dump_parts) for part in parts]

    print(">> Done combining dumped CSV parts.")


def create_db() -> None:
    """
    Imports the dumped CSVs into an SQLite database.

    :return: `None`
    """

    print(f">> Importing CSVs into SQLite database at '{cfg.db_path}'.")

    # Check for existing files
    if cfg.db_path.exists():
        if not prompt_confirmation(f">> WARNING: "
                                   f"'{cfg.db_path.name}' already exists and must be deleted. "
                                   f"Do you want to DELETE '{cfg.db_path}' and continue? (y/n) "):
            exit()
        Files.delete(cfg.db_path)

    # Import into database
    with sqlite3.connect(cfg.db_path) as con:
        for csv in list(cfg.dump_root.glob("*.csv")):
            table_name = csv.stem.split('.', 1)[1]
            print(f">>> Importing '{csv.name}' into table '{table_name}'.")

            df = pd.read_csv(csv, quotechar='"', doublequote=True, skipinitialspace=True,
                             dtype="string", encoding="iso-8859-1")
            df.columns = df.columns.str.replace(" ", "_")
            df.to_sql(table_name, con, index=False)

    print(f">> Done importing CSVs into SQLite database at '{cfg.db_path}'.")


def archive_start() -> None:
    """
    Archives all xEdit dumps that are larger than 10MB, moving the files that are archived into `_archived`.

    :return: `None`
    """

    print(">> Archiving large xEdit dumps in the background.")

    for dump in (list(cfg.dump_root.glob("*.csv")) +
                 list(cfg.dump_root.glob("*.wiki")) +
                 list(cfg.dump_root.glob("*.db"))):
        if dump.stat().st_size < 10000000:
            continue

        print(f">>> Starting archiving of '{dump.name}'.")
        process = subprocess.Popen([cfg.archiver_path, "a", "-mx9", "-mmt4", f"{dump.name}.7z", dump.name],
                                   cwd=cfg.dump_root,
                                   stdout=subprocess.DEVNULL,
                                   stderr=subprocess.STDOUT)
        subprocesses[dump.name] = {"process": process,
                                   "post": lambda it=dump: Files.move_into(it, cfg.dump_archived)}
