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
    client.subscribe(settings.device_record_topic)
    client.subscribe(settings.device_state_topic)


def on_message(client, userdata, msg):
    topic_parts = msg.topic.split("/")

    # Extract device ID
    device_id = topic_parts[1]

    # Extract payload and convert it to json
    data = msg.payload.decode("utf-8")
    print(f"Received MQTT message: {data} from device {device_id}")
    json_data = json.loads(data)

    if topic_parts[2] == "state":
        toggle_device_state(device_id, json_data['state'])
    elif topic_parts[2] == "record":
        send_device_record_to_server(device_id, json_data)
    else:
        print("Invalid topic")


def send_device_record_to_server(device_id, record):
    # Define the URL for the request
    url = f"http://{settings.server_hostname}:{settings.server_port}/{settings.server_records_endpoint}/{device_id}"
    send_request_with_retry(url=url, json_data=record)


def toggle_device_state(device_id, state):
    # Define the URL for the request
    url = f"http://{settings.server_hostname}:{settings.server_port}/{settings.server_devices_endpoint}/{device_id}/toggle"
    # Define the params for the request
    params = {
        "is_online": True if state == "online" else False
    }
    send_request_with_retry(url=url, params=params)


def send_request_with_retry(url, json_data=None, params=None, retries=3):
    headers = {
        "Authorization": f"Bearer {settings.jwt}"
    }

    try:
        with httpx.Client() as client:
            # Send the POST request with both JSON data and query parameters
            response = client.post(url, json=json_data, headers=headers, params=params)
            response.raise_for_status()
            print(f"Response status code: {response.status_code}")
            return response

    except httpx.HTTPStatusError as e:
        # Handle specific HTTP status errors
        if e.response.status_code == 401:  # Unauthorized, possibly due to expired JWT
            if retries > 0:
                get_jwt()  # Refresh JWT token
                return send_request_with_retry(url=url, json_data=json_data, params=params, retries=retries - 1)
        else:
            print(f"HTTP Status error occurred: {e}")

    except httpx.RequestError as e:
        # Handle request errors
        if "Illegal header value" in str(e):
            if retries > 0:
                get_jwt()  # Refresh JWT token
                return send_request_with_retry(url=url, json_data=json_data, params=params, retries=retries - 1)
        else:
            print(f"Request error occurred: {e}")

    except Exception as e:
        # Handle any other unexpected errors
        print(f"Unexpected error occurred: {e}")
    return None
