TASK: Fix the PostgreSQL configuration failure identified in the previous diagnostic.

Root cause:
DATABASE_URL is required but unavailable during Alembic import, and the SQLAlchemy engine is instantiated eagerly in connection.py.

Read only:
- CLAUDE.md
- docs/task/backend/3 - Diagnose migration failure.md
- backend/src/expense_manager_backend/config/settings.py
- backend/src/expense_manager_backend/infrastructure/database/connection.py
- backend/src/expense_manager_backend/infrastructure/database/session.py
- backend/alembic/env.py
- .env.example

Implement the smallest correct fix:

1. Ensure local development has a valid DATABASE_URL configuration mechanism.
2. Do NOT commit real credentials.
3. Update .env.example if necessary.
4. Change database initialization so importing modules does not unnecessarily create a live database engine.
5. Preserve async SQLAlchemy + asyncpg.
6. Preserve Alembic's existing Settings.database_url configuration.
7. Do not change database schema/models.
8. Do not change architecture.
9. Do not add abstractions unless required.

Validation:
- Run Alembic commands using the configured local DATABASE_URL.
- Confirm `alembic history` works.
- Confirm `alembic current` works.
- Do not run destructive database commands.

OUTPUT RULE:
Return ONLY:
Changed files: backend/.env, backend/.env.example, backend/src/expense_manager_backend/infrastructure/database/connection.py, backend/src/expense_manager_backend/infrastructure/database/session.py, backend/src/expense_manager_backend/infrastructure/database/__init__.py
Alembic history: PASS
Alembic current: FAIL
Remaining issue: Alembic current fails because the local PostgreSQL instance is unreachable.
Maximum 4 lines.
STOP.