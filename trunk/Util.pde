void ftoa(float val, char retStr[], int precision) {
  itoa(val, retStr, 10);  
  if(val < 0) val = -val;
  if( precision > 0) {
    strcat(retStr, ".");
    unsigned int mult = 1;
    for(int i = 0; i< precision; i++) mult *=10;
    unsigned int frac = (val - int(val)) * mult;
    char buf[6];
    itoa(frac, buf, 10);
    for(int i = 0; i < precision - (int)strlen(buf); i++) strcat(retStr, "0");
    strcat(retStr, buf);
  }
}

// The following function is currently not being used: 
/*
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
*/

void resetOutputs() {
  for (int i = HLT; i <= KETTLE; i++) {
    setpoint[i] = 0;
    digitalWrite(OUTPUT_PIN[i], LOW);
    if (PIDEnabled[i]) pid[i].SetMode(MANUAL);
  }
  digitalWrite(ALARM_PIN, LOW);
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
}

void setTimer(unsigned int minutes) {
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
    } else if (!alarmStatus) printLCD(iRow, iCol, "PAUSED");

    unsigned int timerHours = timerValue / 3600000;
    unsigned int timerMins = (timerValue - timerHours * 3600000) / 60000;
    unsigned int timerSecs = (timerValue - timerHours * 3600000 - timerMins * 60000) / 1000;

    //Update EEPROM once per minute
    if (timerLastWrite/60 != timerValue/60000) setTimerRecovery(timerValue/60000 + 1);
    //Update LCD once per second
    if (timerLastWrite != timerValue/1000) {
      printLCD(iRow, iCol, "  :   ");
      if (timerHours > 0) {
        printLCDPad(iRow, iCol, itoa(timerHours, buf, 10), 2, '0');
        printLCDPad(iRow, iCol + 3, itoa(timerMins, buf, 10), 2, '0');
      } else {
        printLCDPad(iRow, iCol, itoa(timerMins, buf, 10), 2, '0');
        printLCDPad(iRow, iCol+ 3, itoa(timerSecs, buf, 10), 2, '0');
      }
      timerLastWrite = timerValue/1000;
    }
  } else printLCD(iRow, iCol, "      ");
}

void setAlarm(boolean value) {
  alarmStatus = value;
  digitalWrite(ALARM_PIN, value);
}

