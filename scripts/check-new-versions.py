#!/usr/bin/env python3
"""
check-new-versions.py - Detect new upstream versions and notify Slack.

Two detection modes (both enabled by default, each can be disabled):

  New major versions  A new <image>/<MAJOR>/ directory exists in bitnami that
                      has a debian-12/ sub-directory (i.e. an active Dockerfile)
                      but is absent from containers/soldevelo/.
                      Controlled by --no-major-check.

  New patch versions  The org.opencontainers.image.version label in bitnami's
                      Dockerfile is newer than the one in our containers copy
                      for the same <image>/<MAJOR> slot.
                      Controlled by --no-patch-check (patch checking is ON by
                      default; pass this flag to suppress it).

Usage
-----
  # Both checks, post to Slack via env var:
  SLACK_WEBHOOK_URL=https://hooks.slack.com/... python3 scripts/check-new-versions.py

  # Only major version check (skip patch/minor):
  python3 scripts/check-new-versions.py --no-patch-check

  # Only patch check (skip new-major detection):
  python3 scripts/check-new-versions.py --no-major-check

  # Dry run (print findings, no Slack post):
  python3 scripts/check-new-versions.py --dry-run

  # Explicit repo paths (default: auto-detected relative to this script):
  python3 scripts/check-new-versions.py \
      --containers-dir /path/to/containers \
      --bitnami-dir    /path/to/containers-bitnami

  # Override Slack webhook on the command line:
  python3 scripts/check-new-versions.py --slack-webhook https://hooks.slack.com/...

Exit codes
----------
  0  No new versions found (or --dry-run with findings)
  1  New versions found and notifications sent (useful in CI to flag the run)
  2  Script error (bad arguments, missing paths, Slack post failed)
"""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import NamedTuple

# ---------------------------------------------------------------------------
# Version helpers
# ---------------------------------------------------------------------------

_VERSION_RE = re.compile(r'org\.opencontainers\.image\.version="([^"]+)"')


def _parse_ver(text: str) -> tuple[int, ...]:
    """Return a numeric tuple for semver comparison, e.g. '4.3.1' -> (4, 3, 1).
    Non-numeric segments sort after numeric ones so 'os-shell/12' works too."""
    parts = []
    for seg in text.split("."):
        try:
            parts.append((0, int(seg)))
        except ValueError:
            parts.append((1, seg))          # non-numeric sorts last
    return tuple(parts)


def _read_image_version(dockerfile: Path) -> str | None:
    """Extract org.opencontainers.image.version from a Dockerfile."""
    try:
        content = dockerfile.read_text(errors="replace")
        m = _VERSION_RE.search(content)
        return m.group(1) if m else None
    except OSError:
        return None


# ---------------------------------------------------------------------------
# Findings
# ---------------------------------------------------------------------------

class NewMajor(NamedTuple):
    image: str
    major: str          # the new directory name, e.g. "4.4"
    version: str | None # full version from the Dockerfile label, may be None


class NewPatch(NamedTuple):
    image: str
    major: str
    bitnami_version: str
    containers_version: str


# ---------------------------------------------------------------------------
# Detection logic
# ---------------------------------------------------------------------------

def _has_dockerfile(path: Path) -> bool:
    return (path / "debian-12" / "Dockerfile").is_file()


def detect_new_majors(containers_dir: Path, bitnami_dir: Path) -> list[NewMajor]:
    findings: list[NewMajor] = []
    soldevelo = containers_dir / "soldevelo"

    for bitnami_img in sorted(bitnami_dir.iterdir()):
        if not bitnami_img.is_dir() or bitnami_img.name.startswith("."):
            continue
        image = bitnami_img.name
        our_img_dir = soldevelo / image
        if not our_img_dir.is_dir():
            # Image not tracked by us at all - skip silently
            continue

        our_majors = {d.name for d in our_img_dir.iterdir() if d.is_dir()}
        for bitnami_major in sorted(bitnami_img.iterdir()):
            if not bitnami_major.is_dir():
                continue
            major = bitnami_major.name
            if major in our_majors:
                continue
            if not _has_dockerfile(bitnami_major):
                # No active Dockerfile yet (README-only placeholder) - skip
                continue
            version = _read_image_version(bitnami_major / "debian-12" / "Dockerfile")
            findings.append(NewMajor(image=image, major=major, version=version))

    return findings


def detect_new_patches(containers_dir: Path, bitnami_dir: Path) -> list[NewPatch]:
    findings: list[NewPatch] = []
    soldevelo = containers_dir / "soldevelo"

    for our_img_dir in sorted(soldevelo.iterdir()):
        if not our_img_dir.is_dir() or our_img_dir.name.startswith("."):
            continue
        image = our_img_dir.name
        bitnami_img = bitnami_dir / image
        if not bitnami_img.is_dir():
            continue

        for our_major_dir in sorted(our_img_dir.iterdir()):
            if not our_major_dir.is_dir():
                continue
            major = our_major_dir.name
            bitnami_major = bitnami_img / major
            if not bitnami_major.is_dir():
                continue
            if not _has_dockerfile(bitnami_major):
                continue

            our_dockerfile = our_major_dir / "debian-12" / "Dockerfile"
            bitnami_dockerfile = bitnami_major / "debian-12" / "Dockerfile"

            our_ver = _read_image_version(our_dockerfile)
            bitnami_ver = _read_image_version(bitnami_dockerfile)

            if our_ver is None or bitnami_ver is None:
                continue
            if _parse_ver(bitnami_ver) > _parse_ver(our_ver):
                findings.append(NewPatch(
                    image=image,
                    major=major,
                    bitnami_version=bitnami_ver,
                    containers_version=our_ver,
                ))

    return findings


