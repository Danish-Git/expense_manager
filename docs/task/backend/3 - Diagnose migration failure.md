TASK: Diagnose Step 3 PostgreSQL migration failure. DO NOT fix yet.

Current result:
Migration: FAIL
Tables: FAIL
Constraints: FAIL
Alembic current: FAIL

Read only the minimum relevant files:
- CLAUDE.md
- docs/task/backend/1 - Create the initial Alembic migration.md
- docs/task/backend/2 - Verify database migration.md
- backend/alembic.ini
- backend/alembic/env.py
- backend/alembic/versions/<latest migration>
- backend/src/expense_manager_backend/config/settings.py
- backend/src/expense_manager_backend/infrastructure/database/connection.py
- backend/src/expense_manager_backend/infrastructure/database/session.py
- backend/src/expense_manager_backend/infrastructure/database/models.py

Then:
1. Identify the exact root cause of the migration failure.
2. Check whether the failure is caused by PostgreSQL connectivity/configuration, database creation, Alembic configuration, migration code, SQLAlchemy models, or environment variables.
3. Run only the minimum diagnostic commands necessary to prove the cause.
4. Do NOT modify any files.
5. Do NOT generate a new migration.
6. Do NOT change the architecture.

OUTPUT RULE:
Return ONLY:
Root cause: The missing `DATABASE_URL` environment variable causes a Pydantic validation crash upon module import because `Settings` and `engine` are instantiated eagerly in `connection.py`.
Evidence: Running alembic fails immediately with `pydantic_core._pydantic_core.ValidationError: 1 validation error for Settings database_url Field required [type=missing]`.
Required fix: Provide the `DATABASE_URL` in the environment or `.env` file, and defer the instantiation of the database engine in `connection.py`.
Files requiring change: `backend/src/expense_manager_backend/infrastructure/database/connection.py`, `.env`
Maximum 5 lines.
STOP.