#include <ESP32Servo.h>

// Enums
typedef enum ProductType{
  RECYCABLE, NONRECYCABLE, UNDEFINED
};

// PINS
static const int recycableServoPin = 26;
static const int nonrecycableServoPin = 13;

// Variables;
Servo recycableServo;
Servo nonrecycableServo;
ProductType productType;

void setup() {
  Serial.begin(9600);
  recycableServo.attach(recycableServoPin);
  nonrecycableServo.attach(nonrecycableServoPin);
  recycableServo.write(80);
  nonrecycableServo.write(80);
  productType = UNDEFINED;
}

void loop() {
  if(productType == RECYCABLE){
    recycableServo.write(140);
    delay(5000);
    productType = UNDEFINED;
    recycableServo.write(80);
  }
  else if(productType == NONRECYCABLE){
    nonrecycableServo.write(30);
    delay(5000);
    productType = UNDEFINED;
    nonrecycableServo.write(80);
  delay(5000);
}