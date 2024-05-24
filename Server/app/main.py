from fastapi import FastAPI

from app.routers.auth_router import authRouter
from app.routers.users_router import usersRouter


app = FastAPI()
app.include_router(authRouter)
app.include_router(usersRouter)
