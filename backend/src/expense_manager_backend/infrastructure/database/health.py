"""Database connectivity check for the health module.

No ORM, no pool: opens one fresh asyncpg connection, runs a trivial query, then closes it. Never
raises: a connection or query failure is exactly what a health check needs to report, not
propagate. Never returns host, port, or credentials - see modules/health/service.py, which turns
this into a coarse component state only.
"""

import asyncio
import time
from dataclasses import dataclass
from typing import Optional

import asyncpg

from expense_manager_backend.config.settings import DatabaseConfig

CONNECT_TIMEOUT_SECONDS = 2.0
QUERY_TIMEOUT_SECONDS = 1.0


@dataclass(frozen=True)
class DatabaseCheckResult:
    connected: bool
    latency_ms: Optional[float]


async def check_database(config: DatabaseConfig) -> DatabaseCheckResult:
    start = time.monotonic()
    try:
        conn = await asyncio.wait_for(
            asyncpg.connect(
                host=config.host,
                port=config.port,
                database=config.name,
                user=config.user,
                password=config.password,
            ),
            timeout=CONNECT_TIMEOUT_SECONDS,
        )
    except (OSError, asyncpg.PostgresError, TimeoutError):
        return DatabaseCheckResult(connected=False, latency_ms=None)

    try:
        await asyncio.wait_for(conn.fetchval("SELECT 1"), timeout=QUERY_TIMEOUT_SECONDS)
        latency_ms = round((time.monotonic() - start) * 1000, 2)
        return DatabaseCheckResult(connected=True, latency_ms=latency_ms)
    except (OSError, asyncpg.PostgresError, TimeoutError):
        return DatabaseCheckResult(connected=False, latency_ms=None)
    finally:
        await conn.close()
