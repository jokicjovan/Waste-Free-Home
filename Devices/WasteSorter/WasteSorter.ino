#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <PN532.h>
#include <PN532_I2C.h>
#include <NfcAdapter.h>
#include <ESP32Servo.h>
#include <HCSR04.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include "config.h"

// Constants
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1

// Variables
PN532_I2C pn532_i2c(Wire);
NfcAdapter nfc = NfcAdapter(pn532_i2c);
Servo recycableServo;
Servo nonrecycableServo;
UltraSonicDistanceSensor recycableDistance(recycableDistanceTrigPin, recycableDistanceEchoPin);
UltraSonicDistanceSensor nonrecycableDistance(nonrecycableDistanceTrigPin, nonrecycableDistanceEchoPin);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
WiFiClient espClient;
PubSubClient client(espClient);

// Function prototypes
void openLidForWasteType(String wasteType);
int calculateFillage(float distance);
void updateDisplay(int recyclableFillage, int nonRecyclableFillage);

void setup() {
  Serial.begin(9600);

  // Initialize NFC
  nfc.begin();

  // Initialize Servos
  recycableServo.attach(recycableServoPin);
  nonrecycableServo.attach(nonrecycableServoPin);
  recycableServo.write(80);
  nonrecycableServo.write(80);

  // Initialize the SSD1306 display
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

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
          if (wasteType == "RECYCLABLE" || wasteType == "NON_RECYCLABLE") {
            handleThrownWaste(wasteType);
          } else {
            Serial.println("Invalid waste_type.");
          }
        } else {
          Serial.println("waste_type not found.");
        }
      }
    } else {
      Serial.println("No NDEF message found. Retrying...");
    }
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

void handleThrownWaste(String wasteType) {
  // Open corresponding lid
  openLidForWasteType(wasteType);

  // Calculate fillage for both waste types
  float recyclableDistanceValue = recycableDistance.measureDistanceCm();
  float nonRecyclableDistanceValue = nonrecycableDistance.measureDistanceCm();
  int recyclableFillage = calculateFillage(recyclableDistanceValue);
  int nonRecyclableFillage = calculateFillage(nonRecyclableDistanceValue);

  // Update display with fill levels
  updateDisplay(recyclableFillage, nonRecyclableFillage);

  // Publish messages to MQTT
  String topic = String("devices/") + deviceId;
  
  // Publish waste type message
  String waste_type_message = "{\"waste_type\":\"" + wasteType + "\"}";
  client.publish(topic.c_str(), waste_type_message.c_str());
  
  // Publish fillage message
  String fillage_message = "{\"recyclable_level\":\"" + String(recyclableFillage) + "\", \"non_recyclable_level\":\"" + String(nonRecyclableFillage) + "\"}";
  client.publish(topic.c_str(), fillage_message.c_str());

  // Print for debug
  Serial.print("Waste type message: ");
  Serial.println(waste_type_message.c_str());
  Serial.print("Waste level message: ");
  Serial.println(fillage_message.c_str());
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

int calculateFillage(float distance) {
  if (distance > binSize) distance = 30;
  if (distance < 0) distance = 0;

  int percentage_filled = map(distance, 0, 30, 100, 0);
  return percentage_filled;
}

void updateDisplay(int recyclableFillage, int nonRecyclableFillage) {
  display.clearDisplay();
  // Define rectangle positions and sizes
  int rectWidth = 50;
  int rectHeight = 70;
  int leftRectX = 10;
  int rightRectX = SCREEN_WIDTH - rectWidth - 10;
  int rectY = (SCREEN_HEIGHT - rectHeight) / 2; // Center vertically

  // Calculate fill heights
  int recyclableFillHeight = map(recyclableFillage, 0, 100, 0, rectHeight);
  int nonRecyclableFillHeight = map(nonRecyclableFillage, 0, 100, 0, rectHeight);

  // Draw left rectangle with fill
  display.drawRect(leftRectX, rectY, rectWidth, rectHeight, SSD1306_WHITE); // Draw border
  display.fillRect(leftRectX, rectY + rectHeight - recyclableFillHeight, rectWidth, recyclableFillHeight, SSD1306_WHITE); // Fill with white
  
  // Set text color based on background
  display.setTextColor(recyclableFillHeight > (rectHeight / 2) ? SSD1306_BLACK : SSD1306_WHITE); // Black if fill is above middle
  display.setCursor(leftRectX + 10, rectY + (rectHeight / 2) - 4); // Center text vertically
  display.print("NR");

  // Draw right rectangle with fill
  display.drawRect(rightRectX, rectY, rectWidth, rectHeight, SSD1306_WHITE); // Draw border
  display.fillRect(rightRectX, rectY + rectHeight - nonRecyclableFillHeight, rectWidth, nonRecyclableFillHeight, SSD1306_WHITE); // Fill with white
  
  // Set text color based on background
  display.setTextColor(nonRecyclableFillHeight > (rectHeight / 2) ? SSD1306_BLACK : SSD1306_WHITE); // Black if fill is above middle
  display.setCursor(rightRectX + 10, rectY + (rectHeight / 2) - 4); // Center text vertically
  display.print("R");

  display.display();
}



