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
import getpass
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

# The shared local platform stack (Postgres + nginx) is owned by the sibling `intelligence`
# repo, not this one - this script only detects whether it's up and starts it with that repo's
# own tooling, never duplicating its compose files or touching its secrets.
PLATFORM_REPO = Path(os.environ.get("EXPENSE_PLATFORM_REPO", ROOT.parent / "intelligence"))
PLATFORM_NETWORK = "intelligence-local_expenses_internal"
PLATFORM_EDGE_NETWORK = "intelligence-local_edge"
PG_BRIDGE_NAME = "pg-bridge"


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


def _network_exists(name: str) -> bool:
    result = subprocess.run(["docker", "network", "inspect", name], capture_output=True, check=False)
    return result.returncode == 0


def _container_running(name: str) -> bool:
    result = subprocess.run(
        ["docker", "inspect", "-f", "{{.State.Running}}", name],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0 and result.stdout.strip() == "true"


def ensure_platform_up() -> None:
    """Bring up the shared local platform stack (Postgres + nginx, owned by the sibling
    `intelligence` repo) if it's not running, and recreate the throwaway `pg-bridge` loopback so
    host tools (including this script's own Alembic calls) can reach Postgres on
    127.0.0.1:15432. Never touches credentials - if Docker was restarted, the platform's own
    `local-init.sh` re-provisions roles/databases from intelligence/.env.local (a file this
    script never reads or writes)."""
    if not _network_exists(PLATFORM_NETWORK):
        dev_script = PLATFORM_REPO / "scripts" / "dev.py"
        if not dev_script.exists():
            sys.exit(
                f"The shared platform network {PLATFORM_NETWORK!r} is missing and no "
                f"intelligence repo was found at {PLATFORM_REPO}.\n"
                "Set EXPENSE_PLATFORM_REPO to its path, or start it manually: "
                "python3 scripts/dev.py local-up (run from that repo)."
            )
        print(f"Platform network {PLATFORM_NETWORK!r} not found - starting the local platform stack...")
        result = run(["python3", str(dev_script), "local-up"], cwd=PLATFORM_REPO)
        if result.returncode != 0:
            sys.exit("Failed to start the platform stack - see output above.")
    else:
        print("Platform stack already up.")

    if not _container_running(PG_BRIDGE_NAME):
        print("pg-bridge not running - recreating the loopback bridge to local Postgres...")
        subprocess.run(["docker", "rm", "-f", PG_BRIDGE_NAME], capture_output=True, check=False)
        result = run(
            [
                "docker",
                "run",
                "-d",
                "--name",
                PG_BRIDGE_NAME,
                "--network",
                PLATFORM_EDGE_NETWORK,
                "-p",
                "127.0.0.1:15432:5432",
                "alpine/socat",
                "tcp-listen:5432,fork,reuseaddr",
                "tcp:postgres:5432",
            ]
        )
        if result.returncode != 0:
            sys.exit("Failed to create pg-bridge - see output above.")
        result = run(["docker", "network", "connect", PLATFORM_NETWORK, PG_BRIDGE_NAME])
        if result.returncode != 0:
            sys.exit("Failed to join pg-bridge to the expenses network - see output above.")
    else:
        print("pg-bridge already running.")


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


def _db_connected() -> bool:
    """Reuse the app's own connectivity check (infrastructure/database/health.py) rather than
    duplicating asyncpg connection logic here."""
    code = (
        "import asyncio, sys; sys.path.insert(0, 'src')\n"
        "from expense_manager_backend.config.settings import get_settings\n"
        "from expense_manager_backend.infrastructure.database.health import check_database\n"
        "async def main():\n"
        "    config = get_settings().database\n"
        "    if not config.password:\n"
        "        print('no'); return\n"
        "    result = await check_database(config)\n"
        "    print('yes' if result.connected else 'no')\n"
        "asyncio.run(main())\n"
    )
    result = subprocess.run(
        [str(VENV_PYTHON), "-c", code], cwd=BACKEND, capture_output=True, text=True, check=False
    )
    return result.returncode == 0 and result.stdout.strip() == "yes"


PG_CONTAINER = "intelligence-local-postgres-1"
ENV_APP = BACKEND / ".env"
# role -> (file, key) holding that role's password for the local database.
ROLE_ENV = {
    "expenses_app": (ENV_APP, "EXPENSE_DB_LOCAL_PASSWORD"),
    "expenses_owner": (ENV_MIGRATE, "EXPENSE_DB_LOCAL_OWNER_PASSWORD"),
}


def _set_env_value(path: Path, key: str, value: str) -> None:
    """Set KEY=value in an env file (creating it, mode 0600), leaving every other line alone."""
    lines = path.read_text().splitlines() if path.exists() else []
    entry = f"{key}={value}"
    if any(line.startswith(f"{key}=") for line in lines):
        lines = [entry if line.startswith(f"{key}=") else line for line in lines]
    else:
        lines.append(entry)
    path.write_text("\n".join(lines) + "\n")
    path.chmod(0o600)


def _set_role_password(role: str, password: str) -> bool:
    """ALTER ROLE through psql's stdin so the password never appears in argv or output."""
    literal = password.replace("'", "''")
    result = subprocess.run(
        ["docker", "exec", "-i", "-u", "postgres", PG_CONTAINER, "psql", "-v", "ON_ERROR_STOP=1", "-q"],
        input=f"ALTER ROLE {role} PASSWORD '{literal}';\n",
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def ensure_db_connected() -> bool:
    """Check the app's database connection; if it fails, prompt (hidden input) for the
    expenses_app / expenses_owner passwords, set them on the Postgres roles and save the same
    values to backend/.env and backend/.env.migrate. Passwords are never printed or logged."""
    if _db_connected():
        print("Local DB: OK")
        return True

    print("Local DB: FAIL - the app could not connect (usually backend/.env and the Postgres role disagree on the password).")
    if not sys.stdin.isatty():
        print("Run `python3 scripts/dev.py db-check` in a terminal to set the passwords.")
        return False
    if input("Set the role passwords and update the env files now? [y/N] ").strip().lower() != "y":
        return False

    for role, (path, key) in ROLE_ENV.items():
        password = getpass.getpass(f"New password for {role}: ")
        if not password or password != getpass.getpass("Enter it again: "):
            print(f"Empty or mismatched password for {role} - nothing changed for it.")
            continue
        if not _set_role_password(role, password):
            print(f"Could not set the password for {role} in {PG_CONTAINER} - is the platform up?")
            continue
        _set_env_value(path, key, password)
        print(f"{role}: role password set, {path.relative_to(ROOT)} updated.")

    ok = _db_connected()
    print("Local DB: OK" if ok else "Local DB: still FAIL")
    if ok:
        print("Re-run `python3 scripts/dev.py rerun` so the backend container picks up the new backend/.env.")
    return ok


def migration_status() -> tuple:
    """Return (head_revision, needs_migration: bool | None). None means status is unknown
    (DB unreachable) - callers should not treat that as "no migration needed". A DB that's
    reachable but has no alembic_version table yet (fresh volume, never migrated) correctly
    reports needs_migration=True, not "unreachable"."""
    heads = run(
        [str(VENV_PYTHON), "-m", "alembic", "heads"],
        cwd=BACKEND,
        env={"PYTHONPATH": "src"},
    )
    if heads.returncode != 0:
        sys.exit("Could not read Alembic heads - see output above.")

    if not _db_connected():
        return "", None

    current = subprocess.run(
        [str(VENV_PYTHON), "-m", "alembic", "current"],
        cwd=BACKEND,
        env={**os.environ, "PYTHONPATH": "src"},
        capture_output=True,
        text=True,
        check=False,
    )
    if current.returncode != 0:
        # Connected, but e.g. "relation alembic_version does not exist" - a fresh database that
        # has never been migrated. That needs a migration, it isn't "unreachable".
        return "", True
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


IMAGE_TAG = "expense_backend:local"
COMPOSE_SERVICE = "expense_backend"


def _image_id(tag: str) -> str:
    result = subprocess.run(
        ["docker", "images", "-q", tag], capture_output=True, text=True, check=False
    )
    return result.stdout.strip()


def rebuild_image_if_needed() -> None:
    """Rebuild the backend Docker image only if source, Dockerfile, or dependencies changed,
    then remove the old image build it replaces so stale, untagged images don't pile up."""
    watched = [REQUIREMENTS, BACKEND / "Dockerfile", BACKEND / "alembic.ini"]
    watched += list((BACKEND / "src").rglob("*.py"))
    watched += list((BACKEND / "alembic").rglob("*.py"))
    current = _hash_paths(watched)
    if current == _cache_get("image.hash"):
        print("Backend image inputs unchanged, skipping docker build.")
        return

    old_image_id = _image_id(IMAGE_TAG)
    result = run(["docker", "compose", "-f", str(COMPOSE_FILE), "build", COMPOSE_SERVICE])
    if result.returncode != 0:
        sys.exit("docker compose build failed.")
    _cache_set("image.hash", current)

    new_image_id = _image_id(IMAGE_TAG)
    if old_image_id and old_image_id != new_image_id:
        print(f"Removing superseded image {old_image_id} ({IMAGE_TAG}'s previous build)...")
        # Best-effort: a container still holding this layer (about to be replaced in the next
        # step) blocks removal - ignore that, restart_backend()'s --remove-orphans will free it,
        # and a leftover dangling layer is cleaned up by the next `docker image prune`.
        subprocess.run(["docker", "rmi", old_image_id], capture_output=True, check=False)


def restart_backend() -> None:
    """Recreate the backend container from the current image, removing any orphaned container
    docker compose no longer recognizes (e.g. left over from a renamed/removed service)."""
    result = run(
        ["docker", "compose", "-f", str(COMPOSE_FILE), "up", "-d", "--remove-orphans", COMPOSE_SERVICE]
    )
    if result.returncode != 0:
        sys.exit("docker compose up failed.")


def clean() -> None:
    """Remove this project's stopped containers and dangling (untagged) images left behind by
    old builds. Never touches volumes (the shared Postgres data lives there) or any other
    project's containers/images/networks - only what's scoped to this backend."""
    run(["docker", "container", "prune", "-f", "--filter", "label=com.docker.compose.project=expense_manager"])
    run(["docker", "image", "prune", "-f", "--filter", "label=com.docker.compose.project=expense_manager"])


def rerun() -> None:
    """Detect what changed since the last run and bring the stack back up: start the shared
    local platform (Postgres/nginx) and the pg-bridge if either got stopped, reinstall
    dependencies if requirements.txt changed, apply a pending Alembic migration if one exists,
    rebuild the Docker image if source/deps changed, then restart the backend container."""
    print("== 1/5 platform ==")
    ensure_platform_up()

    print("\n== 2/5 dependencies ==")
    sync_dependencies()

    print("\n== 3/5 migrations ==")
    current, needs_migration = migration_status()
    if needs_migration is None:
        print("Database unreachable - skipping migration check.")
        ensure_db_connected()
        print("Run scripts/dev.py migrate manually once it's up.")
    elif needs_migration:
        print(f"Pending migration detected ({current or 'no version stamped yet'}). Applying...")
        apply_migration()
    else:
        print("Database is already at the latest migration.")

    print("\n== 4/5 image ==")
    rebuild_image_if_needed()

    print("\n== 5/5 restart ==")
    restart_backend()
    print("\nDone. Backend: http://expense.api.localhost:8080/health")


TASKS = {
    "platform-up": ensure_platform_up,
    "sync-deps": sync_dependencies,
    "db-check": ensure_db_connected,
    "migrate": apply_migration,
    "build": rebuild_image_if_needed,
    "restart": restart_backend,
    "clean": clean,
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
