from fastapi import APIRouter
from datetime import datetime, timezone
from .schemas import HealthResponse

router = APIRouter()

@router.get("", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="ok",
        timestamp=datetime.now(timezone.utc)
    )
