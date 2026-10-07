import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock

import pytest
from fastapi.testclient import TestClient
from pydantic import ValidationError

from expense_manager_backend.main import app
from expense_manager_backend.modules.financial_events.schemas import (
    FinancialEventBatchCreate,
    FinancialEventCreate,
)
from expense_manager_backend.modules.financial_events.service import (
    FinancialEventService,
    compute_source_hash,
)

TS = datetime(2026, 9, 28, 10, 0, tzinfo=timezone.utc)


def make_event(**kw):
    data = dict(source="sms", payload={"amount": "10.00", "a": 1, "b": 2}, timestamp=TS)
    data.update(kw)
    return FinancialEventCreate(**data)


def test_missing_token_rejected():
    client = TestClient(app)
    body = {"source": "sms", "payload": {}, "timestamp": TS.isoformat()}
    assert client.post("/financial-events", json=body).status_code in (401, 403)
    assert client.post("/financial-events/batch", json={"events": [body]}).status_code in (401, 403)


def test_validation():
    with pytest.raises(ValidationError):
        make_event(source="carrier_pigeon")
    with pytest.raises(ValidationError):
        FinancialEventCreate(source="sms", payload={})  # timestamp missing
    with pytest.raises(ValidationError):
        FinancialEventBatchCreate(events=[])


def test_user_id_not_accepted_from_client():
    assert "user_id" not in FinancialEventCreate.model_fields


def test_hash_is_deterministic_and_key_order_independent():
    a = make_event(payload={"a": 1, "b": 2})
    b = make_event(payload={"b": 2, "a": 1})
    assert compute_source_hash(a) == compute_source_hash(b)
    assert compute_source_hash(a) != compute_source_hash(make_event(payload={"a": 1, "b": 3}))


@pytest.mark.asyncio
async def test_new_event_created():
    repo = AsyncMock()
    repo.insert_if_new.return_value = uuid.uuid4()
    user_id = uuid.uuid4()
    result = await FinancialEventService(repo).ingest(user_id, make_event())
    assert result.created is True
    repo.get_id_by_hash.assert_not_awaited()
    assert repo.insert_if_new.await_args.kwargs["user_id"] == user_id


@pytest.mark.asyncio
async def test_duplicate_returns_existing_event():
    existing = uuid.uuid4()
    repo = AsyncMock()
    repo.insert_if_new.return_value = None
    repo.get_id_by_hash.return_value = existing
    result = await FinancialEventService(repo).ingest(uuid.uuid4(), make_event())
    assert result.created is False
    assert result.id == existing


@pytest.mark.asyncio
async def test_batch_reports_created_and_duplicate_per_event():
    repo = AsyncMock()
    repo.insert_if_new.side_effect = [uuid.uuid4(), None]
    repo.get_id_by_hash.return_value = uuid.uuid4()
    results = await FinancialEventService(repo).ingest_batch(uuid.uuid4(), [make_event(), make_event()])
    assert [r.created for r in results] == [True, False]


@pytest.mark.asyncio
async def test_user_isolation_scopes_every_repository_call_to_user():
    repo = AsyncMock()
    repo.insert_if_new.return_value = None
    repo.get_id_by_hash.return_value = uuid.uuid4()
    user_a, user_b = uuid.uuid4(), uuid.uuid4()
    svc = FinancialEventService(repo)
    await svc.ingest(user_a, make_event())
    await svc.ingest(user_b, make_event())
    assert [c.kwargs["user_id"] for c in repo.insert_if_new.await_args_list] == [user_a, user_b]
    assert [c.kwargs["user_id"] for c in repo.get_id_by_hash.await_args_list] == [user_a, user_b]
