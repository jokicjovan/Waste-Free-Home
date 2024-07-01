from uuid import UUID

from app.models.enums import DeviceType
from app.security.passwords import get_password_hash
from app.models import models, schemas
from sqlalchemy.orm import Session


def get_user(db: Session, user_id: UUID):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(email=user.email, hashed_password=get_password_hash(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def get_user_devices(db: Session, user_id: UUID, skip: int = 0, limit: int = 100):
    return db.query(models.BaseDevice).filter(models.BaseDevice.owner_id == user_id).offset(skip).limit(limit).all()


def create_user_device(db: Session, device: schemas.DeviceCreate, user_id: UUID):
    if device.type == DeviceType.THERMOMETER:
        db_device = models.Thermometer(owner_id=user_id, **device.model_dump(exclude={'type'}))
    elif device.type == DeviceType.WASTE_SORTER:
        db_device = models.WasteSorter(owner_id=user_id, **device.model_dump(exclude={'type'}))
    else:
        return None
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    return db_device
