from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "Expense Manager Backend"
    debug: bool = False
    
    # Database
    database_url: str
    db_pool_size: int = 5
    db_max_overflow: int = 10
    
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

def get_settings() -> Settings:
    return Settings()
