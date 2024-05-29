import logging
import secrets
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = secrets.token_urlsafe(32)
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30


settings = Settings()
logging.getLogger('passlib').setLevel(logging.ERROR)
