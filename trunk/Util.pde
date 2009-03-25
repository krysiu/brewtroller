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
int availableMemory() {
  int size = 4096;
  byte *buf;
  while ((buf = (byte *) malloc(--size)) == NULL);
  free(buf);
  return size;
}


void resetOutputs() {
  for (int i = HLT; i <= KETTLE; i++) {
    setpoint[i] = 0;
    if (PIDEnabled[i]) pid[i].SetMode(MANUAL);
  }
  digitalWrite(HLTHEAT_PIN, LOW);
  digitalWrite(MASHHEAT_PIN, LOW);
  digitalWrite(KETTLEHEAT_PIN, LOW);
  digitalWrite(ALARM_PIN, LOW);
  setValves(0);
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

void setValves (unsigned int valveBits) { 
  digitalWrite(VALVE0_PIN, valveBits & 1);
  digitalWrite(VALVE1_PIN, valveBits & 2);
  digitalWrite(VALVE2_PIN, valveBits & 4);
  digitalWrite(VALVE3_PIN, valveBits & 8);
  digitalWrite(VALVE4_PIN, valveBits & 16);
  digitalWrite(VALVE5_PIN, valveBits & 32);
  digitalWrite(VALVE6_PIN, valveBits & 64);
  digitalWrite(VALVE7_PIN, valveBits & 128);
  digitalWrite(VALVE8_PIN, valveBits & 256);
  digitalWrite(VALVE9_PIN, valveBits & 512);
  digitalWrite(VALVEA_PIN, valveBits & 1024);
}
