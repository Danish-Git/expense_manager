# PostgreSQL Financial Schema

This document defines the concrete PostgreSQL database schema for the Personal Financial Intelligence application.

## Global Design Rules
- **User Isolation:** All tenant tables include a `user_id` column.
- **Money Representation:** Uses `NUMERIC(19,4)` to ensure exact precision and avoid floating-point errors.
- **Timestamps:** Uses `TIMESTAMPTZ` (Timestamp with Time Zone) for all temporal data.
- **Primary Keys:** Uses `UUID` (UUIDv4 or UUIDv7) for all primary keys to facilitate offline/distributed generation and obscure counts.
- **Auditability:** Most tables include `created_at` and `updated_at`. Immutable tables only have `created_at`.

---

## 1. `users`
Maps Firebase Auth identities to the local database.

- **Columns:**
  - `id` (UUID, PK)
  - `firebase_uid` (VARCHAR, Not Null) - *Immutable*
  - `email` (VARCHAR, Nullable)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW) - *Immutable*
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `UNIQUE (firebase_uid)`
  - `UNIQUE (email)`

---

## 2. `financial_accounts`
Represents assets (bank accounts, wallets) and liabilities (credit cards).

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Not Null) - FK to `users.id`
  - `name` (VARCHAR, Not Null)
  - `type` (VARCHAR, Not Null) - e.g., 'bank', 'credit_card', 'wallet'
  - `currency` (CHAR(3), Not Null) - ISO 4217 code
  - `is_active` (BOOLEAN, Not Null, Default TRUE)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `INDEX (user_id)`

---

## 3. `financial_events`
The canonical, immutable ingestion log for all parsed financial activity.

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Not Null) - FK to `users.id`
  - `account_id` (UUID, Nullable) - FK to `financial_accounts.id` (can be null if account is unknown)
  - `source` (VARCHAR, Not Null) - e.g., 'sms', 'notification', 'statement', 'api'
  - `payload` (JSONB, Not Null) - Raw source data
  - `source_hash` (VARCHAR, Not Null) - Hash fingerprint of source + payload for idempotency
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW) - *Immutable*
- **Constraints & Indexes:**
  - `UNIQUE (user_id, source_hash)` - Enforces ingestion idempotency per user.
  - `INDEX (user_id, source)`

---

## 4. `merchants` & `people`
Counterparties for transactions. Consolidated as a single table or logical entity.

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Nullable) - FK to `users.id`. If null, it is a global system merchant.
  - `name` (VARCHAR, Not Null)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `INDEX (user_id)`

---

## 5. `categories`
Taxonomy for classification.

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Nullable) - FK to `users.id`. Null for global defaults.
  - `parent_id` (UUID, Nullable) - FK to `categories.id` (for subcategories)
  - `name` (VARCHAR, Not Null)
  - `type` (VARCHAR, Not Null) - e.g., 'expense', 'income', 'transfer', 'investment'
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `INDEX (user_id)`

---

## 6. `classification_rules`
Rules for auto-categorization of future transactions.

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Not Null) - FK to `users.id`
  - `merchant_id` (UUID, Nullable) - FK to `merchants.id`
  - `category_id` (UUID, Not Null) - FK to `categories.id`
  - `match_pattern` (VARCHAR, Nullable) - Regex or substring for matching raw event text
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `INDEX (user_id)`

---

## 7. `transactions`
The resolved, mutable financial activity.

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Not Null) - FK to `users.id`
  - `financial_event_id` (UUID, Nullable) - FK to `financial_events.id`. Null for manual entries.
  - `account_id` (UUID, Not Null) - FK to `financial_accounts.id`
  - `merchant_id` (UUID, Nullable) - FK to `merchants.id`
  - `category_id` (UUID, Nullable) - FK to `categories.id`
  - `type` (VARCHAR, Not Null) - e.g., 'debit', 'credit', 'transfer', 'refund', 'reversal'
  - `amount` (NUMERIC(19, 4), Not Null) - Absolute value
  - `currency` (CHAR(3), Not Null)
  - `transaction_time` (TIMESTAMPTZ, Not Null) - Actual time of the transaction
  - `status` (VARCHAR, Not Null) - e.g., 'pending', 'completed', 'failed'
  - `notes` (TEXT, Nullable)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `UNIQUE (user_id, financial_event_id)` - Prevents processing the same event twice.
  - `INDEX (user_id, transaction_time)`
  - `INDEX (account_id)`

---

## 8. `ledger_entries`
Immutable double-entry bookkeeping records ensuring financial consistency. A single transaction may yield two ledger entries (e.g., a transfer yields one debit entry and one credit entry).

- **Columns:**
  - `id` (UUID, PK)
  - `transaction_id` (UUID, Not Null) - FK to `transactions.id`
  - `account_id` (UUID, Not Null) - FK to `financial_accounts.id`
  - `direction` (VARCHAR, Not Null) - 'debit' or 'credit'
  - `amount` (NUMERIC(19, 4), Not Null) - Absolute value
  - `currency` (CHAR(3), Not Null)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW) - *Immutable*
- **Constraints & Indexes:**
  - `INDEX (transaction_id)`
  - `INDEX (account_id)`

---

## 9. `sync_metadata`
Tracks polling state for external integrations (e.g., Bank APIs).

- **Columns:**
  - `id` (UUID, PK)
  - `user_id` (UUID, Not Null) - FK to `users.id`
  - `account_id` (UUID, Not Null) - FK to `financial_accounts.id`
  - `provider` (VARCHAR, Not Null)
  - `last_sync_cursor` (VARCHAR, Nullable)
  - `last_sync_time` (TIMESTAMPTZ, Nullable)
  - `created_at` (TIMESTAMPTZ, Not Null, Default NOW)
  - `updated_at` (TIMESTAMPTZ, Not Null, Default NOW)
- **Constraints & Indexes:**
  - `UNIQUE (user_id, account_id, provider)`
