#!/usr/bin/env python3
"""Check repository documents and research records without network access."""

import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".md", ".json", ".yml", ".yaml", ".py", ".swift", ".toml"}
TEXT_NAMES = {"Makefile", ".gitignore", ".gitattributes", ".editorconfig"}
PRIVATE_SUFFIXES = {
    ".p12", ".p8", ".pem", ".key", ".mobileprovision", ".provisionprofile",
    ".apk", ".aab", ".ipa", ".pcap", ".pcapng", ".btsnoop",
}
LINK = re.compile(r"\[[^\]\n]*\]\((<[^>]+>|[^\s)]+)(?:\s+\"[^\"]*\")?\)")
PRIVATE_KEY = re.compile(r"-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----")


def main():
    if sys.version_info < (3, 10):
        print("FAIL: Python 3.10 or later is required.")
        return 1
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT, capture_output=True, check=True,
    )
    paths = sorted(set(result.stdout.decode().split("\0")) - {""})
    errors = []
    documents = {}
    for name in paths:
        path = ROOT / name
        if not path.is_file():
            continue
        parts = path.relative_to(ROOT).parts
        if (
            any(part in {".local", "captures", "secrets"} for part in parts)
            or path.suffix.lower() in PRIVATE_SUFFIXES
            or (path.name.startswith(".env") and path.name != ".env.example")
        ):
            errors.append(f"{name}: private file must not be tracked")
        if path.suffix not in TEXT_SUFFIXES and path.name not in TEXT_NAMES:
            continue
        try:
            content = path.read_bytes().decode("utf-8")
        except UnicodeDecodeError:
            errors.append(f"{name}: text must use UTF-8")
            continue
        if content and not content.endswith("\n"):
            errors.append(f"{name}: final newline is missing")
        if "\r" in content:
            errors.append(f"{name}: use LF line endings")
        if PRIVATE_KEY.search(content):
            errors.append(f"{name}: private key marker found")
        for number, line in enumerate(content.splitlines(), 1):
            if line != line.rstrip():
                errors.append(f"{name}:{number}: trailing whitespace")
        if path.suffix == ".json":
            try:
                documents[name] = json.loads(content)
            except json.JSONDecodeError as error:
                errors.append(f"{name}: invalid JSON at line {error.lineno}")
        if path.suffix == ".md":
            for match in LINK.finditer(content):
                target = match.group(1).strip("<>")
                url = urlsplit(target)
                if url.scheme or not url.path:
                    continue
                linked = (path.parent / unquote(url.path)).resolve()
                if not linked.is_relative_to(ROOT):
                    errors.append(f"{name}: local link leaves the repository: {target}")
                elif not linked.exists():
                    errors.append(f"{name}: local link is missing: {target}")

    sources = documents.get("research/sources.json", {})
    revision = sources.get("openzeekr_revision", "")
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        errors.append("research/sources.json: full upstream commit ID is required")
    records = sources.get("sources", [])
    if not records:
        errors.append("research/sources.json: source records are required")
    ids = set()
    for record in records:
        source_id = record.get("id")
        if not source_id or source_id in ids:
            errors.append("research/sources.json: source IDs must be present and unique")
        ids.add(source_id)
        for field in ("title", "url", "kind", "accessed", "scope", "limit"):
            if not record.get(field):
                errors.append(f"source {source_id}: {field} is required")
        url = record.get("url", "")
        if not url.startswith("https://"):
            errors.append(f"source {source_id}: use an HTTPS URL")
        if "/borconi/openzeekr/" in url and f"/{revision}/" not in url:
            errors.append(f"source {source_id}: upstream URL must use the pinned revision")

    profile = documents.get("research/target-profile.json", {})
    for source_id in profile.get("source_ids", []):
        if source_id not in ids:
            errors.append(f"target profile: source {source_id} does not exist")
    if profile.get("schema_version") != 1:
        errors.append("target profile: schema version 1 is required")
    if profile.get("project_ble_validated") and not profile.get("evidence_records"):
        errors.append("target profile: target validation needs evidence records")

    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: {len(paths)} repository files; {len(records)} source records.")
    print("Local links, text format, JSON, source references, and selected secret patterns passed.")
    print("No app build, vehicle test, or complete secret scan was performed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
