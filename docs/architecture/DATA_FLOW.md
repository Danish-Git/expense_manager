# Data Flow Pipeline

The core financial processing pipeline ensures that all external input is mapped to a canonical domain model before persisting to the ledger.

## Canonical Financial Pipeline
1. **Source**
2. **FinancialEvent** (Canonical ingestion concept)
3. **Normalization**
4. **Duplicate Detection**
5. **Resolution**
6. **Classification**
7. **Ledger**
8. **Analytics**

Every data source converges into a `FinancialEvent`. 

## Sources
- SMS
- Notification
- Email
- Statement
- Manual
- Bank API

## Source Priority
If multiple sources provide overlapping information, priority is resolved as follows:
1. SMS
2. Notification
3. Email
4. Statement
5. Manual

*Note: Source manager implementation is pending.*
