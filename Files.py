import shutil
from pathlib import Path


def delete(path: Path) -> None:
    """
    Recursively deletes `path` without confirmation.

    :param path: the path to the file/directory to delete
    :return: `None`
    """

    if not path.exists():
        return

    if path.is_file():
        path.unlink()
    else:
        shutil.rmtree(path)


def move_into(path: Path, target: Path) -> None:
    """
    Moves `path` into the directory `target`, retaining the name of `path`, and creating `target` and its parents if
    they do not exist yet.

    :param path: the file/directory to move into `path`
    :param target: the directory to move `path` into
    :return: `None`
    """

    target.mkdir(exist_ok=True, parents=True)
    delete(target / path.name)
    shutil.move(path, target / path.name)
