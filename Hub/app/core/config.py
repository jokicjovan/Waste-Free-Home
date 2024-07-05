from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    hub_id: str
    mqtt_broker_address: str
    mqtt_broker_port: int
    devices_topic: str

    server_address: str
    server_port: int
    server_records_endpoint: str

    server_auth_endpoint: str
    user_email: str
    user_password: str

    jwt: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
