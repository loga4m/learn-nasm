import json
import subprocess
import sys
from dataclasses import dataclass, fields
from enum import Enum
from pathlib import Path
from pprint import pp
from typing import Any


@dataclass
class Config:
    bin_path: Path
    obj_path: Path


class Codes(Enum):
    SUCCESS = 0
    ERR = 1


@dataclass
class Result:
    code: Codes
    value: Any


def configure() -> Result:
    confpath: Path = Path("./build.json")
    conf_keys: set[str] = set([str(x) for x in Config.__annotations__.keys()])

    if confpath.exists():
        config: dict[str, Any] = {}
        with open(confpath, "r") as conf_file:
            config = json.load(conf_file)

        keys: set = set(config.keys())

        if len(conf_keys.intersection(keys)) == len(conf_keys):
            return Result(
                code=Codes.SUCCESS,
                value=Config(
                    bin_path=Path(config["bin_path"]), obj_path=Path(config["obj_path"])
                ),
            )

    err_msg: dict = {
        "err_msg": "Config file does not exist or is invalid. Please, configure the following.",
        "hint": "Put the config in 'build.json' file in the parent dir of this tool.",
    }
    err_msg["config_keys"] = Config.__annotations__

    return Result(code=Codes.ERR, value=err_msg)


def main() -> Codes | int:

    config: Result = configure()
    if config.code == Codes.ERR:
        pp(config.value)
        return config.code

    if len(sys.argv) < 3:
        print("Usage: python build.py <file_path> <entry_point> [run]")
        return Codes.ERR

    src_file = Path("./") / sys.argv[1]
    entry = sys.argv[2]

    if not src_file.exists():
        print(f"Error: {src_file} not found")
        return Codes.ERR

    stem = src_file.stem
    obj_file = config.value.obj_path / (stem + ".obj")
    bin_file = config.value.bin_path / (stem + ".exe")

    # Assemble
    nasm_cmd = ["nasm", "-f", "win64", str(src_file), "-o", str(obj_file)]
    print(f"[NASM] {' '.join(nasm_cmd)}")
    result = subprocess.run(nasm_cmd)
    if result.returncode != 0:
        return result.returncode

    # Link
    golink_cmd = [
        "golink",
        "/console",
        "/entry",
        entry,
        "/fo",
        str(bin_file),
        str(obj_file),
        "kernel32.dll",
    ]
    print(f"[GoLink] {' '.join(golink_cmd)}")
    result = subprocess.run(golink_cmd)
    if result.returncode != 0:
        return result.returncode

    run_exit_code: int = 0

    if len(sys.argv) == 4 and sys.argv[3] == "run":
        print(f"[Run] {bin_file}")
        result = subprocess.run(bin_file)
        run_exit_code = result.returncode

    print(f"[OK] {bin_file}")
    return run_exit_code


if __name__ == "__main__":
    exit_code: Codes | int = main()
    if isinstance(exit_code, Codes):
        exit_code = exit_code.value
    sys.exit(exit_code)
