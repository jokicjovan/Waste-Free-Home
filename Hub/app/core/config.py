from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    hub_id: str
    hub_hostname: str
    hub_port: int

    mqtt_broker_hostname: str
    mqtt_broker_port: int
    mqtt_username: str
    mqtt_password: str
    device_record_topic: str
    device_state_topic: str

    server_hostname: str
    server_port: int
    server_records_endpoint: str
    server_devices_endpoint: str

    server_auth_endpoint: str
    user_email: str
    user_password: str

    jwt: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
