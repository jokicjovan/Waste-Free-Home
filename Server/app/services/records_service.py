from typing import Optional
from uuid import UUID
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.entities import schemas, time_series_models
from app.entities.enums import DeviceType
from app.services import base_device_service

schema_model_map = {
    DeviceType.THERMOMETER: {
        'temperature': (schemas.ThermometerRecord, time_series_models.ThermometerRecord)
    },
    DeviceType.WASTE_SORTER: {
        'waste_type': (schemas.WasteSorterRecycleRecord, time_series_models.WasteSorterRecycleRecord),
        'level': (schemas.WasteSorterLevelRecord, time_series_models.WasteSorterLevelRecord)
    }
}


def get_all_records_schemas():
    all_schemas = set()
    for device_type_map in schema_model_map.values():
        for schema_tuple in device_type_map.values():
            all_schemas.add(schema_tuple[0])
    return all_schemas


def record_device_data(
        models_db: Session,
        time_series_db: Session,
        device_id: UUID,
        record):
    device = base_device_service.get_device(models_db, device_id)

    if device.type not in schema_model_map:
        return None

    for attr, (schema, model_class) in schema_model_map[device.type].items():
        if hasattr(record, attr):
            try:
                schema_instance = schema(**record.model_dump(exclude={'timestamp'}))
                model_instance = model_class(device_id=device_id, **schema_instance.model_dump())
                time_series_db.add(model_instance)
                time_series_db.commit()
                time_series_db.refresh(model_instance)
                return model_instance
            except ValidationError as e:
                return None

    return None


def get_device_records(
        models_db: Session,
        time_series_db: Session,
        device_id: UUID,
        skip: int = 0,
        limit: int = 100,
        start_date: Optional[float] = None,
        end_date: Optional[float] = None):
    device = base_device_service.get_device(models_db, device_id)

    if device.type not in schema_model_map:
        return None

    records = {}

    for key, (_, model_class) in schema_model_map[device.type].items():
        query = time_series_db.query(model_class).filter(model_class.device_id == device_id)
        if start_date:
            query = query.filter(model_class.timestamp >= start_date)
        if end_date:
            query = query.filter(model_class.timestamp <= end_date)
        records[key] = query.offset(skip).limit(limit).all()

    return records
