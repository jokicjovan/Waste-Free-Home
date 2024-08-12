#include <DHT.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>
#include <EEPROM.h>
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
// EEPROM
#define EEPROM_SSID_ADDR 0
#define EEPROM_PASSWORD_ADDR 32
#define EEPROM_MQTT_IP_ADDR 64
#define EEPROM_MQTT_PORT_ADDR 96

// Variables
DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);
WiFiClient espClient;
PubSubClient client(espClient);
ESP8266WebServer server(80);
bool apMode = false;

// Function prototypes
void handleSensorReading();
void checkAndReconnectWiFi();
void checkAndReconnectMQTT();
void discoverMDNSService();
void startAccessPoint();
void stopAccessPoint();
void handleNetworkCredentialsUpdate();

void setup() {
  Serial.begin(9600);
  dht_sensor.begin();
  EEPROM.begin(512);

  // Start Access Point if needed
  checkAndReconnectWiFi();

  if (WiFi.status() == WL_CONNECTED) {
    if (!MDNS.begin("ThermoHumidMeter")) {
      Serial.println("Error starting mDNS");
    }
  } else {
    // Handle the case where WiFi connection failed or is not available
    Serial.println("WiFi not connected. mDNS cannot be initialized. Starting Access Point...");
    startAccessPoint();
  }

}

void loop() {
  if (apMode) {
    server.handleClient(); // Handle HTTP requests in AP mode
  } else {
    checkAndReconnectWiFi(); 
    checkAndReconnectMQTT(); 
    // If not connected to MQTT Broker , search Broker service with mDNS
    if(WiFi.status() == WL_CONNECTED && !client.connected()){
      Serial.println("Discovering services...");
      discoverMDNSService();
    }

    // MQTT loop
    client.loop();

    handleSensorReading();

    delay(10000);
  }
}

void handleSensorReading(){
    // Read from sensor and publish data
    float temperature = dht_sensor.readTemperature();
    float humidity = dht_sensor.readHumidity();

    if (isnan(temperature) || isnan(humidity)) {
      Serial.println("Failed to read from DHT sensor!");
    } else {
      String device_topic = String(MQTT_DEVICE_TOPIC_PREFIX) + String(device_id) + String(MQTT_RECORD_TOPIC_SUFIX);
      String thermo_humid_message = "{\"temperature\":\"" + String(temperature) + "\", \"humidity\":\"" + String(humidity) + "\"}";
      client.publish(device_topic.c_str(), thermo_humid_message.c_str());
      Serial.print("Thermo Humid Meter message: ");
      Serial.println(thermo_humid_message.c_str());
    }
}

void checkAndReconnectWiFi() {
  if (WiFi.status() != WL_CONNECTED) {
    String ssid = readStringFromEEPROM(EEPROM_SSID_ADDR);
    String password = readStringFromEEPROM(EEPROM_PASSWORD_ADDR);

    if (ssid.length() > 0 && password.length() > 0) {
      WiFi.begin(ssid.c_str(), password.c_str());

      int attempts = 0;
      while (WiFi.status() != WL_CONNECTED && attempts < 10) {
        delay(1000);
        Serial.print(".");
        attempts++;
      }

      if (WiFi.status() == WL_CONNECTED) {
        Serial.println("Connected to WiFi");
        return;
      } else {
        Serial.println("Failed to connect to WiFi after 10 attempts.");
      }
    } else {
      Serial.println("No WiFi credentials found.");
    }
  }
}

