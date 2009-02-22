void assignSensor() {
  encMin = 0;
  encMax = 5;
  encCount = 0;
  int lastCount = 1;
  char dispTitle[6][21] = {
    "   Hot Liquor Tank  ",
    "      Mash Tun      ",
    "     Brew Kettle    ",
    "       H2O In       ",
    "       H2O Out      ",
    "      Beer Out      "
  };
  char buf[3];
  
  while (1) {
    if (encCount != lastCount) {
      lastCount = encCount;
      clearLCD();
      printLCD(0, 0, "Assign Temp Sensor");
      printLCD(1, 0, dispTitle[lastCount]);
      for (int i=0; i<8; i++) printLCDPad(2,i*2+2,itoa(tSensor[lastCount][i], buf, 16), 2, '0');  
    }
    if (enterStatus == 2) {
      enterStatus = 0;
      return;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      //Pop-Up Menu
      char subMenu[3][20] = {
        "Scan Bus           ",
        "Close Menu         ",
        "Exit               "
      };
      switch (scrollMenu(dispTitle[lastCount], subMenu, 3)) {
        case 0:
          clearLCD();
          printLCD(0,0, dispTitle[lastCount]);
          printLCD(1,0,"Disconnect all other");
          printLCD(2,0,"  temp sensors now  ");
          {
            char conExit[2][19] = {
              "     Continue     ",
              "      Cancel      "};
            if (getChoice(conExit, 2, 3) == 0) getDSAddr(tSensor[lastCount]);
          }
          break;
        case 1: break;
        default: return;
      }
      encMin = 0;
      encMax = 5;
      encCount = lastCount;
      lastCount += 1;
    }
  }
}

void setTempUnit() {
  clearLCD();
  printLCD(0, 0, "Set Temperature Unit");
  char tempUnits[2][19] = {
    "     Celcius      ",
    "    Fahrenheit    "};
  byte newUnit = getChoice(tempUnits, 2, 1, tempUnit);
  if (newUnit > 1) return;
  if (tempUnit != newUnit) {
    tempUnit = newUnit;
    if (tempUnit) {
      for (int i = HLT; i <= KETTLE; i++) hysteresis[i] = hysteresis[i] * 9 / 5;
    } else {
      for (int i = HLT; i <= KETTLE; i++) hysteresis[i] = hysteresis[i] * 5 / 9;
    }
  }
}

