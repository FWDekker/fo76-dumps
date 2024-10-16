import tomllib
import traceback
from pathlib import Path
from types import SimpleNamespace

import pefile


# noinspection PyBroadException
def load_game_version(my_cfg: SimpleNamespace) -> str:
    """
    Returns the game version to use.
    """

    if my_cfg.game_version != "auto":
        return my_cfg.game_version

    try:
        print("Loading state!")  # TODO: Remove this line!
        pe = pefile.PE(my_cfg.game_root / "Fallout76.exe", fast_load=True)
        pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_RESOURCE"]])
        return pe.FileInfo[0][0].StringTable[0].entries[b"ProductVersion"].decode()
    except:
        traceback.print_exc()
        print(
            "ERROR: "
            "Could not automatically determine version number of your Fallout 76 version. "
            "Either resolve the issue shown above, or enter the game version yourself. "
            "See 'config_default.py' for more information about the 'game_version' option."
        )
        exit(1)


def load_config() -> SimpleNamespace:
    """
    Loads configuration from config files and sets derived fields.
    """

    ## Load and merge configs
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

    ## Set automatic and derived fields
    # Version of the game
    my_cfg.game_version = load_game_version(my_cfg)
    # Version of this script
    my_cfg.script_version = tomllib.loads((Path(__file__).parent / "pyproject.toml").read_text())["project"]["version"]
    # Path to scripts
    my_cfg.script_root = my_cfg.game_root / "Edit scripts/"
    # Path to exported dumps
    my_cfg.dump_root = my_cfg.script_root / "dumps/"
    # Path to store files that have been archived in
    my_cfg.dump_archived = my_cfg.dump_root / "_archived/"
    # Path to store dump parts in
    my_cfg.dump_parts = my_cfg.dump_root / "_parts/"
    # Path to store SQLite database at
    my_cfg.db_path = my_cfg.dump_root / f"fo76-dumps-v{my_cfg.script_version}-v{my_cfg.game_version}.db"
    # Path to `_done.txt`
    my_cfg.done_path = my_cfg.dump_root / "_done.txt"

    return my_cfg


# Configuration
cfg = load_config()
# Unfinished subprocesses
subprocesses = {}
