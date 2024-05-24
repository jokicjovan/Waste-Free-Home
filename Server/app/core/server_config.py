import logging
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = "YOUR_SECRET_KEY"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30


settings = Settings()
logging.getLogger('passlib').setLevel(logging.ERROR)
