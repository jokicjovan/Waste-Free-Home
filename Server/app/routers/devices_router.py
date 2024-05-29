from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.db_context import get_db
from app.models import schemas
from app.services import device_service

devicesRouter = APIRouter()


@devicesRouter.get("/devices/", tags=["Users"], response_model=list[schemas.Device])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    devices = device_service.get_devices(db, skip=skip, limit=limit)
    return devices
