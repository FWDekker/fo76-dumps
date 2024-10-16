import os
import shutil
import subprocess
import tempfile
from pathlib import Path

import Files
from IO import prompt_confirmation, run_executable
from State import cfg, subprocesses
from XEdit import xedit


def ba2extract() -> None:
    """
    Creates raw dumps using ba2extract and archives directories.

    :return: `None`
    """

    print("> Extracting Bethesda archives.")

    for target, files in cfg.ba2extract_targets.items():
        print(f">> Extracting {target}.")

        with tempfile.TemporaryDirectory(prefix=f"fo76-dumps-{target}") as temp_dir:
            temp_dir = Path(temp_dir)

            run_executable(
                args=[cfg.ba2extract_path, cfg.game_root / "Data" / target, temp_dir],
                compatdata_path=cfg.ba2extract_compatdata_path if not cfg.windows else "",
            )

            for archive_path, desired_path in files.items():
                desired_path = cfg.dump_root / f"raw.{desired_path}"

                if desired_path.exists():
                    Files.delete(desired_path)

                shutil.move(temp_dir / archive_path, desired_path)

                if cfg.ba2extract_zip_dirs and desired_path.is_dir():
                    shutil.make_archive(str(desired_path), "zip", desired_path)
                    Files.move_into(desired_path, cfg.dump_archived)

        print(f">> Done extracting {target}.")

    print("> Done extracting Bethesda archives.\n")


def archive_esms_start() -> None:
    """
    Archives ESMs in the background.

    :return: `None`
    """

    print("> Archiving ESMs in the background.")
    subprocesses["ESMs"] = {
        "process": subprocess.Popen(
            [
                cfg.archiver_path,
                "a",
                "-mx9",
                "-mmt4",
                f"SeventySix.esm.v{cfg.game_version}.7z",
                cfg.game_root / "Data/SeventySix.esm",
                cfg.game_root / "Data/NW.esm",
            ],
            cwd=cfg.dump_root,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT,
        ),
        "post": lambda *args: None,
    }
    print("")


def archive_join() -> None:
    """
    Waits for background archiving processes.

    :return: `None`
    """

    print("> Waiting for background archiving processes.")

    for key, child in subprocesses.items():
        print(f">> Waiting for archiving of {key}.")
        child["process"].wait()
        child["post"]()

    print("> Done waiting for background archiving processes.\n")


def main() -> None:
    """
    The main function.

    :return: `None`
    """

    if not cfg.windows and "INSERT NUMBER HERE" in str(cfg.xedit_compatdata_path):
        if not prompt_confirmation(
            f"WARNING: "
            f"You did not adjust the compatdata path for xEdit in the configuration. "
            f"The compatdata path is currently set to '{cfg.xedit_compatdata_path}'. "
            f"This may cause issues when launching xEdit. "
            f"Check the dump scripts wiki at "
            f"https://github.com/FWDekker/fo76-dumps/wiki/Generating-dumps/ for more "
            f"information. "
            f"Continue anyway? (y/n) "
        ):
            exit()
    if not cfg.windows and "INSERT NUMBER HERE" in str(cfg.ba2extract_compatdata_path):
        if not prompt_confirmation(
            f"WARNING: "
            f"You did not adjust the compatdata path for ba2extract in the configuration. "
            f"The compatdata path is currently set to '{cfg.ba2extract_compatdata_path}'. "
            f"This may cause issues when launching ba2extract. "
            f"Check the dump scripts wiki at "
            f"https://github.com/FWDekker/fo76-dumps/wiki/Generating-dumps/ for more "
            f"information. "
            f"Continue anyway? (y/n) "
        ):
            exit()
    if cfg.dump_root.exists() and len(os.listdir(cfg.dump_root)) != 0:
        if prompt_confirmation(
            f"INFO: "
            f"The dump output directory '{cfg.dump_root}' exists and is not empty. "
            f"It may be a good idea to delete this directory. "
            f"Do you want to DELETE the directory and its contents? "
            f"This is optional, the dump scripts will run after this either way. (y/n) "
        ):
            Files.delete(cfg.dump_root)
    print("")

    # Create dumps output dir
    cfg.dump_root.mkdir(exist_ok=True, parents=True)

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
    main()
