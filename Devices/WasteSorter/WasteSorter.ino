#include <ESP32Servo.h>

// Enums
typedef enum ItemType{
  RECYCABLE, NONRECYCABLE, UNDEFINED
};

// PINS
static const int recycableServoPin = 26;
static const int nonrecycableServoPin = 13;

// Variables;
Servo recycableServo;
Servo nonrecycableServo;
ItemType itemType;

void setup() {
  Serial.begin(9600);
  recycableServo.attach(recycableServoPin);
  nonrecycableServo.attach(nonrecycableServoPin);
  recycableServo.write(80);
  nonrecycableServo.write(80);
  itemType = UNDEFINED;
}

void loop() {
  if(itemType == RECYCABLE){
    recycableServo.write(140);
    delay(5000);
    itemType = UNDEFINED;
    recycableServo.write(80);
  }
  else if(itemType == NONRECYCABLE){
    nonrecycableServo.write(30);
    delay(5000);
    itemType = UNDEFINED;
    nonrecycableServo.write(80);
  delay(5000);
}