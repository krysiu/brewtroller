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
    } else if (logCount >= 2 && logCount <= 8) {
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
    } else if (logCount >= 9 && logCount <= 14) {
      int pct;
      byte i = logCount - 9;
      if (coolStatus[i]) pct = -1;
      else {
        if (PIDEnabled[i]) pct = PIDOutput[i] / PIDCycle[i] / 10;
        else if (heatStatus[i]) pct = 100;
        else pct = 0;
      }
      logStart_P(LOGDATA);
      logField_P(PSTR("ZONEPWR"));
      logFieldI(i);
      logFieldI(pct);
      logEnd();
    } else if (logCount >= 15 && logCount <= 20) {
      byte i = logCount - 15;
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
    } else if (logCount == 21) { if (millis() - lastLog > 5000) lastLog = millis(); else lastLog += 1000; }
    if (logCount > 20) logCount = 0;
    logCount++;
  }

  //Check Temps
  if (convStart == 0) {
    convertAll();
    convStart = millis();
  } else if (millis() - convStart >= 750) {
    for (byte i = 0; i < 7; i++) temp[i] = read_temp(tSensor[i]);
    convStart = 0;
  }

  //Process PID Heat Outputs
  for (byte i = 0; i < NUM_ZONES; i++) {
    #ifndef MODE_6COOL
      if (PIDEnabled[i]) {
        if (temp[i] == -1 || coolStatus[i]) {
          pid[i].SetMode(MANUAL);
          PIDOutput[i] = 0;
        } else {
          pid[i].SetMode(AUTO);
          PIDInput[i] = temp[i];
          pid[i].Compute();
        }
        if (cycleStart[i] == 0) cycleStart[i] = millis();
        if (millis() - cycleStart[i] > PIDCycle[i] * 1000) cycleStart[i] += PIDCycle[i] * 1000;
        if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(outputPin[i], HIGH); else digitalWrite(outputPin[i], LOW);
      } 

      //Process On/Off Heat
      if (heatStatus[i]) {
        if (temp[i] == -1 || temp[i] >= setpoint[i]) {
          if (!PIDEnabled[i]) digitalWrite(outputPin[i], LOW);
          heatStatus[i] = 0;
        } else {
          if (!PIDEnabled[i]) digitalWrite(outputPin[i], HIGH);
        }
      } else { 
        if (temp[i] != -1 && (float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0) {
          if (!PIDEnabled[i]) digitalWrite(outputPin[i], HIGH);
          heatStatus[i] = 1;
        } else {
          if (!PIDEnabled[i]) digitalWrite(outputPin[i], LOW);
        }
      }
    #endif

    #if !defined MODE_6HEAT && !defined MODE_6+6
      //Process Non-MUX Cool
      if (coolStatus[i]) {
        if (temp[i] == -1 || temp[i] <= setpoint[i] || setpoint[i] == 0) {
          digitalWrite(outputPin[i + COOLPIN_OFFSET], LOW);
          coolStatus[i] = 0;
        } else digitalWrite(outputPin[i + COOLPIN_OFFSET], HIGH);
      } else { 
        if (temp[i] != -1 && setpoint[i] != 0 && (float)(temp[i] - setpoint[i]) >= (float) hysteresis[i] / 10.0) {
          digitalWrite(outputPin[i + COOLPIN_OFFSET], HIGH);
          coolStatus[i] = 1;
        } else digitalWrite(outputPin[i + COOLPIN_OFFSET], LOW);
      }
    #endif
  }
  #ifdef MODE_6+6
    //Process MUX Cool
    boolean doUpdate = 0;
    for (byte i = 0; i < 6; i++) {
      if ((coolStatus[i] && temp[i] == -1) || (coolStatus[i] && temp[i] <= setpoint[i]) || (!coolStatus[i] && (float)(temp[i] - setpoint[i]) >= (float) hysteresis[i] / 10.0)) {
        coolStatus[i] = coolStatus[i] ^ 1;
        doUpdate = 1;
      }
    }
    if (doUpdate) {
      //Disable outputs
      digitalWrite(MUX_OE_PIN, HIGH);
      //ground latchPin and hold low for as long as you are transmitting
      digitalWrite(MUX_LATCH_PIN, 0);
      //clear everything out just in case to prepare shift register for bit shifting
      digitalWrite(MUX_DATA_PIN, 0);
      digitalWrite(MUX_CLOCK_PIN, 0);

      //for each bit in the long myDataOut
      for (byte i = 0; i < 8; i++)  {
        digitalWrite(MUX_CLOCK_PIN, 0);
        //create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
        if (i < 6) digitalWrite(MUX_DATA_PIN, coolStatus[i]); else digitalWrite(MUX_DATA_PIN, 0);
        //register shifts bits on upstroke of clock pin  
        digitalWrite(MUX_CLOCK_PIN, 1);
        //zero the data pin after shift to prevent bleed through
        digitalWrite(MUX_DATA_PIN, 0);
      }

      //stop shifting
      digitalWrite(MUX_CLOCK_PIN, 0);
      digitalWrite(MUX_LATCH_PIN, 1);
      //Enable outputs
      digitalWrite(MUX_OE_PIN, LOW);
    }
  #endif
}
