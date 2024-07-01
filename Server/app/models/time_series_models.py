import time
from sqlalchemy import Column, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base

timescale_base = declarative_base()


class ThermometerRecord(timescale_base):
    __tablename__ = "thermometer_data"

    timestamp = Column(Float, primary_key=True, default=time.time(), nullable=False)
    device_id = Column(UUID(as_uuid=True), index=True, unique=False, nullable=False)
    temperature = Column(Float, nullable=False)

