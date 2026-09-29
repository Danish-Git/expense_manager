TASK: Implement the minimal authentication foundation for expense_manager.

Read only:
- CLAUDE.md
- docs/contracts/API.md
- docs/domain/FINANCIAL_SCHEMA.md
- backend/src/expense_manager_backend/config/settings.py
- backend/src/expense_manager_backend/infrastructure/database/models.py
- backend/src/expense_manager_backend/modules/
- backend/src/expense_manager_backend/routes/api.py

Requirements:
1. Use Firebase Authentication as the external identity provider.
2. Validate Firebase ID tokens on protected API requests.
3. Resolve Firebase UID to the internal PostgreSQL `users.id`.
4. Create the internal user record when appropriate.
5. Never use Firebase UID as the PostgreSQL primary key.
6. Never trust a client-provided `user_id`.
7. Provide a reusable request authentication dependency/context for future modules.
8. Keep authentication infrastructure separate from financial business logic.
9. Do not implement transactions, financial events, classification, AI, or other financial features.
10. Do not change the database schema unless the existing `users` model is genuinely insufficient; if insufficient, STOP and report the gap instead.
11. Do not log tokens or sensitive user data.
12. Add focused tests for valid token, invalid token, missing token, and UID-to-user resolution.
13. Run existing backend tests/import validation.

OUTPUT ONLY:
Auth foundation: PASS
Tests: PASS
Schema gap: NO
Issue: NONE
STOP.