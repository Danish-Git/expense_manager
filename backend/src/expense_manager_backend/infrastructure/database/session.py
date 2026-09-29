from sqlalchemy.ext.asyncio import async_sessionmaker
from .connection import get_engine

_session_factory = None

def get_session_factory():
    global _session_factory
    if _session_factory is None:
        _session_factory = async_sessionmaker(
            bind=get_engine(),
            expire_on_commit=False,
            autocommit=False,
            autoflush=False,
        )
    return _session_factory

async def get_db_session():
    factory = get_session_factory()
    async with factory() as session:
        yield session
