from typing import Annotated

from fastapi import APIRouter
from datetime import timedelta
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.authorization import user_dependency
from app.core.config import settings
from app.db.postgres import get_postgres_db
from app.core.tokens import create_access_token
from app.entities.enums import Role
from app.entities.models import BaseUser
from app.services.base_user_service import authenticate_base_user
from app.entities.schemas import Token, Admin

auth_router = APIRouter()
auth_router_root_path = "/API/auth"


@auth_router.post(auth_router_root_path + "/token", tags=["Auth"], response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_postgres_db)):
    user = authenticate_base_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@auth_router.get(auth_router_root_path + "/validate_token", tags=["Auth"])
async def validate_token(current_user: Annotated[BaseUser, Depends(user_dependency([Role.ADMIN, Role.REGULAR_USER]))]):
    return "Success"
