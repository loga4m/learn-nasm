import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python build.py <src_filename> <entry_point> [run]")
        sys.exit(1)

    src_file = Path("src") / sys.argv[1]
    entry = sys.argv[2]

    if not src_file.exists():
        print(f"Error: {src_file} not found")
        sys.exit(1)

    stem = src_file.stem
    obj_file = Path("obj") / (stem + ".obj")
    bin_file = Path("bin") / (stem + ".exe")

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
    sys.exit(main())
