#define MINS_PROMPT -1
#define STEP_DOUGHIN 0
#define STEP_PROTEIN 1
#define STEP_SACCH 2
#define STEP_MASHOUT 3

unsigned int hoptimes[10] = { 105, 90, 75, 60, 45, 30, 20, 15, 10, 5 };

void doAutoBrew() {
  unsigned int delayMins = 0;
  byte stepTemp[4], stepMins[4], spargeTemp;
  unsigned long grainWeight = 0;
  unsigned int boilMins;
  unsigned int mashRatio;
  unsigned int boilAdds = 0;
  byte grainTemp;
  byte HLTTemp;
  
  HLTTemp = getABHLTTemp();
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
  
  if (pwrRecovery == 0) {
    recoveryStep = 0;
    //Set Zero Volume Calibrations on Normal AutoBrew Start (Not Power Loss Recovery)
    for (byte i = TS_HLT; i <= TS_KETTLE; i++) zeroVol[i] = analogRead(vSensor[i]);
    saveZeroVols();
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
    logFieldI(HLTTemp);
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
    strcat_P(menuopts[0], VOLUNIT);

    ftoa((float)grainWeight/1000, buf, 3);
    truncFloat(buf, 7);
    strcat(menuopts[1], buf);
    strcat_P(menuopts[1], WTUNIT);

    strncat(menuopts[2], itoa(grainTemp, buf, 10), 3);
    strcat_P(menuopts[2], TUNIT);

    strncat(menuopts[3], itoa(boilMins, buf, 10), 3);
    strcat_P(menuopts[3], PSTR(" min"));
    
    ftoa((float)mashRatio/100, buf, 2);
    truncFloat(buf, 4);
    strcat(menuopts[4], buf);
    strcat_P(menuopts[4], PSTR(":1"));

    strncat(menuopts[5], itoa(delayMins/60, buf, 10), 4);
    strcat_P(menuopts[5], PSTR(" hr"));
    
    strncat(menuopts[6], itoa(HLTTemp, buf, 10), 3);
    strcat_P(menuopts[6], TUNIT);
    
    strncat(menuopts[7], itoa(spargeTemp, buf, 10), 3);
    strcat_P(menuopts[7], TUNIT);
    
    strncat(menuopts[8], itoa(pitchTemp, buf, 10), 3);
    strcat_P(menuopts[8], TUNIT);
    
    lastOption = scrollMenu("AutoBrew Parameters", 15, lastOption);
    if (lastOption == 0) tgtVol[TS_KETTLE] = getValue(PSTR("Batch Volume"), tgtVol[TS_KETTLE], 7, 3, 9999999, VOLUNIT);
    else if (lastOption == 1) grainWeight = getValue(PSTR("Grain Weight"), grainWeight, 7, 3, 9999999, WTUNIT);
    else if (lastOption == 2) grainTemp = getValue(PSTR("Grain Temp"), grainTemp, 3, 0, 255, TUNIT);
    else if (lastOption == 3) boilMins = getTimerValue(PSTR("Boil Length"), boilMins);
    else if (lastOption == 4) { 
      #ifdef USEMETRIC
        mashRatio = getValue(PSTR("Mash Ratio"), mashRatio, 3, 2, 999, PSTR(" l/kg")); 
      #else
        mashRatio = getValue(PSTR("Mash Ratio"), mashRatio, 3, 2, 999, PSTR(" qts/lb"));
      #endif
    }
    else if (lastOption == 5) delayMins = getTimerValue(PSTR("Delay Start"), delayMins);
    else if (lastOption == 6) HLTTemp = getValue(PSTR("HLT Setpoint"), HLTTemp, 3, 0, 255, TUNIT);
    else if (lastOption == 7) spargeTemp = getValue(PSTR("Sparge Temp"), spargeTemp, 3, 0, 255, TUNIT);
    else if (lastOption == 8) pitchTemp = getValue(PSTR("Pitch Temp"), pitchTemp, 3, 0, 255, TUNIT);
    else if (lastOption == 9) editMashSchedule(stepTemp, stepMins);
    else if (lastOption == 10) boilAdds = editHopSchedule(boilAdds);
    else if (lastOption == 11) inMenu = 0;
    else if (lastOption == 12) {
      byte profile = 0;
      //Display Stored Programs
      for (byte i = 0; i < 20; i++) getProgName(i, menuopts[i]);
      profile = scrollMenu("Load Program", 20, profile);
      if (profile < 20) {
        spargeTemp = getProgSparge(profile);
        grainWeight = getProgGrain(profile);
        delayMins = getProgDelay(profile);
        boilMins = getProgBoil(profile);
        mashRatio = getProgRatio(profile);
        getProgSchedule(profile, stepTemp, stepMins);
        getProgVols(profile, tgtVol);
        HLTTemp = getProgHLT(profile);
        pitchTemp = getProgPitch(profile);
        boilAdds = getProgAdds(profile);
        grainTemp = getProgGrainT(profile);
      }
    } 
    else if (lastOption == 13) {
      byte profile = 0;
      //Display Stored Schedules
      for (byte i = 0; i < 20; i++) getProgName(i, menuopts[i]);
      profile = scrollMenu("Save Program", 20, profile);
      if (profile < 20) {
        getString(PSTR("Save Program As:"), menuopts[profile], 19);
        setProgName(profile, menuopts[profile]);
        setProgSparge(profile, spargeTemp);
        setProgGrain(profile, grainWeight);
        setProgDelay(profile, delayMins);
        setProgBoil(profile, boilMins);
        setProgRatio(profile, mashRatio);
        setProgSchedule(profile, stepTemp, stepMins);
        setProgVols(profile, tgtVol);
        setProgHLT(profile, HLTTemp);
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

    #ifdef USEMETRIC
      tgtVol[TS_HLT] += round(grainWeight * 1.7884);
    #else
      tgtVol[TS_HLT] += round(grainWeight * .2143);
    #endif

    //Calculate mash volume
    tgtVol[TS_MASH] = round(grainWeight * mashRatio / 100.0);
    //Convert qts to gal for US
    #ifndef USEMETRIC
      tgtVol[TS_MASH] = round(tgtVol[TS_MASH] / 4.0);
    #endif
    tgtVol[TS_HLT] -= tgtVol[TS_MASH];

    //Grain-to-volume factor for mash tun capacity (1 lb = .15 gal)
    float grain2Vol;
    #ifdef USEMETRIC
      grain2Vol = 1.25;
    #else
      grain2Vol = .15;
    #endif

    //Check for capacity overages
    if (tgtVol[TS_HLT] > capacity[TS_HLT]) {
      clearLCD();
      printLCD_P(0, 0, PSTR("HLT Capacity Issue"));
      printLCD_P(1, 0, PSTR("Sparge Vol:"));
      ftoa(tgtVol[TS_HLT]/1000.0, buf, 2);
      truncFloat(buf, 5);
      printLCD(1, 11, buf);
      printLCD_P(1, 16, VOLUNIT);
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
      printLCD_P(1, 16, VOLUNIT);
      printLCD_P(2, 0, PSTR("Grain Vol:"));
      ftoa(round(grainWeight * grain2Vol) / 1000.0, buf, 2);
      truncFloat(buf, 5);
      printLCD(2, 11, buf);
      printLCD_P(2, 16, VOLUNIT);
      printLCD_P(3, 4, PSTR("> Continue <"));
      while (!enterStatus) delay(500);
      enterStatus = 0;
    }

    //Save Values to EEPROM for Recovery
    setPwrRecovery(1);
    setABRecovery(0);
    setABHLTTemp(HLTTemp);
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
      manFill();
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
        #ifdef USEMETRIC
          strikeTemp = round(.41 / (mashRatio / 100.0) * (strikeTemp - grainTemp)) + strikeTemp;
        #else
          strikeTemp = round(.2 / (mashRatio / 100.0) * (strikeTemp - grainTemp)) + strikeTemp;
        #endif
        setpoint[TS_HLT] = HLTTemp;
        setpoint[TS_MASH] = strikeTemp;
        setpoint[VS_STEAM] = steamTgt;
      }
      setABRecovery(3);
      mashStep("Preheat", MINS_PROMPT);  
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 4:
      setpoint[TS_HLT] = 0;
      setpoint[TS_MASH] = 0;
      setpoint[VS_STEAM] = steamTgt;
      setABRecovery(4);
      setValves(vlvConfig[VLV_ADDGRAIN]);
      inMenu = 1;
      while(inMenu) {
        clearLCD();
        printLCD_P(1, 5, PSTR("Add Grain"));
        printLCD_P(2, 0, PSTR("Press Enter to Start"));
        while(enterStatus == 0) {
          brewCore();
          if (chkMsg()) {
            if (strcasecmp(msg[0], "SELECT") == 0) {
              enterStatus = 1;
              clearMsg();
            } else rejectMsg(LOGSCROLLP);
          }
        }
        if (enterStatus == 1) {
          enterStatus = 0;
          inMenu = 0;
        } else {
          enterStatus = 0;
          if (confirmExit() == 1) {
            resetOutputs(); 
            setPwrRecovery(0); 
            return;
          }
        }
      }
    case 5:
      if (stepTemp[STEP_DOUGHIN]) {
        setABRecovery(5);
        setpoint[TS_HLT] = HLTTemp;
        setpoint[TS_MASH] = stepTemp[STEP_DOUGHIN];
        setpoint[VS_STEAM] = steamTgt;
        unsigned int recoverMins = getTimerRecovery();
        if (recoveryStep == 5 && recoverMins > 0) mashStep("Dough In", recoverMins); else mashStep("Dough In", stepMins[STEP_DOUGHIN]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 6:
      if (stepTemp[STEP_PROTEIN]) {
        setABRecovery(6);
        setpoint[TS_HLT] = HLTTemp;
        setpoint[TS_MASH] = stepTemp[STEP_PROTEIN];
        setpoint[VS_STEAM] = steamTgt;
        unsigned int recoverMins = getTimerRecovery();
        if (recoveryStep == 6 && recoverMins > 0) mashStep("Protein", recoverMins); else mashStep("Protein", stepMins[STEP_PROTEIN]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 7:
      if (stepTemp[STEP_SACCH]) {
        setABRecovery(7);
        setpoint[TS_HLT] = HLTTemp;
        setpoint[TS_MASH] = stepTemp[STEP_SACCH];
        setpoint[VS_STEAM] = steamTgt;
        unsigned int recoverMins = getTimerRecovery();
        if (recoveryStep == 7 && recoverMins > 0) mashStep("Sacch Rest", recoverMins); else mashStep("Sacch Rest", stepMins[STEP_SACCH]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 8:
      if (stepTemp[STEP_MASHOUT]) {
        setABRecovery(8);
        setpoint[TS_HLT] = HLTTemp;
        setpoint[TS_MASH] = stepTemp[STEP_MASHOUT];
        setpoint[VS_STEAM] = steamTgt;
        unsigned int recoverMins = getTimerRecovery();
        if (recoveryStep == 8 && recoverMins > 0) mashStep("Mash Out", recoverMins); else mashStep("Mash Out", stepMins[STEP_MASHOUT]);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 9:
      //Hold last mash temp until user exits
      setABRecovery(9); 
      setpoint[TS_HLT] = spargeTemp;
      //Cycle through steps and use last non-zero step for mash
      for (byte i = STEP_DOUGHIN; i <= STEP_MASHOUT; i++) if (stepTemp[i]) setpoint[TS_MASH] = stepTemp[i];
      setpoint[VS_STEAM] = steamTgt;
      mashStep("End Mash", MINS_PROMPT);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      setpoint[TS_HLT] = 0;
      setpoint[TS_MASH] = 0;
      setpoint[VS_STEAM] = 0;
      
    case 10:  
      setABRecovery(10); 
      manSparge();
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    case 11:
      {
        setABRecovery(11); 
        setpoint[TS_KETTLE] = getBoilTemp();
        unsigned int recoverMins = getTimerRecovery();
        if (recoveryStep == 11 && recoverMins > 0) boilStage(recoverMins, boilAdds); else boilStage(boilMins, boilAdds);
        if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
      }
    case 12:
      setABRecovery(12); 
      manChill();
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
  }  
  enterStatus = 0;
  setABRecovery(0);
  setPwrRecovery(0);
}

void editMashSchedule(byte stepTemp[4], byte stepMins[4]) {
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
    strcat_P(menuopts[1], TUNIT);
    
    strncat(menuopts[2], itoa(stepMins[STEP_PROTEIN], buf, 10), 2);
    strcat(menuopts[2], " min");

    strncat(menuopts[3], itoa(stepTemp[STEP_PROTEIN], buf, 10), 3);
    strcat_P(menuopts[3], TUNIT);
    
    strncat(menuopts[4], itoa(stepMins[STEP_SACCH], buf, 10), 2);
    strcat(menuopts[4], " min");

    strncat(menuopts[5], itoa(stepTemp[STEP_SACCH], buf, 10), 3);
    strcat_P(menuopts[5], TUNIT);
    
    strncat(menuopts[6], itoa(stepMins[STEP_MASHOUT], buf, 10), 2);
    strcat(menuopts[6], " min");

    strncat(menuopts[7], itoa(stepTemp[STEP_MASHOUT], buf, 10), 3);
    strcat_P(menuopts[7], TUNIT);

    lastOption = scrollMenu("Mash Schedule", 9, lastOption);
    if (lastOption == 0) stepMins[STEP_DOUGHIN] = getTimerValue(PSTR("Dough In"), stepMins[STEP_DOUGHIN]);
    else if (lastOption == 1) stepTemp[STEP_DOUGHIN] = getValue(PSTR("Dough In"), stepTemp[STEP_DOUGHIN], 3, 0, 255, TUNIT);
    else if (lastOption == 2) stepMins[STEP_PROTEIN] = getTimerValue(PSTR("Protein Rest"), stepMins[STEP_PROTEIN]);
    else if (lastOption == 3) stepTemp[STEP_PROTEIN] = getValue(PSTR("Protein Rest"), stepTemp[STEP_PROTEIN], 3, 0, 255, TUNIT);
    else if (lastOption == 4) stepMins[STEP_SACCH] = getTimerValue(PSTR("Sacch Rest"), stepMins[STEP_SACCH]);
    else if (lastOption == 5) stepTemp[STEP_SACCH] = getValue(PSTR("Sacch Rest"), stepTemp[STEP_SACCH], 3, 0, 255, TUNIT);
    else if (lastOption == 6) stepMins[STEP_MASHOUT] = getTimerValue(PSTR("Mash Out"), stepMins[STEP_MASHOUT]);
    else if (lastOption == 7) stepTemp[STEP_MASHOUT] = getValue(PSTR("Mash Out"), stepTemp[STEP_MASHOUT], 3, 0, 255, TUNIT);
    else return;
  }
}

void manFill() {
  autoValve = 0;
  
  while (1) {
    clearLCD();
    printLCD_P(0, 0, PSTR("HLT"));
    #ifdef USEMETRIC
      printLCD_P(0, 6, PSTR("Fill (l)"));
    #else
      printLCD_P(0, 5, PSTR("Fill (gal)"));
    #endif
    printLCD_P(0, 16, PSTR("Mash"));
    printLCD_P(1, 7, PSTR("Target"));
    printLCD_P(2, 7, PSTR("Actual"));
    printLCD_P(3, 4, PSTR(">"));
    printLCD_P(3, 15, PSTR("<"));
    ftoa(tgtVol[VS_HLT]/1000.0, buf, 2);
    truncFloat(buf, 6);
    printLCD(1, 0, buf);

    ftoa(tgtVol[VS_MASH]/1000.0, buf, 2);
    truncFloat(buf, 6);
    printLCDLPad(1, 14, buf, 6, ' ');

    setValves(0);

    encMin = 0;
    encMax = 6;
    encCount = 0;
    byte lastCount = 1;
            
    boolean redraw = 0;
    while(!redraw) {
      brewCore();
      ftoa(volAvg[VS_HLT]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDRPad(2, 0, buf, 7, ' ');

      ftoa(volAvg[VS_MASH]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDLPad(2, 14, buf, 6, ' ');

      if (encCount != lastCount) {
        lastCount = encCount;
        printLCDRPad(3, 5, "", 10, ' ');
        if (lastCount == 0) printLCD_P(3, 6, CONTINUE);
        else if (lastCount == 1) printLCD_P(3, 8, AUTOFILL);
        else if (lastCount == 2) printLCD_P(3, 6, FILLHLT);
        else if (lastCount == 3) printLCD_P(3, 6, FILLMASH);
        else if (lastCount == 4) printLCD_P(3, 6, FILLBOTH);
        else if (lastCount == 5) printLCD_P(3, 7, ALLOFF);
        else if (lastCount == 6) printLCD_P(3, 8, ABORT);
      }

      if (chkMsg()) {
        if (strcasecmp(msg[0], "SELECT") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 1 && val  >= 0 && val <= 6) {
            encCount = val;
            enterStatus = 1;
            clearMsg();
          } else rejectParam(LOGSCROLLP);
        } else rejectMsg(LOGSCROLLP);
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        autoValve = 0;
        if (encCount == 0) {
          resetOutputs();
          return;
        } else if (encCount == 1) autoValve = AV_FILL;
        else if (encCount == 2) setValves(vlvConfig[VLV_FILLHLT]);
        else if (encCount == 3) setValves(vlvConfig[VLV_FILLMASH]);
        else if (encCount == 4) setValves(vlvConfig[VLV_FILLHLT] | vlvConfig[VLV_FILLMASH]);
        else if (encCount == 5) setValves(0);
        else if (encCount == 6) {
          setValves(0);
          if (confirmExit()) {
            enterStatus = 2;
            resetOutputs();
            return;
          } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) { 
          resetOutputs();
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
      if (vlvBits == vlvConfig[VLV_FILLMASH]) {
        printLCD_P(3, 0, PSTR("Off"));
        printLCD_P(3, 17, PSTR(" On"));
      } else if (vlvBits == vlvConfig[VLV_FILLHLT]) {
        printLCD_P(3, 0, PSTR("On "));
        printLCD_P(3, 17, PSTR("Off"));
      } else if (vlvBits == (vlvConfig[VLV_FILLHLT] | vlvConfig[VLV_FILLMASH])) {
        printLCD_P(3, 0, PSTR("On "));
        printLCD_P(3, 17, PSTR(" On"));
      } else {
        printLCD_P(3, 0, PSTR("Off"));
        printLCD_P(3, 17, PSTR("Off"));
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
      brewCore();
      printTimer(1,7);

      if (chkMsg()) {
        if (strcasecmp(msg[0], "POPMENU") == 0) {
          enterStatus = 1;
          clearMsg();
        } else rejectMsg(LOGAB);
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        redraw = 1;
        strcpy_P(menuopts[0], CANCEL);
        strcpy_P(menuopts[1], PSTR("Reset Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORT);
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
  boolean preheated = 0;
  setAlarm(0);
  boolean doPrompt = 0;
  if (iMins == MINS_PROMPT) doPrompt = 1;
  timerValue = 0;
  autoValve = AV_MASH;
  
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
    
    #ifdef USEMETRIC
      printLCD_P(1, 7, PSTR("Liters"));
    #else
      printLCD_P(1, 8, PSTR("Gals"));
    #endif

    printLCD_P(2, 3, TUNIT);
    printLCD_P(3, 4, TUNIT);
    printLCD_P(2, 19, TUNIT);
    printLCD_P(3, 18, TUNIT);
    
    while(!preheated || timerValue > 0 || doPrompt) {
      brewCore();
      if (!preheated && temp[TS_MASH] >= setpoint[TS_MASH]) {
        preheated = 1;
        printLCDRPad(2, 7, "", 6, ' ');
        if(doPrompt) {
          printLCD_P(2, 5, PSTR(">Continue<"));
          logStart_P(LOGMENU);
          logField_P(LOGSCROLLP);
          logField(sTitle);
          logFieldI(1);
          logField_P(CONTINUE);
          logEnd();
        } else setTimer(iMins);
      }

      ftoa(volAvg[VS_HLT]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDRPad(1, 0, buf, 7, ' ');
        
      ftoa(volAvg[VS_MASH]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDLPad(1, 14, buf, 6, ' ');

      for (byte i = VS_HLT; i <= VS_MASH; i++) {
        if (temp[i] == -1) printLCD_P(2, i * 16, PSTR("---")); else printLCDLPad(2, i * 16, itoa(temp[i], buf, 10), 3, ' ');
        printLCDLPad(3, i * 14 + 1, itoa(setpoint[i], buf, 10), 3, ' ');
        byte pct;
        if (PIDEnabled[i]) {
          pct = PIDOutput[i] / PIDCycle[i] / 10;
          if (pct == 0) strcpy_P(buf, PSTR("Off"));
          else if (pct == 100) strcpy_P(buf, PSTR(" On"));
          else { itoa(pct, buf, 10); strcat(buf, "%"); }
        } else if (heatStatus[i]) {
          strcpy_P(buf, PSTR(" On")); 
          pct = 100;
        } else {
          strcpy_P(buf, PSTR("Off"));
          pct = 0;
        }
        printLCDLPad(3, i * 5 + 6, buf, 3, ' ');
      }

      if (preheated && !doPrompt) printTimer(2, 7);

      if (chkMsg()) {
        if ((!(doPrompt && preheated) && strcasecmp(msg[0], "POPMENU") == 0) || (doPrompt && preheated && strcasecmp(msg[0], "SELECT") == 0)) {
          enterStatus = 1;
          clearMsg();
        } else rejectMsg(LOGAB);
      }
      if (doPrompt && preheated && enterStatus == 1) { 
        enterStatus = 0;
        logStart_P(LOGMENU);
        logField_P(LOGSCROLLR);
        logField(sTitle);
        logFieldI(0);
        logField_P(CONTINUE);
        logEnd();
        break; 
      }
      else if (enterStatus == 1) {
        enterStatus = 0;
        redraw = 1;
        strcpy_P(menuopts[0], CANCEL);
        if (timerValue > 0) strcpy_P(menuopts[1], PSTR("Reset Timer"));
        else strcpy_P(menuopts[1], PSTR("Start Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORT);
        byte lastOption = scrollMenu("AutoBrew Mash Menu", 5, 0);
        if (lastOption == 1) {
          preheated = 1;
          printLCDRPad(0, 14, "", 6, ' ');
          setTimer(iMins);
        } else if (lastOption == 2) pauseTimer();
        else if (lastOption == 3) {
          resetOutputs();
          return;
        } else if (lastOption == 4) {
            if (confirmExit() == 1) {
              resetOutputs();
              enterStatus = 2;
              return;
            }
        }
        if (redraw) break;
      }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) {
          resetOutputs();
          enterStatus = 2;
          return;
        }
        redraw = 1;
        break;
      }
    }
    if (!redraw) {
      resetOutputs();
      //Exit
      return;
    }
  }
}

void manSparge() {
  while (1) {
    clearLCD();
    printLCD_P(0, 7, PSTR("Sparge"));
    printLCD_P(0, 0, PSTR("HLT"));
    printLCD_P(0, 16, PSTR("Mash"));
    printLCD_P(1, 0, PSTR("---"));
    printLCD_P(1, 16, PSTR("---"));
    printLCD_P(2, 0, PSTR("---.-"));
    printLCD_P(2, 15, PSTR("---.-"));
    printLCD_P(1, 3, TUNIT);
    printLCD_P(1, 19, TUNIT);
    #ifdef USEMETRIC
      printLCD_P(2, 7, PSTR("Liters"));
    #else
      printLCD_P(2, 8, PSTR("Gals"));
    #endif
    printLCD_P(3, 4, PSTR(">"));
    printLCD_P(3, 15, PSTR("<"));
    
    setValves(0);
    printLCD_P(3, 0, PSTR("Off"));
    printLCD_P(3, 17, PSTR("Off"));

    encMin = 0;
    encMax = 5;
    encCount = 0;
    byte lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      brewCore();
      ftoa(volAvg[VS_HLT]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDRPad(2, 0, buf, 7, ' ');
        
      ftoa(volAvg[VS_MASH]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDLPad(2, 14, buf, 6, ' ');

      if (encCount != lastCount) {
        printLCDRPad(3, 5, "", 10, ' ');
        lastCount = encCount;
        if (lastCount == 0) printLCD_P(3, 6, CONTINUE);
        else if (lastCount == 1) printLCD_P(3, 6, SPARGEIN);
        else if (lastCount == 2) printLCD_P(3, 5, SPARGEOUT);
        else if (lastCount == 3) printLCD_P(3, 5, FLYSPARGE);
        else if (lastCount == 4) printLCD_P(3, 7, ALLOFF);
        else if (lastCount == 5) printLCD_P(3, 8, ABORT);
      }

      for (byte i = TS_HLT; i <= TS_MASH; i++) if (temp[i] == -1) printLCD_P(1, i * 16, PSTR("---")); else printLCDLPad(1, i * 16, itoa(temp[i], buf, 10), 3, ' ');

      if (chkMsg()) {
        if (strcasecmp(msg[0], "SELECT") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 1 && val  >= 0 && val <= 5) {
            encCount = val;
            enterStatus = 1;
            clearMsg();
          } else rejectParam(LOGSCROLLP);
        } else rejectMsg(LOGSCROLLP);
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        if (encCount == 0) {
          resetOutputs();
          return;
        } else if (encCount == 1) {
          printLCD_P(3, 0, PSTR("On "));
          printLCD_P(3, 17, PSTR("Off"));
          setValves(vlvConfig[VLV_SPARGEIN]);
        } else if (encCount == 2) {
          printLCD_P(3, 0, PSTR("Off"));
          printLCD_P(3, 17, PSTR(" On"));
          setValves(vlvConfig[VLV_SPARGEOUT]);
        } else if (encCount == 3) {
          printLCD_P(3, 0, PSTR("On "));
          printLCD_P(3, 17, PSTR(" On"));
          setValves(vlvConfig[VLV_SPARGEIN] | vlvConfig[VLV_SPARGEOUT]);
        } else if (encCount == 4) {
          printLCD_P(3, 0, PSTR("Off"));
          printLCD_P(3, 17, PSTR("Off"));
          setValves(0);
        } else if (encCount == 5) {
            if (confirmExit()) {
              resetOutputs();
              enterStatus = 2;
              return;
            } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) {
          resetOutputs();
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
    }
  }  
}

void boilStage(unsigned int iMins, unsigned int boilAdds) {
  boolean preheated = 0;
  unsigned int triggered = getABAddsTrig();
  setAlarm(0);
  timerValue = 0;
  unsigned long lastHop = 0;
  
  while(1) {
    boolean redraw = 0;
    timerLastWrite = 0;
    clearLCD();
    printLCD_P(0,0,PSTR("Kettle"));
    printLCD_P(0,8,PSTR("Boil"));
    if (setpoint[TS_KETTLE] > 0) printLCD_P(2,7,PSTR("(WAIT)"));
    printLCD_P(3,0,PSTR("[    ]"));

    #ifdef USEMETRIC
      printLCD_P(1, 7, PSTR("Liters"));
    #else
      printLCD_P(1, 8, PSTR("Gals"));
    #endif
    printLCD_P(2, 3, TUNIT);
    printLCD_P(3, 4, TUNIT);
    
    while(!preheated || timerValue > 0) {
      brewCore();
      if (preheated) { if (alarmStatus) printLCD_P(0, 19, PSTR("!")); else printLCD_P(0, 19, SPACE); }
      if (!preheated && temp[TS_KETTLE] >= setpoint[TS_KETTLE] && setpoint[TS_KETTLE] > 0) {
        preheated = 1;
        printLCDRPad(0, 14, "", 6, ' ');
        setTimer(iMins);
      }

      ftoa(volAvg[VS_KETTLE]/1000.0, buf, 2);
      truncFloat(buf, 6);
      printLCDRPad(1, 0, buf, 7, ' ');

      if (PIDEnabled[TS_KETTLE]) {
        byte pct = PIDOutput[TS_KETTLE] / PIDCycle[TS_KETTLE] / 10;
        if (pct == 0) strcpy_P(buf, PSTR("Off"));
        else if (pct == 100) strcpy_P(buf, PSTR(" On"));
        else { itoa(pct, buf, 10); strcat(buf, "%"); }
      } else if (heatStatus[TS_KETTLE]) {
        strcpy_P(buf, PSTR(" On")); 
      } else {
        strcpy_P(buf, PSTR("Off"));
      }
      printLCDLPad(3, 6, buf, 3, ' ');
      
      if (temp[TS_KETTLE] == -1) printLCD_P(2, 0, PSTR("---")); else printLCDLPad(2, 0, itoa(temp[TS_KETTLE], buf, 10), 3, ' ');
      printLCDLPad(3, 1, itoa(setpoint[TS_KETTLE], buf, 10), 3, ' ');

      //Turn off hop valve profile after 5s
      if (lastHop > 0 && millis() - lastHop > HOPADD_DELAY) {
        if (vlvBits & vlvConfig[VLV_HOPADD]) setValves(vlvBits ^ vlvConfig[VLV_HOPADD]);
        lastHop = 0;
      }

      if (preheated) {
        printTimer(2, 7);
        //Boil Addition
        if ((boilAdds ^ triggered) & 1) {
          setValves(vlvConfig[VLV_HOPADD]);
          lastHop = millis();
          setAlarm(1); 
          triggered |= 1; 
          setABAddsTrig(triggered); 
        }
        //Timed additions (See hoptimes[] array at top of AutoBrew.pde)
        for (byte i = 0; i < 10; i++) {
          if (((boilAdds ^ triggered) & (1<<(i + 1))) && timerValue <= hoptimes[i] * 60000) { 
            setValves(vlvConfig[VLV_HOPADD]);
            lastHop = millis();
            setAlarm(1); 
            triggered |= (1<<(i + 1)); 
            setABAddsTrig(triggered);
          }
        }
      }

      if (chkMsg()) {
        if ((!alarmStatus && strcasecmp(msg[0], "POPMENU") == 0) || (alarmStatus && strcasecmp(msg[0], "SELECT") == 0)) {
          enterStatus = 1;
          clearMsg();
        } else rejectMsg(LOGAB);
      }
      if (enterStatus == 1 && alarmStatus) {
        enterStatus = 0;
        setAlarm(0);
      } else if (enterStatus == 1) {
        redraw = 1;
        enterStatus = 0;
        strcpy_P(menuopts[0], CANCEL);
        if (timerValue > 0) strcpy_P(menuopts[1], PSTR("Reset Timer"));
        else strcpy_P(menuopts[1], PSTR("Start Timer"));
        strcpy_P(menuopts[2], PSTR("Pause Timer"));
        strcpy_P(menuopts[3], SKIPSTEP);
        strcpy_P(menuopts[4], ABORT);
        byte lastOption = scrollMenu("AutoBrew Boil Menu", 5, 0);
        if (lastOption == 1) {
          preheated = 1;
          printLCDRPad(0, 14, "", 6, ' ');
          setTimer(iMins);
        } else if (lastOption == 2) pauseTimer();
        else if (lastOption == 3) {
          resetOutputs();
          return;
        } else if (lastOption == 4) {
            if (confirmExit() == 1) {
              enterStatus = 2;
              resetOutputs();
              return;
            }
        }
        if (redraw) break;
      }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) {
          enterStatus = 2;
          resetOutputs();
          return;
        } 
        redraw = 1;
        break;
      }
    }
    if (!redraw) {
      //Turn off output
      resetOutputs();
      //0 Min Addition
      if ((boilAdds ^ triggered) & 2048) { 
        setValves(vlvConfig[VLV_HOPADD]);
        setAlarm(1);
        triggered |= 2048;
        setABAddsTrig(triggered);
        delay(HOPADD_DELAY);
        setValves(0);
      }
      //Exit
      return;
    }
  }
}

void manChill() {
  while (1) {
    clearLCD();
    printLCD_P(0, 8, PSTR("Chill"));
    printLCD_P(0, 0, PSTR("Beer"));
    printLCD_P(0, 17, PSTR("H2O"));
    printLCD_P(1, 9, PSTR("IN"));
    printLCD_P(2, 9, PSTR("OUT"));

    printLCD_P(1, 3, TUNIT);
    printLCD_P(1, 19, TUNIT);
    printLCD_P(2, 3, TUNIT);
    printLCD_P(2, 19, TUNIT);
    printLCD_P(3, 4, PSTR(">"));
    printLCD_P(3, 15, PSTR("<"));    
    
    setValves(0);

    encMin = 0;
    encMax = 6;
    encCount = 0;
    int lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      brewCore();
      if (encCount != lastCount) {
        lastCount = encCount;
        printLCDRPad(3, 5, "", 10, ' ');
        if (lastCount == 0) printLCD_P(3, 6, CONTINUE);
        else if (lastCount == 1) printLCD_P(3, 5, CHILLNORM);
        else if (lastCount == 2) printLCD_P(3, 6, CHILLH2O);
        else if (lastCount == 3) printLCD_P(3, 6, CHILLBEER);
        else if (lastCount == 4) printLCD_P(3, 7, ALLOFF);
        else if (lastCount == 5) printLCD_P(3, 8, AUTOFILL);
        else if (lastCount == 6) printLCD_P(3, 8, ABORT);
      }
      
      if (chkMsg()) {
        if (strcasecmp(msg[0], "SELECT") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 1 && val  >= 0 && val <= 6) {
            encCount = val;
            enterStatus = 1;
            clearMsg();
          } else rejectParam(LOGSCROLLP);
        } else rejectMsg(LOGSCROLLP);
      }
      if (enterStatus == 1 && alarmStatus) {
        enterStatus = 0;
        setAlarm(0);
      } else if (enterStatus == 1) {
        autoValve = 0;
        enterStatus = 0;
        if (encCount == 0) {
          resetOutputs();
          return;
        } else if (encCount == 1) setValves(vlvConfig[VLV_CHILLH2O] | vlvConfig[VLV_CHILLBEER]);
        else if (encCount == 2) setValves(vlvConfig[VLV_CHILLH2O]);
        else if (encCount == 3) setValves(vlvConfig[VLV_CHILLBEER]);
        else if (encCount == 4) setValves(0);
        else if (encCount == 5) autoValve = AV_CHILL;
        else if (encCount == 6) {
          if (confirmExit()) {
            resetOutputs();
            enterStatus = 2;
            return;
          } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) { 
          resetOutputs();
          enterStatus = 2;
          return;
        } else redraw = 1;
      }
      if (temp[TS_KETTLE] == -1) printLCD_P(1, 0, PSTR("---")); else printLCDLPad(1, 0, itoa(temp[TS_KETTLE], buf, 10), 3, ' ');
      if (temp[TS_BEEROUT] == -1) printLCD_P(2, 0, PSTR("---")); else printLCDLPad(2, 0, itoa(temp[TS_BEEROUT], buf, 10), 3, ' ');
      if (temp[TS_H2OIN] == -1) printLCD_P(1, 16, PSTR("---")); else printLCDLPad(1, 16, itoa(temp[TS_H2OIN], buf, 10), 3, ' ');
      if (temp[TS_H2OOUT] == -1) printLCD_P(2, 16, PSTR("---")); else printLCDLPad(2, 16, itoa(temp[TS_H2OOUT], buf, 10), 3, ' ');

      if ((vlvBits & vlvConfig[VLV_CHILLBEER]) == vlvConfig[VLV_CHILLBEER]) printLCD_P(3, 0, PSTR("On ")); else printLCD_P(3, 0, PSTR("Off"));
      if ((vlvBits & vlvConfig[VLV_CHILLH2O]) == vlvConfig[VLV_CHILLH2O]) printLCD_P(3, 17, PSTR(" On")); else printLCD_P(3, 17, PSTR("Off"));
      
      if (temp[TS_KETTLE] != -1 && temp[TS_KETTLE] <= KETTLELID_THRESH) {
        if (vlvBits & vlvConfig[VLV_KETTLELID] == 0) setValves(vlvBits | vlvConfig[VLV_KETTLELID]);
      } else {
        if (vlvBits & vlvConfig[VLV_KETTLELID]) setValves(vlvBits ^ vlvConfig[VLV_KETTLELID]);
      }
    }
  }  
}

unsigned int editHopSchedule (unsigned int sched) {
  unsigned int retVal = sched;
  byte lastOption = 0;
  while (1) {
    if (retVal & 1) strcpy_P(menuopts[0], PSTR("Boil: On")); else strcpy_P(menuopts[0], PSTR("Boil: Off"));
    for (byte i = 0; i < 10; i++) {
      strcpy(menuopts[i + 1], itoa(hoptimes[i], buf, 10));
      strcat_P(menuopts[i + 1], PSTR(" Min: "));
      if (retVal & (1<<(i + 1))) strcat_P(menuopts[i + 1], PSTR("On")); else strcat_P(menuopts[i + 1], PSTR("Off"));
    }
    if (retVal & 2048) strcpy_P(menuopts[11], PSTR("0 Min: On")); else strcpy_P(menuopts[11], PSTR("0 Min: Off"));
    strcpy_P(menuopts[12], PSTR("Exit"));

    lastOption = scrollMenu("Boil Additions", 13, lastOption);
    if (lastOption == 12) return retVal;
    else if (lastOption == 13) return sched;
    else retVal = retVal ^ (1 << lastOption);
  }
}
