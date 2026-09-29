"""Typed settings loaded from environment variables (prefix ``EXPENSE_``).

Precedence: process environment > ``.env`` file in the working directory > defaults.
Non-secret per-environment templates live in the repository's top-level ``config/`` folder.
Secrets must never be given defaults here and must never be logged.
"""

from enum import Enum
from functools import lru_cache

from pydantic import BaseModel, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


from typing import Optional

class Environment(str, Enum):
    DEVELOPMENT = "development"
    TESTING = "testing"
    STAGING = "staging"
    PRODUCTION = "production"


class DatabaseTarget(str, Enum):
    """Which database this process connects to."""
    LOCAL = "local"
    LIVE = "live"


#: The allowed user for live environments
LIVE_ALLOWED_ROLE = "expenses_app"


class DatabaseConfig(BaseModel):
    """The resolved connection settings for whichever target is currently active."""
    host: str
    port: int
    name: str
    user: str
    password: Optional[str] = None

    def __repr__(self) -> str:
        # Never let logging/debugging accidentally include the password
        return (
            f"DatabaseConfig(host={self.host!r}, port={self.port!r}, name={self.name!r}, "
            f"user={self.user!r}, password=***)"
        )

    @property
    def url(self) -> str:
        if self.password:
            return f"postgresql+asyncpg://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"
        return f"postgresql+asyncpg://{self.user}@{self.host}:{self.port}/{self.name}"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="EXPENSE_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        frozen=True,
    )

    app_name: str = "expense_manager_backend"
    environment: Environment = Environment.DEVELOPMENT
    debug: bool = False
    log_level: str = "INFO"

    # Database
    db_pool_size: int = 5
    db_max_overflow: int = 10

    # Which database this process talks to.
    db_target: DatabaseTarget = DatabaseTarget.LOCAL

    # Local PostgreSQL settings
    db_local_host: str = "127.0.0.1"
    db_local_port: int = 15432
    db_local_name: str = "expenses_db"
    db_local_user: str = "expenses_app"
    db_local_password: Optional[str] = None

    # Live PostgreSQL settings
    db_live_host: str = "postgres"
    db_live_port: int = 5432
    db_live_name: str = "expenses_db"
    db_live_user: str = "expenses_app"
    db_live_password: Optional[str] = None

    @model_validator(mode="after")
    def _live_must_use_the_runtime_role(self) -> "Settings":
        if (
            self.db_target is DatabaseTarget.LIVE
            and self.db_live_user != LIVE_ALLOWED_ROLE
        ):
            raise ValueError(
                f"EXPENSE_DB_LIVE_USER must be {LIVE_ALLOWED_ROLE!r} when "
                f"EXPENSE_DB_TARGET=live (got {self.db_live_user!r})."
            )
        return self

    @property
    def database(self) -> DatabaseConfig:
        """The active database configuration for the currently selected ``db_target``."""
        if self.db_target is DatabaseTarget.LIVE:
            return DatabaseConfig(
                host=self.db_live_host,
                port=self.db_live_port,
                name=self.db_live_name,
                user=self.db_live_user,
                password=self.db_live_password,
            )
        return DatabaseConfig(
            host=self.db_local_host,
            port=self.db_local_port,
            name=self.db_local_name,
            user=self.db_local_user,
            password=self.db_local_password,
        )


@lru_cache
def get_settings() -> Settings:
    return Settings()
