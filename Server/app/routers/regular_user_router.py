from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.postgres import get_postgres_db
from app.entities import schemas
from app.entities.enums import Role
from app.entities.models import RegularUser
from app.core.authorization import user_dependency
from app.services import regular_user_service, base_user_service

regular_user_router = APIRouter()
regular_user_router_root_path = "/API/users"


@regular_user_router.get(regular_user_router_root_path, tags=["Users"], response_model=list[schemas.RegularUser])
async def read_all_users(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.ADMIN]))],
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_postgres_db)):
    users = regular_user_service.get_users(db, skip=skip, limit=limit)
    return users


@regular_user_router.post(regular_user_router_root_path, tags=["Users"], response_model=schemas.RegularUser)
async def create_user(
        new_user: schemas.UserCreate,
        db: Session = Depends(get_postgres_db)):
    user = base_user_service.get_base_user_by_email(db, email=new_user.email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return regular_user_service.create_user(db=db, user=new_user)


@regular_user_router.get(regular_user_router_root_path + "/me", tags=["Users"], response_model=schemas.RegularUser)
async def read_my_info(
        current_user: Annotated[RegularUser, Depends(user_dependency([Role.REGULAR_USER]))],
        db: Session = Depends(get_postgres_db)):
    user = regular_user_service.get_user(db, user_id=current_user.id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
