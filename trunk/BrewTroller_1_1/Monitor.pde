void doMon() {
//Program memory used: 4KB (as of Build 205)
#ifdef MODULE_BREWMONITOR
  clearTimer();
  
  encMin = 0;
  encMax = 2;
  encCount = 0;
  byte lastCount = 1;
  if (pwrRecovery == 2) {
    loadSetpoints();
    unsigned int newMins = getTimerRecovery();
    if (newMins > 0) setTimer(newMins);
  } else { 
    setTimerRecovery(0);
    saveSetpoints();
    setPwrRecovery(2);
  }
  
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
        strcpy(menuopts[0], "Set HLT Temp");
        strcpy(menuopts[1], "Clear HLT Temp");
        strcpy(menuopts[2], "Set Mash Temp");
        strcpy(menuopts[3], "Clear Mash Temp");
        strcpy(menuopts[4], "Set Kettle Temp");
        strcpy(menuopts[5], "Clear Kettle Temp");
        strcpy(menuopts[6], "Set Timer");
        strcpy(menuopts[7], "Pause Timer");
        strcpy(menuopts[8], "Clear Timer");
        strcpy(menuopts[9], "Close Menu");
        strcpy(menuopts[10], "Quit Brew Monitor");

        boolean inMenu = 1;
        byte lastOption = 0;
        while(inMenu) {
          lastOption = scrollMenu("Brew Monitor Menu   ", 11, lastOption);
          if (lastOption == 0) {
            if (setpoint[TS_HLT] > 0) setpoint[TS_HLT] = getValue("Enter HLT Temp:", setpoint[TS_HLT], 3, 0, 255, TUNIT);
            else {
              #ifdef USEMETRIC
                setpoint[TS_HLT] = getValue("Enter HLT Temp:", 82, 3, 0, 255, TUNIT);
              #else
                setpoint[TS_HLT] = getValue("Enter HLT Temp:", 180, 3, 0, 255, TUNIT);
              #endif
            }
            inMenu = 0;
          } else if (lastOption == 1) {
            setpoint[TS_HLT] = 0;
            inMenu = 0;
          } else if (lastOption == 2) {
            if (setpoint[TS_MASH] > 0) setpoint[TS_MASH] = getValue("Enter Mash Temp:", setpoint[TS_MASH], 3, 0, 255, TUNIT);
            else {
              #ifdef USEMETRIC
                setpoint[TS_MASH] = getValue("Enter Mash Temp:", 67, 3, 0, 255, TUNIT);
              #else
                setpoint[TS_MASH] = getValue("Enter Mash Temp:", 152, 3, 0, 255, TUNIT);
              #endif
            }
            inMenu = 0;
          } else if (lastOption == 3) {
            setpoint[TS_MASH] = 0;
            inMenu = 0;
          } else if (lastOption == 4) {
            if (setpoint[TS_KETTLE] > 0) setpoint[TS_KETTLE] = getValue("Enter Kettle Temp:", setpoint[TS_KETTLE], 3, 0, 255, TUNIT);
            else {
              #ifdef USEMETRIC
                setpoint[TS_KETTLE] = getValue("Enter Kettle Temp:", 100, 3, 0, 255, TUNIT);
              #else
                setpoint[TS_KETTLE] = getValue("Enter Kettle Temp:", 212, 3, 0, 255, TUNIT);
              #endif
            }
            inMenu = 0;
          } else if (lastOption == 5) {
            setpoint[TS_KETTLE] = 0;
            inMenu = 0;
          } else if (lastOption == 6) {
            unsigned int newMins;
            newMins = getTimerValue("Enter Timer Value:", timerValue/60000);
            if (newMins > 0) {
              setTimer(newMins);
              inMenu = 0;
            }
          } else if (lastOption == 7) {
            pauseTimer();
            inMenu = 0;
          } else if (lastOption == 8) {
            clearTimer();
            inMenu = 0;
          } else if (lastOption == 10) {
            if (confirmExit()) {
              resetOutputs();
              setPwrRecovery(0);
              return;
            } else break;
          } else inMenu = 0;
          saveSetpoints();
        }
        encMin = 0;
        encMax = 2;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    brewCore();
    if (encCount == 0) {
      if (encCount != lastCount) {
        clearLCD();
        printLCD_P(0,4,PSTR("Brew Monitor"));
        printLCD_P(1,2,PSTR("HLT"));
        printLCD_P(3,0,PSTR("["));
        printLCD_P(3,5,PSTR("]"));
        printLCD_P(2, 4, TUNIT);
        printLCD_P(3, 4, TUNIT);
        printLCD_P(1,15,PSTR("Mash"));
        printLCD_P(3,14,PSTR("["));
        printLCD_P(3,19,PSTR("]"));
        printLCD_P(2, 18, TUNIT);
        printLCD_P(3, 18, TUNIT);
        lastCount = encCount;
        timerLastWrite = 0;
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

    } else if (encCount == 1) {
      if (encCount != lastCount) {
        clearLCD();
        printLCD(0,4,"Brew Monitor");
        printLCD(1,0,"Kettle");
        printLCD(3,0,"[");
        printLCD(3,5,"]");
        printLCD_P(2, 4, TUNIT);
        printLCD_P(3, 4, TUNIT);
        lastCount = encCount;
        timerLastWrite = 0;
      }

      if (temp[TS_KETTLE] == -1) printLCD(2, 1, "---"); else printLCDLPad(2, 1, itoa(temp[TS_KETTLE], buf, 10), 3, ' ');
      printLCDLPad(3, 1, itoa(setpoint[TS_KETTLE], buf, 10), 3, ' ');
      if (PIDEnabled[TS_KETTLE]) {
        byte pct = PIDOutput[TS_KETTLE] / PIDCycle[TS_KETTLE] / 10;
        if (pct == 0) strcpy(buf, "Off");
        else if (pct == 100) strcpy(buf, " On");
        else { itoa(pct, buf, 10); strcat(buf, "%"); }
      } else { if (heatStatus[TS_KETTLE]) strcpy(buf, " On"); else strcpy(buf, "Off"); }
      printLCDLPad(3, 6, buf, 3, ' ');
    } else if (encCount == 2) {
      if (encCount != lastCount) {
        clearLCD();
        printLCD(0,4,"Brew Monitor");
        printLCD(1,1,"In");
        printLCD(1,16,"Out");
        printLCD(2,8,"Beer");
        printLCD(3,8,"H2O");
        printLCD_P(2, 3, TUNIT);
        printLCD_P(2, 19, TUNIT);
        printLCD_P(3, 3, TUNIT);
        printLCD_P(3, 19, TUNIT);
        lastCount = encCount;
        timerLastWrite = 0;
      }
        
      if (temp[TS_KETTLE] == -1) printLCD(2, 0, "---"); else printLCDLPad(2, 0, itoa(temp[TS_KETTLE], buf, 10), 3, ' ');
      if (temp[TS_BEEROUT] == -1) printLCD(2, 16, "---"); else printLCDLPad(2, 16, itoa(temp[TS_BEEROUT], buf, 10), 3, ' ');
      if (temp[TS_H2OIN] == -1) printLCD(3, 0, "---"); else printLCDLPad(3, 0, itoa(temp[TS_H2OIN], buf, 10), 3, ' ');
      if (temp[TS_H2OOUT] == -1) printLCD(3, 16, "---"); else printLCDLPad(3, 16, itoa(temp[TS_H2OOUT], buf, 10), 3, ' ');
    }
    printTimer(1,7);
  }
#endif
}