void checkAndReconnectMQTT() {
  if (WiFi.status() == WL_CONNECTED) {
    if (!client.connected()) {
      // Read MQTT broker details from EEPROM
      String mqttBrokerIp = readStringFromEEPROM(EEPROM_MQTT_IP_ADDR);
      int mqttBrokerPort = readIntFromEEPROM(EEPROM_MQTT_PORT_ADDR);

      if (mqttBrokerIp.length() > 0 && mqttBrokerPort > 0) {
        client.setServer(mqttBrokerIp.c_str(), mqttBrokerPort);
        String lwt_topic = String(MQTT_DEVICE_TOPIC_PREFIX) + String(device_id) + String(MQTT_STATE_TOPIC_SUFIX);

        int attempts = 0;
        while (!client.connected() && attempts < 10) {
          client.connect(device_id, mqtt_username, mqtt_password, lwt_topic.c_str(), MQTT_LWT_QOS, MQTT_LWT_RETAIN, MQTT_STATE_OFFLINE_MESSAGE);
          delay(1000);
          Serial.print(".");
          attempts++;
        }

        if (client.connected()) {
          Serial.println("Connected to MQTT broker");
          client.publish(lwt_topic.c_str(), MQTT_STATE_ONLINE_MESSAGE);
          return;
        } else {
          Serial.print("Failed to connect to MQTT after 10 attempts. rc=");
          Serial.println(client.state());
        }
      } else {
        Serial.println("No MQTT broker details found.");
      }
    }
  }
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

      if (newServiceName == MQTT_BROKER_SERVICE_NAME) {
        Serial.print("Service Name: ");
        Serial.println(newServiceName);
        Serial.print("Service Type: ");
        Serial.println("_http._tcp");
        Serial.print("Host IP: ");
        Serial.println(newMqttBrokerIp);
        Serial.print("Port: ");
        Serial.println(newMqttBrokerPort);

        writeStringToEEPROM(EEPROM_MQTT_IP_ADDR, newMqttBrokerIp);
        writeIntToEEPROM(EEPROM_MQTT_PORT_ADDR, newMqttBrokerPort);
        EEPROM.commit();
        ESP.restart(); // Restart to apply new broker ip and port
      }
    }
  }
}

void startAccessPoint() {
  server.on("/API/health", HTTP_GET, handleHealthCheck);
  server.on("/API/network-credentials", HTTP_POST, handleNetworkCredentialsUpdate);
  server.begin();
  WiFi.softAP("THERMO_HUMID_METER_AP");
  Serial.println("Access Point Started. Connect to 'THERMO_HUMID_METER_AP' and access http://192.168.4.1/API/network-credentials to set WiFi credentials.");
  apMode = true;
}

void stopAccessPoint() {
  if (WiFi.softAPgetStationNum() > 0) {
    WiFi.softAPdisconnect(true);
    Serial.println("Access Point stopped.");
    apMode = false;
  }
}

void handleHealthCheck() {
  server.send(200, "text/plain", "ok");
}

void handleNetworkCredentialsUpdate() {
  if (server.hasArg("ssid") && server.hasArg("password")) {
    String ssid = server.arg("ssid");
    String password = server.arg("password");

    if (ssid.length() > 0 && password.length() > 0) {
      writeStringToEEPROM(EEPROM_SSID_ADDR, ssid);
      writeStringToEEPROM(EEPROM_PASSWORD_ADDR, password);
      EEPROM.commit();
      server.send(200, "text/plain", "Credentials updated. Restarting...");
      delay(1000); // Allow time for the response to be sent
      
      stopAccessPoint();
      ESP.restart(); // Restart to apply new credentials
    } else {
      server.send(400, "text/plain", "Invalid parameters");
    }
  } else {
    server.send(400, "text/plain", "Missing parameters");
  }
}

void writeStringToEEPROM(int startAddress, String data) {
  int length = data.length();
  EEPROM.write(startAddress, length);
  for (int i = 0; i < length; i++) {
    EEPROM.write(startAddress + 1 + i, data[i]);
  }
}

String readStringFromEEPROM(int startAddress) {
  int length = EEPROM.read(startAddress);
  String data = "";
  for (int i = 0; i < length; i++) {
    data += char(EEPROM.read(startAddress + 1 + i));
  }
  return data;
}

void writeIntToEEPROM(int address, int value) {
  EEPROM.write(address, (value >> 8) & 0xFF);
  EEPROM.write(address + 1, value & 0xFF);
}

int readIntFromEEPROM(int address) {
  int value = (EEPROM.read(address) << 8) | EEPROM.read(address + 1);
  return value;
}
