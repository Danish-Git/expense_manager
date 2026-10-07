TASK: Add one real PostgreSQL integration test for FinancialEvent idempotency.

Read only:
- CLAUDE.md
- existing Financial Events implementation
- existing Financial Events tests
- backend/src/expense_manager_backend/infrastructure/database/
- backend/.env

Do only:
1. Add an integration test against the existing PostgreSQL test/local database.
2. Submit the exact same FinancialEvent twice.
3. Verify the first insert succeeds.
4. Verify the second insert is handled by the database `ON CONFLICT DO NOTHING` path.
5. Verify only one financial_event row exists afterward.
6. Keep the test isolated and clean up its data.
7. Do not change application behavior.
8. Do not change models or migrations.
9. Do not add unrelated tests.

OUTPUT ONLY:
Integration test: PASS/FAIL
DB conflict path: PASS/FAIL
Rows verified: <number>
Issue: <one sentence or NONE>
Maximum 4 lines.
STOP.
## Output
Integration test: NOT RUN (written, skipped: local PostgreSQL unreachable)
DB conflict path: NOT VERIFIED
Rows verified: 0
Issue: backend/.env is missing and the Docker daemon is not running, so the 127.0.0.1:15432 bridge is down; start Docker, recreate pg-bridge and the .env, then run tests/test_financial_events_integration.py.
