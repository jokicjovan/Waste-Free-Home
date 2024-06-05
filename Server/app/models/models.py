from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.database.db_config import Base, postgres_engine


class BaseUser(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

    role = Column(String)
    __mapper_args__ = {
        'polymorphic_on': role
    }


class User(BaseUser):
    __mapper_args__ = {
        'polymorphic_identity': 'user'
    }

    devices = relationship("Device", back_populates="owner")


class Admin(BaseUser):
    __mapper_args__ = {
        'polymorphic_identity': 'admin'
    }


class Device(Base):
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True)
    title = Column(String, index=True)
    description = Column(String, index=True)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="devices")


Base.metadata.create_all(bind=postgres_engine)
