from sqlalchemy.ext.asyncio import async_sessionmaker
from .connection import engine

async_session_factory = async_sessionmaker(
    bind=engine,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

async def get_db_session():
    async with async_session_factory() as session:
        yield session
