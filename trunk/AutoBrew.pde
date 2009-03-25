#define PROMPT -1
#define DOUGHIN 0
#define PROTEIN 1
#define SACCH 2
#define MASHOUT 3
#define PROMPT -1

void doAutoBrew() {
  unsigned int delayMins = 0;
  byte stepTemp[4], stepMins[4], spargeTemp;
  unsigned long tgtVol[3] = { 0, 0, defBatchVol };
  unsigned long grainWeight = 0;
  unsigned int boilMins = 60;
  unsigned int mashRatio = 133;
  byte recoveryStep = 0;
  char buf[9];
  char titles[4][13] = {
    "Dough In",
    "Protein Rest",
    "Sacch Rest",
    "Mash Out"
  };

  if (getPwrRecovery() == 1) {
    recoveryStep = getABRecovery();
    loadSetpoints();
    loadABSteps(stepTemp, stepMins);
    spargeTemp = getABSparge();
    delayMins = getABDelay();
    loadABVols(tgtVol);
    grainWeight = getABGrain();
    boilMins = getABBoil();
    mashRatio = getABRatio();
  } else {
    spargeTemp = 168;
    if (sysHERMS) setpoint[HLT] = 180; else setpoint[HLT] = spargeTemp;
  
    strcpy(menuopts[0], "Single Infusion");
    strcpy(menuopts[1], "Multi-Rest");

    switch (scrollMenu("AutoBrew Program", menuopts, 2)) {
      case 0:
        stepTemp[DOUGHIN] = 0;
        stepMins[DOUGHIN] = 0;
        stepTemp[PROTEIN] = 0;
        stepMins[PROTEIN] = 0;
        stepTemp[SACCH] = 153;
        stepMins[SACCH] = 60;
        stepTemp[MASHOUT] = 168;
        stepMins[MASHOUT] = 0;
        break;
      case 1:
        stepTemp[DOUGHIN] = 104;
        stepMins[DOUGHIN] = 20;
        stepTemp[PROTEIN] = 122;
        stepMins[PROTEIN] = 20;
        stepTemp[SACCH] = 153;
        stepMins[SACCH] = 60;
        stepTemp[MASHOUT] = 168;
        stepMins[MASHOUT] = 0;
        break;
      default: return;
    }
    if (!unit) {
      //Convert default values from F to C
      setpoint[HLT] = round((setpoint[HLT] - 32) / 1.8);
      spargeTemp = round((spargeTemp - 32) / 1.8);
      for (int i = DOUGHIN; i <= MASHOUT; i++) if (stepTemp[i]) stepTemp[i] = round((stepTemp[i] - 32) / 1.8);
      //Convert mashRatio from qts/lb to l/kg
      mashRatio = round(mashRatio * 2.0863514);
    }
  }
  char volUnit[5] = " l";
  char wtUnit[4] = " kg";
  char tempUnit[2] = "C";
  if (unit) {
    strcpy(volUnit, " gal");
    strcpy(wtUnit, " lb");
    strcpy (tempUnit, "F");
  }
  
  boolean inMenu = 1;
  if (recoveryStep) inMenu = 0;
  while (inMenu) {

    strcpy(menuopts[0], "Batch Vol:");
    strcpy(menuopts[1], "Grain Wt:");
    strcpy(menuopts[2], "Boil Length:");
    strcpy(menuopts[3], "Mash Ratio:");
    strcpy(menuopts[4], "Delay Start:");
    strcpy(menuopts[5], "HLT Temp:");
    strcpy(menuopts[6], "Sparge Temp:");
    strcpy(menuopts[7], "Mash Schedule");
    strcpy(menuopts[8], "Start Program");
    strcpy(menuopts[9], "Exit");    

    ftoa((float)tgtVol[KETTLE]/1000, buf, 2);
    strncat(menuopts[0], buf, 5);
    strcat(menuopts[0], volUnit);

    ftoa((float)grainWeight/1000, buf, 3);
    strncat(menuopts[1], buf, 7);
    strcat(menuopts[1], wtUnit);

    strncat(menuopts[2], itoa(boilMins, buf, 10), 3);
    strcat(menuopts[2], " min");

    ftoa((float)mashRatio/100, buf, 2);
    strncat(menuopts[3], buf, 4);
    strcat(menuopts[3], ":1");

    strncat(menuopts[4], itoa(delayMins/60, buf, 10), 4);
    strcat(menuopts[4], " hr");
    
    strncat(menuopts[5], itoa(setpoint[HLT], buf, 10), 3);
    strcat(menuopts[5], tempUnit);
    
    strncat(menuopts[6], itoa(spargeTemp, buf, 10), 3);
    strcat(menuopts[6], tempUnit);

    switch(scrollMenu("AutoBrew Parameters", menuopts, 10)) {
      case 0:
        tgtVol[KETTLE] = getValue("Batch Volume", tgtVol[KETTLE], 7, 3, 9999999, volUnit);
        break;
      case 1:
        grainWeight = getValue("Grain Weight", grainWeight, 7, 3, 9999999, wtUnit);
        break;
      case 2:
        boilMins = getTimerValue("Boil Length", boilMins);
        break;
      case 3:
        if (unit) mashRatio = getValue("Mash Ratio", mashRatio, 3, 2, 999, " qts/lb"); else mashRatio = getValue("Mash Ratio", mashRatio, 3, 2, 999, " l/kg");
        break;
      case 4:
        delayMins = getTimerValue("Delay Start", delayMins);
        break;
      case 5:
        setpoint[HLT] = getValue("HLT Setpoint", setpoint[HLT], 3, 0, 255, tempUnit);
        break;
      case 6:
        spargeTemp = getValue("HLT Setpoint", spargeTemp, 3, 0, 255, tempUnit);
        break;
      case 7:
        editMashSchedule(stepTemp, stepMins);
        break;
      case 8:
        inMenu = 0;
        break;
      default:
        setPwrRecovery(0);
        return;
    }
    //Detrmine Total Water Needed (Evap + Deadspaces)
    tgtVol[HLT] = round(tgtVol[KETTLE] / (1.0 - evapRate / 100.0 * boilMins / 60.0) + volLoss[HLT] + volLoss[MASH]);
    //Add Water Lost in Spent Grain
    if (unit) tgtVol[HLT] += round(grainWeight * .2143); else tgtVol[HLT] += round(grainWeight * 1.7884);
    //Calculate mash volume
    tgtVol[MASH] = round(grainWeight * mashRatio / 100.0);
    //Convert qts to gal for US
    if (unit) tgtVol[MASH] = round(tgtVol[MASH] / 4.0);
    tgtVol[HLT] -= tgtVol[MASH];

    {
      //Grain-to-volume factor for mash tun capacity (1 lb = .15 gal)
      float grain2Vol;
      if (unit) grain2Vol = .15; else grain2Vol = 1.25;

      //Check for capacity overages
      if (tgtVol[HLT] > capacity[HLT]) {
        clearLCD();
        printLCD(0, 0, "HLT too small for");
        printLCD(1, 0, "sparge. Increase");
        printLCD(2, 0, "mash ratio or");
        printLCD(3, 0, "decrease batch size.");
        while (!enterStatus) delay(500);
        enterStatus = 0;
      }
      if (tgtVol[MASH] + round(grainWeight * grain2Vol) > capacity[MASH]) {
        clearLCD();
        printLCD(0, 0, "Mash tun too small.");
        printLCD(1, 0, "Decrease mash ratio");
        printLCD(2, 0, "or grain weight.");
        while (!enterStatus) delay(500);
        enterStatus = 0;
      }
      {
        byte predictedSparge;
        if (sysHERMS) {
          if (unit) predictedSparge = round(((setpoint[HLT] * tgtVol[HLT]) - (stepTemp[MASHOUT] - stepTemp[SACCH]) * (tgtVol[MASH] + grainWeight * .05)) / tgtVol[HLT]);
          else predictedSparge = round(((setpoint[HLT] * tgtVol[HLT]) - (stepTemp[MASHOUT] - stepTemp[SACCH]) * (tgtVol[MASH] + grainWeight * .41)) / tgtVol[HLT]);
        } else predictedSparge = spargeTemp;
        if (predictedSparge > spargeTemp + 3) {
          clearLCD();
          printLCD(0, 0, "HLT setpoint may be");
          printLCD(1, 0, "too high for sparge.");
          printLCD(2, 0, "Sparge:");
          printLCD(3, 0, "Predicted HLT:");
          printLCD(2, 7, itoa(spargeTemp, buf, 10));
          printLCD(3, 14, itoa(predictedSparge, buf, 10));
          printLCD(2, 10, tempUnit);
          printLCD(3, 17, tempUnit);
          while (!enterStatus) delay(500);
          enterStatus = 0;
        }
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
    }
  }

  if (recoveryStep <= 1) {
    setABRecovery(1);
    fillStage(tgtVol[HLT], tgtVol[MASH]);
    if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
  }
  
  if(delayMins && recoveryStep <= 2) {
    if (recoveryStep == 2) {
      delayStart(getTimerRecovery());
    } else { 
      setABRecovery(2);
      delayStart(delayMins);
    }
    if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
  }

  if (recoveryStep <= 3) {
    //Find first temp and adjust for strike temp
    byte strikeTemp = 0;
    int i = 0;
    while (strikeTemp == 0 && i <= MASHOUT) strikeTemp = stepTemp[i++];
    if (unit) strikeTemp = round(.2 / (mashRatio / 100.0) * (strikeTemp - 60)) + strikeTemp; else strikeTemp = round(.41 / (mashRatio / 100.0) * (strikeTemp - 16)) + strikeTemp;
    setpoint[MASH] = strikeTemp;
    
    setABRecovery(3);
    mashStep("Preheat", PROMPT);  
    if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
  }
  
  inMenu = 0;
  if (recoveryStep <=4) inMenu = 1;
  while(inMenu) {
    setABRecovery(4);
    clearLCD();
    printLCD(1, 5, "Add Grain");
    printLCD(2, 0, "Press Enter to Start");
    while(enterStatus == 0) delay(500);
    if (enterStatus == 1) {
      enterStatus = 0;
      inMenu = 0;
    } else {
      enterStatus = 0;
      if (confirmExit() == 1) setPwrRecovery(0); return;
    }
  }
  
  for (int i = DOUGHIN; i <= MASHOUT; i++) {
    if (i == MASHOUT) setpoint[HLT] = spargeTemp;
    if (stepTemp[i] && recoveryStep <= i + 5) {
      setABRecovery(i + 5);
      setpoint[MASH] = stepTemp[i];
      int recoverMins = getTimerRecovery();
      if (recoveryStep == i + 5 && recoverMins > 0) mashStep(titles[i], recoverMins); else mashStep(titles[i], stepMins[i]);
      if (enterStatus == 2) { enterStatus = 0; setPwrRecovery(0); return; }
    }

  }
  //Hold last mash temp until user exits
  if (recoveryStep <= 9) {
    setABRecovery(9); 
    mashStep("Mash Complete", PROMPT);
  }
  
  enterStatus = 0;
  setABRecovery(0);
  setPwrRecovery(0);
}

void fillStage(unsigned long hltVol, unsigned long mashVol) {
  char fString[7], buf[5];
  int fillHLT = getValveCfg(FILLHLT);
  int fillMash = getValveCfg(FILLMASH);
  int fillBoth = fillHLT || fillMash;

  while (1) {
    clearLCD();
    printLCD(0, 0, "HLT");
    if (unit) printLCD(0, 5, "Fill (gal)"); else printLCD(0, 6, "Fill (l)");
    printLCD(0, 16, "Mash");

    printLCD(1, 7, "Target");
    printLCD(2, 7, "Actual");
    unsigned long whole = hltVol / 1000;
    //Throw away the last digit
    unsigned long frac = round ((hltVol - whole * 1000)/10.0);
    //Build string to align left

    strcpy(fString, ltoa(whole, buf, 10));
    strcat(fString, ".");
    strcat(fString, ltoa(frac, buf, 10));
    printLCD(1, 0, fString);

    whole = mashVol / 1000;
    //Throw away the last digit
    frac = round ((mashVol - whole * 1000)/10.0) ;
    printLCDPad(1, 14, ltoa(whole, buf, 10), 3, ' ');
    printLCD(1, 17, ".");
    printLCDPad(1, 18, ltoa(frac, buf, 10), 2, '0');

    setValves(0);
    printLCD(3, 0, "Off");
    printLCD(3, 17, "Off");

    encMin = 0;
    encMax = 5;
    encCount = 0;
    int lastCount = 1;
    
    boolean redraw = 0;
    while(!redraw) {
      if (encCount != lastCount) {
        switch(encCount) {
          case 0: printLCD(3, 4, "> Continue <"); break;
          case 1: printLCD(3, 4, "> Fill HLT <"); break;
          case 2: printLCD(3, 4, "> Fill Mash<"); break;
          case 3: printLCD(3, 4, "> Fill Both<"); break;
          case 4: printLCD(3, 4, ">  All Off <"); break;
          case 5: printLCD(3, 4, ">   Abort  <"); break;
        }
        lastCount = encCount;
      }
      if (enterStatus == 1) {
        enterStatus = 0;
        switch(encCount) {
          case 0: return;
          case 1:
            printLCD(3, 0, "On ");
            printLCD(3, 17, "Off");
            setValves(fillHLT);
            break;
          case 2:
            printLCD(3, 0, "Off");
            printLCD(3, 17, " On");
            setValves(fillMash);
            break;
          case 3:
            printLCD(3, 0, "On ");
            printLCD(3, 17, " On");
            setValves(fillBoth);
            break;
          case 4:
            printLCD(3, 0, "Off");
            printLCD(3, 17, "Off");
            setValves(0);
            break;
          case 5: if (confirmExit()) { enterStatus = 2; return; } else redraw = 1;
        }
      } else if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit()) { enterStatus = 2; return; } else redraw = 1;
      }
    }
  }
}

