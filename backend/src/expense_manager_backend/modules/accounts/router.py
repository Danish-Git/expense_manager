from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from expense_manager_backend.infrastructure.database.session import get_session_factory
from expense_manager_backend.infrastructure.database.models import User
from expense_manager_backend.modules.auth.dependencies import get_current_user
from expense_manager_backend.modules.accounts.schemas import AccountCreate, AccountResponse
from expense_manager_backend.modules.accounts.repository import AccountRepository
from expense_manager_backend.modules.accounts.service import AccountService

router = APIRouter()

async def get_db_session() -> AsyncSession:
    async_session_factory = get_session_factory()
    async with async_session_factory() as session:
        yield session

def get_account_service(session: AsyncSession = Depends(get_db_session)) -> AccountService:
    repository = AccountRepository(session=session)
    return AccountService(repository=repository)

@router.get("", response_model=List[AccountResponse])
async def list_accounts(
    is_active: Optional[bool] = Query(None),
    current_user: User = Depends(get_current_user),
    service: AccountService = Depends(get_account_service)
):
    """Get all accounts for the authenticated user."""
    return await service.get_accounts(user_id=current_user.id, is_active=is_active)

@router.post("", response_model=AccountResponse, status_code=status.HTTP_201_CREATED)
async def create_account(
    account_in: AccountCreate,
    current_user: User = Depends(get_current_user),
    service: AccountService = Depends(get_account_service),
    session: AsyncSession = Depends(get_db_session)
):
    """Create a new account for the authenticated user."""
    account = await service.create_account(user_id=current_user.id, account_in=account_in)
    await session.commit()
    return account