void cfgOutputs() {
  char pidMenu[16][20];
  while(1) {
    byte nextElement = 0;
    if (PIDEnabled[HLT]) {
      strcpy(pidMenu[nextElement++], "HLT Mode: PID      ");
      strcpy(pidMenu[nextElement++], "HLT PID Cycle      ");
      strcpy(pidMenu[nextElement++], "HLT PID Gain       ");
    } else {
      strcpy(pidMenu[nextElement++], "HLT Mode: On/Off   ");
      strcpy(pidMenu[nextElement++], "HLT Hysteresis     ");
    }
    if (PIDEnabled[MASH]) {
      strcpy(pidMenu[nextElement++], "Mash Mode: PID     ");
      strcpy(pidMenu[nextElement++], "Mash PID Cycle     ");
      strcpy(pidMenu[nextElement++], "Mash PID Gain      ");
    } else {
      strcpy(pidMenu[nextElement++], "Mash Mode: On/Off  ");
      strcpy(pidMenu[nextElement++], "Mash Hysteresis    ");
    }
    if (PIDEnabled[KETTLE]) {
      strcpy(pidMenu[nextElement++], "Kettle Mode: PID   ");
      strcpy(pidMenu[nextElement++], "Kettle PID Cycle   ");
      strcpy(pidMenu[nextElement++], "Kettle PID Gain    ");
    } else {
      strcpy(pidMenu[nextElement++], "Kettle Mode: On/Off");
      strcpy(pidMenu[nextElement++], "Kettle Hysteresis  ");
    }
    strcpy(pidMenu[nextElement++],   "Exit               ");
    byte selected = scrollMenu("Configure Outputs", pidMenu, nextElement);
    char unit[2] = "C";
    if (tempUnit) strcpy(unit, "F");
    if (selected > 1 && !PIDEnabled[HLT]) selected++;
    if (selected > 4 && !PIDEnabled[MASH]) selected++;
    if (selected > 7 && !PIDEnabled[KETTLE]) selected++;
    switch(selected) {
      case 0: PIDEnabled[HLT] = PIDEnabled[HLT] ^ 1; break;
      case 3: PIDEnabled[MASH] = PIDEnabled[MASH] ^ 1; break;
      case 6: PIDEnabled[KETTLE] = PIDEnabled[KETTLE] ^ 1; break;
      case 1:
        if (PIDEnabled[HLT]) PIDCycle[HLT] = getValue("HLT Cycle Time", PIDCycle[HLT], 1, 255, "s");
        else hysteresis[HLT] = getValueTenths("HLT Hysteresis", hysteresis[HLT], 0, 255, unit);
        break;
      case 4:
        if (PIDEnabled[MASH]) PIDCycle[MASH] = getValue("Mash Cycle Time", PIDCycle[MASH], 1, 255, "s");
        else hysteresis[MASH] = getValueTenths("Mash Hysteresis", hysteresis[MASH], 0, 255, unit);
        break;
      case 7:
        if (PIDEnabled[KETTLE]) PIDCycle[KETTLE] = getValue("Kettle Cycle Time", PIDCycle[KETTLE], 1, 255, "s");
        else hysteresis[KETTLE] = getValueTenths("Kettle Hysteresis", hysteresis[KETTLE], 0, 255, unit);
        break;
      case 2: setPIDGain("HLT PID Gain", &PIDp[HLT], &PIDi[HLT], &PIDd[HLT]); break;
      case 5: setPIDGain("Mash PID Gain", &PIDp[MASH], &PIDi[MASH], &PIDd[MASH]); break;
      case 8: setPIDGain("Kettle PID Gain", &PIDp[KETTLE], &PIDi[KETTLE], &PIDd[KETTLE]); break;
      default: return;
    }
  } 
}

void setPIDGain(char sTitle[], byte* p, byte* i, byte* d) {
  byte retP = *p;
  byte retI = *i;
  byte retD = *d;
  byte cursorPos = 0; //0 = p, 1 = i, 2 = d, 3 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  encMin = 0;
  encMax = 3;
  encCount = 0;
  int lastCount = 1;
  char buf[3];
  
  clearLCD();
  printLCD(0,0,sTitle);
  printLCD(1, 0, "P:     I:     D:    ");
  printLCD(3, 8, "OK");
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        switch (cursorPos) {
          case 0: retP = encCount; break;
          case 1: retI = encCount; break;
          case 2: retD = encCount; break;
        }
      } else {
        cursorPos = encCount;
        switch (cursorPos) {
          case 0:
            printLCD(1, 2, ">");
            printLCD(1, 9, " ");
            printLCD(1, 16, " ");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 1:
            printLCD(1, 2, " ");
            printLCD(1, 9, ">");
            printLCD(1, 16, " ");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 2:
            printLCD(1, 2, " ");
            printLCD(1, 9, " ");
            printLCD(1, 16, ">");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 3:
            printLCD(1, 2, " ");
            printLCD(1, 9, " ");
            printLCD(1, 16, " ");
            printLCD(3, 7, ">");
            printLCD(3, 10, "<");
            break;
        }
      }
      printLCDPad(1, 3, itoa(retP, buf, 10), 3, ' ');
      printLCDPad(1, 10, itoa(retI, buf, 10), 3, ' ');
      printLCDPad(1, 17, itoa(retD, buf, 10), 3, ' ');
      lastCount = encCount;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (cursorPos == 3) {
        *p = retP;
        *i = retI;
        *d = retD;
        return;
      }
      cursorState = cursorState ^ 1;
      if (cursorState) {
        encMin = 0;
        encMax = 255;
        switch (cursorPos) {
          case 0: encCount = retP; break;
          case 1: encCount = retI; break;
          case 2: encCount = retD; break;
        }
      } else {
        encMin = 0;
        encMax = 3;
        encCount = cursorPos;
      }
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return;
    }
  }
}
