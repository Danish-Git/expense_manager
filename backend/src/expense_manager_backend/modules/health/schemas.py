from enum import Enum
from typing import Literal, Optional

from pydantic import BaseModel


class ComponentState(str, Enum):
    OK = "ok"
    NOT_IMPLEMENTED = "not_implemented"
    UNREACHABLE = "unreachable"


class DatabaseStatus(BaseModel):
    state: ComponentState
    latency_ms: Optional[float] = None


class HealthResponse(BaseModel):
    status: Literal["ready", "degraded"]
    environment: str
    db_target: str
    uptime_seconds: float
    components: dict[str, ComponentState]
    database: DatabaseStatus
    note: str
