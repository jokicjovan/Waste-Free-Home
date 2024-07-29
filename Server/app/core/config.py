import logging
import secrets
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = secrets.token_urlsafe(32)
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    postgres_user: str
    postgres_password: str
    postgres_host: str
    postgres_port: str
    postgres_name: str

    timescale_user: str
    timescale_password: str
    timescale_host: str
    timescale_port: str
    timescale_name: str

    devices_thumbnails_path: str

    class Config:
        env_file = ".env"


settings = Settings()
logging.getLogger('passlib').setLevel(logging.ERROR)
