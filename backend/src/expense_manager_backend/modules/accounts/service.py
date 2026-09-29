import uuid
from typing import List, Optional

from expense_manager_backend.modules.accounts.schemas import AccountCreate, AccountResponse
from expense_manager_backend.modules.accounts.repository import AccountRepository

class AccountService:
    def __init__(self, repository: AccountRepository):
        self.repository = repository

    async def get_accounts(self, user_id: uuid.UUID, is_active: Optional[bool] = None) -> List[AccountResponse]:
        accounts = await self.repository.get_accounts(user_id=user_id, is_active=is_active)
        return [AccountResponse.model_validate(acc) for acc in accounts]

    async def create_account(self, user_id: uuid.UUID, account_in: AccountCreate) -> AccountResponse:
        account = await self.repository.create_account(user_id=user_id, account_in=account_in)
        return AccountResponse.model_validate(account)
