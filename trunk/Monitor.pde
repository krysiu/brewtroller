void doMon() {
  char buf[6];
  int tempHLT = 0;
  int tempMash = 0;
  int tempKettle = 0;
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
        enterStatus = 0;
        return;
    }
    switch (encCount) {
      case 0:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Mash)");
          printLCD(3,0,"HLT:       Mash:    ");
          printLCD(3, 7, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
        }
        printLCDPad(3, 4, itoa(tempHLT, buf, 10), 3, ' ');
        printLCDPad(3, 16, itoa(tempMash, buf, 10), 3, ' ');
        break;
      case 1:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Boil)");
          printLCD(3,0,"Kettle:             ");
          printLCD(3, 10, sTempUnit);
          lastCount = encCount;
        }
        printLCDPad(3, 7, itoa(tempKettle, buf, 10), 3, ' ');
        break;
      case 2:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor (Chill)");
          printLCD(1,0,"       In    Out    ");
          printLCD(2,0,"Beer:               ");
          printLCD(3,0," H2O:               ");
          printLCD(2, 9, sTempUnit);
          printLCD(2, 15, sTempUnit);
          printLCD(3, 9, sTempUnit);
          printLCD(3, 15, sTempUnit);
          lastCount = encCount;
        }
        printLCDPad(2, 6, itoa(tempKettle, buf, 10), 3, ' ');
        printLCDPad(2, 12, itoa(tempCFCBeerOut, buf, 10), 3, ' ');
        printLCDPad(3, 6, itoa(tempCFCH2OIn, buf, 10), 3, ' ');
        printLCDPad(3, 12, itoa(tempCFCH2OOut, buf, 10), 3, ' ');
        break;
      }

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
