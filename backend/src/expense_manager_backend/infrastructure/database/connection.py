from sqlalchemy.ext.asyncio import create_async_engine
from expense_manager_backend.config.settings import get_settings

_engine = None

def get_engine():
    global _engine
    if _engine is None:
        settings = get_settings()
        _engine = create_async_engine(
            settings.database.url,
            echo=settings.debug,
            pool_size=settings.db_pool_size,
            max_overflow=settings.db_max_overflow,
        )
    return _engine
