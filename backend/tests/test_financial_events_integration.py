import uuid
from datetime import datetime, timezone

import pytest
import pytest_asyncio
from sqlalchemy import delete, func, select, text
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from expense_manager_backend.config.settings import DatabaseTarget, get_settings
from expense_manager_backend.infrastructure.database.models import FinancialEvent, User
from expense_manager_backend.modules.financial_events.repository import FinancialEventRepository
from expense_manager_backend.modules.financial_events.schemas import FinancialEventCreate
from expense_manager_backend.modules.financial_events.service import FinancialEventService


@pytest_asyncio.fixture
async def db_session():
    settings = get_settings()
    if settings.db_target is not DatabaseTarget.LOCAL:
        pytest.skip("integration test runs against the local database only")
    engine = create_async_engine(settings.database.url, poolclass=NullPool)
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1 FROM financial_events LIMIT 1"))
    except Exception as exc:
        await engine.dispose()
        pytest.skip(f"local PostgreSQL unavailable or not migrated ({type(exc).__name__})")
    async with async_sessionmaker(engine, expire_on_commit=False)() as session:
        yield session
    await engine.dispose()


@pytest.mark.asyncio
async def test_duplicate_event_hits_on_conflict_and_leaves_one_row(db_session):
    user = User(id=uuid.uuid4(), firebase_uid=f"it-{uuid.uuid4()}")
    db_session.add(user)
    await db_session.commit()
    try:
        service = FinancialEventService(FinancialEventRepository(db_session))
        event = FinancialEventCreate(
            source="sms",
            payload={"amount": "10.00"},
            timestamp=datetime(2026, 9, 28, 10, 0, tzinfo=timezone.utc),
        )
        first = await service.ingest(user.id, event)
        await db_session.commit()
        second = await service.ingest(user.id, event)
        await db_session.commit()

        assert first.created is True
        assert second.created is False
        assert second.id == first.id
        count = await db_session.scalar(
            select(func.count()).select_from(FinancialEvent).where(FinancialEvent.user_id == user.id)
        )
        assert count == 1
    finally:
        await db_session.rollback()
        await db_session.execute(delete(FinancialEvent).where(FinancialEvent.user_id == user.id))
        await db_session.execute(delete(User).where(User.id == user.id))
        await db_session.commit()
