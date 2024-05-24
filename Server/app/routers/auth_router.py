from fastapi import APIRouter
from datetime import timedelta
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.server_config import settings
from app.database.db_context import get_db
from app.security.token import create_access_token
from app.services.user_service import authenticate_user
from app.models.schemas import Token

authRouter = APIRouter()


@authRouter.post("/login", tags=["Auth"], response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
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
