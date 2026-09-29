from typing import Optional
import uuid
from pydantic import BaseModel, Field, constr

class AccountCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    type: str = Field(..., min_length=1, max_length=50) # e.g. bank, credit_card
    currency: constr(min_length=3, max_length=3) = Field(..., description="ISO 4217 currency code")

class AccountResponse(BaseModel):
    id: uuid.UUID
    name: str
    type: str
    currency: str
    is_active: bool

    model_config = {"from_attributes": True}
