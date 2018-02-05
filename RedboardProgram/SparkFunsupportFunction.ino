// Support functions.

// Set all board-specific parameters
void dSPINConfig(void)
{
  for (int bd = 0; bd<NUM_BOARDS; bd++)
  {
    boardIndex[bd]->SPIPortConnect(&SPI);      // Before doing anything else, we need to
    //  tell the object which SPI port to use.
    //  Some devices may have more than one.
    state[bd] = boardIndex[bd]->getParam(CONFIG);

    boardIndex[bd]->configSyncPin(BUSY_PIN, 0);// BUSY pin low during operations;
    //  second paramter ignored.
    boardIndex[bd]->configStepMode(STEP_FS);   // 0 microsteps per step
    boardIndex[bd]->setMaxSpeed(300);        // 300 steps/s max
    boardIndex[bd]->setFullSpeed(10000);       // microstep below 10000 steps/s
    boardIndex[bd]->setAcc(150);             // accelerate at 150 steps/s/s
    boardIndex[bd]->setDec(150);             // F: This is to avoid slipping
    boardIndex[bd]->setSlewRate(SR_530V_us);   // Upping the edge speed increases torque.
    boardIndex[bd]->setOCThreshold(OC_750mA);  // OC threshold 750mA
    boardIndex[bd]->setPWMFreq(PWM_DIV_2, PWM_MUL_2); // 31.25kHz PWM freq
    boardIndex[bd]->setOCShutdown(OC_SD_DISABLE); // don't shutdown on OC
    boardIndex[bd]->setVoltageComp(VS_COMP_DISABLE); // don't compensate for motor V
    boardIndex[bd]->setSwitchMode(SW_USER);    // Switch is not hard stop
    if (bd == 0) {
      boardIndex[bd]->setOscMode(INT_16MHZ_OSCOUT_16MHZ);}
    else {
      boardIndex[bd]->setOscMode(EXT_16MHZ_OSCOUT_INVERT);}
    boardIndex[bd]->setAccKVAL(128);           // We'll tinker with these later, if needed.
    boardIndex[bd]->setDecKVAL(128);
    boardIndex[bd]->setRunKVAL(128);
    boardIndex[bd]->setHoldKVAL(32);           // This controls the holding current; keep it low.
  }
}


// Update position
void nextPos(void) {
  ++counter[NUM_BOARDS - 1];
  for (int bd = NUM_BOARDS - 1; (bd > 0) && ((counter[bd] *stepSize[bd]) > stopStep[bd]); --bd) {
    counter[bd] = startStep[bd];
    ++counter[bd - 1];
  }
  for (int bd = 0; bd < NUM_BOARDS; bd++) {
    pos[bd] = counter[bd] * stepSize[bd];
  }
}



// Connect to computer, recieve config file, set variables
void establishConnection(void) {
  Serial.begin(9600);
  StaticJsonBuffer<300> jsonBuffer;
  // Establish connection
  while (Serial.available() == 0)
  {}
  int msg = Serial.read();
  Serial.println(F("Connected!"));

  // Wait for and receive json-config file
  while (Serial.available() == 0)
  {}
  //String json_str =  Serial.readString();
  JsonObject& root = jsonBuffer.parse(Serial);
  if (root.success()) {
    NUM_BOARDS = root["NumBoards"];
    for (int bd = 0; bd < NUM_BOARDS; bd++) {
      String bdID = "Board" + String(bd);
      startStep[bd] = root[bdID]["StartStep"];
      stopStep[bd] = root[bdID]["StopStep"];
      stepSize[bd] = root[bdID]["StepSize"];
      pos[bd] = root["LastAlpha"][bd];
      counter[bd] = pos[bd]/stepSize[bd];
      // TODO: Check if the vals were read
    }
    
    Serial.println(F("Received!"));
    Serial.flush();
    
 }else {
    Serial.println(F("Could not read json!"));
  }
}
void sanityCheck(void) {
  bool configOk = true;
  for (int bd = 0; bd < NUM_BOARDS; bd ++) {
    if (state[bd] != 11912) {
      configOk = false;} }
      
  if (configOk) {
      Serial.println(1);}
  else {
      Serial.println(0);
    }
}

  



