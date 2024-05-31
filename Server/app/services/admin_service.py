from sqlalchemy.orm import Session

from app.models import schemas, models
from app.security.password_service import get_password_hash


def get_admin(db: Session, admin_id: int):
    return db.query(models.Admin).filter(models.Admin.id == admin_id).first()


def get_admins(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Admin).offset(skip).limit(limit).all()


def create_admin(db: Session, user: schemas.UserCreate):
    db_user = models.Admin(email=user.email, hashed_password=get_password_hash(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
