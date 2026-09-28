# FinancialEvent Contract

## Purpose
The `FinancialEvent` is the universal, canonical ingestion object for the expense_manager. Every external signal (SMS, emails, push notifications, bank statements, API syncs, manual input) is parsed, normalized, and converted into this standard contract before entering the core financial engine. This completely decouples core business logic from parsing complexities and guarantees ingestion consistency.

## Contract Definition

### Enums
- **Source:** `sms`, `email`, `notification`, `statement`, `api`, `manual`
- **EventType:** `debit`, `credit`, `transfer`, `refund`, `reversal`, `investment_blocked`, `investment_executed`, `unknown`

### Required Fields
- `event_id` (UUID) - Unique identifier for the parsed event instance.
- `user_id` (UUID) - The identity of the user.
- `source` (Source Enum) - Origin of the event.
- `event_type` (EventType Enum) - The inferred nature of the event.
- `amount` (Decimal) - The absolute financial value.
- `currency` (String) - ISO 4217 code (e.g., 'INR', 'USD').
- `timestamp` (DateTime UTC) - The exact time the event occurred, according to the source.
- `source_hash` (String) - Deterministic fingerprint derived from `source` + `raw payload` (or critical fields). Used strictly as the **idempotency key**.

### Optional Fields

#### Source Reference
- `source_reference_id` (String) - The original transaction reference or ID provided by the bank/source.
- `raw_payload` (JSON/String) - The original unparsed payload, kept for auditing and potential future re-parsing.

#### Confidence
- `parsing_confidence` (Float 0.0 - 1.0) - Confidence score of the normalization and extraction process.

#### Account Information
- `account_last_four` (String) - Last 4 digits of the account/card.
- `account_name` (String) - Bank or institution name extracted from the source.
- `account_id` (UUID) - Filled if the event can be pre-resolved to an existing `financial_accounts` record.

#### Counterparty (Merchant/Person)
- `merchant_name` (String) - Extracted raw counterparty name (e.g., 'AMZN Mktp US').
- `merchant_id` (UUID) - Filled if resolved against existing `merchants` or `people`.

#### Location
- `location_string` (String) - Raw location text if provided in the source.
- `coordinates` (Lat/Lng) - If available (e.g., rich push notification).

#### Balance Information
- `available_balance` (Decimal) - The post-transaction balance reported by the source.
- `outstanding_balance` (Decimal) - Liability balance (primarily for credit card sources).

---

## Lifecycle Pipeline

The processing pipeline strictly separates the transient event from the persisted mathematical state:

1. **SOURCE** → A raw signal arrives (e.g., an SMS string or webhook payload).
2. **PARSE** → Source-specific logic extracts raw values.
3. **NORMALIZE** → Raw values are mapped to match standard types and formats.
4. **FinancialEvent** → The canonical, immutable event object is generated in memory.
5. **DEDUPLICATE** → The `source_hash` is verified against the database to block duplicates (Idempotency).
6. **RESOLVE** → Loose references (`account_last_four`, `merchant_name`) are linked to database primary keys (`account_id`, `merchant_id`).
7. **CLASSIFY** → Categories are applied based on user rules, global defaults, and merchant mappings.
8. **LEDGER** → A mutable `Transaction` and immutable double-entry `LedgerEntries` are committed in a single database transaction.

---

## Conceptual Distinctions

- **Raw Source Data:** Unstructured or semi-structured origin data. Holds no financial meaning to the core engine.
- **Normalized FinancialEvent:** The immutable interpretation of the raw data. Belongs exclusively to the ingestion boundary.
- **Persisted Transaction:** The mutable, resolved state of the event. Allows users to categorize, edit notes, or re-classify. Belongs to the user-facing application domain.
- **Ledger Entry:** The strictly immutable, mathematical truth (debits and credits). Belongs to the accounting boundary.
