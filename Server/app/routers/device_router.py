from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.databases.postgres import get_postgres_db
from app.databases.timescale import get_timescale_db
from app.models import schemas
from app.models.enums import Role
from app.models.schemas import User, Device
from app.security.authorization import user_dependency, device_dependency
from app.services import base_device_service, user_service

device_router = APIRouter()


@device_router.get("/api/devices", tags=["Devices"], response_model=list[schemas.Device])
def read_all_devices(current_user: Annotated[User, Depends(user_dependency([Role.ADMIN]))],
                     db: Session = Depends(get_postgres_db),
                     limit: int = 100,
                     skip: int = 0):
    devices = base_device_service.get_devices(db, skip=skip, limit=limit)
    return devices


@device_router.get("/api/devices/me", tags=["Devices"], response_model=list[schemas.Device])
def read_all_user_devices(
        current_user: Annotated[User, Depends(user_dependency([Role.USER]))],
        db: Session = Depends(get_postgres_db),
        skip: int = 0,
        limit: int = 100, ):
    devices = user_service.get_user_devices(db, skip=skip, limit=limit, user_id=current_user.id)
    return devices


@device_router.get("/api/devices/{device_id}", tags=["Devices"], response_model=schemas.Device)
def read_device(current_device: Annotated[Device, Depends(device_dependency)],
                db: Session = Depends(get_timescale_db)):
    return current_device


@device_router.post("/api/devices/me", tags=["Devices"], response_model=schemas.Device)
def create_user_device(
        current_user: Annotated[User, Depends(user_dependency([Role.USER]))],
        device: schemas.DeviceCreate,
        db: Session = Depends(get_postgres_db)
):
    return user_service.create_user_device(db=db, device=device, user_id=current_user.id)
