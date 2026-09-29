TASK: Add minimal Docker/Compose support for expense_manager backend using the existing shared PostgreSQL platform.

Read:
- CLAUDE.md
- backend/
- infrastructure/
- config/
- docs/architecture/
- the provided platform connection reference

Goal:
Run expense_manager backend as a container connected to the existing Expenses PostgreSQL network.

Requirements:
1. Do NOT create PostgreSQL.
2. Do NOT create or modify the shared platform PostgreSQL stack.
3. Do NOT publish PostgreSQL port 5432.
4. Create only the minimum Docker/Compose files required for expense_manager.
5. Backend container must use:
   host=postgres
   port=5432
   database=expenses_db
   user=expenses_app
6. Backend must use the `expenses` project internal network as an external network.
7. Local network name:
   `intelligence-local_expenses_internal`
8. Live network name:
   `platform_expenses_internal`
9. Do not hardcode passwords.
10. Use the project's `.env` for the runtime password.
11. Do not add PostgreSQL, Nginx, Redis, or any unrelated service.
12. Preserve the existing FastAPI application and package structure.
13. Do not modify database models.
14. Do not run migrations.
15. Do not add authentication or financial features.
16. Ensure the container can import/start `expense_manager_backend.main`.
17. Validate the local Compose configuration without exposing secrets.

OUTPUT ONLY:
Files added/changed: backend/Dockerfile, docker-compose.yml, backend/requirements.txt
Container build: PASS
Compose validation: PASS
Network configuration: PASS
Issue: NONE
STOP.