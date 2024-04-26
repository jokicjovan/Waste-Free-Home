#include <Wire.h>
#include <PN532_I2C.h>
#include <PN532.h>
#include <NfcAdapter.h>

PN532_I2C pn532_i2c(Wire);
NfcAdapter nfc = NfcAdapter(pn532_i2c);

void setup() {
  Serial.begin(9600);
  Serial.println("NDEF Writer");
  nfc.begin();
}

void loop() {
  String productId;
  bool recyclable = false;

  // Input productId
  Serial.println("\nEnter productId:");
  productId = readFromConsole();

  // Input recyclable
  Serial.println("Enter recyclable (true/false):");
  String recyclableStr = readFromConsole();
  recyclable = (recyclableStr.equalsIgnoreCase("true"));

  // Construct NdefMessage with the input data
  NdefMessage message = NdefMessage();
  message.addTextRecord("productId:" + productId + ";recyclable:" + (recyclable ? "true" : "false"));

  // Try to write to the NFC tag until success
  while (true) {
    Serial.println("\nPlace a formatted Mifare Classic NFC tag on the reader.");
    if (nfc.tagPresent()) {
      bool success = nfc.write(message);
      if (success) {
        Serial.println("Success. Try reading this tag with your phone.");
        break; // Exit the loop if writing is successful
      } else {
        Serial.println("Write failed. Retrying...");
        delay(2000); // Wait before retrying
      }
    }
    delay(1000); // Wait before checking for tag again
  }

  delay(5000); // Wait before allowing new input
}

String readFromConsole() {
  String input = "";
  while (!Serial.available()) {
    // Wait for input
  }
  delay(100); // Wait for the input buffer to fill
  while (Serial.available()) {
    char c = Serial.read();
    input += c;
    delay(5); // Adjust delay as necessary
  }
  input.trim(); // Remove leading/trailing whitespace
  return input; // Return the trimmed input
}
