#include <SparkFunAutoDriver.h>
#include <SPI.h>
#include "ArduinoJson.h"


#define MAX_BOARDS 5
int NUM_BOARDS;
unsigned long state [MAX_BOARDS];
AutoDriver *boardIndex[MAX_BOARDS];

// Create our AutoDriver instances. The parameters are the position in the chain of
//  boards (with board 0 being located at the end of the chain, farthest from the
//  controlling processor), CS pin, and reset pin.
AutoDriver boardA(0,10,6);
AutoDriver boardB(1,10,6);

void setup() {

  boardIndex[1] = &boardA;
  boardIndex[0] = &boardB;
  
  establishConnection();

  // Start by setting up the SPI port and pins. The
  //  Autodriver library does not do this for you!
  pinMode(6, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, INPUT);
  pinMode(13, OUTPUT);
  pinMode(10, OUTPUT);
  digitalWrite(10, HIGH);
  digitalWrite(6, LOW);        // This low/high is a reset of the L6470 chip on the
  digitalWrite(6, HIGH);      //  Autodriver board, and is a good thing to do at
                              //  the start of any Autodriver sketch, to be sure
                              //  you're starting the Autodriver from a known state.

  SPI.begin();
  SPI.setDataMode(SPI_MODE3);

  // Configure the boards
  dSPINConfig();

  // Check the internal registers of the boards.
  // If getParam(CONFIG) != 11912, then something is wrong,
  // most likely the hardware setup
  sanityCheck();
}


void loop() {

  // Allocate space for and parse the incoming message
  StaticJsonBuffer<100> jsonBuffer;
  while (Serial.available() == 0) {}
  JsonObject& root = jsonBuffer.parse(Serial);
  
  if (root.success()) {
  
    for (int bd = 0; bd <NUM_BOARDS; bd++) {
        int pos = root["position"][bd];
        boardIndex[bd]->goTo(pos);
    }
    
    // Wait until all motors have reached their destinations
    for (int bd = 0; bd <NUM_BOARDS; bd++) {
        while (boardIndex[bd]->busyCheck()) {}
    }

    // 1 singals success and 0 failure
    Serial.println(1); } 
  else {
    Serial.println(0);}
}


