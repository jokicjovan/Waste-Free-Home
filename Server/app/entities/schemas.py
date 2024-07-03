import datetime
from uuid import UUID
from pydantic import BaseModel

from app.entities.enums import DeviceType, Role, WasteType


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


class RegularUser(UserBase):
    devices: list[Device] = []

    class Config:
        from_attributes = True


class Admin(UserBase):
    class Config:
        from_attributes = True


class BaseRecord(BaseModel):
    timestamp: datetime.datetime | None = None


class ThermometerRecord(BaseRecord):
    temperature: float


class WasteSorterRecycleRecord(BaseRecord):
    waste_type: WasteType


class WasteSorterLevelRecord(BaseRecord):
    level: float
