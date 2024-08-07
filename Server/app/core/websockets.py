import uuid
from typing import Dict, Set

from fastapi.websockets import WebSocket


class WebSocketManager:
    def __init__(self):
        self.active_connections: Dict[uuid.UUID, Set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, group_id: uuid.UUID):
        await websocket.accept()
        self.active_connections.setdefault(group_id, set()).add(websocket)

    async def disconnect(self, websocket: WebSocket, group_id: uuid.UUID):
        if group_id in self.active_connections:
            self.active_connections[group_id].remove(websocket)
            if not self.active_connections[group_id]:
                del self.active_connections[group_id]

    async def broadcast(self, group_id: uuid.UUID, message: str):
        if group_id in self.active_connections:
            for connection in self.active_connections[group_id]:
                await connection.send_text(message)


records_ws_manager = WebSocketManager()
