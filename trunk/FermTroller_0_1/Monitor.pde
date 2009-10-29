void doMon() {
  encMin = 0;
  encMax = NUM_ZONES;
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
        byte pos = 0;
        if (lastCount > 0) {
          strcpy_P(menuopts[pos++], PSTR("Adjust Set Point"));
          strcpy_P(menuopts[pos++], PSTR("Clear Set Point"));
        }
        strcpy_P(menuopts[pos++], PSTR("Close Menu"));
        strcpy_P(menuopts[pos++], PSTR("Quit"));

        boolean inMenu = 1;
        byte lastOption = 0;
        while(inMenu) {
          lastOption = scrollMenu("Ferm Monitor Menu", pos, lastOption);
          if (pos == 2) lastOption += 2;
          if (lastOption == 0) {
            setpoint[lastCount - 1] = getValue("Enter New Temp:", setpoint[lastCount - 1], 3, 0, 255, TUNIT);
            inMenu = 0;
          } else if (lastOption == 1) {
            setpoint[lastCount - 1] = 0;
            inMenu = 0;
          } else if (lastOption == 2) inMenu = 0;
          else if (lastOption == 3) {
            if (confirmExit()) {
              resetOutputs();
              setPwrRecovery(0);
              return;
            } else break;
          }
          saveSetpoints();
        }
        encMin = 0;
        encMax = NUM_ZONES;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    fermCore();
    if (encCount == 0) {
      //Summary Screen: Display up to the first six zones (or less based on NUM_ZONES)
      if (encCount != lastCount) {
        lastCount = encCount;
        clearLCD();
        printLCD_P(0, 4, PSTR("Ambient:"));
        printLCD_P(0, 16, TUNIT);

        if (NUM_ZONES > 0) {
          printLCD(1, 0, "1>");
          printLCD_P(1, 5, TUNIT);
          printLCD(1, 6, "[");
          printLCD(1, 8, "]");
        }
        if (NUM_ZONES > 1) {
          printLCD(2, 0, "2>");
          printLCD_P(2, 5, TUNIT);
          printLCD(2, 6, "[");
          printLCD(2, 8, "]");
        }
        if (NUM_ZONES > 2) {
          printLCD(3, 0, "3>");
          printLCD_P(3, 5, TUNIT);
          printLCD(3, 6, "[");
          printLCD(3, 8, "]");
        }
        if (NUM_ZONES > 3) {
          printLCD(1, 11, "4>");
          printLCD_P(1, 16, TUNIT);
          printLCD(1, 17, "[");
          printLCD(1, 19, "]");
        }
        if (NUM_ZONES > 4) {
          printLCD(2, 11, "5>");
          printLCD_P(2, 16, TUNIT);
          printLCD(2, 17, "[");
          printLCD(2, 19, "]");
        }
        if (NUM_ZONES > 5) {
          printLCD(3, 11, "6>");
          printLCD_P(3, 16, TUNIT);
          printLCD(3, 17, "[");
          printLCD(3, 19, "]");
        }
        timerLastWrite = 0;
      }

      for (byte i = 0; i < NUM_ZONES + 1; i++) {
        if (temp[i] == -1) strcpy_P(menuopts[i], PSTR("---"));
        else { 
          itoa(temp[i], buf, 10); 
          strcpy(menuopts[i], buf); 
        } 
      }
      
      printLCDLPad(0, 13, menuopts[NUM_ZONES], 3, ' ');

      if (NUM_ZONES > 0) printLCDLPad(1,  2, menuopts[0], 3, ' ');
      if (NUM_ZONES > 1) printLCDLPad(2,  2, menuopts[1], 3, ' ');
      if (NUM_ZONES > 2) printLCDLPad(3,  2, menuopts[2], 3, ' ');
      if (NUM_ZONES > 3) printLCDLPad(1, 13, menuopts[3], 3, ' ');
      if (NUM_ZONES > 4) printLCDLPad(2, 13, menuopts[4], 3, ' ');
      if (NUM_ZONES > 5) printLCDLPad(3, 13, menuopts[5], 3, ' ');
      
      for (byte i = 0; i < 6; i++) {
        if (coolStatus[i]) strcpy_P(menuopts[i], PSTR("C"));
        else if ((PIDEnabled[i] && PIDOutput[i] > 0) || heatStatus[i]) strcpy_P(menuopts[i], PSTR("H"));
        else strcpy_P(menuopts[i], PSTR(" "));
      }
      
      if (NUM_ZONES > 0) printLCD(1,  7, menuopts[0]);
      if (NUM_ZONES > 1) printLCD(2,  7, menuopts[1]);
      if (NUM_ZONES > 2) printLCD(3,  7, menuopts[2]);
      if (NUM_ZONES > 3) printLCD(1, 18, menuopts[3]);
      if (NUM_ZONES > 4) printLCD(2, 18, menuopts[4]);
      if (NUM_ZONES > 5) printLCD(3, 18, menuopts[5]);

    } else {
      //Zone 1 - 6 Detail
      if (encCount != lastCount) {
        lastCount = encCount;
        clearLCD();
        printLCD_P(0, 7, PSTR("Zone"));
        printLCD(0, 12, itoa(lastCount, buf, 10));
        printLCD_P(1, 0, PSTR("Current Temp:"));        
        printLCD_P(1, 17, TUNIT);
        printLCD_P(2, 0,PSTR("Set Point:"));
        printLCD_P(2, 17, TUNIT);
        printLCD_P(3, 0,PSTR("Output:"));
        timerLastWrite = 0;
      }

      if (temp[lastCount - 1] == -1) printLCD_P(1, 14, PSTR("---")); else printLCDLPad(1, 14, itoa(temp[lastCount - 1], buf, 10), 3, ' ');
      printLCDLPad(2, 14, itoa(setpoint[lastCount - 1], buf, 10), 3, ' ');
      if (PIDEnabled[lastCount - 1]) {
        byte pct = PIDOutput[lastCount - 1] / PIDCycle[lastCount - 1] / 10;
        if (pct == 0) strcpy_P(buf, PSTR("Off"));
        else if (pct == 100) strcpy_P(buf, PSTR("Heat On"));
        else {
          strcpy_P(buf, PSTR("Heat "));
          itoa(pct, buf, 10);
          strcat(buf, "%");
        }
      } else if (heatStatus[lastCount - 1]) strcpy_P(buf, PSTR("Heat On")); else strcpy_P(buf, PSTR("Off"));
      if (coolStatus[lastCount - 1]) strcpy_P(buf, PSTR("Cool On"));
      printLCDRPad(3, 8, buf, 7, ' ');
    }
  }
}
