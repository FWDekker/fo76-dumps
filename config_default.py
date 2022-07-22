from pathlib import Path


# This file contains the default configuration. To change the configuration, either edit this file directly, or create
# a copy called `config.py` and adjust the values there. Values in `config.py` will always override those in this file.


config = {
    # Version of Fallout 76, used in some file names. Shown in-game in bottom-left corner in settings menu.
    "game_version": "x.y.z.w",
    # `True` if you are running this script on Windows, `False` for Linux.
    "windows": True,

    # `True` if xEdit should be used to generate tabular and wiki dumps.
    "enable_xedit": True,
    # `True` if ba2extract should be used to extract raw files.
    "enable_ba2extract": True,
    # `True` if large dumps should be archived to reduce space.
    "enable_archive_large": True,
    # `True` if `SeventySix.esm` and `NW.esm` should be archived.
    "enable_archive_esms": False,

    # The list of archives to be extracted using ba2extract.
    "ba2extract_archives": ["SeventySix - Interface.ba2"],
    # The files to be moved from the extracted archives to the dumps output folder. Each entry maps the path in the
    # archive to the desired path in the dumps output folder.
    "ba2extract_files": {
        "interface/credits.txt": "raw.credits.txt",
    },

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