# ---------------------------------------------------------------------------
# Slack notification
# ---------------------------------------------------------------------------

def _slack_block_text(text: str) -> dict:
    return {"type": "section", "text": {"type": "mrkdwn", "text": text}}


def _build_slack_payload(
    new_majors: list[NewMajor],
    new_patches: list[NewPatch],
) -> dict:
    blocks: list[dict] = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": ":bitnami: New Bitnami upstream versions detected",
                "emoji": True,
            },
        }
    ]

    if new_majors:
        blocks.append({"type": "divider"})
        blocks.append(_slack_block_text("*:new: New major versions*"))
        for nm in new_majors:
            ver_str = f"  (`{nm.version}`)" if nm.version else ""
            blocks.append(
                _slack_block_text(
                    f"• `{nm.image}` - new major *{nm.major}*{ver_str}"
                )
            )

    if new_patches:
        blocks.append({"type": "divider"})
        blocks.append(_slack_block_text("*:up: Patch / minor version updates*"))
        for np in new_patches:
            blocks.append(
                _slack_block_text(
                    f"• `{np.image}/{np.major}` - "
                    f"`{np.containers_version}` → `{np.bitnami_version}`"
                )
            )

    blocks.append({"type": "divider"})
    blocks.append(
        _slack_block_text(
            "_Run `scripts/sync-upstream.sh apply` or trigger the "
            "*Sync from Upstream* workflow to pull these changes._"
        )
    )

    return {"blocks": blocks}


def post_to_slack(webhook_url: str, payload: dict) -> None:
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            body = resp.read().decode()
            if body.strip().lower() != "ok":
                print(f"WARNING: Slack responded with unexpected body: {body!r}", file=sys.stderr)
    except urllib.error.HTTPError as exc:
        raise RuntimeError(
            f"Slack webhook returned HTTP {exc.code}: {exc.read().decode()}"
        ) from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Failed to reach Slack webhook: {exc.reason}") from exc


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _find_repo_root() -> Path:
    """Walk up from this script to the git root."""
    candidate = Path(__file__).resolve().parent
    for _ in range(5):
        if (candidate / ".git").exists():
            return candidate
        candidate = candidate.parent
    return Path(__file__).resolve().parent.parent


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Detect new Bitnami upstream versions and notify Slack.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--containers-dir",
        default=None,
        help="Path to the containers repo root (default: auto-detected from script location).",
    )
    parser.add_argument(
        "--bitnami-dir",
        default=None,
        help="Path to the bitnami/bitnami sub-directory inside containers-bitnami "
             "(default: <containers-dir>/../containers-bitnami/bitnami).",
    )
    parser.add_argument(
        "--slack-webhook",
        default=None,
        help="Slack Incoming Webhook URL. Falls back to SLACK_WEBHOOK_URL env var.",
    )
    parser.add_argument(
        "--no-major-check",
        action="store_true",
        help="Skip detection of new major version directories.",
    )
    parser.add_argument(
        "--no-patch-check",
        action="store_true",
        help="Skip detection of patch/minor version updates within existing major slots.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print findings to stdout; do NOT post to Slack.",
    )
    args = parser.parse_args()

    # ---- Resolve paths ----
    containers_dir = Path(args.containers_dir) if args.containers_dir else _find_repo_root()
    if not (containers_dir / "soldevelo").is_dir():
        print(
            f"ERROR: {containers_dir}/soldevelo not found. "
            "Pass --containers-dir pointing at the containers repo root.",
            file=sys.stderr,
        )
        return 2

    if args.bitnami_dir:
        bitnami_dir = Path(args.bitnami_dir)
    else:
        bitnami_dir = containers_dir.parent / "containers-bitnami" / "bitnami"

    if not bitnami_dir.is_dir():
        print(
            f"ERROR: bitnami directory not found at {bitnami_dir}. "
            "Pass --bitnami-dir pointing at containers-bitnami/bitnami.",
            file=sys.stderr,
        )
        return 2

    # ---- Resolve Slack webhook ----
    webhook_url = args.slack_webhook or os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook_url and not args.dry_run:
        print(
            "ERROR: No Slack webhook URL provided. "
            "Use --slack-webhook or set SLACK_WEBHOOK_URL. "
            "Use --dry-run to print without posting.",
            file=sys.stderr,
        )
        return 2

    # ---- Run checks ----
    new_majors: list[NewMajor] = []
    new_patches: list[NewPatch] = []

    if not args.no_major_check:
        new_majors = detect_new_majors(containers_dir, bitnami_dir)

    if not args.no_patch_check:
        new_patches = detect_new_patches(containers_dir, bitnami_dir)

    # ---- Report ----
    if not new_majors and not new_patches:
        print("All tracked images are up to date.")
        return 0

    if new_majors:
        print("New major versions:")
        for nm in new_majors:
            ver_str = f" ({nm.version})" if nm.version else ""
            print(f"  {nm.image}/{nm.major}{ver_str}")

    if new_patches:
        print("Patch/minor version updates:")
        for np in new_patches:
            print(f"  {np.image}/{np.major}: {np.containers_version} -> {np.bitnami_version}")

    if args.dry_run:
        print("\n(dry run - Slack notification skipped)")
        return 0

    # ---- Notify Slack ----
    payload = _build_slack_payload(new_majors, new_patches)
    try:
        post_to_slack(webhook_url, payload)
        print("Slack notification sent.")
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    return 1   # signal "new versions found" to CI


if __name__ == "__main__":
    sys.exit(main())
