from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from starlette import status

from app.database.db_config import get_db
from app.models import schemas
from app.models.schemas import User
from app.security.auth_service import get_current_active_user_with_roles
from app.services import device_service, user_service

device_router = APIRouter()
route_base = "/api/devices"


@device_router.get(route_base, tags=["Devices"], response_model=list[schemas.Device])
def read_users(current_user: Annotated[User, Depends(get_current_active_user_with_roles(["admin"]))],
               db: Session = Depends(get_db),
               limit: int = 100,
               skip: int = 0):
    devices = device_service.get_devices(db, skip=skip, limit=limit)
    return devices


@device_router.get(route_base + "/me", tags=["Devices"], response_model=list[schemas.Device])
def read_devices(
        current_user: Annotated[User, Depends(get_current_active_user_with_roles(["user"]))],
        db: Session = Depends(get_db),
        skip: int = 0,
        limit: int = 100, ):
    devices = user_service.get_user_devices(db, skip=skip, limit=limit, user_id=current_user.id)
    return devices


@device_router.get(route_base + "/me/{device_id}", tags=["Devices"], response_model=schemas.Device)
def read_users(device_id: int,
               current_user: Annotated[User, Depends(get_current_active_user_with_roles(["user"]))],
               db: Session = Depends(get_db)):
    device = device_service.get_device(db, device_id)
    if device is None or device.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found",
        )
    return device


@device_router.post("/devices/create", tags=["Devices"], response_model=schemas.Device)
def create_device_for_user(
        current_user: Annotated[User, Depends(get_current_active_user_with_roles(["user"]))],
        device: schemas.DeviceCreate,
        db: Session = Depends(get_db)
):
    return user_service.create_user_device(db=db, device=device, user_id=current_user.id)
