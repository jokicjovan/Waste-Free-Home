from sqlalchemy import Column, Float, Enum, TIMESTAMP, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base

from app.entities.enums import WasteType

timescale_base = declarative_base()


class ThermometerRecord(timescale_base):
    __tablename__ = "thermometer"

    timestamp = Column(TIMESTAMP, primary_key=True, server_default=func.now())
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    temperature = Column(Float, nullable=False)


class WasteSorterWasteRecord(timescale_base):
    __tablename__ = "waste_sorter_waste"

    timestamp = Column(TIMESTAMP, primary_key=True, server_default=func.now())
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    waste_type = Column(Enum(WasteType), nullable=False)
