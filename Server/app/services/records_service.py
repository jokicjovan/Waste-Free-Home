from typing import Optional
from uuid import UUID
from sqlalchemy.orm import Session

from app.core.utils import camelcase_to_snakecase
from app.entities import schemas, time_series_models
from app.entities.enums import DeviceType
from app.services import base_device_service

schema_model_map = {
    DeviceType.THERMO_HUMID_METER: {
        schemas.ThermoHumidMeterRecord: time_series_models.ThermoHumidMeterRecord
    },
    DeviceType.WASTE_SORTER: {
        schemas.WasteSorterRecycleRecord: time_series_models.WasteSorterRecycleRecord,
        schemas.WasteSorterLevelRecord: time_series_models.WasteSorterLevelRecord
    }
}


def get_all_records_schemas():
    all_schemas = set()
    for device_type_map in schema_model_map.values():
        all_schemas.update(device_type_map.keys())
    return all_schemas


async def record_device_data(
        models_db: Session,
        time_series_db: Session,
        device_id: UUID,
        record):
    device = base_device_service.get_device(models_db, device_id)

    model_map = schema_model_map.get(device.type)
    if model_map is None:
        return None
    model_class = model_map.get(record.__class__)
    if model_class is None:
        return None

    model_instance = model_class(device_id=device_id, **record.model_dump(exclude={'timestamp'}))
    time_series_db.add(model_instance)
    time_series_db.commit()
    time_series_db.refresh(model_instance)
    return model_instance


def get_device_records(
        models_db: Session,
        time_series_db: Session,
        device_id: UUID,
        skip: int = 0,
        limit: int = 100,
        start_date: Optional[float] = None,
        end_date: Optional[float] = None):
    device = base_device_service.get_device(models_db, device_id)

    records = {}
    for record_model in schema_model_map[device.type].values():
        query = time_series_db.query(record_model).filter(record_model.device_id == device_id)
        if start_date:
            query = query.filter(record_model.timestamp >= start_date)
        if end_date:
            query = query.filter(record_model.timestamp <= end_date)
        records[camelcase_to_snakecase(record_model.__name__)] = query.offset(skip).limit(limit).all()

    return records
