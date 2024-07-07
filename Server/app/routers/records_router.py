from datetime import datetime
from typing import Union, Annotated, List, Optional, Dict
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from app.core.authorization import device_dependency
from app.db.postgres import get_postgres_db
from app.db.timescale import get_timescale_db
from app.entities.schemas import Device
from app.services import records_service

records_router = APIRouter()
records_router_root_path = "/API/records"

records_schemas = records_service.get_all_records_schemas()
records_response_model = Union[tuple(records_schemas)]
records_lists_response_model = Dict[
    str, Union[tuple({schema.__name__: List[schema] for schema in records_schemas}.values())]]


@records_router.post(records_router_root_path + "/{device_id}", tags=["Records"],
                     response_model=records_response_model)
async def create_device_records(current_device: Annotated[Device, Depends(device_dependency)],
                          record_body: records_response_model,
                          models_db: Session = Depends(get_postgres_db),
                          time_series_db: Session = Depends(get_timescale_db)):
    record = records_service.record_device_data(models_db, time_series_db, current_device.id, record_body)
    if record is None:
        raise HTTPException(status_code=400, detail="Bad request")
    return record


@records_router.get(records_router_root_path + "/{device_id}", tags=["Records"],
                    response_model=records_lists_response_model)
async def get_device_records(current_device: Annotated[Device, Depends(device_dependency)],
                       models_db: Session = Depends(get_postgres_db),
                       time_series_db: Session = Depends(get_timescale_db),
                       limit: int = 100,
                       skip: int = 0,
                       start_date: Optional[datetime] = None,
                       end_date: Optional[datetime] = None):
    records = records_service.get_device_records(
        models_db, time_series_db, current_device.id, skip=skip, limit=limit, start_date=start_date, end_date=end_date
    )
    if records is None:
        raise HTTPException(status_code=400, detail="Bad request")
    return records
