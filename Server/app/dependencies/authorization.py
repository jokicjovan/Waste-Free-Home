from typing import Annotated, List
from uuid import UUID
from fastapi import Depends, status, HTTPException
from jwt import InvalidTokenError
from sqlalchemy.orm import Session

from app.dependencies.database import get_regular_db
from app.entities.enums import Role
from app.entities.schemas import TokenData, RegularUser
from app.core.tokens import oauth2_scheme, decode_access_token
from app.services import base_device_service
from app.services.base_user_service import get_base_user_by_email


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)],
                           db: Annotated[Session, Depends(get_regular_db)]):
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


async def get_current_active_user(current_user: Annotated[RegularUser, Depends(get_current_user)]):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


def user_dependency(required_roles: List[Role]):
    def role_checker(
            current_user: Annotated[RegularUser, Depends(get_current_active_user)]
    ):
        if current_user.role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have the necessary permissions",
            )
        return current_user

    return role_checker


def device_dependency(device_id: UUID,
                      current_user: Annotated[RegularUser, Depends(get_current_active_user)],
                      db: Session = Depends(get_regular_db)):
    device = base_device_service.get_device(db, device_id)
    if device is None or device.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found",
        )
    return device
