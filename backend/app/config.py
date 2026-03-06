"""
Application settings loaded from .env
"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql+asyncpg://mathquest:password@localhost:5432/mathquest_db"
    SECRET_KEY: str = "change-me-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    OPENAI_API_KEY: str = ""
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://10.0.2.2:8000"]

    class Config:
        env_file = ".env"


settings = Settings()
