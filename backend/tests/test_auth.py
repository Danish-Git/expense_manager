import pytest
from unittest.mock import patch, MagicMock, AsyncMock
from fastapi import HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials

from expense_manager_backend.modules.auth.dependencies import get_current_user
from expense_manager_backend.infrastructure.database.models import User

@pytest.mark.asyncio
async def test_invalid_token():
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="invalid-token")
    mock_session = AsyncMock()
    
    with patch("expense_manager_backend.modules.auth.dependencies.auth.verify_id_token") as mock_verify:
        mock_verify.side_effect = Exception("Invalid token")
        
        with pytest.raises(HTTPException) as exc_info:
            await get_current_user(credentials=credentials, session=mock_session)
            
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        assert exc_info.value.detail == "Invalid authentication credentials"

@pytest.mark.asyncio
async def test_missing_uid_in_token():
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid-but-no-uid")
    mock_session = AsyncMock()
    
    with patch("expense_manager_backend.modules.auth.dependencies.auth.verify_id_token") as mock_verify:
        mock_verify.return_value = {"email": "test@example.com"} # no uid
        
        with pytest.raises(HTTPException) as exc_info:
            await get_current_user(credentials=credentials, session=mock_session)
            
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        assert exc_info.value.detail == "Invalid token structure: missing uid"

@pytest.mark.asyncio
async def test_uid_to_user_resolution_existing_user():
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid-token")
    mock_session = AsyncMock()
    
    # Mock existing user
    mock_user = User(firebase_uid="firebase123", email="test@example.com")
    
    # Setup mock session execute to return our user
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = mock_user
    mock_session.execute = AsyncMock(return_value=mock_result)
    
    with patch("expense_manager_backend.modules.auth.dependencies.auth.verify_id_token") as mock_verify:
        mock_verify.return_value = {"uid": "firebase123", "email": "test@example.com"}
        
        user = await get_current_user(credentials=credentials, session=mock_session)
        
        assert user.firebase_uid == "firebase123"
        # Verify add was not called since user exists
        mock_session.add.assert_not_called()

@pytest.mark.asyncio
async def test_uid_to_user_resolution_new_user():
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid-token")
    mock_session = AsyncMock()
    
    # Setup mock session execute to return None (user not found)
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_session.execute = AsyncMock(return_value=mock_result)
    mock_session.commit = AsyncMock()
    mock_session.refresh = AsyncMock()
    
    with patch("expense_manager_backend.modules.auth.dependencies.auth.verify_id_token") as mock_verify:
        mock_verify.return_value = {"uid": "firebase123", "email": "new@example.com"}
        
        user = await get_current_user(credentials=credentials, session=mock_session)
        
        assert user.firebase_uid == "firebase123"
        assert user.email == "new@example.com"
        # Verify user was added and committed
        mock_session.add.assert_called_once()
        mock_session.commit.assert_awaited_once()
        mock_session.refresh.assert_awaited_once()
