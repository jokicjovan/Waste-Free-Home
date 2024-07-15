#include <Wire.h>
#include <PN532_I2C.h>
#include <PN532.h>
#include <NfcAdapter.h>

PN532_I2C pn532_i2c(Wire);
NfcAdapter nfc = NfcAdapter(pn532_i2c);

void setup() {
  Serial.begin(9600);
  Serial.println("NDEF Writer, Reader, and Formatter");
  nfc.begin();
}

void loop() {
  // Option to write, read, or format an NFC tag
  Serial.println("\nEnter 'write' to write to NFC tag, 'read' to read from NFC tag, or 'format' to format NFC tag:");
  String choice = readFromConsole();

  if (choice.equalsIgnoreCase("write")) {
    writeNfcTag();
  } else if (choice.equalsIgnoreCase("read")) {
    readNfcTag();
  } else if (choice.equalsIgnoreCase("format")) {
    formatNfcTag();
  } else {
    Serial.println("Invalid choice. Please enter 'write', 'read', or 'format'.");
  }

  delay(5000); // Wait before allowing new input
}

void writeNfcTag() {
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
  message.addTextRecord("productId:" + productId + ";type:" + (recyclable ? "RECYCABLE" : "NONRECYCABLE"));

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
}

void readNfcTag() {
  // Try to read from the NFC tag until success
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
          int languageCodeLength = payload[0]; // The length of the language code is stored in the first byte
          Serial.print("Record ");
          Serial.print(i);
          Serial.print(": ");
          for (int c = languageCodeLength + 1; c < payloadLength; c++) {
            Serial.print((char)payload[c]);
          }
          Serial.println();
        }
        break; // Exit the loop if reading is successful
      } else {
        Serial.println("No NDEF message found. Retrying...");
      }
    }
    delay(1000); // Wait before checking for tag again
  }
}

void formatNfcTag() {
  // Try to format the NFC tag until success
  while (true) {
    Serial.println("\nPlace an unformatted Mifare Classic NFC tag on the reader.");
    if (nfc.tagPresent()) {
      bool success = nfc.format();
      if (success) {
        Serial.println("Success, tag formatted as NDEF.");
        break; // Exit the loop if formatting is successful
      } else {
        Serial.println("Format failed. Retrying...");
      }
    }
    delay(1000); // Wait before checking for tag again
  }
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
    delay(5);
  }
  input.trim(); // Remove leading/trailing whitespace
  return input; // Return the trimmed input
}
