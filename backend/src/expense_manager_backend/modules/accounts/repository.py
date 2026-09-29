import uuid
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from expense_manager_backend.infrastructure.database.models import FinancialAccount
from expense_manager_backend.modules.accounts.schemas import AccountCreate

class AccountRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_accounts(self, user_id: uuid.UUID, is_active: Optional[bool] = None) -> List[FinancialAccount]:
        query = select(FinancialAccount).where(FinancialAccount.user_id == user_id)
        if is_active is not None:
            query = query.where(FinancialAccount.is_active == is_active)
        
        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def create_account(self, user_id: uuid.UUID, account_in: AccountCreate) -> FinancialAccount:
        account = FinancialAccount(
            user_id=user_id,
            name=account_in.name,
            type=account_in.type,
            currency=account_in.currency.upper()
        )
        self.session.add(account)
        await self.session.flush()
        return account
