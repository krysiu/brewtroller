const boolean PROMPT = -1;

void doAutoBrew() {
  int delayMins;
  const byte DOUGHIN = 0;
  const byte PROTEIN = 1;
  const byte SACCH = 2;
  const byte MASHOUT = 3;
  byte stepTemp[4], stepMins[4];
  char titles[4][15] = {
    "Dough In",
    "Protein Rest",
    "Sacch Rest",
    "Mash Out"
  };

  char profileMenu[2][20] = {
    "Single Infusion    ",
    "Multi-Rest         "
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

  if (!tempUnit) {
    //Convert default values from F to C
    setpoint[HLT] = (setpoint[HLT] - 32) * 5 / 9;
    for (int i = DOUGHIN; i <= MASHOUT; i++) if (stepTemp[i]) stepTemp[i] = (stepTemp[i] - 32) * 5 / 9;
  }

  

  if(delayMins) delayStart(delayMins);
  if (enterStatus == 2) { enterStatus = 0; resetOutputs(); return; }

  {
    int i = 0;
    setpoint[MASH] = 0;
    while (setpoint[MASH] == 0 && i <= MASHOUT) setpoint[MASH] = stepTemp[i++];
  }

  mashStep("Preheat", 0);
  if (enterStatus == 2) { enterStatus = 0; resetOutputs(); return; }
  mashStep("Add Grain", PROMPT);  
  if (enterStatus == 2) { enterStatus = 0; resetOutputs(); return; }

  for (int i = DOUGHIN; i <= MASHOUT; i++) {
    if (stepTemp[i]) {
      setpoint[MASH] = stepTemp[i];
      mashStep(titles[i], stepMins[i]);
    }
    if (enterStatus == 2) { enterStatus = 0; resetOutputs(); return; }
  }
  resetOutputs();
  clearLCD();
  printLCD(1, 1, "AutoBrew Complete");
  printLCD(2, 0, "Press Enter to Continue");
  while(enterStatus == 0) delay(500);
  enterStatus = 0;
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
  
  if (tempUnit == TEMPF) strcpy(sTempUnit, "F");

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
        if(doPrompt) printLCD(1, 0, "Press Enter to Start"); else setTimer(iMins);
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
        for (int i = HLT; i <= MASH; i++) temp[i] = read_temp(tempUnit, tSensor[i]);
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
      if (doPrompt && preheated && enterStatus == 1) { enterStatus = 0; return; }
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
