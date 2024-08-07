import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI

from app.core.MDNS_service import MDNSService
from app.entities.schemas import UserCredentials
from app.core.config import settings
from app.core.utils import update_env_file, get_jwt
from app.core.mqtt_handler import mqtt_client, on_connect, on_message


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize JWT and MQTT client
    get_jwt()
    mqtt_client.username_pw_set(settings.mqtt_username, settings.mqtt_password)
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.connect(host=settings.mqtt_broker_hostname, port=settings.mqtt_broker_port, keepalive=60)
    mqtt_client.loop_start()

    # Initialize mDNS service
    loop = asyncio.get_event_loop()
    mdns_service = await loop.run_in_executor(None, MDNSService)
    try:
        yield
    finally:
        # Cleanup resources
        await loop.run_in_executor(None, mdns_service.close)
        mqtt_client.loop_stop()
        mqtt_client.disconnect()


# Create FastAPI app with custom lifespan
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
    return {"message": "Success"}
