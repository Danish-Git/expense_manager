# ruff: noqa: T201 - this is a CLI; printing is its interface.
"""Development task runner. Kept separate from application code (backend/src) and from the
migration scripts (backend/alembic), the same way Alembic's own templates live in their own
directory rather than inside the app.

Usage:
    python3 scripts/dev.py rerun     # detect what changed and bring the stack back up
    python3 scripts/dev.py --list    # show all tasks

`rerun` is the main entry point: after editing code, run it and it figures out on its own
whether dependencies need reinstalling, whether a new Alembic migration needs applying, and
whether the Docker image needs rebuilding - then restarts the backend container.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "backend"
VENV_PYTHON = ROOT / "venv" / "bin" / "python"
CACHE_DIR = ROOT / "scripts" / ".cache"
REQUIREMENTS = BACKEND / "requirements.txt"
COMPOSE_FILE = ROOT / "docker-compose.yml"
# Untracked, mode 0600, human-created - never written or printed by this script. Same pattern
# as the platform's own owner-password file (see docs referenced in PLATFORM_REFERENCE.md).
ENV_MIGRATE = BACKEND / ".env.migrate"


def run(cmd: list, cwd: Path = ROOT, env: dict | None = None) -> subprocess.CompletedProcess:
    printable = " ".join(str(c) for c in cmd)
    print(f"$ {printable}")
    full_env = {**os.environ, **env} if env else None
    return subprocess.run(cmd, cwd=cwd, env=full_env, check=False)


def _hash_paths(paths: list) -> str:
    digest = hashlib.sha256()
    for path in sorted(paths):
        if path.is_file():
            digest.update(str(path.relative_to(ROOT)).encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()


def _cache_get(name: str) -> str:
    marker = CACHE_DIR / name
    return marker.read_text().strip() if marker.exists() else ""


def _cache_set(name: str, value: str) -> None:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / name).write_text(value)


# ---- steps ----------------------------------------------------------------------


def sync_dependencies() -> None:
    """Reinstall backend Python dependencies if requirements.txt changed."""
    current = _hash_paths([REQUIREMENTS])
    if current == _cache_get("requirements.hash"):
        print("Dependencies unchanged, skipping pip install.")
        return
    if not VENV_PYTHON.exists():
        sys.exit(f"Missing venv at {VENV_PYTHON}. Create it first: python3 -m venv venv")
    result = run([str(VENV_PYTHON), "-m", "pip", "install", "-r", str(REQUIREMENTS)])
    if result.returncode != 0:
        sys.exit("pip install failed.")
    _cache_set("requirements.hash", current)


def migration_status() -> tuple:
    """Return (head_revision, needs_migration: bool | None). None means status is unknown
    (DB unreachable) - callers should not treat that as "no migration needed"."""
    heads = run(
        [str(VENV_PYTHON), "-m", "alembic", "heads"],
        cwd=BACKEND,
        env={"PYTHONPATH": "src"},
    )
    if heads.returncode != 0:
        sys.exit("Could not read Alembic heads - see output above.")

    current = subprocess.run(
        [str(VENV_PYTHON), "-m", "alembic", "current"],
        cwd=BACKEND,
        env={**os.environ, "PYTHONPATH": "src"},
        capture_output=True,
        text=True,
        check=False,
    )
    if current.returncode != 0:
        # Unreachable DB, not-yet-created schema, etc. Report unknown rather than guessing.
        return "", None
    is_head = "(head)" in current.stdout
    return current.stdout.strip(), not is_head


def apply_migration() -> None:
    """Apply pending Alembic migrations using the owner role, one-off, exactly like a human
    operator would - never using the app's regular runtime credentials. Reads the owner
    password from backend/.env.migrate (untracked, mode 0600, created by a human via
    `docker exec -u postgres <postgres-container> psql -c "\\password expenses_owner"` and
    saving the same value there). Never reads it from backend/.env and never logs it."""
    if not ENV_MIGRATE.exists():
        print(
            "\nA migration is needed but backend/.env.migrate does not exist.\n"
            "This script will not read, guess, or reset the expenses_owner password itself - "
            "that is a human-operator action.\n\n"
            "1. Reset/confirm it:\n"
            '   docker exec -it -u postgres intelligence-local-postgres-1 psql -c "\\password expenses_owner"\n'
            "2. Save that same password as backend/.env.migrate (mode 0600), one line:\n"
            "   EXPENSE_DB_LOCAL_OWNER_PASSWORD=<the password you just set>\n"
            "3. Re-run this script.\n"
        )
        sys.exit(1)

    owner_password = None
    for line in ENV_MIGRATE.read_text().splitlines():
        if line.startswith("EXPENSE_DB_LOCAL_OWNER_PASSWORD="):
            owner_password = line.split("=", 1)[1].strip()
    if not owner_password:
        sys.exit("backend/.env.migrate exists but has no EXPENSE_DB_LOCAL_OWNER_PASSWORD line.")

    result = run(
        [str(VENV_PYTHON), "-m", "alembic", "upgrade", "head"],
        cwd=BACKEND,
        env={
            "PYTHONPATH": "src",
            "EXPENSE_DB_LOCAL_USER": "expenses_owner",
            "EXPENSE_DB_LOCAL_PASSWORD": owner_password,
        },
    )
    if result.returncode != 0:
        sys.exit("Migration failed - see output above.")


def rebuild_image_if_needed() -> None:
    """Rebuild the backend Docker image only if source, Dockerfile, or dependencies changed."""
    watched = [REQUIREMENTS, BACKEND / "Dockerfile", BACKEND / "alembic.ini"]
    watched += list((BACKEND / "src").rglob("*.py"))
    watched += list((BACKEND / "alembic").rglob("*.py"))
    current = _hash_paths(watched)
    if current == _cache_get("image.hash"):
        print("Backend image inputs unchanged, skipping docker build.")
        return
    result = run(["docker", "compose", "-f", str(COMPOSE_FILE), "build", "backend"])
    if result.returncode != 0:
        sys.exit("docker compose build failed.")
    _cache_set("image.hash", current)


def restart_backend() -> None:
    """Recreate the backend container from the current image."""
    result = run(["docker", "compose", "-f", str(COMPOSE_FILE), "up", "-d", "backend"])
    if result.returncode != 0:
        sys.exit("docker compose up failed.")


def rerun() -> None:
    """Detect what changed since the last run and bring the stack back up: reinstall
    dependencies if requirements.txt changed, apply a pending Alembic migration if one exists,
    rebuild the Docker image if source/deps changed, then restart the backend container."""
    print("== 1/4 dependencies ==")
    sync_dependencies()

    print("\n== 2/4 migrations ==")
    current, needs_migration = migration_status()
    if needs_migration is None:
        print("Database unreachable - skipping migration check. Run scripts/dev.py migrate manually once it's up.")
    elif needs_migration:
        print(f"Pending migration detected ({current or 'no version stamped yet'}). Applying...")
        apply_migration()
    else:
        print("Database is already at the latest migration.")

    print("\n== 3/4 image ==")
    rebuild_image_if_needed()

    print("\n== 4/4 restart ==")
    restart_backend()
    print("\nDone. Backend: http://expense.api.localhost:8080/health")


TASKS = {
    "sync-deps": sync_dependencies,
    "migrate": apply_migration,
    "build": rebuild_image_if_needed,
    "restart": restart_backend,
    "rerun": rerun,
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("task", nargs="?", default="rerun")
    parser.add_argument("--list", action="store_true")
    args = parser.parse_args()
    if args.list:
        for name, func in TASKS.items():
            print(f"  {name:<12} {(func.__doc__ or '').strip().splitlines()[0]}")
        return
    if args.task not in TASKS:
        parser.error(f"unknown task {args.task!r}. Use --list.")
    TASKS[args.task]()


if __name__ == "__main__":
    main()
