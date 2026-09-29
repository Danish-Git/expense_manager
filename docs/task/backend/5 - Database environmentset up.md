TASK: Add a simple database environment selector.

Goal:
APP_ENV=local → use LOCAL_DATABASE_URL
APP_ENV=live  → use LIVE_DATABASE_URL

Read only:
- CLAUDE.md
- backend/src/expense_manager_backend/config/settings.py
- backend/src/expense_manager_backend/infrastructure/database/connection.py
- backend/src/expense_manager_backend/infrastructure/database/session.py
- backend/alembic/env.py
- backend/.env.example

Implement:
1. Add APP_ENV with allowed values: local, live.
2. Add LOCAL_DATABASE_URL.
3. Add LIVE_DATABASE_URL.
4. Resolve the database URL from APP_ENV.
5. Alembic and SQLAlchemy must use the same resolved URL.
6. Default APP_ENV to local.
7. Invalid APP_ENV must fail clearly.
8. LIVE_DATABASE_URL must be required when APP_ENV=live.
9. Never log database credentials.
10. Keep real credentials only in backend/.env.
11. Update backend/.env.example with safe placeholders.
12. Do not modify models, migrations, API routes, or architecture.

Validation:
- APP_ENV=local → LOCAL_DATABASE_URL: PASS/FAIL
- APP_ENV=live → LIVE_DATABASE_URL: PASS/FAIL
- Invalid APP_ENV: PASS/FAIL
- Alembic history: PASS/FAIL

OUTPUT RULE:
Return ONLY:
Changed files: backend/src/expense_manager_backend/config/settings.py, backend/.env.example, backend/.env
local resolution: PASS
live resolution: PASS
invalid environment: PASS
Alembic history: PASS
Maximum 5 lines.
STOP.