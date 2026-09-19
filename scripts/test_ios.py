#!/usr/bin/env python3
"""Run iPhone app and interface tests on an available simulator."""

import json
import os
import subprocess
import sys


def main():
    device_id = os.environ.get("ZEEKR_SIMULATOR_ID")
    if not device_id:
        result = subprocess.run(
            ["xcrun", "simctl", "list", "devices", "available", "--json"],
            check=True, capture_output=True, text=True,
        )
        devices = json.loads(result.stdout)["devices"]
        candidates = []
        for runtime, entries in devices.items():
            if ".iOS-" not in runtime:
                continue
            version = tuple(int(part) for part in runtime.split(".iOS-")[1].split("-"))
            if version[0] < 18:
                continue
            for device in entries:
                if device.get("isAvailable") and device["name"].startswith("iPhone"):
                    candidates.append((device["state"] == "Booted", version, device["udid"]))
        if not candidates:
            print("No iPhone simulator with iOS 18 or later is available.")
            return 1
        device_id = sorted(candidates, reverse=True)[0][2]
    command = [
        "xcodebuild", "-project", "apps/ios/Zeekr.xcodeproj", "-scheme", "Zeekr",
        "-destination", f"platform=iOS Simulator,id={device_id}",
        "-derivedDataPath", ".local/DerivedData", "CODE_SIGNING_ALLOWED=NO", "test",
    ]
    return subprocess.run(command).returncode


if __name__ == "__main__":
    sys.exit(main())
