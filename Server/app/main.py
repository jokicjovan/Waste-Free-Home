from fastapi import FastAPI

from app.routers.admin_router import admin_router
from app.routers.auth_router import auth_router
from app.routers.device_router import device_router
from app.routers.records_router import records_router
from app.routers.regular_user_router import regular_user_router

app = FastAPI()
app.include_router(auth_router)
app.include_router(admin_router)
app.include_router(regular_user_router)
app.include_router(device_router)
app.include_router(records_router)
