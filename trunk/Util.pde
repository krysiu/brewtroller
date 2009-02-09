void ftoa(float val, char retStr[], int precision) {
  itoa(val, retStr, 10);  
  if(val < 0) val = -val;
  if( precision > 0) {
    strcat(retStr, ".");
    unsigned int mult = 1;
    while(precision--) mult *=10;
    unsigned int frac = (val - int(val)) * mult;
    char buf[6];
    strcat(retStr, itoa(frac, buf, 10));
  }
}

int memoryTest() {
  int byteCounter = 0; // initialize a counter
  byte *byteArray; // create a pointer to a byte array
  // More on pointers here: http://en.wikipedia.org/wiki/Pointer#C_pointers

  // use the malloc function to repeatedly attempt allocating a certain number of bytes to memory
  // More on malloc here: http://en.wikipedia.org/wiki/Malloc
  while ( (byteArray = (byte*) malloc (byteCounter * sizeof(byte))) != NULL ) {
    byteCounter++; // if allocation was successful, then up the count for the next try
    free(byteArray); // free memory after allocating it
  }
  
  free(byteArray); // also free memory after the function finishes
  return byteCounter; // send back the highest number of bytes successfully allocated
}

void resetOutputs() {
  hltSetpoint = 0;
  mashSetpoint = 0;
  kettleSetpoint = 0;
  digitalWrite(ALARM_PIN, LOW);
  digitalWrite(HLTHEAT_PIN, LOW);
  digitalWrite(MASHHEAT_PIN, LOW);
  digitalWrite(KETTLEHEAT_PIN, LOW);
  digitalWrite(VALVE1_PIN, LOW);
  digitalWrite(VALVE2_PIN, LOW);
  digitalWrite(VALVE3_PIN, LOW);
  digitalWrite(VALVE4_PIN, LOW);
  digitalWrite(VALVE5_PIN, LOW);
  digitalWrite(VALVE6_PIN, LOW);
  digitalWrite(VALVE7_PIN, LOW);
  digitalWrite(VALVE8_PIN, LOW);
  digitalWrite(VALVE9_PIN, LOW);
  digitalWrite(VALVE10_PIN, LOW);
  digitalWrite(VALVE11_PIN, LOW);
  if (hltPIDEnabled) hltPID.SetMode(MANUAL);
  if (mashPIDEnabled) mashPID.SetMode(MANUAL);
  if (kettlePIDEnabled) kettlePID.SetMode(MANUAL);
}

void setTimer(int minutes) {
  timerValue = minutes * 60000;
  lastTime = millis();
  timerStatus = 1;
}

void pauseTimer() {
  if (timerStatus) {
    //Pause
    timerStatus = 0;
  } else {
    //Unpause
    timerStatus = 1;
    lastTime = millis();
    timerLastWrite = 0;
  }
}

void clearTimer() {
  timerValue = 0;
  timerStatus = 0;
}

void printTimer(int iRow, int iCol) {
  char buf[3];
  if (alarmStatus || timerValue > 0) {
    if (timerStatus) {
      unsigned long now = millis();
      if (timerValue > now - lastTime) {
        timerValue -= now - lastTime;
      } else {
        timerValue = 0;
        timerStatus = 0;
        setAlarm(1);
        printLCD(iRow, iCol + 5, "!");
      }
      lastTime = now;
    } else if (!alarmStatus) printLCD(iRow, iCol, "[PAUSE]");

    int timerHours = timerValue / 3600000;
    int timerMins = (timerValue - timerHours * 3600000) / 60000;
    int timerSecs = (timerValue - timerHours * 3600000 - timerMins * 60000) / 1000;

    if (timerLastWrite != timerValue/1000) {
      printLCD(iRow, iCol, "  :    ");
      if (timerHours > 0) {
        printLCDPad(iRow, iCol, itoa(timerHours, buf, 10), 2, '0');
        printLCDPad(iRow, iCol + 3, itoa(timerMins, buf, 10), 2, '0');
      } else {
        printLCDPad(iRow, iCol, itoa(timerMins, buf, 10), 2, '0');
        printLCDPad(iRow, iCol+ 3, itoa(timerSecs, buf, 10), 2, '0');
      }
      timerLastWrite = timerValue/1000;
    }
  } else printLCD(iRow, iCol, "       ");
}

void setAlarm(boolean value) {
  alarmStatus = value;
  digitalWrite(ALARM_PIN, value);
}
