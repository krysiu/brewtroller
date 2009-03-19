void doMon() {
  setPwrRecovery(2);
  char buf[6];
  float temp[6] = { 0, 0, 0, 0, 0, 0 };
  char sTempUnit[2] = "C";
  unsigned long convStart = 0;
  unsigned long cycleStart[3];
  boolean heatStatus[3] = { 0, 0, 0 };

  for (int i = HLT; i <= KETTLE; i++) {
    if (PIDEnabled[i]) {
      pid[i].SetIOLimits(0, 255, 0, PIDCycle[i] * 1000);
      PIDOutput[i] = 0;
      cycleStart[i] = millis();
    }
  }
  
  if (unit) strcpy(sTempUnit, "F");
  encMin = 0;
  encMax = 2;
  encCount = 0;
  int lastCount = 1;
  
  while (1) {
    if (enterStatus == 2) {
      enterStatus = 0;
      if (confirmExit()) {
          resetOutputs();
          setPwrRecovery(0); 
          return;
      } else {
        encCount = lastCount;
        lastCount += 1;
      }
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (alarmStatus) {
        setAlarm(0);
      } else {
        //Pop-Up Menu
        char monMenu[11][20] = {
          "Set HLT Temp",
          "Clear HLT Temp",
          "Set Mash Temp",
          "Clear Mash Temp",
          "Set Kettle Temp",
          "Clear Kettle Temp",
          "Set Timer",
          "Pause Timer",
          "Clear Timer",
          "Close Menu",
          "Quit Brew Monitor"
        };
        boolean inMenu = 1;
        while(inMenu) {
          char dispUnit[2] = "C"; if (unit) strcpy(dispUnit, "F");
          switch (scrollMenu("Brew Monitor Menu   ", monMenu, 11)) {
            case 0:
              {
                byte defHLTTemp = 180;
                if (!unit) defHLTTemp = round(defHLTTemp / 1.8) + 32;
                if (setpoint[HLT] > 0) setpoint[HLT] = getValue("Enter HLT Temp:", setpoint[HLT], 3, 0, 255, dispUnit);
                else setpoint[HLT] = getValue("Enter HLT Temp:", defHLTTemp, 3, 0, 255, dispUnit);
              }
              inMenu = 0;
              break;
            case 1: setpoint[HLT] = 0; inMenu = 0; break; 
            case 2:
              {
                byte defMashTemp = 152;
                if (!unit) defMashTemp = round(defMashTemp / 1.8) + 32;
                if (setpoint[MASH] > 0) setpoint[MASH] = getValue("Enter Mash Temp:", setpoint[MASH], 3, 0, 255, dispUnit);
                else setpoint[MASH] = getValue("Enter Mash Temp:", defMashTemp, 3, 0, 255, dispUnit);
              }
              inMenu = 0;
              break;
            case 3: setpoint[MASH] = 0; inMenu = 0; break; 
            case 4:
              {
                byte defKettleTemp = 212;
                if (!unit) defKettleTemp = round(defKettleTemp / 1.8) + 32;
                if (setpoint[KETTLE] > 0) setpoint[KETTLE] = getValue("Enter Kettle Temp:", setpoint[KETTLE], 3, 0, 255, dispUnit);
                else setpoint[KETTLE] = getValue("Enter Kettle Temp:", defKettleTemp, 3, 0, 255, dispUnit);
              }
              inMenu = 0;
              break;
            case 5: setpoint[KETTLE] = 0; inMenu = 0; break; 
            case 6:
              unsigned int newMins;
              newMins = getTimerValue("Enter Timer Value:", timerValue/60000);
              if (newMins > 0) {
                setTimer(newMins);
                inMenu = 0;
              }
              break;
            case 7:
              pauseTimer();
              inMenu = 0;
              break;
            case 8:
              clearTimer();
              inMenu = 0;
              break;
            case 10:
              if (confirmExit()) {
                resetOutputs();
                setPwrRecovery(0);
                return;
              } else break;
            default:
              inMenu = 0;
              break;
          }
        }
        encMin = 0;
        encMax = 2;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    char buf[6];
    switch (encCount) {
      case 0:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,4,"Brew Monitor");
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
          lastCount = encCount;
          timerLastWrite = 0;
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
        break;
      case 1:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,4,"Brew Monitor");
          printLCD(1,0,"Kettle");
          printLCD(3,0,"[");
          printLCD(3,5,"]");
          printLCD(2, 4, sTempUnit);
          printLCD(3, 4, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        if (temp[KETTLE] == -1) printLCD(2, 1, "---"); else printLCDPad(2, 1, itoa(temp[KETTLE], buf, 10), 3, ' ');
        printLCDPad(3, 1, itoa(setpoint[KETTLE], buf, 10), 3, ' ');
        if (PIDEnabled[KETTLE]) {
          byte pct = PIDOutput[KETTLE] / PIDCycle[KETTLE] / 10;
          switch (pct) {
            case 0: strcpy(buf, "Off"); break;
            case 100: strcpy(buf, " On"); break;
            default: itoa(pct, buf, 10); strcat(buf, "%"); break;
          }
        } else if (heatStatus[KETTLE]) strcpy(buf, " On"); else strcpy(buf, "Off");
        printLCDPad(3, 6, buf, 3, ' ');
        break;
      case 2:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,4,"Brew Monitor");
          printLCD(1,1,"In");
          printLCD(1,16,"Out");
          printLCD(2,8,"Beer");
          printLCD(3,8,"H2O");
          printLCD(2, 3, sTempUnit);
          printLCD(2, 19, sTempUnit);
          printLCD(3, 3, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        
        if (temp[KETTLE] == -1) printLCD(2, 0, "---"); else printLCDPad(2, 0, itoa(temp[KETTLE], buf, 10), 3, ' ');
        if (temp[BEEROUT] == -1) printLCD(2, 16, "---"); else printLCDPad(2, 16, itoa(temp[BEEROUT], buf, 10), 3, ' ');
        if (temp[H2OIN] == -1) printLCD(3, 0, "---"); else printLCDPad(3, 0, itoa(temp[H2OIN], buf, 10), 3, ' ');
        if (temp[H2OOUT] == -1) printLCD(3, 16, "---"); else printLCDPad(3, 16, itoa(temp[H2OOUT], buf, 10), 3, ' ');
        break;
    }
    printTimer(1,7);

    if (convStart == 0) {
      convertAll();
      convStart = millis();
    } else if (millis() - convStart >= 750) {
      for (int i = HLT; i <= BEEROUT; i++) temp[i] = read_temp(unit, tSensor[i]);
      convStart = 0;
    }
    for (int i = HLT; i <= KETTLE; i++) {
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
  }
}
