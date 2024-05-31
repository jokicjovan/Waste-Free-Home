from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.db_config import get_db
from app.models import schemas
from app.models.models import User
from app.security.auth_service import get_current_active_user_with_roles
from app.services import user_service, base_user_service

user_router = APIRouter()
route_base = "/api/users"


@user_router.get(route_base, tags=["Users"], response_model=list[schemas.User])
def read_users(
        current_user: Annotated[User, Depends(get_current_active_user_with_roles(["admin"]))],
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_db)):
    users = user_service.get_users(db, skip=skip, limit=limit)
    return users


@user_router.get(route_base + "/me", tags=["Users"], response_model=schemas.User)
def read_user(
        current_user: Annotated[User, Depends(get_current_active_user_with_roles(["user"]))],
        db: Session = Depends(get_db)):
    user = user_service.get_user(db, user_id=current_user.id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@user_router.post(route_base + "/create", tags=["Users"], response_model=schemas.User)
def create_user(
        new_user: schemas.UserCreate,
        db: Session = Depends(get_db)):
    user = base_user_service.get_base_user_by_email(db, email=new_user.email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return user_service.create_user(db=db, user=new_user)
