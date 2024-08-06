import json
import httpx
import paho.mqtt.client as mqtt

from app.core.config import settings
from app.core.utils import get_jwt

# Initialize MQTT client
mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, settings.hub_id)


def on_connect(client, userdata, flags, rc):
    print(f"Connected to MQTT broker with result code {rc}")
    # Subscribe to the topic
    client.subscribe(settings.devices_topic)


def on_message(client, userdata, msg):
    # Extract device ID and message payload, then send to server
    device_id = msg.topic.split("/")[1]
    data = msg.payload.decode("utf-8")
    print(f"Received MQTT message: {data} from device {device_id}")
    json_data = json.loads(data)
    send_device_record_to_server(device_id, json_data)


def send_device_record_to_server(device_id, record):
    # Define the URL and headers for the request
    url = f"http://{settings.server_hostname}:{settings.server_port}/{settings.server_records_endpoint}/{device_id}"
    headers = {
        "Authorization": f"Bearer {settings.jwt}"
    }

    try:
        with httpx.Client() as client:
            # Send the POST request with the record
            response = client.post(url, json=record, headers=headers)
            response.raise_for_status()
            print(f"Response status code: {response.status_code}")

    except httpx.HTTPStatusError as e:
        if e.response.status_code == 401:  # Unauthorized, possibly due to expired JWT
            get_jwt()  # Refresh JWT
            headers["Authorization"] = f"Bearer {settings.jwt}"
            # Retry the POST request with the new JWT
            response = client.post(url, json=record, headers=headers)
            response.raise_for_status()
            print(f"Response status code (after JWT refresh): {response.status_code}")

    except httpx.RequestError as e:
        print(f"Request error occurred: {e}")
