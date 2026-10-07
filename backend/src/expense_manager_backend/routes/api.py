from fastapi import APIRouter
from expense_manager_backend.modules.health.routes import router as health_router
from expense_manager_backend.modules.accounts.router import router as accounts_router
from expense_manager_backend.modules.financial_events.router import router as financial_events_router

api_router = APIRouter()

api_router.include_router(health_router, prefix="/health", tags=["health"])
api_router.include_router(accounts_router, prefix="/accounts", tags=["accounts"])
api_router.include_router(financial_events_router, prefix="/financial-events", tags=["financial-events"])
