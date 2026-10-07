import hashlib
import json
import uuid
from typing import List

from expense_manager_backend.modules.financial_events.repository import FinancialEventRepository
from expense_manager_backend.modules.financial_events.schemas import (
    FinancialEventCreate,
    FinancialEventResponse,
)


def compute_source_hash(event_in: FinancialEventCreate) -> str:
    """Deterministic idempotency key: sha256 of the canonical JSON of the submitted event."""
    canonical = json.dumps(
        {
            "source": event_in.source.value,
            "source_id": event_in.source_id,
            "timestamp": event_in.timestamp.isoformat(),
            "payload": event_in.payload,
        },
        sort_keys=True,
        separators=(",", ":"),
        default=str,
    )
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


class FinancialEventService:
    def __init__(self, repository: FinancialEventRepository):
        self.repository = repository

    async def ingest(self, user_id: uuid.UUID, event_in: FinancialEventCreate) -> FinancialEventResponse:
        source_hash = compute_source_hash(event_in)
        stored = {
            "source_id": event_in.source_id,
            "timestamp": event_in.timestamp.isoformat(),
            "data": event_in.payload,
        }
        event_id = await self.repository.insert_if_new(
            user_id=user_id, source=event_in.source.value, payload=stored, source_hash=source_hash
        )
        created = event_id is not None
        if not created:
            event_id = await self.repository.get_id_by_hash(user_id=user_id, source_hash=source_hash)
        return FinancialEventResponse(
            id=event_id, source=event_in.source.value, source_hash=source_hash, created=created
        )

    async def ingest_batch(
        self, user_id: uuid.UUID, events: List[FinancialEventCreate]
    ) -> List[FinancialEventResponse]:
        return [await self.ingest(user_id=user_id, event_in=e) for e in events]
