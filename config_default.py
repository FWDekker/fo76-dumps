from pathlib import Path


# This file contains the default configuration. To change the configuration, either edit this file directly, or create
# a copy called `config.py` and adjust the values there. Values in `config.py` will always override those in this file.


config = {
    ## Main settings
    # Version of Fallout 76, used in some file names. Shown in-game in bottom-left corner in settings menu, and in the
    # properties of `Fallout76.exe`. Set this to `"auto"` to automatically detect the version number.
    "game_version": "auto",
    # `True` if you are running this script on Windows, `False` for Linux.
    "windows": True,


    ## Toggleable features
    # `True` if `SeventySix.esm` and `NW.esm` should be archived.
    "enable_archive_esms": False,
    # `True` if xEdit should be used to generate tabular and wiki dumps.
    "enable_xedit": True,
    # `True` if large xEdit dumps should be archived.
    "enable_archive_xedit": True,
    # `True` if ba2extract should be used to extract raw files.
    "enable_ba2extract": True,


    ## ba2extract settings
    # The archives to be extracted using ba2extract. Each entry names an archive to be extracted, and maps for each file
    # to be moved from the archive to the dumps output directory the path in the archive to the path in the dumps output
    # directory.
    "ba2extract_targets": {
        "SeventySix - Interface.ba2": {
            "interface/credits.txt": "credits.txt",
        },
        "SeventySix - Startup.ba2": {
            "misc/curvetables/json": "curvetables",
        },
    },
    # `True` if directories extracted with ba2extract should be turned into a ZIP.
    "ba2extract_zip_dirs": True,


    ## Settings for Windows
    # Path to 7z executable
    "archiver_path": Path(r"C:\Program Files\7-Zip\7z.exe"),
    # Path to game files
    "game_root": Path(r"C:\Program Files (x86)\Steam\steamapps\common\Fallout76"),
    # Path to xEdit executable
    "xedit_path": Path(r"C:\Program Files (x86)\Steam\steamapps\common\Fallout76\FO76Edit64.exe"),
    # Path to ba2extract executable
    "ba2extract_path": Path.cwd() / "ba2extract.exe",


    ## Settings for Linux
    "linux_settings": {
        # Path to 7z executable
        "archiver_path": "7z",
        # Path to game files
        "game_root": Path.home() / ".steam/steam/steamapps/common/Fallout76/",
        # Path to Steam installation
        "steam_path": Path.home() / ".steam/steam/",
        # Path to Proton installation
        "proton_path": Path.home() / ".local/share/Steam/steamapps/common/Proton - Experimental/proton",

        # Path to xEdit executable
        "xedit_path": Path.home() / ".steam/steam/steamapps/common/Fallout76/FO76Edit64.exe",
        # Path to xEdit compatdata
        "xedit_compatdata_path": Path.home() / ".steam/steam/steamapps/compatdata/INSERT NUMBER HERE/",

        # Path to ba2extract executable
        "ba2extract_path": Path.cwd() / "ba2extract.exe",
        # Path to ba2extract compatdata
        "ba2extract_compatdata_path": Path.home() / ".steam/steam/steamapps/compatdata/INSERT NUMBER HERE/",
    }
}
