import uuid
from typing import Any, Dict, Optional

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from expense_manager_backend.infrastructure.database.models import FinancialEvent


class FinancialEventRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def insert_if_new(
        self, user_id: uuid.UUID, source: str, payload: Dict[str, Any], source_hash: str
    ) -> Optional[uuid.UUID]:
        """Insert the event; returns its id, or None if (user_id, source_hash) already exists."""
        stmt = (
            insert(FinancialEvent)
            .values(id=uuid.uuid4(), user_id=user_id, source=source, payload=payload, source_hash=source_hash)
            .on_conflict_do_nothing(constraint="uq_financial_events_user_source")
            .returning(FinancialEvent.id)
        )
        return (await self.session.execute(stmt)).scalar_one_or_none()

    async def get_id_by_hash(self, user_id: uuid.UUID, source_hash: str) -> uuid.UUID:
        stmt = select(FinancialEvent.id).where(
            FinancialEvent.user_id == user_id, FinancialEvent.source_hash == source_hash
        )
        return (await self.session.execute(stmt)).scalar_one()
