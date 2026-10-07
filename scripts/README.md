# scripts/

Development automation for this repo, kept separate from application code (`backend/src`) and
from the migration scripts (`backend/alembic`) - the same way Alembic's own templates live in
their own directory instead of inside the app.

## `dev.py`

A single task runner. After changing code, run:

```sh
python3 scripts/dev.py rerun
```

`rerun` auto-detects what actually needs to happen and does only that:

| Step | Detects | Action |
|---|---|---|
| 1. Dependencies | `backend/requirements.txt` content changed since last run | `pip install -r` into the repo's `venv/` |
| 2. Migrations | DB's current Alembic version != the latest revision in `backend/alembic/versions/` | Applies `alembic upgrade head` |
| 3. Docker image | `Dockerfile`, `requirements.txt`, or any file under `backend/src`/`backend/alembic` changed | `docker compose build backend`, then removes the image it replaced |
| 4. Restart | always | `docker compose up -d --remove-orphans backend` |

Steps 1 and 3 use a content hash cached in `scripts/.cache/` (gitignored) so unrelated runs are
skipped and fast - not "usually you don't need to rebuild," but "hash unchanged, guaranteed
skip."

**Cleanup on rebuild:** whenever step 3 actually builds a new image, it records the previous
image's ID first and removes it (`docker rmi`) right after the new one replaces it - so rebuilding
never leaves the old, now-untagged image sitting around. Step 4 also passes `--remove-orphans`,
which drops any container Compose no longer recognizes (e.g. left over from a renamed service).
This never touches volumes (the shared Postgres data lives in one, owned by the `intelligence`
stack, not this repo) and never touches any other project's containers/images/networks.

Other tasks (see `python3 scripts/dev.py --list`):

```sh
python3 scripts/dev.py sync-deps   # just step 1
python3 scripts/dev.py db-check    # test the app's DB connection; if it fails, prompts (hidden input)
                                    # for the expenses_app/expenses_owner passwords, sets them on the
                                    # Postgres roles and writes backend/.env and backend/.env.migrate
python3 scripts/dev.py migrate     # just step 2
python3 scripts/dev.py build       # just step 3 (with its own cleanup)
python3 scripts/dev.py restart     # just step 4
python3 scripts/dev.py clean       # extra, opt-in: prune this project's stopped containers
                                    # and dangling images (not run automatically by rerun)
```

### Applying a migration

`rerun`/`migrate` never use the app's regular `expenses_app` credentials for migrations - that
role is DML-only and cannot `CREATE TABLE`. Migrations run once, as `expenses_owner`, exactly
like a human operator would:

1. Reset/confirm the owner password (you'll be prompted twice, hidden input):
   ```sh
   docker exec -it -u postgres intelligence-local-postgres-1 psql -c "\password expenses_owner"
   ```
2. Save that same password to `backend/.env.migrate` (untracked, mode `0600`, one line):
   ```
   EXPENSE_DB_LOCAL_OWNER_PASSWORD=<the password you just set>
   ```
3. Run `python3 scripts/dev.py rerun` (or `migrate`) again.

If `backend/.env.migrate` doesn't exist, the script stops and prints these same steps rather
than guessing or resetting anything itself.

---

## Troubleshooting

### `Local DB: FAIL` / `[Errno 61] Connect call failed ('127.0.0.1', 15432)`

The loopback bridge to the shared local Postgres isn't running (it's throwaway - it doesn't
survive a reboot or a manual `docker rm`). Recreate it:

```sh
docker run -d --name pg-bridge --network intelligence-local_edge \
  -p 127.0.0.1:15432:5432 alpine/socat tcp-listen:5432,fork,reuseaddr tcp:postgres:5432
docker network connect intelligence-local_expenses_internal pg-bridge
```

**Do not** attach `pg-bridge` directly to `intelligence-local_expenses_internal` and skip the
`edge` network - that network is `internal: true`, which silently drops the `-p` port
publish. It must join `edge` first, then be additionally connected to the project network so it
can resolve the `postgres` hostname.

