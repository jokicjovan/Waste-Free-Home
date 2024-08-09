import datetime
from typing import Optional
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
    description: str


class DeviceCreate(DeviceBase):
    type: DeviceType


class DeviceUpdate(DeviceBase):
    pass


class Device(DeviceBase):
    id: UUID
    owner_id: Optional[UUID] = None
    type: DeviceType
    is_online: bool
    linked_timestamp: Optional[datetime.datetime] = None

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


class ThermoHumidMeterRecord(BaseRecord):
    temperature: float
    humidity: float

    class Config:
        use_enum_values = True


class WasteSorterRecycleRecord(BaseRecord):
    waste_type: WasteType

    class Config:
        use_enum_values = True


class WasteSorterLevelRecord(BaseRecord):
    recyclable_level: float
    non_recyclable_level: float

    class Config:
        use_enum_values = True
