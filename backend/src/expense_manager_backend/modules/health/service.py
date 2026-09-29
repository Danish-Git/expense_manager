from expense_manager_backend.config.settings import Settings
from expense_manager_backend.infrastructure.database.health import check_database
from expense_manager_backend.modules.health.schemas import (
    ComponentState,
    DatabaseStatus,
    HealthResponse,
)


async def get_health(settings: Settings, uptime_seconds: float) -> HealthResponse:
    config = settings.database
    # No password configured means "not built for this environment," not "broken" - never
    # attempt a doomed connection.
    if not config.password:
        database = DatabaseStatus(state=ComponentState.NOT_IMPLEMENTED)
    else:
        result = await check_database(config)
        database = DatabaseStatus(
            state=ComponentState.OK if result.connected else ComponentState.UNREACHABLE,
            latency_ms=result.latency_ms,
        )

    components = {"api": ComponentState.OK, "database": database.state}
    is_ready = database.state != ComponentState.UNREACHABLE

    return HealthResponse(
        status="ready" if is_ready else "degraded",
        environment=settings.environment.value,
        db_target=settings.db_target.value,
        uptime_seconds=round(uptime_seconds, 2),
        components=components,
        database=database,
        note="The database check confirms connectivity.",
    )
