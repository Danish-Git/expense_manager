TASK: Align expense_manager database connectivity with the shared platform reference and verify local/live access. Do not create a new PostgreSQL instance.

Read:
- CLAUDE.md
- backend/src/expense_manager_backend/config/settings.py
- backend/src/expense_manager_backend/infrastructure/database/connection.py
- backend/src/expense_manager_backend/infrastructure/database/session.py
- backend/alembic/env.py
- backend/.env
- backend/.env.example
- the provided platform connection reference

Platform facts for expense_manager:
- Database: expenses_db
- Runtime role: expenses_app
- Migration role: expenses_owner
- Schema: expenses
- Internal host: postgres
- Internal port: 5432
- Local mirror PostgreSQL already exists in the shared platform stack.
- Live PostgreSQL already exists in the shared platform stack.
- No PostgreSQL port is published.
- Local host access uses 127.0.0.1:15432 through the documented bridge.
- Live host access uses an SSH tunnel for human/operator testing only.
- The application itself must use the internal Docker network.
- Never use expenses_owner for the running application.

Do:
1. Verify settings use expenses_db / expenses_app / expenses and not any trading/intelligence values.
2. Verify APP_ENV/local selects the local database configuration.
3. Verify APP_ENV/live selects the live database configuration.
4. Do NOT install PostgreSQL.
5. Do NOT create another PostgreSQL container.
6. Do NOT publish port 5432.
7. Inspect whether expense_manager currently has a Compose service/network configuration.
8. If the app is not containerized yet, do not invent a new architecture; report that internal-network connectivity requires the app Compose service to be attached to the expenses internal network.
9. For local host connectivity, use only the documented 127.0.0.1:15432 bridge if it already exists; do not create persistent infrastructure.
10. For live connectivity, do not run the app from the laptop against production. Only verify the configured live target from an appropriate platform/VPS context if available.
11. Never print passwords or full connection URLs.
12. Do not run migrations.
13. Do not modify models.

OUTPUT ONLY:
Local DB: FAIL
Live DB: FAIL
Issue: The container successfully connects to the PostgreSQL network, but fails password authentication for user 'expenses_app'.
Maximum 3 lines.
STOP.