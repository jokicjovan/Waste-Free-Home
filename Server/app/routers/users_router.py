from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.db_context import get_db
from app.models import schemas
from app.models.models import User
from app.security.token import get_current_active_user
from app.services import user_service

usersRouter = APIRouter()


@usersRouter.get("/users/", tags=["Users"], response_model=list[schemas.User])
def read_users(
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_db)):
    users = user_service.get_users(db, skip=skip, limit=limit)
    return users


@usersRouter.get("/users/me", tags=["Users"], response_model=schemas.User)
def read_user(
        current_user: Annotated[User, Depends(get_current_active_user)],
        db: Session = Depends(get_db)):
    db_user = user_service.get_user(db, user_id=current_user.id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


@usersRouter.post("/users/", tags=["Users"], response_model=schemas.User)
def create_user(
        user: schemas.UserCreate,
        db: Session = Depends(get_db)):
    db_user = user_service.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return user_service.create_user(db=db, user=user)


@usersRouter.get("/users/devices/me", tags=["Users"], response_model=list[schemas.Device])
def read_devices(
        current_user: Annotated[User, Depends(get_current_active_user)],
        db: Session = Depends(get_db),
        skip: int = 0,
        limit: int = 100, ):
    devices = user_service.get_user_devices(db, skip=skip, limit=limit, user_id=current_user.id)
    return devices


@usersRouter.post("/users/devices/", tags=["Users"], response_model=schemas.Device)
def create_device_for_user(
        device: schemas.DeviceCreate,
        current_user: Annotated[User, Depends(get_current_active_user)],
        db: Session = Depends(get_db)
):
    return user_service.create_user_device(db=db, device=device, user_id=current_user.id)
