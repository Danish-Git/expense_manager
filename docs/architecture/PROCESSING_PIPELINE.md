# FinancialEvent Processing Pipeline

This document defines the generic processing pipeline that converts all raw signals (SMS, email, push notifications, API statements, manual input) into normalized `FinancialEvent` objects, and ultimately into persisted financial state.

---

## Pipeline Stages

### 1. Parser
- **Responsibility:** Extracts structured fields from raw, unstructured, or semi-structured source data using source-specific logic (regex, JSON path, NLP).
- **Input:** Raw source signal (e.g., SMS text string, webhook JSON).
- **Output:** Dictionary of extracted raw fields + parsing confidence score.
- **Nature:** Deterministic (given identical parsing rules).

### 2. Normalizer
- **Responsibility:** Validates and maps the raw extracted dictionary into the strict, strongly-typed `FinancialEvent` contract. Computes the unique `source_hash`.
- **Input:** Extracted fields dictionary.
- **Output:** Canonical `FinancialEvent` object.
- **Nature:** Deterministic.

### 3. Duplicate Detector
- **Responsibility:** Prevents double-processing of identical events. Evaluates the `source_hash` against existing records to guarantee ingestion idempotency.
- **Input:** Canonical `FinancialEvent`.
- **Output:** Boolean flag/exception if duplicate; otherwise proceeds.
- **Nature:** Deterministic.

### 4. Account Resolver
- **Responsibility:** Matches transient account information (e.g., `account_last_four`, `account_name`) to a registered `financial_accounts` primary key (`account_id`).
- **Input:** `FinancialEvent`.
- **Output:** `FinancialEvent` enriched with `account_id`.
- **Nature:** Configurable (alias matching). User-overridable (users can manually link strings to accounts).

### 5. Merchant Resolver
- **Responsibility:** Normalizes raw counterparty strings into canonical `merchants` records.
- **Input:** `FinancialEvent` with `merchant_name`.
- **Output:** `FinancialEvent` enriched with `merchant_id`.
- **Nature:** Configurable. User-overridable (users can alias or rename merchants).

### 6. Person Resolver
- **Responsibility:** Specifically for P2P transfers. Normalizes counterparty names/identifiers into canonical `people` records.
- **Input:** `FinancialEvent` (typically `transfer` or `reversal`).
- **Output:** `FinancialEvent` enriched with `person_id`.
- **Nature:** Configurable. User-overridable.

### 7. Classifier
- **Responsibility:** Evaluates `classification_rules` and applies global/user taxonomy to categorize the event (e.g., "Groceries", "Salary") based on merchant, amount, or regex.
- **Input:** Enriched `FinancialEvent`.
- **Output:** `FinancialEvent` enriched with `category_id`.
- **Nature:** Configurable. Highly user-overridable.

### 8. Transaction Processor
- **Responsibility:** Converts the fully enriched `FinancialEvent` into a mutable, user-facing `Transaction` record, applying domain logic to determine standard transaction status.
- **Input:** Fully enriched and classified `FinancialEvent`.
- **Output:** Prepared `Transaction` object.
- **Nature:** Deterministic.

### 9. Ledger Processor
- **Responsibility:** Enforces strict double-entry bookkeeping rules. Computes the corresponding debits and credits mathematically required by the transaction.
- **Input:** Prepared `Transaction` object.
- **Output:** A set of immutable `LedgerEntry` objects.
- **Nature:** Strictly deterministic. Not user-overridable.

### 10. Reconciliation Processor
- **Responsibility:** Validates the cumulative ledger state against the `available_balance` reported by the original `FinancialEvent`. Flags discrepancies for manual review if the computed ledger balance diverges from the bank's reported truth.
- **Input:** Persisted `Transaction`, `LedgerEntries`, and the original `FinancialEvent` balance fields.
- **Output:** Reconciliation status (Success, Discrepancy Flagged).
- **Nature:** Deterministic.

---

## Idempotency Guarantee
Idempotency is structurally enforced at the edge. 
- The **Normalizer** deterministically generates a `source_hash` based on the source payload. 
- The **Duplicate Detector** utilizes a unique composite database constraint (`user_id`, `source_hash`). 
If an identical payload is submitted multiple times (due to app crashes, network retries, or overlapping ingestion vectors), the pipeline safely aborts at Stage 3 without mutating any state.

## Failure Handling
- **Parsing/Normalization Failure:** If a payload cannot be parsed, it is discarded or routed to an dead-letter queue for telemetry/improvement. It does not crash the system.
- **Resolution Failure (Account/Merchant/Category):** The pipeline does **not** fail. It proceeds leaving the respective IDs `null`. The resulting `Transaction` is flagged as "Needs Review" in the database, allowing the user to resolve it manually in the UI.
- **Database/Ledger Failure:** Stages 8 and 9 execute inside a single ACID database transaction. Any failure rolls back the entire database transaction. Due to strict idempotency, the ingestion pipeline can be safely retried without risk of duplication.
