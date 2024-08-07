from uuid import UUID
from sqlalchemy.orm import Session

from app.entities import schemas, models
from app.core.passwords import get_password_hash


def get_user(db: Session, user_id: UUID):
    return db.query(models.RegularUser).filter(models.RegularUser.id == user_id).first()


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.RegularUser).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.RegularUser(email=user.email, hashed_password=get_password_hash(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
