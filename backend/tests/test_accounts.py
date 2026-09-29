import uuid
import pytest
from httpx import AsyncClient
from fastapi import FastAPI
from unittest.mock import patch, MagicMock

from expense_manager_backend.main import app
from expense_manager_backend.infrastructure.database.models import User, FinancialAccount

@pytest.fixture
def mock_user():
    return User(
        id=uuid.uuid4(),
        firebase_uid="firebase123",
        email="test@example.com"
    )

# We use unit tests for service layer instead of full HTTP to avoid complex FastAPI dependency overriding
from expense_manager_backend.modules.accounts.service import AccountService
from expense_manager_backend.modules.accounts.schemas import AccountCreate
from unittest.mock import AsyncMock

@pytest.mark.asyncio
async def test_service_create_account(mock_user):
    mock_repo = AsyncMock()
    service = AccountService(repository=mock_repo)
    
    mock_repo.create_account.return_value = FinancialAccount(
        id=uuid.uuid4(),
        user_id=mock_user.id,
        name="Test Bank",
        type="bank",
        currency="USD",
        is_active=True
    )
    
    account_in = AccountCreate(name="Test Bank", type="bank", currency="USD")
    result = await service.create_account(user_id=mock_user.id, account_in=account_in)
    
    assert result.name == "Test Bank"
    assert result.type == "bank"
    assert result.currency == "USD"
    assert result.is_active is True
    mock_repo.create_account.assert_awaited_once_with(user_id=mock_user.id, account_in=account_in)

@pytest.mark.asyncio
async def test_service_get_accounts(mock_user):
    mock_repo = AsyncMock()
    service = AccountService(repository=mock_repo)
    
    mock_repo.get_accounts.return_value = [
        FinancialAccount(id=uuid.uuid4(), user_id=mock_user.id, name="Acc1", type="bank", currency="USD", is_active=True),
        FinancialAccount(id=uuid.uuid4(), user_id=mock_user.id, name="Acc2", type="credit", currency="EUR", is_active=False)
    ]
    
    results = await service.get_accounts(user_id=mock_user.id)
    
    assert len(results) == 2
    assert results[0].name == "Acc1"
    assert results[1].name == "Acc2"
    mock_repo.get_accounts.assert_awaited_once_with(user_id=mock_user.id, is_active=None)
    
@pytest.mark.asyncio
async def test_invalid_account_data():
    from pydantic import ValidationError
    
    # Currency must be 3 chars
    with pytest.raises(ValidationError):
        AccountCreate(name="Bank", type="bank", currency="US")
        
    # Name must not be empty
    with pytest.raises(ValidationError):
        AccountCreate(name="", type="bank", currency="USD")
