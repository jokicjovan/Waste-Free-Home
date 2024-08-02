#include <ESP32Servo.h>
#include <PN532_I2C.h>
#include <PN532.h>
#include <NfcAdapter.h>
#include <WiFi.h>
#include <PubSubClient.h>


// Pins
static const int recycableServoPin = 26;
static const int nonrecycableServoPin = 13;

// MQTT Settings
// const char* ssid = "your_SSID";
// const char* password = "your_PASSWORD";
// const char* mqttServer = "broker.hivemq.com"; // Replace with your MQTT broker address
// const int mqttPort = 1883; // Default MQTT port
// const char* mqttUser = "your_MQTT_username"; // Replace with your MQTT username
// const char* mqttPassword = "your_MQTT_password"; // Replace with your MQTT password

// Variables
PN532_I2C pn532_i2c(Wire);
NfcAdapter nfc = NfcAdapter(pn532_i2c);
Servo recycableServo;
Servo nonrecycableServo;
WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(9600);
  nfc.begin();
  recycableServo.attach(recycableServoPin);
  nonrecycableServo.attach(nonrecycableServoPin);
  recycableServo.write(80);
  nonrecycableServo.write(80);
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");

  // Connect to MQTT broker
  client.setServer(mqttServer, mqttPort);
  while (!client.connected()) {
    if (client.connect("WasteSorter")) {
      Serial.println("Connected to MQTT broker");
    } else {
      Serial.print("Failed to connect, rc=");
      Serial.print(client.state());
      delay(2000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    while (!client.connected()) {
      if (client.connect("WasteSorter")) {
        Serial.println("Reconnected to MQTT broker");
      } else {
        Serial.print("Failed to connect, rc=");
        Serial.print(client.state());
        delay(2000);
      }
    }
  }
  client.loop();
  readNfcTag();
  delay(1000);
}

void readNfcTag() {
  while (true) {
    Serial.println("\nPlace an NFC tag on the reader.");
    if (nfc.tagPresent()) {
      NfcTag tag = nfc.read();
      if (tag.hasNdefMessage()) {
        NdefMessage message = tag.getNdefMessage();
        Serial.println("NDEF message found:");

        for (int i = 0; i < message.getRecordCount(); i++) {
          NdefRecord record = message.getRecord(i);
          int payloadLength = record.getPayloadLength();
          byte payload[payloadLength];
          record.getPayload(payload);

          // Extract text without the language code
          int languageCodeLength = payload[0];
          String payloadString = "";
          for (int c = languageCodeLength + 1; c < payloadLength; c++) {
            payloadString += (char)payload[c];
          }

          // Print the entire payload for debugging
          Serial.print("Record ");
          Serial.print(i);
          Serial.print(": ");
          Serial.println(payloadString);

          // Extract the waste_type
          String wasteType = extractWasteType(payloadString);
          if (wasteType.length() > 0) {
            Serial.print("Extracted waste_type: ");
            Serial.println(wasteType);
            
            if (wasteType == "RECYCLABLE" || wasteType == "NON_RECYCLABLE") {
              openLidForWasteType(wasteType); // Open coresponding lid
              String topic = String("devices/") + deviceId;
              String message = "{\"waste_type\":\"" + wasteType + "\"}";
              client.publish(topic.c_str(), message.c_str()); // Publish on MQTT
            } else {
              Serial.println("Invalid waste_type.");
            }
          } else {
            Serial.println("waste_type not found.");
          }
        }
        break; // Exit the loop if reading is successful
      } else {
        Serial.println("No NDEF message found. Retrying...");
      }
    }
    delay(1000);
  }
}

String extractWasteType(String payload) {
  String wasteTypePrefix = "waste_type:";
  int startIndex = payload.indexOf(wasteTypePrefix);
  if (startIndex == -1) {
    return "";
  }
  startIndex += wasteTypePrefix.length();
  int endIndex = payload.indexOf(';', startIndex);
  if (endIndex == -1) {
    endIndex = payload.length();
  }
  return payload.substring(startIndex, endIndex);
}

void openLidForWasteType(String wasteType) {
  if (wasteType == "RECYCLABLE") {
    recycableServo.write(140);
    delay(5000);
    recycableServo.write(80);
  } else if (wasteType == "NON_RECYCLABLE") {
    nonrecycableServo.write(30);
    delay(5000);
    nonrecycableServo.write(80);
  }
}
