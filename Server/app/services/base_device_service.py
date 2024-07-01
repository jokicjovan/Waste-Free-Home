from uuid import UUID

from sqlalchemy.orm import Session

from app.models import models


def get_device(db: Session, device_id: UUID):
    return db.query(models.BaseDevice).filter(models.BaseDevice.id == device_id).first()


def get_devices(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.BaseDevice).offset(skip).limit(limit).all()
