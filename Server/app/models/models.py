import uuid

from sqlalchemy import Boolean, Column, ForeignKey, String, Enum, UUID
from sqlalchemy.orm import relationship

from app.databases.postgres_config import Base, postgres_engine
from app.models.enums import DeviceType, Role


class BaseUser(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

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


class BaseDevice(Base):
    __tablename__ = "devices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, index=True)
    description = Column(String, index=True)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
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


Base.metadata.create_all(bind=postgres_engine)
