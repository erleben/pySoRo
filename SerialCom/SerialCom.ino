#include <SparkFunAutoDriver.h>
#include <SPI.h>
#include "ArduinoJson.h"


#define MAX_BOARDS 5
int NUM_BOARDS;
int startStep [MAX_BOARDS];
int stopStep [MAX_BOARDS];
int stepSize [MAX_BOARDS];
int counter [MAX_BOARDS];
int pos [MAX_BOARDS];
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

  String currPos;
  while (Serial.available() == 0) {}
  int msg = Serial.parseInt();
  for (int bd = 0; bd <NUM_BOARDS; bd++) {
      boardIndex[bd]->goTo(pos[bd]);
  }

  for (int bd = 0; bd <NUM_BOARDS; bd++) {
      while (boardIndex[bd]->busyCheck()) {}
      currPos = currPos + String(pos[bd])+String(',');
  }
  
  Serial.println(currPos);
  nextPos();
  
  if (pos[0]>stopStep[0]) {
    while (Serial.available() == 0) {}
    Serial.parseInt();
    Serial.println(String("Done!")); }
}


