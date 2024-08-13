from uuid import UUID

from sqlalchemy import desc
from sqlalchemy.orm import Session

from app.entities import schemas, models
from app.entities.enums import DeviceType

model_mapping = {
    DeviceType.THERMO_HUMID_METER: models.ThermoHumidMeter,
    DeviceType.WASTE_SORTER: models.WasteSorter
}


def get_device(db: Session, device_id: UUID):
    return (db.query(models.BaseDevice)
            .filter(models.BaseDevice.id == device_id)
            .first())


def get_devices(db: Session, skip: int = 0, limit: int = 100):
    return (db.query(models.BaseDevice)
            .offset(skip)
            .limit(limit).all())


def get_unlinked_devices(db: Session, skip: int = 0, limit: int = 100):
    return (db.query(models.BaseDevice)
            .filter(models.BaseDevice.owner_id == None)
            .offset(skip)
            .limit(limit).all())


def get_user_devices(db: Session, user_id: UUID, skip: int = 0, limit: int = 100):
    return (db.query(models.BaseDevice)
            .filter(models.BaseDevice.owner_id == user_id)
            .order_by(desc(models.BaseDevice.linked_timestamp))
            .offset(skip)
            .limit(limit)
            .all())


def link_device_to_user(db: Session, device_id: UUID, user_id: UUID):
    db_device = get_device(db, device_id)
    if db_device.owner_id:
        return None
    db_device.owner_id = user_id
    db.commit()
    db.refresh(db_device)
    return db_device


def create_device(db: Session, device_schema: schemas.DeviceCreate):
    model_class = model_mapping.get(device_schema.type)
    if not model_class:
        return None
    db_device = model_class(**device_schema.model_dump(exclude={'type'}))
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    return db_device


def update_device(db: Session, device_id: UUID, device_schema: schemas.DeviceUpdate):
    db_device = get_device(db, device_id)
    db_device.title = device_schema.title
    db_device.description = device_schema.description
    db.commit()
    db.refresh(db_device)
    return db_device


def toggle_device(db: Session, device_id: UUID, is_online: bool):
    db_device = get_device(db, device_id)
    db_device.is_online = is_online
    db.commit()
    db.refresh(db_device)
    return db_device
