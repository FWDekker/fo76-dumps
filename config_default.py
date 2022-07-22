from pathlib import Path


# This file contains the default configuration. To change the configuration, either edit this file directly, or create
# a copy called `config.py` and adjust the values there. Values in `config.py` will always override those in this file.


config = {
    # Version of Fallout 76, used in some file names. Shown in-game in bottom-left corner in settings menu.
    "game_version": "x.y.z.w",
    # `True` if you are running this script on Windows, `False` for Linux.
    "windows": True,

    # `True` if `SeventySix.esm` and `NW.esm` should be archived.
    "enable_archive_esms": False,

    # Windows-specific settings
    "windows_settings": {
        # Path to 7z executable
        "archiver_path": "7z.exe",
        # Path to game files
        "game_root": r"C:\Program Files (x86)\Steam\steamapps\common\Fallout76",
        # Path to xEdit executable
        "xedit_path": r"C:\Program Files (x86)\Steam\steamapps\common\Fallout76\FO76Edit64.exe",
        # Path to ba2extract executable
        "ba2extract_path": "ba2extract.exe",
    },

    # Linux-specific settings
    "linux_settings": {
        # Path to 7z executable
        "archiver_path": "7z",
        # Path to game files
        "game_root": f"{Path.home()}/.steam/steam/steamapps/common/Fallout76/",
        # Path to Steam installation
        "steam_path": f"{Path.home()}/.steam/steam/",
        # Path to Proton installation
        "proton_path": f"{Path.home()}/.local/share/Steam/steamapps/common/Proton - Experimental/proton",

        # Path to xEdit executable
        "xedit_path": f"{Path.home()}/.steam/steam/steamapps/common/Fallout76/FO76Edit64.exe",
        # Path to xEdit compatdata
        "xedit_compatdata_path": f"{Path.home()}/.steam/steam/steamapps/compatdata/3708952410/",

        # Path to ba2extract executable
        "ba2extract_path": "./ba2extract.exe",
        # Path to ba2extract compatdata
        "ba2extract_compatdata_path": f"{Path.home()}/.steam/steam/steamapps/compatdata/3915714770/",
    },
}
