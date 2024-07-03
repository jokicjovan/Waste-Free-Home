from uuid import UUID

from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.entities import schemas, models, time_series_models
from app.entities.enums import DeviceType


def get_device(db: Session, device_id: UUID):
    return db.query(models.BaseDevice).filter(models.BaseDevice.id == device_id).first()


def get_devices(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.BaseDevice).offset(skip).limit(limit).all()


def get_user_devices(db: Session, user_id: UUID, skip: int = 0, limit: int = 100):
    return db.query(models.BaseDevice).filter(models.BaseDevice.owner_id == user_id).offset(skip).limit(limit).all()


def create_user_device(db: Session, device: schemas.DeviceCreate, user_id: UUID):
    if device.type == DeviceType.THERMOMETER:
        model_class = models.Thermometer
    elif device.type == DeviceType.WASTE_SORTER:
        model_class = models.WasteSorter
    else:
        return None
    db_device = model_class(owner_id=user_id, **device.model_dump(exclude={'type'}))
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    return db_device


def record_device_data(models_db: Session, time_series_db: Session, device_id: UUID, record_body):
    device = get_device(models_db, device_id)
    if device.type == DeviceType.THERMOMETER:
        schema = schemas.ThermometerRecord
        model_class = time_series_models.ThermometerRecord
    elif device.type == DeviceType.WASTE_SORTER:
        schema = schemas.WasteSorterWasteRecord
        model_class = time_series_models.WasteSorterWasteRecord
    else:
        return None

    try:
        schema_instance = schema(**record_body.model_dump())
    except ValidationError as e:
        return None

    record = model_class(device_id=device_id, **schema_instance.model_dump())
    time_series_db.add(record)
    time_series_db.commit()
    time_series_db.refresh(record)
    return record
