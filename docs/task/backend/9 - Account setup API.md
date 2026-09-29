TASK: Implement the minimal Accounts module for expense_manager.

Read only:
- CLAUDE.md
- docs/domain/FINANCIAL_SCHEMA.md
- docs/contracts/API.md
- docs/architecture/PROCESSING_PIPELINE.md
- backend/src/expense_manager_backend/infrastructure/database/models.py
- backend/src/expense_manager_backend/modules/
- backend/src/expense_manager_backend/interface/
- backend/src/expense_manager_backend/routes/api.py
- existing authentication implementation

Implement only:
1. GET /accounts
2. POST /accounts

Rules:
- Every query must be scoped to the authenticated internal user_id.
- Never accept user_id from the request body.
- Use route → service → repository/data-access boundary.
- Keep FastAPI-specific code in routes.
- Keep business logic out of routes.
- Use existing SQLAlchemy infrastructure.
- Match the existing FinancialAccount model.
- Validate account type and required fields.
- Do not implement transactions or financial events.
- Do not add database migrations unless the existing model/API contract is insufficient; if so, STOP and report the gap.
- Add focused tests for:
  - authenticated user isolation
  - create account
  - list accounts
  - invalid account data
- Run relevant tests and import validation.

OUTPUT ONLY:
Accounts API: PASS
Tests: PASS
User isolation: PASS
Schema change: NO
Issue: NONE
STOP.