#include <SparkFunAutoDriver.h>
#include <SPI.h>
#include "ArduinoJson.h"


#define MAX_BOARDS 5
int NUM_BOARDS;
unsigned long state [MAX_BOARDS];
AutoDriver *boardIndex[MAX_BOARDS];
AutoDriver boardA(0,10,6);
AutoDriver boardB(1,10,6);

void setup() {

  boardIndex[1] = &boardA;
  boardIndex[0] = &boardB;
  
  establishConnection();

  // dSPIN configuration
  pinMode(6, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, INPUT);
  pinMode(13, OUTPUT);
  pinMode(10, OUTPUT);
  digitalWrite(10, HIGH);
  digitalWrite(6, LOW);
  digitalWrite(6, HIGH);

  SPI.begin();
  SPI.setDataMode(SPI_MODE3);
  
  dSPINConfig();
  
  sanityCheck();
}


void loop() {
  StaticJsonBuffer<100> jsonBuffer;
  while (Serial.available() == 0) {}
  JsonObject& root = jsonBuffer.parse(Serial);
  if (root.success()) {
  
    for (int bd = 0; bd <NUM_BOARDS; bd++) {
        int pos = root["position"][bd];
        boardIndex[bd]->goTo(pos);
    }
  
    for (int bd = 0; bd <NUM_BOARDS; bd++) {
        while (boardIndex[bd]->busyCheck()) {}
    }
    
    Serial.println(1); } 
  else {
    Serial.println(0);}
}


