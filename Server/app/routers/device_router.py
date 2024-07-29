import io
import os
from typing import Annotated, Optional
from uuid import UUID

from fastapi import APIRouter, HTTPException, Depends, UploadFile, Form
from sqlalchemy.orm import Session
from fastapi.responses import StreamingResponse, FileResponse

from app.core import utils
from app.core.validations import  validate_thumbnail
from app.db.postgres import get_postgres_db
from app.entities import schemas
from app.entities.enums import Role, DeviceType
from app.entities.schemas import RegularUser, Device, Admin
from app.core.authorization import user_dependency, device_dependency
from app.services import base_device_service, image_service

device_router = APIRouter()
device_router_root_path = "/API/devices"


@device_router.get(device_router_root_path, tags=["Devices"], response_model=list[schemas.Device])
async def read_all_devices(current_user: Annotated[RegularUser, Depends(user_dependency([Role.ADMIN]))],
                           db: Session = Depends(get_postgres_db),
                           limit: int = 100,
                           skip: int = 0):
    devices = base_device_service.get_devices(db, skip=skip, limit=limit)
    return devices


@device_router.get(device_router_root_path + "/me", tags=["Devices"], response_model=list[schemas.Device])
async def read_all_user_devices(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.REGULAR_USER]))],
        db: Session = Depends(get_postgres_db),
        skip: int = 0,
        limit: int = 100, ):
    devices = base_device_service.get_user_devices(db, skip=skip, limit=limit, user_id=current_user.id)
    return devices


@device_router.get(device_router_root_path + "/{device_id}", tags=["Devices"], response_model=schemas.Device)
async def read_device(current_device: Annotated[Device, Depends(device_dependency)]):
    return current_device


@device_router.put(device_router_root_path + "/{device_id}", tags=["Devices"], response_model=schemas.Device)
async def update_device(
        current_device: Annotated[Device, Depends(device_dependency)],
        device_schema: schemas.DeviceUpdate,
        db: Session = Depends(get_postgres_db)):
    return base_device_service.update_device(db=db, device_id=current_device.id, device_schema=device_schema)


@device_router.post(device_router_root_path + "/link/{device_id}", tags=["Devices"], response_model=schemas.Device)
async def link_with_device(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.REGULAR_USER]))],
        device_id: UUID,
        db: Session = Depends(get_postgres_db)
):
    device = base_device_service.link_device_to_user(db=db, device_id=device_id, user_id=current_user.id)
    if device is None:
        raise HTTPException(status_code=400, detail="Bad request")
    return device


@device_router.post(device_router_root_path, tags=["Devices"])
async def create_device(
        current_admin: Annotated[Admin, Depends(user_dependency([Role.ADMIN]))],
        title: str = Form(...),
        description: str = Form(...),
        type: DeviceType = Form(...),
        thumbnail: Optional[UploadFile] = Depends(validate_thumbnail),
        db: Session = Depends(get_postgres_db)
):
    device_schema = schemas.DeviceCreate(title=title, description=description, type=type)
    db_device = base_device_service.create_device(db=db, device_schema=device_schema)

    if thumbnail:
        await image_service.save_device_thumbnail(db_device.id, thumbnail)

    qr_code_img = utils.generate_qr_code(str(db_device.id))
    buf = io.BytesIO()
    qr_code_img.save(buf)
    buf.seek(0)

    return StreamingResponse(buf, media_type="image/png")


@device_router.get(device_router_root_path + "/{device_id}/thumbnail", tags=["Devices"],)
async def get_device_thumbnail(
        current_device: Annotated[Device, Depends(device_dependency)]
):
    thumbnail_path = image_service.get_device_thumbnail_path(current_device.id)
    print(thumbnail_path)
    if not os.path.exists(thumbnail_path):
        raise HTTPException(status_code=404, detail="Thumbnail not found")

    return FileResponse(thumbnail_path, media_type="image/png")
