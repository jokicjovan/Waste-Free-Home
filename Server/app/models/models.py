import uuid

from sqlalchemy import Boolean, Column, ForeignKey, String, Enum, UUID
from sqlalchemy.orm import relationship, declarative_base

from app.models.enums import DeviceType, Role

postgres_base = declarative_base()


class BaseUser(postgres_base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    role = Column(Enum(Role), nullable=False)
    __mapper_args__ = {
        'polymorphic_on': role
    }


class User(BaseUser):
    __mapper_args__ = {
        'polymorphic_identity': 'USER'
    }
    devices = relationship("BaseDevice", back_populates="owner")


class Admin(BaseUser):
    __mapper_args__ = {
        'polymorphic_identity': 'ADMIN'
    }


class BaseDevice(postgres_base):
    __tablename__ = "devices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, nullable=False)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    owner = relationship("User", back_populates="devices")

    type = Column(Enum(DeviceType), nullable=False)
    __mapper_args__ = {
        'polymorphic_on': type
    }


class Thermometer(BaseDevice):
    __mapper_args__ = {
        'polymorphic_identity': 'THERMOMETER'
    }


class WasteSorter(BaseDevice):
    __mapper_args__ = {
        'polymorphic_identity': 'WASTE_SORTER'
    }
