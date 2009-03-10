const boolean PROMPT = -1;

void doAutoBrew() {
  int delayMins = 0;
  byte stepTemp[4], stepMins[4];
  unsigned long tgtVol[3] = { 0, 0, defBatchVol };
  unsigned long grainWeight = 0;
  unsigned int boilMins = 60;
  unsigned int mashRatio = 133;
  const byte DOUGHIN = 0;
  const byte PROTEIN = 1;
  const byte SACCH = 2;
  const byte MASHOUT = 3;
  char buf[9];
  char titles[4][15] = {
    "Dough In",
    "Protein Rest",
    "Sacch Rest",
    "Mash Out"
  };

  {
    char profileMenu[2][20] = {
      "Single Infusion",
      "Multi-Rest"
    };
    switch (scrollMenu("AutoBrew Program", profileMenu, 2)) {
      case 0:
        setpoint[HLT] = 180;
        stepTemp[DOUGHIN] = 0;
        stepMins[DOUGHIN] = 0;
        stepTemp[PROTEIN] = 0;
        stepMins[PROTEIN] = 0;
        stepTemp[SACCH] = 153;
        stepMins[SACCH] = 60;
        stepTemp[MASHOUT] = 170;
        stepMins[MASHOUT] = 0;
        break;
      case 1:
        setpoint[HLT] = 180;
        stepTemp[DOUGHIN] = 104;
        stepMins[DOUGHIN] = 20;
        stepTemp[PROTEIN] = 122;
        stepMins[PROTEIN] = 20;
        stepTemp[SACCH] = 153;
        stepMins[SACCH] = 60;
        stepTemp[MASHOUT] = 170;
        stepMins[MASHOUT] = 0;
        break;
      default: return;
    }
  }
  if (!unit) {
    //Convert default values from F to C
    setpoint[HLT] = round((setpoint[HLT] - 32) / 1.8);
    for (int i = DOUGHIN; i <= MASHOUT; i++) if (stepTemp[i]) stepTemp[i] = round((stepTemp[i] - 32) / 1.8);
    //Convert mashRatio from qts/lb to l/kg
    mashRatio = round(mashRatio * 2.0863514);
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
  while (inMenu) {
    char paramMenu[16][20] = {
      "Batch Vol:",
      "Grain Wt:",
      "Boil Length:",
      "Mash Ratio:",
      "Delay Start:",
      "HLT Setpoint:",
      "Dough In:",
      "Dough In:",
      "Protein Rest:",
      "Protein Rest:",
      "Sacch Rest:",
      "Sacch Rest:",
      "Mash Out:",
      "Mash Out:",
      "Start Program",
      "Exit"
    };
    ftoa((float)tgtVol[KETTLE]/1000, buf, 2);
    strncat(paramMenu[0], buf, 5);
    strcat(paramMenu[0], volUnit);

    ftoa((float)grainWeight/1000, buf, 3);
    strncat(paramMenu[1], buf, 7);
    strcat(paramMenu[1], wtUnit);

    strncat(paramMenu[2], itoa(boilMins, buf, 10), 3);
    strcat(paramMenu[2], " min");

    ftoa((float)mashRatio/100, buf, 2);
    strncat(paramMenu[3], buf, 4);
    strcat(paramMenu[3], ":1");

    strncat(paramMenu[4], itoa(delayMins/60, buf, 10), 4);
    strcat(paramMenu[4], " hr");
    
    strncat(paramMenu[5], itoa(setpoint[HLT], buf, 10), 3);
    strcat(paramMenu[5], tempUnit);

    strncat(paramMenu[6], itoa(stepMins[DOUGHIN], buf, 10), 2);
    strcat(paramMenu[6], " min");

    strncat(paramMenu[7], itoa(stepTemp[DOUGHIN], buf, 10), 3);
    strcat(paramMenu[7], tempUnit);
    
    strncat(paramMenu[8], itoa(stepMins[PROTEIN], buf, 10), 2);
    strcat(paramMenu[8], " min");

    strncat(paramMenu[9], itoa(stepTemp[PROTEIN], buf, 10), 3);
    strcat(paramMenu[9], tempUnit);
    
    strncat(paramMenu[10], itoa(stepMins[SACCH], buf, 10), 2);
    strcat(paramMenu[10], " min");

    strncat(paramMenu[11], itoa(stepTemp[SACCH], buf, 10), 3);
    strcat(paramMenu[11], tempUnit);
    
    strncat(paramMenu[12], itoa(stepMins[MASHOUT], buf, 10), 2);
    strcat(paramMenu[12], " min");

    strncat(paramMenu[13], itoa(stepTemp[MASHOUT], buf, 10), 3);
    strcat(paramMenu[13], tempUnit);
    
    switch(scrollMenu("AutoBrew Parameters", paramMenu, 16)) {
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
        stepMins[DOUGHIN] = getTimerValue("Dough In", stepMins[DOUGHIN]);
        break;
      case 7:
        stepTemp[DOUGHIN] = getValue("Dough In", stepTemp[DOUGHIN], 3, 0, 255, tempUnit);
        break;
      case 8:
        stepMins[PROTEIN] = getTimerValue("Protein Rest", stepMins[PROTEIN]);
        break;
      case 9:
        stepTemp[PROTEIN] = getValue("Protein Rest", stepTemp[PROTEIN], 3, 0, 255, tempUnit);
        break;
      case 10:
        stepMins[SACCH] = getTimerValue("Sacch Rest", stepMins[SACCH]);
        break;
      case 11:
        stepTemp[SACCH] = getValue("Sacch Rest", stepTemp[SACCH], 3, 0, 255, tempUnit);
        break;
      case 12:
        stepMins[MASHOUT] = getTimerValue("Mash Out", stepMins[MASHOUT]);
        break;
      case 13:
        stepTemp[MASHOUT] = getValue("Mash Out", stepTemp[MASHOUT], 3, 0, 255, tempUnit);
        break;
      case 14:
        inMenu = 0;
        break;
      default:
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
    }
  }

  fillStage(tgtVol[HLT], tgtVol[MASH], volUnit);
  if (enterStatus == 2) { enterStatus = 0; return; }
  
  if(delayMins) delayStart(delayMins);
  if (enterStatus == 2) { enterStatus = 0; return; }


  {
    //Find first temp and adjust for strike temp
    byte strikeTemp = 0;
    int i = 0;
    while (strikeTemp == 0 && i <= MASHOUT) strikeTemp = stepTemp[i++];
    if (unit) strikeTemp = round(.2 / (mashRatio / 100.0) * (strikeTemp - 60)) + strikeTemp; else strikeTemp = round(.41 / (mashRatio / 100.0) * (strikeTemp - 16)) + strikeTemp;
    setpoint[MASH] = strikeTemp;
  }

  mashStep("Preheat", PROMPT);  
  if (enterStatus == 2) { enterStatus = 0; return; }
  
  inMenu = 1;
  while(inMenu) {
    clearLCD();
    printLCD(1, 5, "Add Grain");
    printLCD(2, 0, "Press Enter to Start");
    while(enterStatus == 0) delay(500);
    if (enterStatus == 1) {
      enterStatus = 0;
      inMenu = 0;
    } else {
      enterStatus = 0;
      if (confirmExit() == 1) return;
    }
  }
  
  for (int i = DOUGHIN; i <= MASHOUT; i++) {
    if (stepTemp[i]) {
      setpoint[MASH] = stepTemp[i];
      mashStep(titles[i], stepMins[i]);
    }
    if (enterStatus == 2) { enterStatus = 0; return; }
  }
  //Hold last mash temp until user exits
  mashStep("Mash Complete", PROMPT);
  enterStatus = 0;
}

void fillStage(unsigned long hltVol, unsigned long mashVol, char volUnit[]) {
  char buf[5];
  clearLCD();
  printLCD(0, 0, "Add Brewing Liquor");
  unsigned long whole = hltVol / 1000;
  unsigned long frac = hltVol - (whole * 1000) ;
  printLCD(1, 0, " HLT:");
  printLCDPad(1, 6, ltoa(whole, buf, 10), 4, ' ');
  printLCD(1, 10, ".");
  printLCDPad(1, 11, ltoa(frac, buf, 10), 3, '0');
  printLCD(1, 14, volUnit);
  whole = mashVol / 1000;
  frac = mashVol - (whole * 1000) ;
  printLCD(2, 0, "Mash:");
  printLCDPad(2, 6, ltoa(whole, buf, 10), 4, ' ');
  printLCD(2, 10, ".");
  printLCDPad(2, 11, ltoa(frac, buf, 10), 3, '0');
  printLCD(2, 14, volUnit);
  char conExit[2][19] = {
    "     Continue     ",
    "       Abort      "};
  if (getChoice(conExit, 2, 3) != 0) enterStatus = 2;
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
  
  for (int i = HLT; i <= MASH; i++) {
    if (PIDEnabled[i]) {
      pid[i].SetIOLimits(0, 255, 0, PIDCycle[i] * 1000);
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
          if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(OUTPUT_PIN[i], HIGH);
          else digitalWrite(OUTPUT_PIN[i], LOW);
        } else {
          if (heatStatus[i]) {
            if (temp[i] == -1 || temp[i] >= setpoint[i]) {
              digitalWrite(OUTPUT_PIN[i], LOW);
              heatStatus[i] = 0;
            }
          } else { 
            if (temp[i] != -1 && (float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0) {
              digitalWrite(OUTPUT_PIN[i], HIGH);
              heatStatus[i] = 1;
            }
          }
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
       for (int i = HLT; i <= MASH; i++) {
        if (PIDEnabled[i]) pid[i].SetMode(MANUAL);
        digitalWrite(OUTPUT_PIN[i], LOW);
       }
       //Exit
      return;
    }
  }
}
