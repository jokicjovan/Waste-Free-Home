from uuid import UUID
from pydantic import BaseModel

from app.models.enums import DeviceType, Role


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    email: str | None = None


class DeviceBase(BaseModel):
    title: str
    description: str = ""
    type: DeviceType


class DeviceCreate(DeviceBase):
    pass


class Device(DeviceBase):
    id: UUID
    owner_id: UUID

    class Config:
        from_attributes = True


class UserBase(BaseModel):
    id: UUID
    email: str
    is_active: bool
    role: Role


class UserCreate(BaseModel):
    email: str
    password: str


class User(UserBase):
    devices: list[Device] = []

    class Config:
        from_attributes = True


class Admin(UserBase):

    class Config:
        from_attributes = True
