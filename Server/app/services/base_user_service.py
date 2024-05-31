from sqlalchemy.orm import Session

from app.models import models
from app.security.password_service import verify_password


def authenticate_base_user(db: Session, email: str, password: str):
    user = get_base_user_by_email(db, email)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def get_base_user_by_email(db: Session, email: str):
    return db.query(models.BaseUser).filter(models.User.email == email).first()