void delayStart(int iMins) {
  setTimer(iMins);
  while(1) {
    boolean redraw = 0;
    clearLCD();
    printLCD(0,0,"Delay Start");
    printLCD(0,14,"(WAIT)");
    while(timerValue > 0) { 
      printTimer(1,7);
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
  char buf[6];
  float temp[2] = { 0, 0 };
  char sTempUnit[2] = "C";
  unsigned long convStart = 0;
  unsigned long cycleStart[2] = { 0, 0 };
  boolean heatStatus[2] = { 0, 0 };
  boolean preheated = 0;
  setAlarm(0);
  boolean doPrompt = 0;
  if (iMins == PROMPT) doPrompt = 1;
  timerValue = 0;
  
  for (int i = HLT; i <= MASH; i++) {
    if (PIDEnabled[i]) {
      pid[i].SetInputLimits(0, 255);
      pid[i].SetOutputLimits(0, PIDCycle[i] * 1000);
      PIDOutput[i] = 0;
      cycleStart[i] = millis();
    }
  }
  
  if (unit) strcpy(sTempUnit, "F");

  while(1) {
    boolean redraw = 0;
    timerLastWrite = 0;
    clearLCD();
    printLCD(0,0,sTitle);
    printLCD(0,14,"(WAIT)");
    printLCD(1,2,"HLT");
    printLCD(3,0,"[");
    printLCD(3,5,"]");
    printLCD(2, 4, sTempUnit);
    printLCD(3, 4, sTempUnit);
    printLCD(1,15,"Mash");
    printLCD(3,14,"[");
    printLCD(3,19,"]");
    printLCD(2, 18, sTempUnit);
    printLCD(3, 18, sTempUnit);
    
    while(!preheated || timerValue > 0 || doPrompt) {
      if (!preheated && temp[MASH] >= setpoint[MASH]) {
        preheated = 1;
        printLCD(0,14,"      ");
        if(doPrompt) printLCD(1, 0, "    > Continue <    "); else setTimer(iMins);
      }

      for (int i = HLT; i <= MASH; i++) {
        if (temp[i] == -1) printLCD(2, i * 14 + 1, "---"); else printLCDPad(2, i * 14 + 1, itoa(temp[i], buf, 10), 3, ' ');
        printLCDPad(3, i * 14 + 1, itoa(setpoint[i], buf, 10), 3, ' ');
        if (PIDEnabled[i]) {
          byte pct = PIDOutput[i] / PIDCycle[i] / 10;
          switch (pct) {
            case 0: strcpy(buf, "Off"); break;
            case 100: strcpy(buf, " On"); break;
            default: itoa(pct, buf, 10); strcat(buf, "%"); break;
          }
        } else if (heatStatus[i]) strcpy(buf, " On"); else strcpy(buf, "Off"); 
        printLCDPad(3, i * 5 + 6, buf, 3, ' ');
      }
      if (!doPrompt) printTimer(1,7);

      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        for (int i = HLT; i <= MASH; i++) temp[i] = read_temp(unit, tSensor[i]);
        convStart = 0;
      }

      for (int i = HLT; i <= MASH; i++) {
        boolean setOut;
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
          if (PIDOutput[i] > millis() - cycleStart[i]) setOut = 1; else setOut = 0;
        } else {
          if (heatStatus[i]) {
            if (temp[i] == -1 || temp[i] >= setpoint[i]) {
              setOut = 0;
              heatStatus[i] = 0;
            } else setOut = 1;
          } else { 
            if (temp[i] != -1 && (float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0) {
              setOut = 1;
              heatStatus[i] = 1;
            } else setOut = 0;
          }
        }
        switch(i) {
          case HLT: digitalWrite(HLTHEAT_PIN, setOut); break;
          case MASH: digitalWrite(MASHHEAT_PIN, setOut); break;
          case KETTLE: digitalWrite(KETTLEHEAT_PIN, setOut); break;
        }
      }
      if (doPrompt && preheated && enterStatus == 1) { enterStatus = 0; break; }
      if (enterStatus == 2) {
        enterStatus = 0;
        if (confirmExit() == 1) enterStatus = 2; else redraw = 1;
        break;
      }
    }
    if (!redraw) {
       //Turn off HLT and MASH outputs
       for (int i = HLT; i <= MASH; i++) { if (PIDEnabled[i]) pid[i].SetMode(MANUAL); }
       digitalWrite(HLTHEAT_PIN, LOW);
       digitalWrite(MASHHEAT_PIN, LOW);
       digitalWrite(KETTLEHEAT_PIN, LOW);
       //Exit
      return;
    }
  }
}

void editMashSchedule(byte stepTemp[4], byte stepMins[4]) {
  char buf[4];
  char tempUnit[2] = "C";
  if (unit) strcpy (tempUnit, "F");
  while (1) {
    strcpy(menuopts[0], "Dough In:");
    strcpy(menuopts[1], "Dough In:");
    strcpy(menuopts[2], "Protein Rest:");
    strcpy(menuopts[3], "Protein Rest:");
    strcpy(menuopts[4], "Sacch Rest:");
    strcpy(menuopts[5], "Sacch Rest:");
    strcpy(menuopts[6], "Mash Out:");
    strcpy(menuopts[7], "Mash Out:");
    strcpy(menuopts[8], "Exit");
  
    strncat(menuopts[0], itoa(stepMins[DOUGHIN], buf, 10), 2);
    strcat(menuopts[0], " min");

    strncat(menuopts[1], itoa(stepTemp[DOUGHIN], buf, 10), 3);
    strcat(menuopts[1], tempUnit);
    
    strncat(menuopts[2], itoa(stepMins[PROTEIN], buf, 10), 2);
    strcat(menuopts[2], " min");

    strncat(menuopts[3], itoa(stepTemp[PROTEIN], buf, 10), 3);
    strcat(menuopts[3], tempUnit);
    
    strncat(menuopts[4], itoa(stepMins[SACCH], buf, 10), 2);
    strcat(menuopts[4], " min");

    strncat(menuopts[5], itoa(stepTemp[SACCH], buf, 10), 3);
    strcat(menuopts[5], tempUnit);
    
    strncat(menuopts[6], itoa(stepMins[MASHOUT], buf, 10), 2);
    strcat(menuopts[6], " min");

    strncat(menuopts[7], itoa(stepTemp[MASHOUT], buf, 10), 3);
    strcat(menuopts[7], tempUnit);

    switch (scrollMenu("Mash Schedule", menuopts, 9)) {
      case 0:
        stepMins[DOUGHIN] = getTimerValue("Dough In", stepMins[DOUGHIN]);
        break;
      case 1:
        stepTemp[DOUGHIN] = getValue("Dough In", stepTemp[DOUGHIN], 3, 0, 255, tempUnit);
        break;
      case 2:
        stepMins[PROTEIN] = getTimerValue("Protein Rest", stepMins[PROTEIN]);
        break;
      case 3:
        stepTemp[PROTEIN] = getValue("Protein Rest", stepTemp[PROTEIN], 3, 0, 255, tempUnit);
        break;
      case 4:
        stepMins[SACCH] = getTimerValue("Sacch Rest", stepMins[SACCH]);
        break;
      case 5:
        stepTemp[SACCH] = getValue("Sacch Rest", stepTemp[SACCH], 3, 0, 255, tempUnit);
        break;
      case 6:
        stepMins[MASHOUT] = getTimerValue("Mash Out", stepMins[MASHOUT]);
        break;
      case 7:
        stepTemp[MASHOUT] = getValue("Mash Out", stepTemp[MASHOUT], 3, 0, 255, tempUnit);
        break;
      default:
        return;
    }
  }
}
