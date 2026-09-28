import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional

from sqlalchemy import String, DateTime, Numeric, Boolean, ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from expense_manager_backend.infrastructure.database.base import Base

# 1. users
class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    firebase_uid: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String, unique=True, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

# 2. financial_accounts
class FinancialAccount(Base):
    __tablename__ = "financial_accounts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    type: Mapped[str] = mapped_column(String, nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("ix_financial_accounts_user_id", "user_id"),
    )

# 3. financial_events
class FinancialEvent(Base):
    __tablename__ = "financial_events"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    account_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_accounts.id"), nullable=True)
    source: Mapped[str] = mapped_column(String, nullable=False)
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False)
    source_hash: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False) # Immutable

    __table_args__ = (
        UniqueConstraint("user_id", "source_hash", name="uq_financial_events_user_source"),
        Index("ix_financial_events_user_source", "user_id", "source"),
    )

# 4. merchants
class Merchant(Base):
    __tablename__ = "merchants"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("ix_merchants_user_id", "user_id"),
    )

# 5. people
class Person(Base):
    __tablename__ = "people"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("ix_people_user_id", "user_id"),
    )

# 6. categories
class Category(Base):
    __tablename__ = "categories"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    parent_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    type: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("ix_categories_user_id", "user_id"),
    )

# 7. classification_rules
class ClassificationRule(Base):
    __tablename__ = "classification_rules"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    merchant_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("merchants.id"), nullable=True)
    category_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=False)
    match_pattern: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("ix_classification_rules_user_id", "user_id"),
    )

# 8. transactions
class Transaction(Base):
    __tablename__ = "transactions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    financial_event_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_events.id"), nullable=True)
    account_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_accounts.id"), nullable=False)
    merchant_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("merchants.id"), nullable=True)
    category_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    type: Mapped[str] = mapped_column(String, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(19, 4), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False)
    transaction_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    status: Mapped[str] = mapped_column(String, nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "financial_event_id", name="uq_transactions_user_event"),
        Index("ix_transactions_user_time", "user_id", "transaction_time"),
        Index("ix_transactions_account_id", "account_id"),
    )

# 9. ledger_entries
class LedgerEntry(Base):
    __tablename__ = "ledger_entries"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    transaction_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("transactions.id"), nullable=False)
    account_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_accounts.id"), nullable=False)
    direction: Mapped[str] = mapped_column(String, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(19, 4), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False) # Immutable

    __table_args__ = (
        Index("ix_ledger_entries_transaction_id", "transaction_id"),
        Index("ix_ledger_entries_account_id", "account_id"),
    )

# 10. sync_metadata
class SyncMetadata(Base):
    __tablename__ = "sync_metadata"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    account_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_accounts.id"), nullable=False)
    provider: Mapped[str] = mapped_column(String, nullable=False)
    last_sync_cursor: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    last_sync_time: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "account_id", "provider", name="uq_sync_metadata_user_account_provider"),
    )
