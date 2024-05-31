from typing import Annotated, List
from fastapi import Depends, status, HTTPException
from jwt import InvalidTokenError
from sqlalchemy.orm import Session

from app.database.db_config import get_db
from app.models.schemas import TokenData, User
from app.security.token_service import oauth2_scheme, decode_access_token
from app.services.base_user_service import get_base_user_by_email


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)], db: Annotated[Session, Depends(get_db)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
        if payload is None:
            raise credentials_exception
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
        token_data = TokenData(email=email)
    except InvalidTokenError:
        raise credentials_exception
    user = get_base_user_by_email(db, token_data.email)
    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(current_user: Annotated[User, Depends(get_current_user)]):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


def get_current_active_user_with_roles(required_roles: List[str]):
    def role_checker(
            current_user: Annotated[User, Depends(get_current_active_user)]
    ):
        if current_user.role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have the necessary permissions",
            )
        return current_user

    return role_checker
