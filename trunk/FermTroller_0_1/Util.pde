void ftoa(float val, char retStr[], byte precision) {
  char lbuf[11];
  itoa(val, retStr, 10);  
  if(val < 0) val = -val;
  if( precision > 0) {
    strcat(retStr, ".");
    unsigned int mult = 1;
    for(byte i = 0; i< precision; i++) mult *=10;
    unsigned int frac = (val - int(val)) * mult;
    itoa(frac, lbuf, 10);
    for(byte i = 0; i < precision - (int)strlen(lbuf); i++) strcat(retStr, "0");
    strcat(retStr, lbuf);
  }
}

//Truncate a string representation of a float to (length) chars but do not end string with a decimal point
void truncFloat(char string[], byte length) {
  if (strlen(string) > length) {
    if (string[length - 1] == '.') string[length - 1] = '\0';
    else string[length] = '\0';
  }
}

int availableMemory() {
  int size = 4096;
  byte *buf;
  while ((buf = (byte *) malloc(--size)) == NULL);
  free(buf);
  return size;
}

void resetOutputs() {
  for (byte i = 0; i < 4; i++) {
    setpoint[i] = 0;
    digitalWrite(heatPin[i], LOW);
    digitalWrite(coolPin[i], LOW);
  }
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

void printTimer(byte iRow, byte iCol) {
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
      printLCDRPad(iRow, iCol, "", 6, ' ');
      printLCD_P(iRow, iCol+2, PSTR(":"));
      if (timerHours > 0) {
        printLCDLPad(iRow, iCol, itoa(timerHours, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol + 3, itoa(timerMins, buf, 10), 2, '0');
      } else {
        printLCDLPad(iRow, iCol, itoa(timerMins, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol+ 3, itoa(timerSecs, buf, 10), 2, '0');
      }
      timerLastWrite = timerValue/1000;
    }
  } else printLCDRPad(iRow, iCol, "", 6, ' ');
}

void setAlarm(boolean value) {
  alarmStatus = value;
  digitalWrite(ALARM_PIN, value);
}
