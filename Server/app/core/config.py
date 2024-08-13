import logging
import secrets
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = secrets.token_urlsafe(32)
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    devices_thumbnails_path: str = "static/devices/thumbnails/"

    regular_database_url: str
    time_series_database_url: str

    class Config:
        env_file = ".env"


settings = Settings()
logging.getLogger('passlib').setLevel(logging.ERROR)
