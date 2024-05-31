from pydantic import BaseModel
from typing import Optional


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    email: Optional[str] = None


class DeviceBase(BaseModel):
    title: str
    description: str | None = None


class DeviceCreate(DeviceBase):
    pass


class Device(DeviceBase):
    id: int
    owner_id: int

    class Config:
        from_attributes = True


class UserBase(BaseModel):
    email: str


class UserCreate(UserBase):
    password: str


class User(UserBase):
    id: int
    is_active: bool
    role: str
    devices: list[Device] = []

    class Config:
        from_attributes = True


class Admin(UserBase):
    id: int
    is_active: bool
    role: str

    class Config:
        from_attributes = True
