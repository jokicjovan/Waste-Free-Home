from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.db_config import get_db
from app.models import schemas
from app.models.schemas import Admin
from app.security.auth_service import get_current_active_user_with_roles
from app.services import base_user_service, admin_service

admin_router = APIRouter()
route_base = "/api/admins"


@admin_router.get(route_base, tags=["Admins"], response_model=list[schemas.Admin])
def create_user(
        current_user: Annotated[Admin, Depends(get_current_active_user_with_roles(["admin"]))],
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_db)):
    admins = admin_service.get_admins(db, skip=skip, limit=limit)
    return admins


@admin_router.post(route_base + "/create", tags=["Admins"], response_model=schemas.Admin)
def create_user(
        new_user: schemas.UserCreate,
        db: Session = Depends(get_db)):
    base_user = base_user_service.get_base_user_by_email(db, email=new_user.email)
    if base_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return admin_service.create_admin(db=db, user=new_user)
