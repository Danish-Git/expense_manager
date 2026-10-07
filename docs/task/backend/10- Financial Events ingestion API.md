TASK: Implement the minimal Financial Events ingestion API.

Read only:
- CLAUDE.md
- docs/domain/FINANCIAL_SCHEMA.md
- docs/architecture/PROCESSING_PIPELINE.md
- docs/contracts/API.md
- backend/src/expense_manager_backend/infrastructure/database/models.py
- existing authentication implementation
- existing Accounts module

Implement only:
1. POST /financial-events
2. POST /financial-events/batch

Rules:
- Authenticate every request.
- Always derive user_id from authenticated context.
- Never accept user_id from the client.
- Validate the FinancialEvent contract.
- Calculate/use deterministic source_hash for idempotency.
- Enforce the existing user + source_hash uniqueness constraint.
- Duplicate submission must not create a second financial event.
- Persist the raw/canonical financial event only.
- Do NOT implement parser, classifier, merchant resolver, account resolver, transaction processor, ledger processor, or reconciliation yet.
- Keep routes thin and business logic in the service layer.
- Use the existing SQLAlchemy/PostgreSQL infrastructure.
- Do not change the database schema.
- Add focused tests for authentication, validation, idempotency, batch ingestion, and user isolation.

OUTPUT ONLY:
Financial Events API: PASS/FAIL
Tests: PASS/FAIL
Idempotency: PASS/FAIL
User isolation: PASS/FAIL
Schema change: YES/NO
Issue: <one sentence or NONE>
Maximum 6 lines.
STOP.
## Output
Financial Events API: PASS
Tests: PASS (15/15; 7 new in backend/tests/test_financial_events.py)
Idempotency: PASS (service/hash level; ON CONFLICT insert not yet run against live PostgreSQL)
User isolation: PASS
Schema change: NO
Issue: Insert path was verified with mocked repository only, so a real-DB check of the ON CONFLICT clause is still pending.
