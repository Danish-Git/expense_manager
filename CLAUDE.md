# Expense Manager

## Identity
Expense Manager application.

## Technology Stack
- Backend: Python 3.13, FastAPI, Pydantic, PostgreSQL
- Frontend: Flutter, Dart, GetX (package: expense_manager)
- Infrastructure: PostgreSQL, Firebase (Auth, Storage, Messaging, Crashlytics)

## Architectural Invariants
- PostgreSQL is the source of truth (No MongoDB).
- FinancialEvent is the canonical ingestion object. All sources produce this.
- Transactions must be idempotent.
- Duplicate financial events must not create duplicate transactions.
- Credit-card payment is not an expense.
- Bank-to-bank transfer is not an expense.
- P2P transfer is not automatically an expense.
- SIP is investment activity.
- Stock purchase is investment activity.
- IPO blocked funds are not automatically expenses.
- Refunds and reversals must be represented correctly.
- User classification overrides automatic classification.
- Permission denial must never block application usage.
- Raw SMS must not be uploaded by default.
- Sensitive financial information must not be logged.
- Backend identity must come from authenticated Firebase identity.
- Firebase is infrastructure; PostgreSQL is the financial database.

## Dependency Rules
- Backend: `routes.py` is the only layer that knows HTTP.
- Backend: Services contain business logic and must not depend on FastAPI.
- Backend: Repositories are introduced only when persistence needs abstraction.
- Backend: Infrastructure depends on interfaces, never the reverse. Domain logic must not depend on infrastructure.
- Backend: Modules must not import another module's internals.
- Frontend: Dependency direction is `presentation -> domain <- data`.
- Frontend: Keep domain free from Flutter/framework dependencies.
- Frontend: Use GetX for presentation state management. Feature-specific controllers belong inside presentation feature.

## AI Development Rules
- Read CLAUDE.md before modifying code.
- Read only the documentation directly relevant to the requested task. Do not scan the entire repository or unrelated feature modules.
- Prefer small targeted changes.
- Do not create speculative files, directories, abstractions, interfaces, services, or models.
- Do not refactor unrelated code.
- Do not duplicate architecture rules in source files.
- Follow existing documentation before introducing new architecture.
- If a required architectural decision is missing, update the appropriate small document before implementing code.

## Documentation Rules
- Use: INDEX → SMALL DOCUMENT → TASK
- Architecture indexes should link to focused documents.
- Do not create large all-in-one architecture documents.
- Each document should answer one architectural question.
- Tasks should reference the minimum required documents.

## Implementation Rules
- One task = one bounded change.
- Before implementation: identify required files, required documentation, and dependencies.
- After implementation: run the smallest relevant test/check, report changed files, report validation result, and stop.
- Do not continue into the next feature automatically.
- Strict Workflow: Read 3-5 relevant files → Make ONE decision/change → Validate → Stop
