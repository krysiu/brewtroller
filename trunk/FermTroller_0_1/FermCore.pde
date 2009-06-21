void fermCore() {

  //Log data every 2s
  //Log 1 of 6 chunks per cycle to improve responsiveness to calling function
  if (millis() - lastLog > 1000) {
    if (logCount == 0) {
      logPgm();
    } else if (logCount == 1) {
      logStart_P(LOGDATA);
      logField_P(PSTR("TIMER"));
      logFieldI(timerValue);
      logFieldI(timerStatus);
      logEnd();
      logStart_P(LOGDATA);
      logField_P(PSTR("ALARM"));
      logFieldI(alarmStatus);
      logEnd();
    } else if (logCount >= 2 && logCount <= 6) {
      byte i = logCount - 2;
      logStart_P(LOGDATA);
      logField_P(PSTR("TEMP"));
      logFieldI(i);
      ftoa(temp[i], buf, 3);
      logField(buf);
      #ifdef USEMETRIC
        logFieldI(0);
      #else
        logFieldI(1);
      #endif
      logEnd();
    } else if (logCount >= 7 && logCount <= 10) {
      byte pct;
      byte i = logCount - 7;
      if (PIDEnabled[i]) pct = PIDOutput[i] / PIDCycle[i] / 10;
      else if (heatStatus[i]) pct = 100;
      else pct = 0;
      logStart_P(LOGDATA);
      logField_P(PSTR("HEATPWR"));
      logFieldI(i);
      logFieldI(pct);
      logEnd();
    } else if (logCount >= 11 && logCount <= 14) {
      byte i = logCount - 11;
      logStart_P(LOGDATA);
      logField_P(PSTR("SETPOINT"));
      logFieldI(i);
      ftoa(setpoint[i], buf, 0);
      logField(buf);
      #ifdef USEMETRIC
        logFieldI(0);
      #else
        logFieldI(1);
      #endif
      logEnd();
      if (millis() - lastLog > 5000) lastLog = millis(); else lastLog += 1000;
    }
    logCount++;
    if (logCount > 15) logCount = 0;
  }

  //Check Temps
  if (convStart == 0) {
    convertAll();
    convStart = millis();
  } else if (millis() - convStart >= 750) {
    for (byte i = 0; i < 5; i++) temp[i] = read_temp(tSensor[i]);
    convStart = 0;
  }

  //Process PID Heat Outputs
  for (byte i = 0; i < 4; i++) {
    if (PIDEnabled[i]) {
      if (temp[i] == -1) {
        pid[i].SetMode(MANUAL);
        PIDOutput[i] = 0;
      } else {
        pid[i].SetMode(AUTO);
        PIDInput[i] = temp[i];
        pid[i].Compute();
      }
      if (cycleStart[i] == 0) cycleStart[i] = millis();
      if (millis() - cycleStart[i] > PIDCycle[i] * 1000) cycleStart[i] += PIDCycle[i] * 1000;
      if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(heatPin[i], HIGH); else digitalWrite(heatPin[i], LOW);
    } 

    //Process On/Off Heat
    if (heatStatus[i]) {
      if (temp[i] == -1 || temp[i] >= setpoint[i]) {
        if (!PIDEnabled[i]) digitalWrite(heatPin[i], LOW);
        heatStatus[i] = 0;
      } else {
        if (!PIDEnabled[i]) digitalWrite(heatPin[i], HIGH);
      }
    } else { 
      if (temp[i] != -1 && (float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0) {
        if (!PIDEnabled[i]) digitalWrite(heatPin[i], HIGH);
        heatStatus[i] = 1;
      } else {
        if (!PIDEnabled[i]) digitalWrite(heatPin[i], LOW);
      }
    }

    //Process On/Off Cool
    if (coolStatus[i]) {
      if (temp[i] == -1 || temp[i] <= setpoint[i]) {
        digitalWrite(coolPin[i], LOW);
        coolStatus[i] = 0;
      } else digitalWrite(coolPin[i], HIGH);
    } else { 
      if (temp[i] != -1 && (float)(temp[i] - setpoint[i]) >= (float) hysteresis[i] / 10.0) {
        digitalWrite(coolPin[i], HIGH);
        coolStatus[i] = 1;
      } else digitalWrite(coolPin[i], LOW);
    }
  }    
}
