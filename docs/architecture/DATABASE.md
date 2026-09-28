# Database Architecture

## PostgreSQL Ownership
PostgreSQL is the sole application database and the absolute source of truth. MongoDB is explicitly not part of this architecture.

## Boundaries
- **Database Boundary:** Manages relational integrity, constraint enforcement, and user isolation.
- **Backend Access Boundary:** The backend interacts with the database exclusively through abstracted repositories.
- **Future Repository Boundary:** Database interaction patterns will be encapsulated inside feature-specific repository implementations.

## General Requirements
- **Transactions:** Financial events and state modifications require strict database transaction consistency.
- **Idempotency:** Transactions and ingestion pipelines must be idempotent to prevent duplicate records (e.g., using unique constraints on source event hashes).
- **Migrations:** Schema migrations are the sole responsibility of backend database tooling.
- **User Isolation:** All user-data tables MUST include a `user_id` column. Queries MUST consistently scope by `user_id` to ensure multi-tenant security.

## Core Entities

- **users**
  - *Responsibility:* Maps the authenticated Firebase identity to the database.
  - *Ownership:* Identity/Auth domain.
  - *Relationships:* Parent to all isolated tenant data.
  - *Data Type:* Mostly immutable after creation (except profile info).

- **financial_accounts**
  - *Responsibility:* Represents a user's bank account, credit card, or wallet.
  - *Relationships:* Belongs to `users`. Parent to `financial_events`, `transactions`, and `ledger_entries`.
  - *Data Type:* Mutable (e.g., cached balances, active status).

- **financial_events**
  - *Responsibility:* The raw, canonical ingestion object from any source (SMS, Notification, Email, API).
  - *Relationships:* Belongs to `users` and `financial_accounts`.
  - *Data Type:* **Immutable** (append-only log).
  - *Idempotency:* Requires strict unique composite constraints (e.g., `user_id` + `source_hash`) to block duplicate ingestion.

- **transactions**
  - *Responsibility:* The resolved, deduplicated, and normalized financial activity derived from events.
  - *Relationships:* Belongs to `users`, `financial_accounts`, `merchants`/`people`, and `categories`. Maps 1:1 or N:1 to `financial_events`.
  - *Data Type:* Mutable (classification, notes, status changes).

- **ledger_entries**
  - *Responsibility:* Double-entry bookkeeping records ensuring strict financial consistency.
  - *Relationships:* Belongs to `transactions` and `financial_accounts`.
  - *Data Type:* **Immutable**.
  - *Idempotency:* Inserted exclusively within the same database transaction as the parent `transaction`.

- **merchants** & **people**
  - *Responsibility:* Identifies the counterparty in a transaction.
  - *Relationships:* Belongs to `users` (custom counterparties) or system (global entities).
  - *Data Type:* Mutable (name updates, alias merging).

- **categories**
  - *Responsibility:* The classification taxonomy.
  - *Relationships:* Belongs to `users` (custom) or system (global defaults).
  - *Data Type:* Mutable.

- **classification_rules**
  - *Responsibility:* Rules for auto-categorization based on merchants, regex, or amounts.
  - *Relationships:* Belongs to `users`.
  - *Data Type:* Mutable.

- **sync_metadata**
  - *Responsibility:* Tracks the last successful sync state and cursors for polled sources (e.g., Bank APIs).
  - *Relationships:* Belongs to `users` and `financial_accounts`.
  - *Data Type:* Mutable.

## Financial Consistency Rules

These invariants govern how activities map to the system without duplicating expenses or misrepresenting wealth:

- **Debit:** Decreases an asset account balance. Standard expense if paid to an external merchant.
- **Credit:** Increases an asset account balance. Standard income if received externally.
- **Transfer:** Bank-to-bank movement between a user's own accounts. Comprises a debit and a credit. Net expense is 0.
- **Credit-Card Purchase:** Increases liability (credit card account balance). Recorded as an expense.
- **Credit-Card Payment:** Transfer from an asset (bank) to a liability (credit card). Net expense is 0.
- **Refund:** Reverses a previous expense. Must correctly adjust the category balance and link to the original context if possible.
- **Reversal:** Nullifies an incomplete, failed, or accidental transaction. Net impact is 0.
- **Investment:** Transfer from an asset (bank) to an investment asset. Net expense is 0, tracked separately for portfolio analytics.
- **IPO:** Blocked funds move from an available asset to a restricted asset. Only becomes an investment/expense if allotment succeeds; otherwise unblocked.
- **SIP:** Automated recurring investment. Handled under standard Investment rules.
- **P2P Transfer:** Not automatically classified as an expense. Requires user input to determine if it is an expense, a reimbursement, or a loan.

*Note: Table designs, columns, and ORM models are not yet implemented.*
