void brewCore() {
  //Check volume every 200 ms and update vol with average of 5 readings
  if (millis() - lastVolChk > 200) {
    for (byte i = VS_HLT; i <= VS_KETTLE; i++) {
      volReadings[i][volCount] = readVolume(vSensor[i], calibVols[i], calibVals[i], zeroVol[i]);
      volAvg[i] = (volReadings[i][0] + volReadings[i][1] + volReadings[i][2] + volReadings[i][3] + volReadings[i][4]) / 5;
    }
    volCount++;
    if (volCount > 4) volCount = 0;
    lastVolChk = millis();
  }

  //Log data every 2s
  //Log 1 of 6 chunks per cycle to improve responsiveness to calling function
  if (millis() - lastLog > 1000) {
    if (logCount == 0) {
      logPgm();
      if (pwrRecovery == 1) {
        logStart_P(LOGDATA);
        logField_P(PSTR("AB_STEP"));
        logFieldI(recoveryStep);
        logEnd();
      }
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
    } else if (logCount >= 2 && logCount <= 4) {
      byte i = logCount - 2;
      logStart_P(LOGDATA);
      logField_P(PSTR("VOL"));
      logFieldI(i);
      ftoa(volAvg[i]/1000.0, buf, 3);
      logField(buf);
      #ifdef USEMETRIC
        logFieldI(0);
      #else
        logFieldI(1);
      #endif
      logEnd();
    } else if (logCount >= 5 && logCount <= 10) {
      byte i = logCount - 5;
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
    } else if (logCount == 11) {
      logStart_P(LOGDATA);
      logField_P(PSTR("STEAM"));
      ftoa(steamPressure, buf, 3);
      logField(buf);
      #ifdef USEMETRIC
        logFieldI(0);
      #else
        logFieldI(1);
      #endif
      logEnd();
    } else if (logCount >= 12 && logCount <= 15) {
      byte pct;
      byte i = logCount - 12;
      if (PIDEnabled[i]) pct = PIDOutput[i] / PIDCycle[i] / 10;
      else if (heatStatus[i]) pct = 100;
      else pct = 0;
      logStart_P(LOGDATA);
      logField_P(PSTR("HEATPWR"));
      logFieldI(i);
      logFieldI(pct);
      logEnd();
    } else if (logCount >= 16 && logCount <= 19) {
      byte i = logCount - 16;
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
    } else if (logCount == 20) {
      logStart_P(LOGDATA);
      logField_P(PSTR("AUTOVLV"));
      logFieldI(autoValve);
      logEnd();
      logStart_P(LOGDATA);
      logField_P(PSTR("SETVLV"));
      logFieldI(vlvBits);
      logEnd();
    } else if (logCount == 21) {
      logStart_P(LOGDATA);
      logField_P(PSTR("VLVPRF"));
      for (byte i = VLV_FILLHLT; i <= VLV_CHILLBEER; i++) { if ((vlvBits & vlvConfig[i]) == vlvConfig[i]) logFieldI(1); else logFieldI(0); }
      logEnd();
      if (millis() - lastLog > 5000) lastLog = millis(); else lastLog += 1000;
    }
    logCount++;
    if (logCount > 21) logCount = 0;
  }

  //Check Temps
  if (convStart == 0) {
    convertAll();
    convStart = millis();
  } else if (millis() - convStart >= 750) {
    for (byte i = TS_HLT; i <= TS_BEEROUT; i++) temp[i] = read_temp(tSensor[i]);
    convStart = 0;
  }

#ifdef USESTEAM
  //Check steam Pressure
  steamPressure = readPressure(STEAMPRESS_APIN, steamPSens);
#endif

  //Process Heat Outputs
#ifdef USESTEAM
  for (byte i = VS_HLT; i <= VS_STEAM; i++) {
#else
  for (byte i = VS_HLT; i <= VS_KETTLE; i++) {
#endif
    if (PIDEnabled[i]) {
      if (i != VS_STEAM && temp[i] == -1) {
        pid[i].SetMode(MANUAL);
        PIDOutput[i] = 0;
      } else {
        pid[i].SetMode(AUTO);
        if (i == VS_STEAM) PIDInput[i] = steamPressure; else PIDInput[i] = temp[i];
        pid[i].Compute();
      }
      if (cycleStart[i] == 0) cycleStart[i] = millis();
      if (millis() - cycleStart[i] > PIDCycle[i] * 1000) cycleStart[i] += PIDCycle[i] * 1000;
      if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(heatPin[i], HIGH); else digitalWrite(heatPin[i], LOW);
    } 

    if (heatStatus[i]) {
      if (i == VS_STEAM) {
        if (steamPressure >= setpoint[i]) {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], LOW);
          heatStatus[i] = 0;
        } else {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], HIGH);
        }
      } else {
        if (temp[i] == -1 || temp[i] >= setpoint[i]) {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], LOW);
          heatStatus[i] = 0;
        } else {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], HIGH);
        }
      }
    } else {
      if (i == VS_STEAM) {
        if ((float)(setpoint[i] - steamPressure) >= (float) hysteresis[i] / 10.0) {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], HIGH);
          heatStatus[i] = 1;
        } else {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], LOW);
        }
      } else {
        if (temp[i] != -1 && (float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0) {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], HIGH);
          heatStatus[i] = 1;
        } else {
          if (PIDEnabled[i] == 0) digitalWrite(heatPin[i], LOW);
        }
      }        
    }
  }    

  //Do Valves
  if (autoValve == AV_FILL) {
    if (volAvg[VS_HLT] < tgtVol[VS_HLT] && volAvg[VS_MASH] < tgtVol[VS_MASH]) {
      if (vlvBits != (vlvConfig[VLV_FILLHLT] | vlvConfig[VLV_FILLMASH])) setValves(vlvConfig[VLV_FILLHLT] | vlvConfig[VLV_FILLMASH]);
    } else if (volAvg[VS_HLT] < tgtVol[VS_HLT]) {
      if (vlvBits != vlvConfig[VLV_FILLHLT]) setValves(vlvConfig[VLV_FILLHLT]);
    } else if (volAvg[VS_MASH] < tgtVol[VS_MASH]) {
      if (vlvBits != vlvConfig[VLV_FILLMASH]) setValves(vlvConfig[VLV_FILLMASH]);
    } else if (vlvBits != 0) setValves(0);
  } else if (autoValve == AV_MASH) {
    if (heatStatus[TS_MASH]) {
      if (vlvBits != vlvConfig[VLV_MASHHEAT]) setValves(vlvConfig[VLV_MASHHEAT]);
    } else if (vlvBits != vlvConfig[VLV_MASHIDLE]) setValves(vlvConfig[VLV_MASHIDLE]); 
  } else if (autoValve == AV_CHILL) {
    if (temp[TS_BEEROUT] > pitchTemp + 1.0) {
     if (vlvBits != vlvConfig[VLV_CHILLH2O]) setValves(vlvConfig[VLV_CHILLH2O]);
    } else if (temp[TS_BEEROUT] < pitchTemp - 1.0) {
      if (vlvBits != vlvConfig[VLV_CHILLBEER]) setValves(vlvConfig[VLV_CHILLBEER]);
    } else if (vlvBits != (vlvConfig[VLV_CHILLBEER] | vlvConfig[VLV_CHILLH2O])) setValves(vlvConfig[VLV_CHILLBEER] | vlvConfig[VLV_CHILLH2O]);
  }

}
