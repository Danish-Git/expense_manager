TASK: Validate the PostgreSQL migration against a local PostgreSQL instance.

Read only:
- CLAUDE.md
- backend/alembic/env.py
- backend/src/expense_manager_backend/infrastructure/database/models.py
- latest Alembic migration from docs/task/db/1 - Create the initial Alembic migration.md

Requirements:
- Start/use the project's local PostgreSQL environment if already configured.
- Apply Alembic migrations from an empty database.
- Verify all 10 expected tables exist.
- Verify foreign keys and unique constraints.
- Verify Alembic reports the database as up to date.
- Do not modify application code.
- Do not add features.

OUTPUT RULE:
Return ONLY:
Migration: PASS/FAIL
Tables: PASS/FAIL
Constraints: PASS/FAIL
Alembic current: PASS/FAIL
Maximum 4 lines.
STOP.

Migration: FAIL
Tables: FAIL
Constraints: FAIL
Alembic current: FAIL