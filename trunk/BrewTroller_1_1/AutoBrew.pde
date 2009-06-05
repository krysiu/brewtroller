#define MINS_PROMPT -1
#define STEP_DOUGHIN 0
#define STEP_PROTEIN 1
#define STEP_SACCH 2
#define STEP_MASHOUT 3

void doAutoBrew() {
  logString_P(LOGAB, PSTR("START"));
  unsigned int delayMins = 0;
  byte stepTemp[4], stepMins[4], spargeTemp;
  unsigned long tgtVol[3];
  unsigned long grainWeight = 0;
  unsigned int boilMins;
  unsigned int mashRatio;
  byte pitchTemp;
  unsigned int boilAdds = 0;
  byte grainTemp;
  
  byte recoveryStep = 0;

  loadSetpoints();
  loadABSteps(stepTemp, stepMins);
  spargeTemp = getABSparge();
  delayMins = getABDelay();
  loadABVols(tgtVol);
  grainWeight = getABGrain();
  boilMins = getABBoil();
  mashRatio = getABRatio();
  pitchTemp = getABPitch();
  boilAdds = getABAdds();
  grainTemp = getABGrainTemp();
  
  if (getPwrRecovery() == 1) {
    recoveryStep = getABRecovery();
  } else {
    //Set Zero Volume Calibrations on Normal AutoBrew Start (Not Power Loss Recovery)
    for (byte i = TS_HLT; i <= TS_KETTLE; i++) setZeroVol(i, analogRead(vSensor[i]));
  }

  char volUnit[5] = " l";
  char wtUnit[4] = " kg";
  char tempUnit[2] = "C";
  if (unit) {
    strcpy_P(volUnit, PSTR(" gal"));
    strcpy_P(wtUnit, PSTR(" lb"));
    strcpy_P (tempUnit, PSTR("F"));
  }
  
  boolean inMenu = 1;
  if (recoveryStep) inMenu = 0;
  byte lastOption = 0;
  while (inMenu) {
    logStart_P(LOGAB);
    logField_P(PSTR("SETTINGS"));
  
    for (byte i = STEP_DOUGHIN; i <= STEP_MASHOUT; i++) {
      logFieldI(stepTemp[i]);
      logFieldI(stepMins[i]);
    }
    logFieldI(spargeTemp);
    logFieldI(delayMins);
    for (byte i = VS_HLT; i <= VS_KETTLE; i++) logFieldI(tgtVol[i]);
    logFieldI(grainWeight);
    logFieldI(boilMins);
    logFieldI(mashRatio);
    logFieldI(pitchTemp);
    logFieldI(boilAdds);
    logFieldI(grainTemp);
    logEnd();
  
    strcpy_P(menuopts[0], PSTR("Batch Vol:"));
    strcpy_P(menuopts[1], PSTR("Grain Wt:"));
    strcpy_P(menuopts[2], PSTR("Grain Temp:"));
    strcpy_P(menuopts[3], PSTR("Boil Length:"));
    strcpy_P(menuopts[4], PSTR("Mash Ratio:"));
    strcpy_P(menuopts[5], PSTR("Delay Start:"));
    strcpy_P(menuopts[6], PSTR("HLT Temp:"));
    strcpy_P(menuopts[7], PSTR("Sparge Temp:"));
    strcpy_P(menuopts[8], PSTR("Pitch Temp:"));
    strcpy_P(menuopts[9], PSTR("Mash Schedule"));
    strcpy_P(menuopts[10], PSTR("Boil Additions"));    
    strcpy_P(menuopts[11], PSTR("Start Program"));
    strcpy_P(menuopts[12], PSTR("Load Program"));
    strcpy_P(menuopts[13], PSTR("Save Program"));
    strcpy_P(menuopts[14], PSTR("Exit"));

    ftoa((float)tgtVol[TS_KETTLE]/1000, buf, 2);
    truncFloat(buf, 5);
    strcat(menuopts[0], buf);
    strcat(menuopts[0], volUnit);

    ftoa((float)grainWeight/1000, buf, 3);
    truncFloat(buf, 7);
    strcat(menuopts[1], buf);
    strcat(menuopts[1], wtUnit);

    strncat(menuopts[2], itoa(grainTemp, buf, 10), 3);
    strcat(menuopts[2], tempUnit);

    strncat(menuopts[3], itoa(boilMins, buf, 10), 3);
    strcat_P(menuopts[3], PSTR(" min"));
    
    ftoa((float)mashRatio/100, buf, 2);
    truncFloat(buf, 4);
    strcat(menuopts[4], buf);
    strcat_P(menuopts[4], PSTR(":1"));

    strncat(menuopts[5], itoa(delayMins/60, buf, 10), 4);
    strcat_P(menuopts[5], PSTR(" hr"));
    
    strncat(menuopts[6], itoa(setpoint[TS_HLT], buf, 10), 3);
    strcat(menuopts[6], tempUnit);
    
    strncat(menuopts[7], itoa(spargeTemp, buf, 10), 3);
    strcat(menuopts[7], tempUnit);
    
    strncat(menuopts[8], itoa(pitchTemp, buf, 10), 3);
    strcat(menuopts[8], tempUnit);
    
    lastOption = scrollMenu("AutoBrew Parameters", 15, lastOption);
    if (lastOption == 0) tgtVol[TS_KETTLE] = getValue("Batch Volume", tgtVol[TS_KETTLE], 7, 3, 9999999, volUnit);
    else if (lastOption == 1) grainWeight = getValue("Grain Weight", grainWeight, 7, 3, 9999999, wtUnit);
    else if (lastOption == 2) grainTemp = getValue("Grain Temp", grainTemp, 3, 0, 255, tempUnit);
    else if (lastOption == 3) boilMins = getTimerValue("Boil Length", boilMins);
    else if (lastOption == 4) { if (unit) mashRatio = getValue("Mash Ratio", mashRatio, 3, 2, 999, " qts/lb"); else mashRatio = getValue("Mash Ratio", mashRatio, 3, 2, 999, " l/kg"); }
    else if (lastOption == 5) delayMins = getTimerValue("Delay Start", delayMins);
    else if (lastOption == 6) setpoint[TS_HLT] = getValue("HLT Setpoint", setpoint[TS_HLT], 3, 0, 255, tempUnit);
    else if (lastOption == 7) spargeTemp = getValue("Sparge Temp", spargeTemp, 3, 0, 255, tempUnit);
    else if (lastOption == 8) pitchTemp = getValue("Pitch Temp", pitchTemp, 3, 0, 255, tempUnit);
    else if (lastOption == 9) editMashSchedule(stepTemp, stepMins);
    else if (lastOption == 10) boilAdds = editHopSchedule(boilAdds);
    else if (lastOption == 11) inMenu = 0;
    else if (lastOption == 12) {
      byte profile = 0;
      //Display Stored Programs
      for (byte i = 0; i < 30; i++) getProgName(i, menuopts[i]);
      profile = scrollMenu("Load Program", 30, profile);
      if (profile < 30) {
        spargeTemp = getProgSparge(profile);
        grainWeight = getProgGrain(profile);
        delayMins = getProgDelay(profile);
        boilMins = getProgBoil(profile);
        mashRatio = getProgRatio(profile);
        getProgSchedule(profile, stepTemp, stepMins);
        getProgVols(profile, tgtVol);
        setpoint[TS_HLT] = getProgHLT(profile);
        pitchTemp = getProgPitch(profile);
        boilAdds = getProgAdds(profile);
        grainTemp = getProgGrainT(profile);
      }
    } 
    else if (lastOption == 13) {
      byte profile = 0;
      //Display Stored Schedules
      for (byte i = 0; i < 30; i++) getProgName(i, menuopts[i]);
      profile = scrollMenu("Save Program", 30, profile);
      if (profile < 30) {
        getString("Save Program As:", menuopts[profile], 19);
        setProgName(profile, menuopts[profile]);
        setProgSparge(profile, spargeTemp);
        setProgGrain(profile, grainWeight);
        setProgDelay(profile, delayMins);
        setProgBoil(profile, boilMins);
        setProgRatio(profile, mashRatio);
        setProgSchedule(profile, stepTemp, stepMins);
        setProgVols(profile, tgtVol);
        setProgHLT(profile, setpoint[TS_HLT]);
        setProgPitch(profile, pitchTemp);
        setProgAdds(profile, boilAdds);
        setProgGrainT(profile, grainTemp);
      }
    }
    else {
        if(confirmExit()) {
          setPwrRecovery(0);
          return;
        } else lastOption = 0;
    }
    
    //Detrmine Total Water Needed (Evap + Deadspaces)
    tgtVol[TS_HLT] = round(tgtVol[TS_KETTLE] / (1.0 - evapRate / 100.0 * boilMins / 60.0) + volLoss[TS_HLT] + volLoss[TS_MASH]);
    //Add Water Lost in Spent Grain
    if (unit) tgtVol[TS_HLT] += round(grainWeight * .2143); else tgtVol[TS_HLT] += round(grainWeight * 1.7884);
    //Calculate mash volume
    tgtVol[TS_MASH] = round(grainWeight * mashRatio / 100.0);
    //Convert qts to gal for US
    if (unit) tgtVol[TS_MASH] = round(tgtVol[TS_MASH] / 4.0);
    tgtVol[TS_HLT] -= tgtVol[TS_MASH];


    //Grain-to-volume factor for mash tun capacity (1 lb = .15 gal)
    float grain2Vol;
    if (unit) grain2Vol = .15; else grain2Vol = 1.25;

    //Check for capacity overages
    if (tgtVol[TS_HLT] > capacity[TS_HLT]) {
      clearLCD();
      printLCD_P(0, 0, PSTR("HLT Capacity Issue"));
      printLCD_P(1, 0, PSTR("Sparge Vol:"));
      ftoa(tgtVol[TS_HLT]/1000.0, buf, 2);
      truncFloat(buf, 5);
      printLCD(1, 11, buf);
      printLCD(1, 16, volUnit);
      printLCD_P(3, 4, PSTR("> Continue <"));
      while (!enterStatus) delay(500);
      enterStatus = 0;
    }
    if (tgtVol[TS_MASH] + round(grainWeight * grain2Vol) > capacity[TS_MASH]) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Mash Capacity Issue"));
      printLCD_P(1, 0, PSTR("Strike Vol:"));
      ftoa(tgtVol[TS_MASH]/1000.0, buf, 2);
      truncFloat(buf, 5);
      printLCD(1, 11, buf);
      printLCD(1, 16, volUnit);
      printLCD_P(2, 0, PSTR("Grain Vol:"));
      ftoa(round(grainWeight * grain2Vol) / 1000.0, buf, 2);
      truncFloat(buf, 5);
      printLCD(2, 11, buf);
      printLCD(2, 16, volUnit);
      printLCD_P(3, 4, PSTR("> Continue <"));
      while (!enterStatus) delay(500);
      enterStatus = 0;
    }

    //Save Values to EEPROM for Recovery
    setPwrRecovery(1);
    setABRecovery(0);
    saveSetpoints();
    saveABSteps(stepTemp, stepMins);
    setABSparge(spargeTemp);
    setABDelay(delayMins);
    saveABVols(tgtVol);
    setABGrain(grainWeight);
    setABBoil(boilMins);
    setABRatio(mashRatio);
    setABPitch(pitchTemp);
    setABAdds(boilAdds);
    setABAddsTrig(0);
    setABGrainTemp(grainTemp);
  }

  switch (recoveryStep) {
    case 0:
    case 1:
      setABRecovery(1);
      manFill(tgtVol[TS_HLT], tgtVol[TS_MASH]);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 2:
      if(delayMins) {
        setABRecovery(2);
        if (recoveryStep == 2) delayStart(getTimerRecovery()); else delayStart(delayMins);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 3:
      //Find first temp and adjust for strike temp
      {
        byte strikeTemp = 0;
        byte i = 0;
        while (strikeTemp == 0 && i <= STEP_MASHOUT) strikeTemp = stepTemp[i++];
        if (unit) strikeTemp = round(.2 / (mashRatio / 100.0) * (strikeTemp - grainTemp)) + strikeTemp; else strikeTemp = round(.41 / (mashRatio / 100.0) * (strikeTemp - grainTemp)) + strikeTemp;
        setpoint[TS_MASH] = strikeTemp;
      }
      setABRecovery(3);
      mashStep("Preheat", MINS_PROMPT);  
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 4:
      setABRecovery(4);
      inMenu = 1;
      while(inMenu) {
        clearLCD();
        printLCD_P(1, 5, PSTR("Add Grain"));
        printLCD_P(2, 0, PSTR("Press Enter to Start"));
        while(enterStatus == 0) delay(500);
        if (enterStatus == 1) {
          enterStatus = 0;
          inMenu = 0;
        } else {
          enterStatus = 0;
          if (confirmExit() == 1) setPwrRecovery(0); return;
        }
      }
    case 5:
      if (stepTemp[STEP_DOUGHIN]) {
        setABRecovery(5);
        setpoint[TS_MASH] = stepTemp[STEP_DOUGHIN];
        int recoverMins = getTimerRecovery();
        if (recoveryStep == 5 && recoverMins > 0) mashStep("Dough In", recoverMins); else mashStep("Dough In", stepMins[STEP_DOUGHIN]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 6:
      if (stepTemp[STEP_PROTEIN]) {
        setABRecovery(6);
        setpoint[TS_MASH] = stepTemp[STEP_PROTEIN];
        int recoverMins = getTimerRecovery();
        if (recoveryStep == 6 && recoverMins > 0) mashStep("Protein", recoverMins); else mashStep("Protein", stepMins[STEP_PROTEIN]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 7:
      if (stepTemp[STEP_SACCH]) {
        setABRecovery(7);
        setpoint[TS_MASH] = stepTemp[STEP_SACCH];
        int recoverMins = getTimerRecovery();
        if (recoveryStep == 7 && recoverMins > 0) mashStep("Sacch Rest", recoverMins); else mashStep("Sacch Rest", stepMins[STEP_SACCH]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 8:
      if (stepTemp[STEP_MASHOUT]) {
        setABRecovery(8);
        setpoint[TS_MASH] = stepTemp[STEP_MASHOUT];
        int recoverMins = getTimerRecovery();
        if (recoveryStep == 8 && recoverMins > 0) mashStep("Mash Out", recoverMins); else mashStep("Mash Out", stepMins[STEP_MASHOUT]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 9:
      //Hold last mash temp until user exits
      setABRecovery(9); 
      setpoint[TS_HLT] = spargeTemp;
      mashStep("End Mash", MINS_PROMPT);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      setpoint[TS_HLT] = 0;
      setpoint[TS_MASH] = 0;
      
    case 10:  
      setABRecovery(10); 
      manSparge();
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 11:
      setABRecovery(11); 
      setpoint[TS_KETTLE] = getBoilTemp();
      boilStage(boilMins, boilAdds);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 12:
      setABRecovery(12); 
      manChill(pitchTemp);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
  }  
  enterStatus = 0;
  setABRecovery(0);
  setPwrRecovery(0);
}

void editMashSchedule(byte stepTemp[4], byte stepMins[4]) {
  char tempUnit[2] = "C";
  if (unit) strcpy (tempUnit, "F");
  byte lastOption = 0;
  while (1) {
    strcpy_P(menuopts[0], PSTR("Dough In:"));
    strcpy_P(menuopts[1], PSTR("Dough In:"));
    strcpy_P(menuopts[2], PSTR("Protein Rest:"));
    strcpy_P(menuopts[3], PSTR("Protein Rest:"));
    strcpy_P(menuopts[4], PSTR("Sacch Rest:"));
    strcpy_P(menuopts[5], PSTR("Sacch Rest:"));
    strcpy_P(menuopts[6], PSTR("Mash Out:"));
    strcpy_P(menuopts[7], PSTR("Mash Out:"));
    strcpy_P(menuopts[8], PSTR("Exit"));
  
    strncat(menuopts[0], itoa(stepMins[STEP_DOUGHIN], buf, 10), 2);
    strcat(menuopts[0], " min");

    strncat(menuopts[1], itoa(stepTemp[STEP_DOUGHIN], buf, 10), 3);
    strcat(menuopts[1], tempUnit);
    
    strncat(menuopts[2], itoa(stepMins[STEP_PROTEIN], buf, 10), 2);
    strcat(menuopts[2], " min");

    strncat(menuopts[3], itoa(stepTemp[STEP_PROTEIN], buf, 10), 3);
    strcat(menuopts[3], tempUnit);
    
    strncat(menuopts[4], itoa(stepMins[STEP_SACCH], buf, 10), 2);
    strcat(menuopts[4], " min");

    strncat(menuopts[5], itoa(stepTemp[STEP_SACCH], buf, 10), 3);
    strcat(menuopts[5], tempUnit);
    
    strncat(menuopts[6], itoa(stepMins[STEP_MASHOUT], buf, 10), 2);
    strcat(menuopts[6], " min");

    strncat(menuopts[7], itoa(stepTemp[STEP_MASHOUT], buf, 10), 3);
    strcat(menuopts[7], tempUnit);

    lastOption = scrollMenu("Mash Schedule", 9, lastOption);
    if (lastOption == 0) stepMins[STEP_DOUGHIN] = getTimerValue("Dough In", stepMins[STEP_DOUGHIN]);
    else if (lastOption == 1) stepTemp[STEP_DOUGHIN] = getValue("Dough In", stepTemp[STEP_DOUGHIN], 3, 0, 255, tempUnit);
    else if (lastOption == 2) stepMins[STEP_PROTEIN] = getTimerValue("Protein Rest", stepMins[STEP_PROTEIN]);
    else if (lastOption == 3) stepTemp[STEP_PROTEIN] = getValue("Protein Rest", stepTemp[STEP_PROTEIN], 3, 0, 255, tempUnit);
    else if (lastOption == 4) stepMins[STEP_SACCH] = getTimerValue("Sacch Rest", stepMins[STEP_SACCH]);
    else if (lastOption == 5) stepTemp[STEP_SACCH] = getValue("Sacch Rest", stepTemp[STEP_SACCH], 3, 0, 255, tempUnit);
    else if (lastOption == 6) stepMins[STEP_MASHOUT] = getTimerValue("Mash Out", stepMins[STEP_MASHOUT]);
    else if (lastOption == 7) stepTemp[STEP_MASHOUT] = getValue("Mash Out", stepTemp[STEP_MASHOUT], 3, 0, 255, tempUnit);
    else return;
  }
}

void manFill(unsigned long hltVol, unsigned long mashVol) {
  unsigned long fillHLT = getValveCfg(VLV_FILLHLT);
  unsigned long fillMash = getValveCfg(VLV_FILLMASH);
  unsigned long fillBoth = fillHLT | fillMash;
  unsigned int calibVals[2][10];
  unsigned long calibVols[2][10];
  unsigned int zero[2];
  unsigned long vols[2];
  unsigned long lastUpdate = 0;
  boolean fillAuto = 0;
  unsigned long volReadings[2][5];
  byte volCount = 0;
  
  for (byte i = TS_HLT; i <= TS_MASH; i++) {
    zero[i] = getZeroVol(i);
    getVolCalibs(i, calibVols[i], calibVals[i]);
  }
  
  while (1) {
    clearLCD();
    printLCD_P(0, 0, PSTR("HLT"));
    if (unit) printLCD_P(0, 5, PSTR("Fill (gal)")); else printLCD_P(0, 6, PSTR("Fill (l)"));
    printLCD_P(0, 16, PSTR("Mash"));
    printLCD_P(1, 7, PSTR("Target"));
    printLCD_P(2, 7, PSTR("Actual"));
    
    ftoa(hltVol/1000.0, buf, 2);
    truncFloat(buf, 6);
    printLCD(1, 0, buf);

    ftoa(mashVol/1000.0, buf, 2);
    truncFloat(buf, 6);
    printLCDLPad(1, 14, buf, 6, ' ');

    setValves(0);
    printLCD_P(3, 0, PSTR("Off"));
    printLCD_P(3, 17, PSTR("Off"));

    encMin = 0;
    encMax = 6;
    encCount = 0;
    byte lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      //Check volume every 200 ms and update screen with average of 5 readings (once per second)      
      if (millis() - lastUpdate > 200 * volCount) {
        for (byte i = VS_HLT; i <= VS_MASH; i++) volReadings[i][volCount] = readVolume(vSensor[i], calibVols[i], calibVals[i], zero[i]);
        volCount++;
        for (byte i = VS_HLT; i <= VS_MASH; i++) vols[i] = (volReadings[i][0] + volReadings[i][1] + volReadings[i][2] + volReadings[i][3] + volReadings[i][4]) / 5;
        if (volCount > 4) {
          volCount = 0;
          ftoa(vols[VS_HLT]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDRPad(2, 0, buf, 7, ' ');
          logVolume(VS_HLT, vols[VS_HLT]);

          ftoa(vols[VS_MASH]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDLPad(2, 14, buf, 6, ' ');
          logVolume(VS_MASH, vols[VS_MASH]);
          lastUpdate = millis();
        }
      }

      if (fillAuto) {
        if (vols[VS_HLT] < hltVol && vols[VS_MASH] < mashVol) {
          printLCD_P(3, 0, PSTR("On "));
          printLCD_P(3, 17, PSTR(" On"));
          setValves(fillBoth);
        } else if (vols[VS_HLT] < hltVol) {
          printLCD_P(3, 0, PSTR("On "));
          printLCD_P(3, 17, PSTR("Off"));
          setValves(fillHLT);
        } else if (vols[VS_MASH] < mashVol) {
          printLCD_P(3, 0, PSTR("Off"));
          printLCD_P(3, 17, PSTR(" On"));
          setValves(fillMash);
        } else {
          printLCD_P(3, 0, PSTR("Off"));
          printLCD_P(3, 17, PSTR("Off"));
          setValves(0);
        }
      }

      if (encCount != lastCount) {
        lastCount = encCount;
        if (lastCount == 0) printLCD_P(3, 4, PSTR("> Continue <"));
        else if (lastCount == 1) printLCD_P(3, 4, PSTR("> Auto Fill<"));
        else if (lastCount == 2) printLCD_P(3, 4, PSTR("> Fill HLT <"));
        else if (lastCount == 3) printLCD_P(3, 4, PSTR("> Fill Mash<"));
        else if (lastCount == 4) printLCD_P(3, 4, PSTR("> Fill Both<"));
        else if (lastCount == 5) printLCD_P(3, 4, PSTR(">  All Off <"));
        else if (lastCount == 6) printLCD_P(3, 4, PSTR(">   Abort  <"));
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        fillAuto = 0;
        if (encCount == 0) return;
        else if (encCount == 1) fillAuto = 1;
        else if (encCount == 2) {
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(fillHLT);
        } else if (encCount == 3) {
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(fillMash);
        } else if (encCount == 4) {
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(fillBoth);
        } else if (encCount == 5) {
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(0);
        } else if (encCount == 6) {
          setValves(0);
          if (confirmExit()) {
              enterStatus = 2;
              return;
            } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) { 
          setValves(0);
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
    }
  }
}

void delayStart(int iMins) {
  setTimer(iMins);
  while(1) {
    boolean redraw = 0;
    clearLCD();
    printLCD_P(0,0,PSTR("Delay Start"));
    printLCD_P(0,14,PSTR("(WAIT)"));
    while(timerValue > 0) { 
      printTimer(1,7);
      if (enterStatus == 1) {
        //Turn off heat outputs to keep from overheating if menu is up
        resetOutputs();
        enterStatus = 0;
        redraw = 1;
        strcpy_P(menuopts[0], CANCEL);
        strcpy_P(menuopts[1], PSTR("Reset Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORTAB);
        byte lastOption = scrollMenu("AutoBrew Delay Menu", 5, 0);
        if (lastOption == 1) {
          printLCDRPad(0, 14, "", 6, ' ');
          setTimer(iMins);
        } else if (lastOption == 2) pauseTimer();
        else if (lastOption == 3) return;
        else if (lastOption == 4) {
            if (confirmExit() == 1) {
              enterStatus = 2;
              return;
            }
        }
        if (redraw) break;
      }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) {
          enterStatus = 2;
          return;
        } else redraw = 1; break;
      }
    }
    if (!redraw) return;
  }
}

void mashStep(char sTitle[ ], int iMins) {
  float temp[2] = { 0, 0 };
  unsigned long convStart = 0;
  unsigned long cycleStart[2] = { 0, 0 };
  unsigned long mashHeat = getValveCfg(VLV_MASHHEAT);
  unsigned long mashIdle = getValveCfg(VLV_MASHIDLE);
  unsigned int calibVals[2][10];
  unsigned long calibVols[2][10];
  unsigned int zero[2];
  unsigned long vols[2];
  unsigned long lastUpdate = 0;
  boolean heatStatus[2] = { 0, 0 };
  boolean preheated = 0;
  unsigned long volReadings[2][5];
  byte volCount = 0;
  setAlarm(0);
  boolean doPrompt = 0;
  if (iMins == MINS_PROMPT) doPrompt = 1;
  timerValue = 0;
  
  for (byte i = TS_HLT; i <= TS_MASH; i++) {
    zero[i] = getZeroVol(i);
    getVolCalibs(i, calibVols[i], calibVals[i]);

    if (PIDEnabled[i]) {
      pid[i].SetInputLimits(0, 255);
      pid[i].SetOutputLimits(0, PIDCycle[i] * 1000);
      PIDOutput[i] = 0;
      cycleStart[i] = millis();
    }
  }

  while(1) {
    boolean redraw = 0;
    timerLastWrite = 0;
    clearLCD();
    printLCDCenter(0, 5, sTitle, 10);
    printLCD_P(2, 7, PSTR("(WAIT)"));
    printLCD_P(0, 0, PSTR("HLT"));
    printLCD_P(3, 0, PSTR("[    ]"));
    printLCD_P(0, 16, PSTR("Mash"));
    printLCD_P(3, 14, PSTR("[    ]"));
    
    if (unit) {
      printLCD_P(1, 8, PSTR("Gals"));
      printLCD_P(2, 3, PSTR("F"));
      printLCD_P(3, 4, PSTR("F"));
      printLCD_P(2, 19, PSTR("F"));
      printLCD_P(3, 18, PSTR("F"));
    } else {
      printLCD_P(1, 7, PSTR("Liters"));
      printLCD_P(2, 3, PSTR("C"));
      printLCD_P(3, 4, PSTR("C"));
      printLCD_P(2, 19, PSTR("C"));
      printLCD_P(3, 18, PSTR("C"));
    }
    
    while(!preheated || timerValue > 0 || doPrompt) {
      if (!preheated && temp[TS_MASH] >= setpoint[TS_MASH]) {
        preheated = 1;
        printLCDRPad(2, 7, "", 6, ' ');
        if(doPrompt) printLCD_P(2, 5, PSTR(">Continue<")); else setTimer(iMins);
      }



      for (byte i = VS_HLT; i <= VS_MASH; i++) {
        if (temp[i] == -1) printLCD_P(2, i * 16, PSTR("---")); else printLCDLPad(2, i * 16, itoa(temp[i], buf, 10), 3, ' ');
        printLCDLPad(3, i * 14 + 1, itoa(setpoint[i], buf, 10), 3, ' ');
        if (PIDEnabled[i]) {
          byte pct = PIDOutput[i] / PIDCycle[i] / 10;
          if (pct == 0) strcpy_P(buf, PSTR("Off"));
          else if (pct == 100) strcpy_P(buf, PSTR(" On"));
          else { itoa(pct, buf, 10); strcat(buf, "%"); }
        } else if (heatStatus[i]) strcpy_P(buf, PSTR(" On")); else strcpy_P(buf, PSTR("Off")); 
        printLCDLPad(3, i * 5 + 6, buf, 3, ' ');
      }

      //Check volume every 200 ms and update screen with average of 5 readings (once per second)      
      if (millis() - lastUpdate > 200 * volCount) {
        for (byte i = VS_HLT; i <= VS_MASH; i++) volReadings[i][volCount] = readVolume(vSensor[i], calibVols[i], calibVals[i], zero[i]);
        volCount++;
        for (byte i = VS_HLT; i <= VS_MASH; i++) vols[i] = (volReadings[i][0] + volReadings[i][1] + volReadings[i][2] + volReadings[i][3] + volReadings[i][4]) / 5;
        if (volCount > 4) {
          volCount = 0;
          ftoa(vols[VS_HLT]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDRPad(1, 0, buf, 7, ' ');
          logVolume(VS_HLT, vols[VS_HLT]);
        
          ftoa(vols[VS_MASH]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDLPad(1, 14, buf, 6, ' ');
          logVolume(VS_MASH, vols[VS_MASH]);
          lastUpdate = millis();
        }
      }

      if (preheated && !doPrompt) printTimer(2, 7);

      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        for (byte i = TS_HLT; i <= TS_MASH; i++) {
          temp[i] = read_temp(unit, tSensor[i]);
          logTemp(i, temp[i]);
        }
        convStart = 0;
      }

      for (byte i = TS_HLT; i <= TS_MASH; i++) {
        if (PIDEnabled[i]) {
          if (temp[i] == -1) {
            pid[i].SetMode(MANUAL);
            PIDOutput[i] = 0;
          } else {
            pid[i].SetMode(AUTO);
            PIDInput[i] = temp[i];
            pid[i].Compute();
          }
          if (millis() - cycleStart[i] > PIDCycle[i] * 1000) cycleStart[i] += PIDCycle[i] * 1000;
          if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(heatPin[i], HIGH); else digitalWrite(heatPin[i], LOW);
        } 

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
      }    
      //Do Valves
      if (heatStatus[TS_MASH]) setValves(mashHeat); else setValves(mashIdle); 

      if (doPrompt && preheated && enterStatus == 1) { enterStatus = 0; break; }
      else if (enterStatus == 1) {
        resetOutputs();
        enterStatus = 0;
        redraw = 1;
        strcpy_P(menuopts[0], CANCEL);
        if (timerValue > 0) strcpy_P(menuopts[1], PSTR("Reset Timer"));
        else strcpy_P(menuopts[1], PSTR("Start Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORTAB);
        byte lastOption = scrollMenu("AutoBrew Mash Menu", 5, 0);
        if (lastOption == 1) {
          preheated = 1;
          printLCDRPad(0, 14, "", 6, ' ');
          setTimer(iMins);
        } else if (lastOption == 2) pauseTimer();
        else if (lastOption == 3) return;
        else if (lastOption == 4) {
            if (confirmExit() == 1) {
              enterStatus = 2;
              return;
            }
        }
        if (redraw) break;
      }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) enterStatus = 2; else redraw = 1;
        break;
      }
    }
    if (!redraw) {
       //Turn off HLT and MASH outputs
       for (byte i = TS_HLT; i <= TS_MASH; i++) { 
         if (PIDEnabled[i]) pid[i].SetMode(MANUAL);
         digitalWrite(heatPin[i], LOW);
       }
       setValves(0);
       //Exit
      return;
    }
  }
}

void manSparge() {
  float temp[2] = { 0, 0 };
  unsigned long convStart = 0;
  unsigned long spargeIn = getValveCfg(VLV_SPARGEIN);
  unsigned long spargeOut = getValveCfg(VLV_SPARGEOUT);
  unsigned long spargeFly = spargeIn | spargeOut;
  unsigned int calibVals[2][10];
  unsigned long calibVols[2][10];
  unsigned int zero[2];
  unsigned long vols[2];
  unsigned long lastUpdate = 0;
  unsigned long volReadings[2][5];
  byte volCount = 0;
  
  for (byte i = TS_HLT; i <= TS_MASH; i++) {
    zero[i] = getZeroVol(i);
    getVolCalibs(i, calibVols[i], calibVals[i]);
  }
  
  while (1) {
    clearLCD();
    printLCD_P(0, 7, PSTR("Sparge"));
    printLCD_P(0, 0, PSTR("HLT"));
    printLCD_P(0, 16, PSTR("Mash"));
    printLCD_P(1, 0, PSTR("---"));
    printLCD_P(1, 16, PSTR("---"));
    printLCD_P(2, 0, PSTR("---.-"));
    printLCD_P(2, 15, PSTR("---.-"));
    if (unit) {
      printLCD_P(1, 3, PSTR("F"));
      printLCD_P(1, 19, PSTR("F"));
      printLCD_P(2, 8, PSTR("Gals"));
    } else {
      printLCD_P(1, 3, PSTR("C"));
      printLCD_P(1, 19, PSTR("C"));
      printLCD_P(2, 7, PSTR("Liters"));
    }

    setValves(0);
    printLCD_P(3, 0, PSTR("Off"));
    printLCD_P(3, 17, PSTR("Off"));

    encMin = 0;
    encMax = 5;
    encCount = 0;
    byte lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      //Check volume every 200 ms and update screen with average of 5 readings (once per second)      
      if (millis() - lastUpdate > 200 * volCount) {
        for (byte i = VS_HLT; i <= VS_MASH; i++) volReadings[i][volCount] = readVolume(vSensor[i], calibVols[i], calibVals[i], zero[i]);
        volCount++;
        for (byte i = VS_HLT; i <= VS_MASH; i++) vols[i] = (volReadings[i][0] + volReadings[i][1] + volReadings[i][2] + volReadings[i][3] + volReadings[i][4]) / 5;
        if (volCount > 4) {
          volCount = 0;
          ftoa(vols[VS_HLT]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDRPad(2, 0, buf, 7, ' ');
          logVolume(VS_HLT, vols[VS_HLT]);
        
          ftoa(vols[VS_MASH]/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDLPad(2, 14, buf, 6, ' ');
          logVolume(VS_MASH, vols[VS_MASH]);
          lastUpdate = millis();
        }
      }

      if (encCount != lastCount) {
        lastCount = encCount;
        if (lastCount == 0) printLCD_P(3, 4, PSTR("> Continue <"));
        else if (lastCount == 1) printLCD_P(3, 4, PSTR("> Sparge In<"));
        else if (lastCount == 2) printLCD_P(3, 4, PSTR(">Sparge Out<"));
        else if (lastCount == 3) printLCD_P(3, 4, PSTR(">Fly Sparge<"));
        else if (lastCount == 4) printLCD_P(3, 4, PSTR(">  All Off <"));
        else if (lastCount == 5) printLCD_P(3, 4, PSTR(">   Abort  <"));
      }
      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        for (byte i = TS_HLT; i <= TS_MASH; i++) {
          temp[i] = read_temp(unit, tSensor[i]);
          logTemp(i, temp[i]);
          if (temp[i] == -1) printLCD_P(1, i * 16, PSTR("---")); else printLCDLPad(1, i * 16, itoa(temp[i], buf, 10), 3, ' ');
        }
        convStart = 0;
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        if (encCount == 0) return;
        else if (encCount == 1) {
          printLCD_P(3, 0, PSTR("On "));
          printLCD_P(3, 17, PSTR("Off"));
          setValves(spargeIn);
        } else if (encCount == 2) {
          printLCD_P(3, 0, PSTR("Off"));
          printLCD_P(3, 17, PSTR(" On"));
          setValves(spargeOut);
        } else if (encCount == 3) {
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(spargeFly);
        } else if (encCount == 4) {
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(0);
        } else if (encCount == 5) {
            if (confirmExit()) {
              setValves(0);
              enterStatus = 2;
              return;
            } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) {
          setValves(0);
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
    }
  }  
}

void boilStage(unsigned int iMins, unsigned int boilAdds) {
  float temp = 0;
  unsigned long convStart = 0;
  unsigned long cycleStart = 0;
  boolean heatStatus = 0;
  boolean preheated = 0;
  unsigned int triggered = getABAddsTrig();
  setAlarm(0);
  timerValue = 0;
  unsigned int calibVals[10];
  unsigned long calibVols[10];
  unsigned long vol;
  unsigned long lastUpdate = 0;
  unsigned long volReadings[5];
  byte volCount = 0;
  
  unsigned int zero = getZeroVol(VS_KETTLE);
  getVolCalibs(VS_KETTLE, calibVols, calibVals);
    
  if (PIDEnabled[TS_KETTLE]) {
    pid[TS_KETTLE].SetInputLimits(0, 255);
    pid[TS_KETTLE].SetOutputLimits(0, PIDCycle[TS_KETTLE] * 1000);
    PIDOutput[TS_KETTLE] = 0;
    cycleStart = millis();
  }
  
  while(1) {
    boolean redraw = 0;
    timerLastWrite = 0;
    clearLCD();
    printLCD_P(0,0,PSTR("Kettle"));
    printLCD_P(0,8,PSTR("Boil"));
    if (setpoint[TS_KETTLE] > 0) printLCD_P(2,7,PSTR("(WAIT)"));
    printLCD_P(3,0,PSTR("[    ]"));

    if (unit) {
      printLCD_P(1, 8, PSTR("Gals"));
      printLCD_P(2, 3, PSTR("F"));
      printLCD_P(3, 4, PSTR("F"));
    } else {
      printLCD_P(1, 7, PSTR("Liters"));
      printLCD_P(2, 3, PSTR("C"));
      printLCD_P(3, 4, PSTR("C"));
    }
    
    while(!preheated || timerValue > 0) {
      if (preheated) { if (alarmStatus) printLCD_P(0, 19, PSTR("!")); else printLCD_P(0, 19, SPACE); }
      if (!preheated && temp >= setpoint[TS_KETTLE] && setpoint[TS_KETTLE] > 0) {
        preheated = 1;
        printLCDRPad(0, 14, "", 6, ' ');
        setTimer(iMins);
      }

      //Check volume every 200 ms and update screen with average of 5 readings (once per second)      
      if (millis() - lastUpdate > 200 * volCount) {
        volReadings[volCount] = readVolume(vSensor[VS_KETTLE], calibVols, calibVals, zero);
        volCount++;
        vol = (volReadings[0] + volReadings[1] + volReadings[2] + volReadings[3] + volReadings[4]) / 5;
        if (volCount > 4) {
          volCount = 0;
          ftoa(vol/1000.0, buf, 2);
          truncFloat(buf, 6);
          printLCDRPad(1, 0, buf, 7, ' ');
          logVolume(VS_KETTLE, vol);
          lastUpdate = millis();
        }
      }
      
      if (temp == -1) printLCD_P(2, 0, PSTR("---")); else printLCDLPad(2, 0, itoa(temp, buf, 10), 3, ' ');
      printLCDLPad(3, 1, itoa(setpoint[TS_KETTLE], buf, 10), 3, ' ');
      if (PIDEnabled[TS_KETTLE]) {
        byte pct = PIDOutput[TS_KETTLE] / PIDCycle[TS_KETTLE] / 10;
        if (pct == 0) strcpy_P(buf, PSTR("Off"));
        else if (pct == 100) strcpy_P(buf, PSTR(" On"));
        else { itoa(pct, buf, 10); strcat(buf, "%"); }
      } else if (heatStatus) strcpy_P(buf, PSTR(" On")); else strcpy_P(buf, PSTR("Off")); 
      printLCDLPad(3, 6, buf, 3, ' ');

      if (preheated) {
        printTimer(2, 7);
        if ((boilAdds ^ triggered) & 1) { setAlarm(1); triggered |= 1; setABAddsTrig(triggered); }
        if (((boilAdds ^ triggered) & 2) && timerValue <= 105 * 60000) { setAlarm(1); triggered |= 2; setABAddsTrig(triggered); } //105 Min
        if (((boilAdds ^ triggered) & 4) && timerValue <= 90 * 60000) { setAlarm(1); triggered |= 4; setABAddsTrig(triggered); } //90 Min
        if (((boilAdds ^ triggered) & 8) && timerValue <= 75 * 60000) { setAlarm(1); triggered |= 8; setABAddsTrig(triggered); } //75 Min
        if (((boilAdds ^ triggered) & 16) && timerValue <= 60 * 60000) { setAlarm(1); triggered |= 16; setABAddsTrig(triggered); } //60 Min
        if (((boilAdds ^ triggered) & 32) && timerValue <= 45 * 60000) { setAlarm(1); triggered |= 32; setABAddsTrig(triggered); } //45 Min
        if (((boilAdds ^ triggered) & 64) && timerValue <= 30 * 60000) { setAlarm(1); triggered |= 64; setABAddsTrig(triggered); } //30 Min
        if (((boilAdds ^ triggered) & 128) && timerValue <= 20 * 60000) { setAlarm(1); triggered |= 128; setABAddsTrig(triggered); } //20 Min
        if (((boilAdds ^ triggered) & 256) && timerValue <= 15 * 60000) { setAlarm(1); triggered |= 256; setABAddsTrig(triggered); } //15 Min
        if (((boilAdds ^ triggered) & 512) && timerValue <= 10 * 60000) { setAlarm(1); triggered |= 512; setABAddsTrig(triggered); } //10 Min
        if (((boilAdds ^ triggered) & 1024) && timerValue <= 5 * 60000) { setAlarm(1); triggered |= 1024; setABAddsTrig(triggered); } //5 Min
      }
      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        temp = read_temp(unit, tSensor[TS_KETTLE]);
        logTemp(TS_KETTLE, temp);
        convStart = 0;
      }

      if (PIDEnabled[TS_KETTLE]) {
        if (temp == -1) {
          pid[TS_KETTLE].SetMode(MANUAL);
          PIDOutput[TS_KETTLE] = 0;
        } else {
          pid[TS_KETTLE].SetMode(AUTO);
          PIDInput[TS_KETTLE] = temp;
          pid[TS_KETTLE].Compute();
        }
        if (millis() - cycleStart > PIDCycle[TS_KETTLE] * 1000) cycleStart += PIDCycle[TS_KETTLE] * 1000;
        if (PIDOutput[TS_KETTLE] > millis() - cycleStart) digitalWrite(KETTLEHEAT_PIN, HIGH); else digitalWrite(KETTLEHEAT_PIN, LOW);
      } else {
        if (heatStatus) {
          if (temp == -1 || temp >= setpoint[TS_KETTLE]) {
            digitalWrite(KETTLEHEAT_PIN, LOW);
            heatStatus = 0;
          } else digitalWrite(KETTLEHEAT_PIN, HIGH);
        } else { 
          if (temp != -1 && (float)(setpoint[TS_KETTLE] - temp) >= (float) hysteresis[TS_KETTLE] / 10.0) {
            digitalWrite(KETTLEHEAT_PIN, HIGH);
            heatStatus = 1;
          } else digitalWrite(KETTLEHEAT_PIN, LOW);
        }
      }

      if (enterStatus == 1 && alarmStatus) {
        enterStatus = 0;
        setAlarm(0);
      } else if (enterStatus == 1) {
        redraw = 1;
        resetOutputs();
        enterStatus = 0;
        strcpy_P(menuopts[0], CANCEL);
        if (timerValue > 0) strcpy_P(menuopts[1], PSTR("Reset Timer"));
        else strcpy_P(menuopts[1], PSTR("Start Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORTAB);
        byte lastOption = scrollMenu("AutoBrew Boil Menu", 5, 0);
        if (lastOption == 1) {
          preheated = 1;
          printLCDRPad(0, 14, "", 6, ' ');
          setTimer(iMins);
        } else if (lastOption == 2) pauseTimer();
        else if (lastOption == 3) return;
        else if (lastOption == 4) {
            if (confirmExit() == 1) {
              enterStatus = 2;
              return;
            }
        }
        if (redraw) break;
      }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) enterStatus = 2; else redraw = 1;
        break;
      }
    }
    if (!redraw) {
      if ((boilAdds ^ triggered) & 2048) { setAlarm(1); triggered |= 2048; setABAddsTrig(triggered); } //0 Min
      //Turn off output
       if (PIDEnabled[TS_KETTLE]) pid[TS_KETTLE].SetMode(MANUAL);
       digitalWrite(KETTLEHEAT_PIN, LOW);
       //Exit
      return;
    }
  }
}

void manChill(byte settemp) {
  boolean doAuto = 0;
  unsigned long chillLow = getValveCfg(VLV_CHILLBEER);
  unsigned long chillHigh = getValveCfg(VLV_CHILLH2O);
  unsigned long chillNorm = chillLow | chillHigh;
  unsigned long convStart = 0;
  float temp[6];
  
  while (1) {
    clearLCD();
    printLCD_P(0, 8, PSTR("Chill"));
    printLCD_P(0, 0, PSTR("Beer"));
    printLCD_P(0, 17, PSTR("H2O"));
    printLCD_P(1, 9, PSTR("IN"));
    printLCD_P(2, 9, PSTR("OUT"));
    if (unit) {
      printLCD_P(1, 3, PSTR("F"));
      printLCD_P(1, 19, PSTR("F"));
      printLCD_P(2, 3, PSTR("F"));
      printLCD_P(2, 19, PSTR("F"));
    } else {
      printLCD_P(1, 3, PSTR("C"));
      printLCD_P(1, 19, PSTR("C"));
      printLCD_P(2, 3, PSTR("C"));
      printLCD_P(2, 19, PSTR("C"));
    }
    
    setValves(0);
    printLCD_P(3, 0, PSTR("Off"));
    printLCD_P(3, 17, PSTR("Off"));

    encMin = 0;
    encMax = 6;
    encCount = 0;
    int lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      if (encCount != lastCount) {
        lastCount = encCount;
        if (lastCount == 0) printLCD_P(3, 4, PSTR("> Continue <"));
        else if (lastCount == 1) printLCD_P(3, 4, PSTR(">Chill Norm<"));
        else if (lastCount == 2) printLCD_P(3, 4, PSTR("> H2O Only <"));
        else if (lastCount == 3) printLCD_P(3, 4, PSTR("> Beer Only<"));
        else if (lastCount == 4) printLCD_P(3, 4, PSTR(">  All Off <"));
        else if (lastCount == 5) printLCD_P(3, 4, PSTR(">   Auto   <"));
        else if (lastCount == 6) printLCD_P(3, 4, PSTR(">   Abort  <"));
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        if (encCount == 0) return;
        else if (encCount == 1) {
            doAuto = 0;
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(chillNorm);
        } else if (encCount == 2) {
            doAuto = 0;
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(chillHigh);
        } else if (encCount == 3) {            doAuto = 0;
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(chillLow);
        } else if (encCount == 4) {            doAuto = 0;
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(0);
        } else if (encCount == 5) {
          doAuto = 1;
        } else if (encCount == 6) {
          if (confirmExit()) {
              setValves(0);
              enterStatus = 2;
              return;
            } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) { 
          setValves(0);
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        for (byte i = TS_KETTLE; i <= TS_BEEROUT; i++) {
          temp[i] = read_temp(unit, tSensor[i]);
          logTemp(i, temp[i]);
        }
        convStart = 0;
      }
      if (temp[TS_KETTLE] == -1) printLCD_P(1, 0, PSTR("---")); else printLCDLPad(1, 0, itoa(temp[TS_KETTLE], buf, 10), 3, ' ');
      if (temp[TS_BEEROUT] == -1) printLCD_P(2, 0, PSTR("---")); else printLCDLPad(2, 0, itoa(temp[TS_BEEROUT], buf, 10), 3, ' ');
      if (temp[TS_H2OIN] == -1) printLCD_P(1, 16, PSTR("---")); else printLCDLPad(1, 16, itoa(temp[TS_H2OIN], buf, 10), 3, ' ');
      if (temp[TS_H2OOUT] == -1) printLCD_P(2, 16, PSTR("---")); else printLCDLPad(2, 16, itoa(temp[TS_H2OOUT], buf, 10), 3, ' ');
      if (doAuto) {
        if (temp[TS_BEEROUT] > settemp + 1.0) {
            printLCD_P(3, 0, PSTR("Off"));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(chillHigh);
        } else if (temp[TS_BEEROUT] < settemp - 1.0) {
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR("Off"));
            setValves(chillLow);
        } else {
            printLCD_P(3, 0, PSTR("On "));
            printLCD_P(3, 17, PSTR(" On"));
            setValves(chillNorm);
        }
      }
    }
  }  
}

unsigned int editHopSchedule (unsigned int sched) {
  unsigned int retVal = sched;
  byte lastOption = 0;
  while (1) {
    if (retVal & 1) strcpy_P(menuopts[0], PSTR("Boil: On")); else strcpy_P(menuopts[0], PSTR("Boil: Off"));
    if (retVal & 2) strcpy_P(menuopts[1], PSTR("105 Min: On")); else strcpy_P(menuopts[1], PSTR("105 Min: Off"));
    if (retVal & 4) strcpy_P(menuopts[2], PSTR("90 Min: On")); else strcpy_P(menuopts[2], PSTR("90 Min: Off"));
    if (retVal & 8) strcpy_P(menuopts[3], PSTR("75 Min: On")); else strcpy_P(menuopts[3], PSTR("75 Min: Off"));
    if (retVal & 16) strcpy_P(menuopts[4], PSTR("60 Min: On")); else strcpy_P(menuopts[4], PSTR("60 Min: Off"));
    if (retVal & 32) strcpy_P(menuopts[5], PSTR("45 Min: On")); else strcpy_P(menuopts[5], PSTR("45 Min: Off"));
    if (retVal & 64) strcpy_P(menuopts[6], PSTR("30 Min: On")); else strcpy_P(menuopts[6], PSTR("30 Min: Off"));
    if (retVal & 128) strcpy_P(menuopts[7], PSTR("20 Min: On")); else strcpy_P(menuopts[7], PSTR("20 Min: Off"));
    if (retVal & 256) strcpy_P(menuopts[8], PSTR("15 Min: On")); else strcpy_P(menuopts[8], PSTR("15 Min: Off"));
    if (retVal & 512) strcpy_P(menuopts[9], PSTR("10 Min: On")); else strcpy_P(menuopts[9], PSTR("10 Min: Off"));
    if (retVal & 1024) strcpy_P(menuopts[10], PSTR("5 Min: On")); else strcpy_P(menuopts[10], PSTR("5 Min: Off"));
    if (retVal & 2048) strcpy_P(menuopts[11], PSTR("0 Min: On")); else strcpy_P(menuopts[11], PSTR("0 Min: Off"));
    strcpy_P(menuopts[12], PSTR("Exit"));

    lastOption = scrollMenu("Boil Additions", 13, lastOption);
    if (lastOption == 0) retVal = retVal ^ 1;
    else if (lastOption == 1) retVal = retVal ^ 2;
    else if (lastOption == 2) retVal = retVal ^ 4;
    else if (lastOption == 3) retVal = retVal ^ 8;
    else if (lastOption == 4) retVal = retVal ^ 16;
    else if (lastOption == 5) retVal = retVal ^ 32;
    else if (lastOption == 6) retVal = retVal ^ 64;
    else if (lastOption == 7) retVal = retVal ^ 128;
    else if (lastOption == 8) retVal = retVal ^ 256;
    else if (lastOption == 9) retVal = retVal ^ 512;
    else if (lastOption == 10) retVal = retVal ^ 1024;
    else if (lastOption == 11) retVal = retVal ^ 2048;
    else if (lastOption == 12) return retVal;
    else return sched;
  }
}
