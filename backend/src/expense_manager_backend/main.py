from fastapi import FastAPI
from expense_manager_backend.routes.api import api_router
from expense_manager_backend.common.exceptions import setup_exception_handlers
from expense_manager_backend.config.settings import get_settings

def create_app() -> FastAPI:
    settings = get_settings()
    
    app = FastAPI(
        title=settings.app_name,
        debug=settings.debug
    )
    
    setup_exception_handlers(app)
    
    app.include_router(api_router)
    
    return app

app = create_app()
