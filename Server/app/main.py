from fastapi import FastAPI

from app.routers.auth_router import authRouter
from app.routers.devices_router import devicesRouter
from app.routers.users_router import usersRouter


app = FastAPI()
app.include_router(authRouter)
app.include_router(usersRouter)
app.include_router(devicesRouter)
