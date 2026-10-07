from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from expense_manager_backend.infrastructure.database.session import get_session_factory
from expense_manager_backend.infrastructure.database.models import User
from expense_manager_backend.modules.auth.dependencies import get_current_user
from expense_manager_backend.modules.financial_events.schemas import (
    FinancialEventBatchCreate,
    FinancialEventBatchResponse,
    FinancialEventCreate,
    FinancialEventResponse,
)
from expense_manager_backend.modules.financial_events.repository import FinancialEventRepository
from expense_manager_backend.modules.financial_events.service import FinancialEventService

router = APIRouter()

async def get_db_session() -> AsyncSession:
    async_session_factory = get_session_factory()
    async with async_session_factory() as session:
        yield session

def get_financial_event_service(session: AsyncSession = Depends(get_db_session)) -> FinancialEventService:
    return FinancialEventService(repository=FinancialEventRepository(session=session))

@router.post("", response_model=FinancialEventResponse, status_code=status.HTTP_201_CREATED)
async def create_financial_event(
    event_in: FinancialEventCreate,
    response: Response,
    current_user: User = Depends(get_current_user),
    service: FinancialEventService = Depends(get_financial_event_service),
    session: AsyncSession = Depends(get_db_session),
):
    """Ingest one financial event. Duplicates return 200 with the existing event."""
    result = await service.ingest(user_id=current_user.id, event_in=event_in)
    await session.commit()
    if not result.created:
        response.status_code = status.HTTP_200_OK
    return result

@router.post("/batch", response_model=FinancialEventBatchResponse)
async def create_financial_events_batch(
    batch_in: FinancialEventBatchCreate,
    current_user: User = Depends(get_current_user),
    service: FinancialEventService = Depends(get_financial_event_service),
    session: AsyncSession = Depends(get_db_session),
):
    """Ingest events idempotently; each result reports created or duplicate."""
    results = await service.ingest_batch(user_id=current_user.id, events=batch_in.events)
    await session.commit()
    return FinancialEventBatchResponse(results=results)
