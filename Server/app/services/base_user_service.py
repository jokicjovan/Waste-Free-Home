from sqlalchemy.orm import Session

from app.entities import models
from app.core.passwords import verify_password


def authenticate_base_user(db: Session, email: str, password: str):
    user = get_base_user_by_email(db, email)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def get_base_user_by_email(db: Session, email: str):
    return db.query(models.BaseUser).filter(models.BaseUser.email == email).first()
