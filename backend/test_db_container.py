import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from expense_manager_backend.config.settings import Settings, DatabaseTarget

async def test_db(target: DatabaseTarget):
    try:
        s = Settings(db_target=target, _env_file=".env")
        engine = create_async_engine(s.database.url)
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        print(f"{target.value.capitalize()} DB: PASS")
        await engine.dispose()
    except Exception as e:
        print(f"{target.value.capitalize()} DB: FAIL")
        print(e)

if __name__ == "__main__":
    asyncio.run(test_db(DatabaseTarget.LOCAL))
    asyncio.run(test_db(DatabaseTarget.LIVE))
