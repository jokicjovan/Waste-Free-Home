from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.db_config import get_postgres_db
from app.models import schemas
from app.models.schemas import Admin
from app.security.auth_service import get_user_dependency
from app.services import base_user_service, admin_service

admin_router = APIRouter()


@admin_router.get("/api/admins", tags=["Admins"], response_model=list[schemas.Admin])
def create_user(
        current_user: Annotated[Admin, Depends(get_user_dependency(["admin"]))],
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_postgres_db)):
    admins = admin_service.get_admins(db, skip=skip, limit=limit)
    return admins


@admin_router.post("/api/admins", tags=["Admins"], response_model=schemas.Admin)
def create_user(
        new_user: schemas.UserCreate,
        db: Session = Depends(get_postgres_db)):
    base_user = base_user_service.get_base_user_by_email(db, email=new_user.email)
    if base_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return admin_service.create_admin(db=db, user=new_user)
