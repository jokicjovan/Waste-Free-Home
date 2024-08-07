#include <DHT.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ESP8266mDNS.h>
#include "config.h"

// Macros
// MQTT
#define MQTT_BROKER_SERVICE_NAME "waste-free-home-mqtt-broker"
#define MQTT_DEVICE_TOPIC_PREFIX "device/"
#define MQTT_RECORD_TOPIC_SUFIX "/record"
#define MQTT_STATE_TOPIC_SUFIX "/state"
#define MQTT_STATE_OFFLINE_MESSAGE "{\"state\":\"offline\"}"
#define MQTT_STATE_ONLINE_MESSAGE "{\"state\":\"online\"}"
#define MQTT_LWT_RETAIN true
#define MQTT_LWT_QOS 1
// Sensors
#define DHT_SENSOR_PIN 13
#define DHT_SENSOR_TYPE DHT22

// Variables
DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);
WiFiClient espClient;
PubSubClient client(espClient);
String mqttBrokerIp = "";
int mqttBrokerPort = -1;

// Function prototypes
void discoverMDNSService();
void reconnectMQTT();

void setup() {
  Serial.begin(9600);

  // Initialize sensor
  dht_sensor.begin();
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");

  // Initialize mDNS
  if (!MDNS.begin("ThermoHumidMeter")) {
    Serial.println("Error starting mDNS");
    return;
  }
}

void loop() {
  // Discover mDNS service if mqttBrokerIp or mqttBrokerPort are empty
  if (mqttBrokerIp.isEmpty() || mqttBrokerPort == -1) {
    discoverMDNSService();
  }

  // Connect to MQTT broker if mqttBrokerIp and mqttBrokerPort are found and client not connected
  if (!mqttBrokerIp.isEmpty() && mqttBrokerPort != -1 && !client.connected()) {
    reconnectMQTT();
  }

  // MQTT loop
  client.loop();

  // Read from sensor
  float temperature = dht_sensor.readTemperature();
  float humidity = dht_sensor.readHumidity();

  // Check whether the reading is successful or not
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    // Define topic for messages
    String device_topic = String(MQTT_DEVICE_TOPIC_PREFIX) + String(device_id) + String(MQTT_RECORD_TOPIC_SUFIX);
    
    // Publish temperature and humidity message
    String thermo_humid_message = "{\"temperature\":\"" + String(temperature) + "\", \"humidity\":\"" + String(humidity) + "\"}";
    client.publish(device_topic.c_str(), thermo_humid_message.c_str());

    // Print for debug
    Serial.print("Thermo Humid Meter message: ");
    Serial.println(thermo_humid_message.c_str());
  }

  // Wait a 60 seconds between readings
  delay(60000);
}

void discoverMDNSService() {
  int n = MDNS.queryService("_mqtt", "_tcp");
  if (n == 0) {
    Serial.println("No mDNS services found");
  } else {
    Serial.print(n);
    Serial.println(" service(s) found");
    for (int i = 0; i < n; i++) {
      String newServiceName = MDNS.hostname(i);
      String newMqttBrokerIp = MDNS.IP(i).toString();
      int newMqttBrokerPort = MDNS.port(i);

      if (newServiceName.endsWith(".local")) {
        newServiceName = newServiceName.substring(0, newServiceName.length() - 6);
      }

      Serial.println(newServiceName);

      if (newServiceName == MQTT_BROKER_SERVICE_NAME){
        Serial.print("Service Name: ");
        Serial.println(newServiceName);
        Serial.print("Service Type: ");
        Serial.println("_http._tcp");
        Serial.print("Host IP: ");
        Serial.println(newMqttBrokerIp);
        Serial.print("Port: ");
        Serial.println(newMqttBrokerPort);

        mqttBrokerIp = newMqttBrokerIp;
        mqttBrokerPort = newMqttBrokerPort;
        client.setServer(mqttBrokerIp.c_str(), newMqttBrokerPort);
        break;
      }
    }
  }
}

void reconnectMQTT() {
  if (!client.connected()) {
    // Define topic for LWT
    String lwt_topic = String(MQTT_DEVICE_TOPIC_PREFIX) + String(device_id) + String(MQTT_STATE_TOPIC_SUFIX);
    
    if (client.connect(device_id, mqtt_username, mqtt_password, lwt_topic.c_str(), MQTT_LWT_QOS, MQTT_LWT_RETAIN, MQTT_STATE_OFFLINE_MESSAGE)) {
      client.publish(lwt_topic.c_str(), MQTT_STATE_ONLINE_MESSAGE);
      Serial.println("Connected to MQTT broker");
    } else {
      Serial.print("Failed to connect, rc=");
      Serial.print(client.state());
    }
  }
}
