from fastapi import FastAPI

from app.routers.admin_router import admin_router
from app.routers.auth_router import auth_router
from app.routers.device_router import device_router
from app.routers.user_router import user_router

app = FastAPI()
app.include_router(auth_router)
app.include_router(admin_router)
app.include_router(user_router)
app.include_router(device_router)
