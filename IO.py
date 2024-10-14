import os
import subprocess
from pathlib import Path
from typing import List

from State import cfg


def prompt_confirmation(message: str) -> bool:
    """
    Prompts the user to confirm `message`, returning `True` if the user inputs `"y"`, returning `False` if the user
    inputs `"n"`, and repeating the prompt otherwise.

    :param message: the message to present to the user for confirmation
    :return: whether the user confirms the prompt
    """

    while True:
        result = input(message).lower()
        if result == "y":
            return True
        elif result == "n":
            return False
        else:
            continue


def run_executable(args: List[str], compatdata_path: str, cwd: Path = Path.cwd()) -> None:
    """
    Runs the command `args` inside `cwd`; on Windows the command is executed directly on the command line, but on Linux
    the command is executed in a Proton instance using `compatdata_path`.

    :param args: the arguments of the command to execute
    :param compatdata_path: the path to the compatdata directory for Proton; may be `None` for Windows
    :param cwd: the directory to run the command in
    :return: `None`
    """

    if cfg.windows:
        subprocess.Popen(args, cwd=cwd, stdout=subprocess.DEVNULL).wait()
    else:
        subprocess.Popen(
            [cfg.proton_path, "run"] + args,
            cwd=cwd,
            stdout=subprocess.DEVNULL,
            env=dict(
                os.environ,
                STEAM_COMPAT_CLIENT_INSTALL_PATH=cfg.steam_path,
                STEAM_COMPAT_DATA_PATH=compatdata_path,
            ),
        ).wait()
