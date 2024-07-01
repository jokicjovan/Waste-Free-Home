from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.databases.postgres_config import get_postgres_db
from app.models import schemas
from app.models.enums import Role
from app.models.models import User
from app.security.authorization import get_user_dependency
from app.services import user_service, base_user_service

user_router = APIRouter()


@user_router.get("/api/users", tags=["Users"], response_model=list[schemas.User])
def read_all_users(
        current_user: Annotated[User, Depends(get_user_dependency([Role.ADMIN]))],
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_postgres_db)):
    users = user_service.get_users(db, skip=skip, limit=limit)
    return users


@user_router.post("/api/users", tags=["Users"], response_model=schemas.User)
def create_user(
        new_user: schemas.UserCreate,
        db: Session = Depends(get_postgres_db)):
    user = base_user_service.get_base_user_by_email(db, email=new_user.email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return user_service.create_user(db=db, user=new_user)


@user_router.get("/api/users/me", tags=["Users"], response_model=schemas.User)
def read_my_info(
        current_user: Annotated[User, Depends(get_user_dependency([Role.USER]))],
        db: Session = Depends(get_postgres_db)):
    user = user_service.get_user(db, user_id=current_user.id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
