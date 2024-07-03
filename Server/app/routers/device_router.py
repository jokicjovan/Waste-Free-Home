from typing import Annotated, Union
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.postgres import get_postgres_db
from app.db.timescale import get_timescale_db
from app.entities import schemas
from app.entities.enums import Role
from app.entities.schemas import RegularUser, Device
from app.core.authorization import user_dependency, device_dependency
from app.services import base_device_service

device_router = APIRouter()


@device_router.get("/api/devices", tags=["Devices"], response_model=list[schemas.Device])
def read_all_devices(current_user: Annotated[RegularUser, Depends(user_dependency([Role.ADMIN]))],
                     db: Session = Depends(get_postgres_db),
                     limit: int = 100,
                     skip: int = 0):
    devices = base_device_service.get_devices(db, skip=skip, limit=limit)
    return devices


@device_router.get("/api/devices/me", tags=["Devices"], response_model=list[schemas.Device])
def read_all_user_devices(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.REGULAR_USER]))],
        db: Session = Depends(get_postgres_db),
        skip: int = 0,
        limit: int = 100, ):
    devices = base_device_service.get_user_devices(db, skip=skip, limit=limit, user_id=current_user.id)
    return devices


@device_router.get("/api/devices/{device_id}", tags=["Devices"], response_model=schemas.Device)
def read_device(current_device: Annotated[Device, Depends(device_dependency)]):
    return current_device


@device_router.post("/api/devices/me", tags=["Devices"], response_model=schemas.Device)
def create_user_device(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.REGULAR_USER]))],
        device: schemas.DeviceCreate,
        db: Session = Depends(get_postgres_db)
):
    return base_device_service.create_user_device(db=db, device=device, user_id=current_user.id)


@device_router.post("/api/devices/{device_id}/records", tags=["Devices"],
                    response_model=Union[schemas.ThermometerRecord, schemas.WasteSorterWasteRecord])
def create_user_device(current_device: Annotated[Device, Depends(device_dependency)],
                       record_body: Union[schemas.ThermometerRecord, schemas.WasteSorterWasteRecord],
                       models_db: Session = Depends(get_postgres_db),
                       time_series_db: Session = Depends(get_timescale_db)):
    record = base_device_service.record_device_data(models_db, time_series_db, current_device.id, record_body)
    if record is None:
        raise HTTPException(status_code=400, detail="Bad request")
    return record
