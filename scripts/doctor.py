#!/usr/bin/env python3
"""Report the local tools required for research and Apple builds."""

import platform
import shutil
import subprocess
import sys


def main():
    print(f"System: {platform.system()} {platform.release()}")
    print(f"Python: {platform.python_version()}")
    commands = [
        ["git", "--version"],
        ["xcode-select", "-p"],
        ["xcodebuild", "-version"],
        ["swift", "--version"],
        ["xcodebuild", "-showsdks"],
    ]
    missing = sys.version_info < (3, 10)
    for command in commands:
        if not shutil.which(command[0]):
            print(f"MISSING: {command[0]}")
            missing = True
            continue
        try:
            result = subprocess.run(command, capture_output=True, text=True, timeout=30)
            print(f"\n{' '.join(command)}")
            print((result.stdout or result.stderr).strip())
            missing = missing or result.returncode != 0
        except subprocess.TimeoutExpired:
            print(f"TIMEOUT: {' '.join(command)}")
            missing = True
    print("\nThe iPhone target is in apps/ios/Zeekr.xcodeproj.")
    print("This tool check does not build, sign, or test the app.")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