Remove it when done (it's meant to be throwaway):
```sh
docker rm -f pg-bridge
```

### `asyncpg.exceptions.InvalidPasswordError: password authentication failed for user "..."`

The password in `backend/.env` (for `expenses_app`) or `backend/.env.migrate` (for
`expenses_owner`) doesn't match what's actually set on that Postgres role - most likely because
it was reset since, or never matched. Reset it directly and update the matching file:

```sh
# app role (used at runtime, in backend/.env as EXPENSE_DB_LOCAL_PASSWORD)
docker exec -it -u postgres intelligence-local-postgres-1 psql -c "\password expenses_app"

# owner role (used only for migrations, in backend/.env.migrate)
docker exec -it -u postgres intelligence-local-postgres-1 psql -c "\password expenses_owner"
```

This must be typed by a human, interactively - never scripted or piped, and never resolved by
having Claude/an agent run it on your behalf.

### `asyncpg.exceptions.InsufficientPrivilegeError: permission denied for schema expenses`

Something tried to run DDL (e.g. `alembic upgrade`) using the `expenses_app` credentials.
`expenses_app` is DML-only by platform design (`SELECT`/`INSERT`/`UPDATE`/`DELETE`) and can never
create, alter, or drop anything - this is correct, expected behavior, not a bug. Use
`python3 scripts/dev.py migrate` (owner role) instead of running Alembic directly with the app's
`backend/.env`.

### `FAILED: No 'script_location' key found in configuration`

`backend/alembic.ini` is missing or reverted to a stale copy (e.g. from an accidental
`git checkout`). Restore it - it must contain `script_location = %(here)s/alembic`.

### `zsh: command not found: alembic`

`alembic` was invoked as a bare command instead of through the project's venv. Always call it as:

```sh
cd backend && PYTHONPATH=src ../venv/bin/python -m alembic <command>
```

### `TypeError: unsupported operand type(s) for |: 'type' and 'NoneType'`

The backend image runs Python 3.9 (`backend/Dockerfile`), which doesn't support the `X | None`
type-hint syntax at runtime (only 3.10+). Use `typing.Optional[X]` instead in any file imported
inside the container, or add `from __future__ import annotations` at the top of the file so
annotations are never evaluated at runtime.

### `address already in use` when starting the app / port 8000

Something is already listening on 8000, usually a leftover `uvicorn` process from an earlier
manual run (not from `docker compose`, which reuses the same container). Find and stop it:

```sh
lsof -nP -iTCP:8000 -sTCP:LISTEN
kill <PID>
```

### Swagger UI shows "Failed to load API definition" / "Not Found /openapi.json"

The shared local nginx (`intelligence/infrastructure/nginx/local/conf.d/expenses.conf`) is
blocking `/openapi.json` at the edge. `/docs` and `/redoc` are meant to be blocked (FastAPI
itself disables them - only `/swagger` is served), but `/openapi.json` must stay reachable since
the Swagger UI at `/swagger` fetches it client-side to render. After editing that file, reload
nginx:

```sh
docker exec intelligence-local-nginx-1 nginx -t
docker exec intelligence-local-nginx-1 nginx -s reload
```

### `502 Bad Gateway` from `expense.api.localhost:8080`

Either the backend container isn't running (`docker ps | grep expense_backend`, then
`python3 scripts/dev.py restart`), or nginx can't resolve the `expense-backend-1` upstream - check
that `docker-compose.yml`'s `expense_backend` service has the network alias:

```yaml
networks:
  expenses_internal:
    aliases:
      - expense-backend-1
```

`http://expense.localhost:8080/` returning 502 for `/` is expected and unrelated - no dashboard
container exists yet.

### General diagnostics

```sh
# Is the backend container up, and what does it log?
docker ps --filter name=expense_backend
docker logs expense_backend --tail 50

# Is the app healthy end-to-end (API + DB)?
curl -sS http://expense.api.localhost:8080/health

# Is the shared local Postgres up, and do the expenses role/database exist?
docker exec -u postgres intelligence-local-postgres-1 psql -tAc \
  "SELECT rolname FROM pg_authid WHERE rolname IN ('expenses_app','expenses_owner');"
docker exec -u postgres intelligence-local-postgres-1 psql -tAc \
  "SELECT datname FROM pg_database WHERE datname='expenses_db';"

# Is nginx config valid, and which conf.d files does it see?
docker exec intelligence-local-nginx-1 nginx -t
docker exec intelligence-local-nginx-1 ls /etc/nginx/conf.d

# What Alembic revision is the code at vs. the database?
cd backend && PYTHONPATH=src ../venv/bin/python -m alembic heads
cd backend && PYTHONPATH=src ../venv/bin/python -m alembic current
```


1) password for postgres in intelligence: set any password (example 'postgres')
2) password for expenses owner in intelligence: set any password (example 'postgres')
3) password for expenses app in intelligence: set any password (example 'postgres')
4) copy password from intelligence expenses owner in to backend .env.migrate
5) copy password from intelligence expenses app in to backend .env
6) run python3 scripts/dev.py rerun

for copy password from intelligence expenses owner in to backend .env.migrate

```sh
grep '^EXPENSES_OWNER_PASSWORD=' /Users/apptunix/Documents/Projects/intelligence/.env.local \
  | sed 's/^EXPENSES_OWNER_PASSWORD=/EXPENSE_DB_LOCAL_OWNER_PASSWORD=/' \
  > /Users/apptunix/Documents/Projects/expense_manager/backend/.env.migrate
chmod 600 /Users/apptunix/Documents/Projects/expense_manager/backend/.env.migrate
python3 scripts/dev.py rerun
```

for copy password from intelligence expenses app in to backend .env

```sh
grep '^EXPENSES_APP_PASSWORD=' /Users/apptunix/Documents/Projects/intelligence/.env.local \
  | sed 's/^EXPENSES_APP_PASSWORD=/EXPENSE_DB_LOCAL_PASSWORD=/' \
  > /Users/apptunix/Documents/Projects/expense_manager/backend/.env
chmod 600 /Users/apptunix/Documents/Projects/expense_manager/backend/.env
python3 scripts/dev.py rerun
```

