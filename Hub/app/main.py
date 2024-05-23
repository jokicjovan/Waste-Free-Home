import paho.mqtt.client as mqtt
from fastapi import FastAPI

app = FastAPI()

client_id = "b2cd11e9-8c25-4515-9efa-810c02f05255"
mqtt_broker_address = "mqtt_broker"
mqtt_broker_port = 1883
mqtt_topic = "devices/#"


def on_connect(client, userdata, flags, rc):
    print(f"Connected to MQTT broker with result code {rc}")
    client.subscribe(mqtt_topic)


def on_message(client, userdata, msg):
    data = msg.payload.decode("utf-8")
    print(f"Received MQTT message: {data}")


mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, client_id=client_id)
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message
mqtt_client.connect(mqtt_broker_address, mqtt_broker_port, 60)
mqtt_client.loop_start()


@app.get("/")
async def root():
    return {"message": "Hello Hub"}
