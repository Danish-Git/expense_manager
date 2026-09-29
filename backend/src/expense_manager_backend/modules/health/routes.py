import time

from fastapi import APIRouter, Request

from expense_manager_backend.config.settings import get_settings
from expense_manager_backend.modules.health import service
from expense_manager_backend.modules.health.schemas import HealthResponse

router = APIRouter()


@router.get("", response_model=HealthResponse)
async def health_check(request: Request):
    settings = get_settings()
    started_at = getattr(request.app.state, "started_at", None)
    uptime_seconds = time.monotonic() - started_at if started_at is not None else 0.0
    return await service.get_health(settings, uptime_seconds=uptime_seconds)
