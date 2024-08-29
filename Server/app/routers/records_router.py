import uuid
from datetime import datetime
from typing import Union, Annotated, List, Optional, Dict
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from fastapi.websockets import WebSocket, WebSocketDisconnect

from app.dependencies.authorization import device_dependency, get_current_user, get_current_active_user
from app.core.websockets import records_ws_manager
from app.dependencies.database import get_regular_db, get_time_series_db
from app.entities.schemas import Device
from app.services import records_service

records_router = APIRouter()
records_router_root_path = "/API/records"

records_schemas = records_service.get_all_records_schemas()
records_response_model = Union[tuple(records_schemas)]
records_lists_response_model = Dict[str, Union[tuple(List[schema] for schema in records_schemas)]]


@records_router.post(records_router_root_path + "/{device_id}", tags=["Records"],
                     response_model=records_response_model)
async def create_device_records(current_device: Annotated[Device, Depends(device_dependency)],
                                record: records_response_model,
                                models_db: Session = Depends(get_regular_db),
                                time_series_db: Session = Depends(get_time_series_db)):
    db_record = await records_service.record_device_data(models_db, time_series_db, current_device.id, record)
    if db_record is None:
        raise HTTPException(status_code=400, detail="Bad request")

    ws_message = record.__class__(**db_record.__dict__).model_dump()
    ws_message['timestamp'] = ws_message['timestamp'].isoformat()
    await records_ws_manager.broadcast(current_device.id, str(ws_message))
    return db_record


@records_router.get(records_router_root_path + "/{device_id}", tags=["Records"],
                    response_model=records_lists_response_model)
async def get_device_records(current_device: Annotated[Device, Depends(device_dependency)],
                             models_db: Session = Depends(get_regular_db),
                             time_series_db: Session = Depends(get_time_series_db),
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


@records_router.websocket(records_router_root_path + "/{device_id}")
async def device_records_websocket(websocket: WebSocket,
                                   device_id: uuid.UUID,
                                   db: Session = Depends(get_regular_db)):
    # Get token from headers
    token = websocket.headers.get('Authorization')
    if not token:
        await websocket.close()
        return
    if token.startswith("Bearer "):
        token = token[7:]

    try:
        # Check client authorization
        current_user = await get_current_user(token=token, db=db)
        current_user = await get_current_active_user(current_user=current_user)
        device = device_dependency(device_id=device_id, current_user=current_user, db=db)

        await records_ws_manager.connect(websocket, device.id)
        try:
            while True:
                await websocket.receive_text()
        except WebSocketDisconnect:
            await records_ws_manager.disconnect(websocket, device.id)
    finally:
        db.close()
