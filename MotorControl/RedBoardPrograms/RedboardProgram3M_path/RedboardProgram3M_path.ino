#include <SparkFunAutoDriver.h>
#include <SPI.h>
#include "ArduinoJson.h"


#define NUM_BOARDS 3
unsigned long state [NUM_BOARDS];
AutoDriver *boardIndex[NUM_BOARDS];

// Create our AutoDriver instances. The parameters are the position in the chain of
//  boards (with board 0 being located at the end of the chain, farthest from the
//  controlling processor), CS pin, and reset pin.
AutoDriver boardA(0,10,6);
AutoDriver boardB(1,10,6);
AutoDriver boardC(2,10,6);

void setup() {

  boardIndex[2] = &boardA;
  boardIndex[1] = &boardB;
  boardIndex[0] = &boardC;

  
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
  StaticJsonBuffer<15000> jsonBuffer;
  while (Serial.available() == 0) {}
  JsonObject& root = jsonBuffer.parseObject(Serial);
  
  if (root.success()) {
    if (root.containsKey("position")) {
      for (int bd = 0; bd <NUM_BOARDS; bd++) {
          int pos = root["position"][bd];
          boardIndex[bd]->goTo(pos);
      }
      
      // Wait until all motors have reached their destinations
      for (int bd = 0; bd <NUM_BOARDS; bd++) {
          while (boardIndex[bd]->busyCheck()) {}
      }
      Serial.println(1);}
    else if (root.containsKey("path")){
      int s = root["path"].size();
      for (int i = 0; i< s; i++) {
        for (int bd = 0; bd < NUM_BOARDS; bd++) {
          int pos = root["path"][i][bd];
          boardIndex[bd]->goTo(pos);}
      for (int bd = 0; bd <NUM_BOARDS; bd++) {
          while (boardIndex[bd]->busyCheck()) {}
      }}
      Serial.println(1);}
     else { Serial.println(0);}}
   else {Serial.println(0);}
   Serial.flush();

}


