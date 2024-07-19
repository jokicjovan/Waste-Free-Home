from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.entities.schemas import UserCredentials
from app.core.config import settings
from app.core.utils import update_env_file, get_jwt
from app.core.mqtt_handler import mqtt_client, on_connect, on_message


@asynccontextmanager
async def lifespan(app: FastAPI):
    get_jwt()
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.connect(settings.mqtt_broker_address, settings.mqtt_broker_port, 60)
    mqtt_client.loop_start()
    yield


app = FastAPI(lifespan=lifespan)


@app.get("/API/health")
async def health_check():
    return {"status": "ok"}


@app.put("/API/update-credentials")
async def update_credentials(credentials: UserCredentials):
    settings.user_email = credentials.email
    settings.user_password = credentials.password
    update_env_file("user_email", credentials.email)
    update_env_file("user_password", credentials.password)
    return "Success"
