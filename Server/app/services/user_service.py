from app.security.password_service import get_password_hash
from app.models import models, schemas
from sqlalchemy.orm import Session


def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(email=user.email, hashed_password=get_password_hash(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def get_user_devices(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.Device).filter(models.Device.owner_id == user_id).offset(skip).limit(limit).all()


def create_user_device(db: Session, device: schemas.DeviceCreate, user_id: int):
    db_device = models.Device(**device.dict(), owner_id=user_id)
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    return db_device
