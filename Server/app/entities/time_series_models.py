from sqlalchemy import Column, Float, Enum, TIMESTAMP, func, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base

from app.entities.enums import WasteType

timescale_base = declarative_base()


class ThermoHumidMeterRecord(timescale_base):
    __tablename__ = "thermo_humid_meter"

    timestamp = Column(TIMESTAMP, primary_key=True, server_default=func.now())
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    temperature = Column(Float, nullable=False)
    humidity = Column(Float, nullable=False)


class WasteSorterRecycleRecord(timescale_base):
    __tablename__ = "waste_sorter_recycle"

    timestamp = Column(TIMESTAMP, primary_key=True, server_default=func.now())
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    waste_type = Column(Enum(WasteType), nullable=False)


class WasteSorterLevelRecord(timescale_base):
    __tablename__ = "waste_sorter_level"

    timestamp = Column(TIMESTAMP, primary_key=True, server_default=func.now())
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    recyclable_level = Column(Float, nullable=False)
    non_recyclable_level = Column(Float, nullable=False)

    __table_args__ = (
        CheckConstraint('recyclable_level >= 0.0 AND recyclable_level <= 100.0', name='waste_recyclable_level_range'),
        CheckConstraint('non_recyclable_level >= 0.0 AND non_recyclable_level <= 100.0',
                        name='waste_non_recyclable_level_range'),
    )
