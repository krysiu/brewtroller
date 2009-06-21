void doMon() {
  encMin = 0;
  encMax = 1;
  encCount = 0;
  byte lastCount = 1;
  setPwrRecovery(1);
  
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
        strcpy(menuopts[0], "Set Zone 1");
        strcpy(menuopts[1], "Set Zone 2");
        strcpy(menuopts[2], "Set Zone 3");
        strcpy(menuopts[3], "Set Zone 4");
        strcpy(menuopts[4], "Clear Zone 1");
        strcpy(menuopts[5], "Clear Zone 2");
        strcpy(menuopts[6], "Clear Zone 3");
        strcpy(menuopts[7], "Clear Zone 4");
        strcpy(menuopts[8], "Close Menu");
        strcpy(menuopts[9], "Quit Brew Monitor");

        boolean inMenu = 1;
        byte lastOption = 0;
        while(inMenu) {
          lastOption = scrollMenu("Ferm Monitor Menu", 10, lastOption);
          if (lastOption >= 0 && lastOption <= 3) {
            setpoint[lastOption] = getValue("Enter New Temp:", setpoint[lastOption], 3, 0, 255, TUNIT);
            inMenu = 0;
          } else if (lastOption >= 4 && lastOption <= 7) {
            setpoint[lastOption - 4] = 0;
            inMenu = 0;
          } else if (lastOption == 9) {
            if (confirmExit()) {
              resetOutputs();
              setPwrRecovery(0);
              return;
            } else break;
          } else inMenu = 0;
          saveSetpoints();
        }
        encMin = 0;
        encMax = 1;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    fermCore();
    if (encCount == 0) {
      if (encCount != lastCount) {
        clearLCD();
        printLCD_P(0, 5, PSTR("FermTroller"));
        printLCD_P(1, 4, PSTR("Ambient:"));
        printLCD_P(1, 15, TUNIT);

        printLCD_P(2, 3, TUNIT);
        printLCD_P(2, 19, TUNIT);
        printLCD_P(3, 3, TUNIT);
        printLCD_P(3, 19, TUNIT);
        
        printLCD(2, 4, "[");
        printLCD(2, 6, "]");
        printLCD(2, 13, "[");
        printLCD(2, 15, "]");
        printLCD(3, 4, "[");
        printLCD(3, 6, "]");
        printLCD(3, 13, "[");
        printLCD(3, 15, "]");
        
        printLCD(2, 7, "<1");
        printLCD(2, 11, "2>");
        printLCD(3, 7, "<3");
        printLCD(3, 11, "4>");
        
        lastCount = encCount;
        timerLastWrite = 0;
      }

      for (byte i = 0; i < 5; i++) {
        if (temp[i] == -1) strcpy_P(menuopts[i], PSTR("---"));
        else { 
          itoa(temp[4], buf, 10); 
          strcpy(menuopts[i], buf); 
        } 
      }
      
      printLCDLPad(1, 12, menuopts[4], 3, ' ');
      printLCDLPad(2,  0, menuopts[0], 3, ' ');
      printLCDLPad(2, 16, menuopts[1], 3, ' ');
      printLCDLPad(3,  0, menuopts[2], 3, ' ');
      printLCDLPad(3, 16, menuopts[3], 3, ' ');

      for (byte i = 0; i < 4; i++) {
        if (coolStatus[i]) strcpy_P(menuopts[i], PSTR("C"));
        else if ((PIDEnabled[i] && PIDOutput[i] > 0) || heatStatus[i]) strcpy_P(menuopts[i], PSTR("H"));
        else strcpy_P(menuopts[i], PSTR(" "));
      }
      
      printLCD(2,  5, menuopts[0]);
      printLCD(2, 14, menuopts[1]);
      printLCD(3,  5, menuopts[2]);
      printLCD(3, 14, menuopts[3]);
      
    } else if (encCount == 1) {
      if (encCount != lastCount) {
        clearLCD();
        for (byte i = 0; i < 4; i++) {
          printLCD(i, 0, itoa(i+1, buf, 10));
          printLCD(i, 1, ":");        
          printLCD_P(i, 5, TUNIT);
          printLCD_P(i, 6,PSTR("["));
          printLCD_P(i, 10, TUNIT);
          printLCD_P(i, 11,PSTR("]"));
        }
        lastCount = encCount;
        timerLastWrite = 0;
      }

      for (byte i = 0; i < 4; i++) {
        if (temp[i] == -1) printLCD_P(i, 2, PSTR("---")); else printLCDLPad(i, 2, itoa(temp[i], buf, 10), 3, ' ');
        printLCDLPad(i, 7, itoa(setpoint[i], buf, 10), 3, ' ');
        if (PIDEnabled[i]) {
          byte pct = PIDOutput[i] / PIDCycle[i] / 10;
          if (pct == 0) strcpy_P(buf, PSTR("Off"));
          else if (pct == 100) strcpy_P(buf, PSTR("Heat On"));
          else {
            strcpy_P(buf, PSTR("Heat "));
            itoa(pct, buf, 10);
            strcat(buf, "%");
          }
        } else if (heatStatus[i]) strcpy_P(buf, PSTR("Heat On")); else strcpy_P(buf, PSTR("Off"));
        if (coolStatus[i]) strcpy_P(buf, PSTR("Cool On"));
        printLCDLPad(i, 12, buf, 3, ' ');
      }
    }
  }
}
