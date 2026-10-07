import uuid
from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class Source(str, Enum):
    SMS = "sms"
    EMAIL = "email"
    NOTIFICATION = "notification"
    STATEMENT = "statement"
    API = "api"
    MANUAL = "manual"


class FinancialEventCreate(BaseModel):
    source: Source
    source_id: Optional[str] = Field(None, min_length=1, max_length=255)
    payload: Dict[str, Any]
    timestamp: datetime


class FinancialEventBatchCreate(BaseModel):
    events: List[FinancialEventCreate] = Field(..., min_length=1, max_length=500)


class FinancialEventResponse(BaseModel):
    id: uuid.UUID
    source: str
    source_hash: str
    created: bool


class FinancialEventBatchResponse(BaseModel):
    results: List[FinancialEventResponse]
