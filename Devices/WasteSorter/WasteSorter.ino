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
#include <ESPmDNS.h>
#include "config.h"

// Variables
PN532_I2C pn532_i2c(Wire);
NfcAdapter nfc(pn532_i2c);
Servo recycableServo;
Servo nonrecycableServo;
UltraSonicDistanceSensor recycableDistance(RECYCABLE_DISTANCE_TRIG_PIN, RECYCABLE_DISTANCE_ECHO_PIN);
UltraSonicDistanceSensor nonrecycableDistance(NON_RECYCABLE_DISTANCE_TRIG_PIN, NON_RECYCABLE_DISTANCE_ECHO_PIN);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
WiFiClient espClient;
PubSubClient client(espClient);
String hubHostname = "";
int hubPort = 1883;

// Function prototypes
void readNfcTag();
void reconnectMQTT();
String extractWasteType(const String& payload);
void handleThrownWaste(const String& wasteType);
void openLidForWasteType(const String& wasteType);
int calculateFillage(float distance);
void updateDisplay(int recyclableFillage, int nonRecyclableFillage);

void setup() {
  Wire.begin();
  Serial.begin(9600);

  // Initialize NFC
  nfc.begin();

  // Initialize Servos
  recycableServo.attach(RECYCABLE_SERVO_PIN);
  nonrecycableServo.attach(NON_RECYCABLE_SERVO_PIN);
  recycableServo.write(80);
  nonrecycableServo.write(80);

  // Initialize the SSD1306 display
  if(!display.begin(SSD1306_SWITCHCAPVCC, SSD1306_I2C_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.display();

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");

  // Initialize mDNS
  if (!MDNS.begin("WasteSorter")) {
    Serial.println("Error starting mDNS");
    return;
  }
}

void loop() {
  // Discover mDNS service if hostname is empty
  if (hubHostname.isEmpty() || hubPort == -1) {
    discoverMDNSService();
  }

  // Connect to MQTT broker if hubHostname is found and  clientis not connected
  if (!hubHostname.isEmpty() && hubPort != -1 && !client.connected()) {
    reconnectMQTT();
  }

  // MQTT loop
  client.loop();

  // Tag handling
  readNfcTag();
  
  delay(1000);
}

void discoverMDNSService() {
  int n = MDNS.queryService("_http", "_tcp");
  if (n == 0) {
    Serial.println("No mDNS services found");
  } else {
    Serial.print(n);
    Serial.println(" service(s) found");
    for (int i = 0; i < n; i++) {
      String newServiceName = MDNS.hostname(i);
      String newHubHostname = MDNS.address(i).toString();
      int newHubPort = MDNS.port(i);
      if (newServiceName == HUB_SERVICE_NAME){
        Serial.print("Service Name: ");
        Serial.println(newServiceName);
        Serial.print("Service Type: ");
        Serial.println("_http._tcp");
        Serial.print("Host IP: ");
        Serial.println(newHubHostname);
        Serial.print("Port: ");
        Serial.println(newHubPort);

        hubHostname = newHubHostname;
        //hubPort = newHubPort;
        client.setServer(hubHostname.c_str(), hubPort);
        break;
      }
    }
  }
}


void reconnectMQTT() {
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
          if (wasteType == WASTE_TYPE_RECYCLABLE || wasteType == WASTE_TYPE_NON_RECYCLABLE) {
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

String extractWasteType(const String& payload) {
  const String wasteTypePrefix = "waste_type:";
  int startIndex = payload.indexOf(wasteTypePrefix);
  if (startIndex == -1) return "";

  startIndex += wasteTypePrefix.length();
  int endIndex = payload.indexOf(';', startIndex);
  if (endIndex == -1) endIndex = payload.length();

  return payload.substring(startIndex, endIndex);
}

void handleThrownWaste(const String& wasteType) {
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
  String topic = String(MQTT_TOPIC_PREFIX) + DEVICE_ID;
  
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

void openLidForWasteType(const String& wasteType) {
  if (wasteType == WASTE_TYPE_RECYCLABLE) {
    recycableServo.write(140);
    delay(5000);
    recycableServo.write(80);
  } else if (wasteType == WASTE_TYPE_NON_RECYCLABLE) {
    nonrecycableServo.write(30);
    delay(5000);
    nonrecycableServo.write(80);
  }
}

int calculateFillage(float distance) {
  distance = constrain(distance, 0, BIN_SIZE);
  return map(distance, 0, BIN_SIZE, 100, 0);
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
  display.print("R");

  // Draw right rectangle with fill
  display.drawRect(rightRectX, rectY, rectWidth, rectHeight, SSD1306_WHITE); // Draw border
  display.fillRect(rightRectX, rectY + rectHeight - nonRecyclableFillHeight, rectWidth, nonRecyclableFillHeight, SSD1306_WHITE); // Fill with white
  
  // Set text color based on background
  display.setTextColor(nonRecyclableFillHeight > (rectHeight / 2) ? SSD1306_BLACK : SSD1306_WHITE); // Black if fill is above middle
  display.setCursor(rightRectX + 10, rectY + (rectHeight / 2) - 4); // Center text vertically
  display.print("NR");

  display.display();
}
