import time

from fastapi import FastAPI
from expense_manager_backend.routes.api import api_router
from expense_manager_backend.common.exceptions import setup_exception_handlers
from expense_manager_backend.config.settings import Environment, get_settings

def create_app() -> FastAPI:
    settings = get_settings()
    docs_enabled = settings.environment in {Environment.DEVELOPMENT, Environment.TESTING}

    app = FastAPI(
        title=settings.app_name,
        debug=settings.debug,
        docs_url="/swagger" if docs_enabled else None,
        redoc_url=None,
        openapi_url="/openapi.json" if docs_enabled else None,
    )
    app.state.started_at = time.monotonic()

    setup_exception_handlers(app)
    
    app.include_router(api_router)
    
    return app

app = create_app()
