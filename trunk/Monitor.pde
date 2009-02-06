void doMon() {
  char buf[6];
  float tempHLT = 0;
  float tempMash = 0;
  float tempKettle = 0;
  int tempCFCH2OIn = 0;
  int tempCFCH2OOut = 0;
  int tempCFCBeerOut = 0;
  char sTempUnit[2] = "C";
  unsigned long convStart = 0;
  
  if (tempUnit == TEMPF) strcpy(sTempUnit, "F");
  encMin = 0;
  encMax = 2;
  encCount = 0;
  int lastCount = 1;
  
  while (1) {
    if (enterStatus == 2) {
        //Exit Brew Monitor
        enterStatus = 0;
        resetOutputs();
        return;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (alarmStatus) {
        setAlarm(0);
      } else {
        //Pop-Up Menu
        char monMenu[7][20] = {
          "Set HLT Temp       ",
          "Set Mash Temp      ",
          "Set Timer          ",
          "Pause Timer        ",
          "Clear Timer        ",
          "Close Menu         ",
          "Quit Brew Monitor  "
        };
        boolean inMenu = 1;
        while(inMenu) {
          switch (scrollMenu("Brew Monitor Menu   ", monMenu, 7)) {
            case 0:
              
              break;
            case 1:
              
              break;
            case 2:
              //Prompt for value
              int newMins;
              newMins = getTimerValue("Enter Timer Value:", timerValue/60000);
              if (newMins > 0) {
                setTimer(newMins);
                inMenu = 0;
              }
              break;
            case 3:
              pauseTimer();
              inMenu = 0;
              break;
            case 4:
              clearTimer();
              inMenu = 0;
              break;
            case 6:
              //Confirm dialog
              resetOutputs();
              return;
            default:
              inMenu = 0;
              break;
          }
        }
        encCount = lastCount;
        lastCount += 1;
      }
    }
    char buf[6];
    switch (encCount) {
      case 0:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Mash)");
          printLCD(2,0,"         HLT:       ");
          printLCD(3,0,"        Mash:       ");
          printLCD(2, 19, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        
        ftoa(tempHLT, buf, 1);
        printLCDPad(2, 14, buf, 5, ' ');
        ftoa(tempMash, buf, 1);
        printLCDPad(3, 14, buf, 5, ' ');
        break;
      case 1:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Boil)");
          printLCD(3,0,"       Kettle:      ");
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        ftoa(tempKettle, buf, 1);
        printLCDPad(3, 14, buf, 5, ' ');
        break;
      case 2:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor (Chill)");
          printLCD(1,0,"            In   Out");
          printLCD(2,0,"     Beer:          ");
          printLCD(3,0,"      H2O:          ");
          printLCD(2, 14, sTempUnit);
          printLCD(2, 19, sTempUnit);
          printLCD(3, 14, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        printLCDPad(2, 11, itoa(tempKettle, buf, 10), 3, ' ');
        printLCDPad(2, 16, itoa(tempCFCBeerOut, buf, 10), 3, ' ');
        printLCDPad(3, 11, itoa(tempCFCH2OIn, buf, 10), 3, ' ');
        printLCDPad(3, 16, itoa(tempCFCH2OOut, buf, 10), 3, ' ');
        break;
      }
      printTimer(1,0);

      if (convStart == 0) {
        convertAll();
        convStart = millis();
      } else if (millis() - convStart >= 750) {
        tempHLT = read_temp(tempUnit, tsHLT);
        tempMash = read_temp(tempUnit, tsMash);
        tempKettle = read_temp(tempUnit, tsKettle);
        tempCFCH2OIn = read_temp(tempUnit, tsCFCH2OIn);
        tempCFCH2OOut = read_temp(tempUnit, tsCFCH2OOut);
        tempCFCBeerOut = read_temp(tempUnit, tsCFCBeerOut);
        convStart = 0;
      }
    }
  }


  
