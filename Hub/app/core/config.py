from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    hub_id: str
    hub_hostname: str
    http_port: int
    mqtt_broker_port: int
    mqtt_username: str
    mqtt_password: str
    device_record_topic: str = "device/+/record"
    device_state_topic: str = "device/+/state"

    server_hostname: str
    server_port: int
    server_records_endpoint: str = "API/records"
    server_devices_endpoint: str = "API/devices"

    server_auth_endpoint: str = "API/auth"
    user_email: str
    user_password: str

    jwt: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
