from fastapi import APIRouter
from expense_manager_backend.modules.health.routes import router as health_router

api_router = APIRouter()

api_router.include_router(health_router, prefix="/health", tags=["health"])
