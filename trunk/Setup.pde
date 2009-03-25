void menuSetup()
{
  


  while(1) {
    if (unit) strcpy(menuopts[0], "Unit: US"); else strcpy(menuopts[0], "Unit: Metric");
    if (sysHERMS) strcpy(menuopts[1], "System Type: HERMS"); else strcpy(menuopts[1], "System Type: Direct");
      
    switch (encMode) {
      case CUI:
        strcpy(menuopts[2], "Encoder: CUI");
        break;
      case ALPS:
        strcpy(menuopts[2], "Encoder: ALPS");
        break;
    }
    
    strcpy(menuopts[3], "Assign Temp Sensor");
    strcpy(menuopts[4], "Configure Outputs");
    strcpy(menuopts[5], "Volume/Capacity");
    strcpy(menuopts[6], "Configure Valves");
    strcpy(menuopts[7], "Save Settings");
    strcpy(menuopts[8], "Load Settings");
    strcpy(menuopts[9], "Exit Setup");
  
    switch(scrollMenu("System Setup", menuopts, 10)) {
      case 0:
        unit = unit ^ 1;
        if (unit) {
          //Convert Setup params
          for (int i = HLT; i <= KETTLE; i++) {
            hysteresis[i] = round(hysteresis[i] * 1.8);
            capacity[i] = round(capacity[i] * 0.26417);
            volume[i] = round(volume[i] * 0.26417);
            volLoss[i] = round(volLoss[i] * 0.26417);
          }
          defBatchVol = round(defBatchVol * 0.26417);
        } else {
          for (int i = HLT; i <= KETTLE; i++) {
            hysteresis[i] = round(hysteresis[i] / 1.8);
            capacity[i] = round(capacity[i] / 0.26417);
            volume[i] = round(volume[i] / 0.26417);
            volLoss[i] = round(volLoss[i] / 0.26417);
          }
          defBatchVol = round(defBatchVol / 0.26417);
        }
        break;
      case 1:
        sysHERMS = sysHERMS ^ 1;
        break;
      case 2: cfgEncoder(); break;
      case 3: assignSensor(); break;
      case 4: cfgOutputs(); break;
      case 5: cfgVolumes(); break;
      case 6: cfgValves(); break;
      case 7: saveSetup(); break;
      case 8: loadSetup(); break;
      default: return;
    }
  }
}

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
      strcpy(menuopts[0], "Scan Bus");
      strcpy(menuopts[1], "Close Menu");
      strcpy(menuopts[2], "Exit");
      switch (scrollMenu(dispTitle[lastCount], menuopts, 3)) {
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

void cfgOutputs() {
  char dispUnit[2] = "C";
  if (unit) strcpy(dispUnit, "F");

  while(1) {
    if (PIDEnabled[HLT]) strcpy(menuopts[0], "HLT Mode: PID"); else strcpy(menuopts[0], "HLT Mode: On/Off");
    strcpy(menuopts[1], "HLT PID Cycle");
    strcpy(menuopts[2], "HLT PID Gain");
    strcpy(menuopts[3], "HLT Hysteresis");
    if (PIDEnabled[MASH]) strcpy(menuopts[4], "Mash Mode: PID"); else strcpy(menuopts[4], "Mash Mode: On/Off");
    strcpy(menuopts[5], "Mash PID Cycle");
    strcpy(menuopts[6], "Mash PID Gain");
    strcpy(menuopts[7], "Mash Hysteresis");
    if (PIDEnabled[KETTLE]) strcpy(menuopts[8], "Kettle Mode: PID"); else strcpy(menuopts[8], "Kettle Mode: On/Off");
    strcpy(menuopts[9], "Kettle PID Cycle");
    strcpy(menuopts[10], "Kettle PID Gain");
    strcpy(menuopts[11], "Kettle Hysteresis");
    strcpy(menuopts[12], "Exit");

    switch(scrollMenu("Configure Outputs", menuopts, 13)) {
      case 0: PIDEnabled[HLT] = PIDEnabled[HLT] ^ 1; break;
      case 1: PIDCycle[HLT] = getValue("HLT Cycle Time", PIDCycle[HLT], 3, 0, 255, "s"); break;
      case 2: setPIDGain("HLT PID Gain", &PIDp[HLT], &PIDi[HLT], &PIDd[HLT]); break;
      case 3: hysteresis[HLT] = getValue("HLT Hysteresis", hysteresis[HLT], 3, 1, 255, dispUnit); break;
      case 4: PIDEnabled[MASH] = PIDEnabled[MASH] ^ 1; break;
      case 5: PIDCycle[MASH] = getValue("Mash Cycle Time", PIDCycle[MASH], 3, 0, 255, "s"); break;
      case 6: setPIDGain("Mash PID Gain", &PIDp[MASH], &PIDi[MASH], &PIDd[MASH]); break;
      case 7: hysteresis[MASH] = getValue("Mash Hysteresis", hysteresis[MASH], 3, 1, 255, dispUnit); break;
      case 8: PIDEnabled[KETTLE] = PIDEnabled[KETTLE] ^ 1; break;
      case 9: PIDCycle[KETTLE] = getValue("Kettle Cycle Time", PIDCycle[KETTLE], 3, 0, 255, "s"); break;
      case 10: setPIDGain("Kettle PID Gain", &PIDp[KETTLE], &PIDi[KETTLE], &PIDd[KETTLE]); break;
      case 11: hysteresis[KETTLE] = getValue("Kettle Hysteresis", hysteresis[KETTLE], 3, 1, 255, dispUnit); break;
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

void cfgVolumes() {
  while(1) {
    strcpy(menuopts[0], "HLT Capacity       ");
    strcpy(menuopts[1], "HLT Dead Space     ");
    strcpy(menuopts[2], "Mash Capacity      ");
    strcpy(menuopts[3], "Mash Dead Space    ");
    strcpy(menuopts[4], "Kettle Capacity    ");
    strcpy(menuopts[5], "Kettle Dead Space  ");
    strcpy(menuopts[6], "Batch Size         ");
    strcpy(menuopts[7], "Evaporation Rate   ");
    strcpy(menuopts[8], "Exit               ");

    char volUnit[5] = "L";
    if (unit) strcpy(volUnit, "Gal");
    switch(scrollMenu("Volume/Capacity", menuopts, 9)) {
      case 0: capacity[HLT] = getValue("HLT Capacity", capacity[HLT], 7, 3, 9999999, volUnit); break;
      case 1: volLoss[HLT] = getValue("HLT Dead Space", volLoss[HLT], 5, 3, 65535, volUnit); break;
      case 2: capacity[MASH] = getValue("Mash Capacity", capacity[MASH], 7, 3, 9999999, volUnit); break;
      case 3: volLoss[MASH] = getValue("Mash Dead Spac", volLoss[MASH], 5, 3, 65535, volUnit); break;
      case 4: capacity[KETTLE] = getValue("Kettle Capacity", capacity[KETTLE], 7, 3, 9999999, volUnit); break;
      case 5: volLoss[KETTLE] = getValue("Kettle Dead Spac", volLoss[KETTLE], 5, 3, 65535, volUnit); break;
      case 6: defBatchVol = getValue("Batch Size", defBatchVol, 7, 3, 9999999, volUnit); break;
      case 7: evapRate = getValue("Evaporation Rate", evapRate, 3, 0, 100, "%/hr");
      default: return;
    }
  } 
}

void cfgValves() {
  while (1) {
    strcpy(menuopts[0], "HLT Fill           ");
    strcpy(menuopts[1], "Mash Fill          ");
    strcpy(menuopts[2], "Mash Heat          ");
    strcpy(menuopts[3], "Mash Idle          ");
    strcpy(menuopts[4], "Sparge In          ");
    strcpy(menuopts[5], "Sparge Out         ");
    strcpy(menuopts[6], "Chiller H2O In     ");
    strcpy(menuopts[7], "Chiller Beer In    ");
    strcpy(menuopts[8], "Exit               ");
    
    byte profile = scrollMenu("Valve Configuration", menuopts, 9);
    if (profile > 7) return; else setValveCfg(profile, cfgValveProfile(menuopts[profile], getValveCfg(profile)));
  }
}

unsigned int cfgValveProfile (char sTitle[], unsigned int defValue) {
  unsigned int retValue = defValue;
  encMin = 0;
  encMax = 11;
  encCount = 0;
  int lastCount = 1;
  char buf[6];

  clearLCD();
  printLCD(0,0,sTitle);
  {
    int bit = 1;
    for (int i = 0; i < 11; i++) { 
      if (retValue & bit) printLCD(1, i + 4, "1"); else printLCD(1, i + 4, "0");
      bit *= 2;
    }
  }
  printLCD(3, 8, "OK");
  
  while(1) {
    if (encCount != lastCount) {
      printLCD(2, 0, "    0123456789A     ");
      if (encCount == 11) {
        printLCD(3, 7, ">");
        printLCD(3, 10, "<");
      } else {
        printLCD(3, 7, " ");
        printLCD(3, 10, " ");
        printLCD(2, encCount + 4, "^");
      }
    }
    lastCount = encCount;
    
    if (enterStatus == 1) {
      enterStatus = 0;
      if (encCount == 11) {  return retValue; }
      {
        int bit;
        for (int i = 0; i <= encCount; i++) if (!i) bit = 1; else bit *= 2;
        retValue = retValue ^ bit;
      }

      {
        int bit = 1;
        for (int i = 0; i < 11; i++) { 
          if (retValue & bit) printLCD(1, i + 4, "1"); else printLCD(1, i + 4, "0");
          bit *= 2;
        }
      }
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return defValue;
    }
  }
}

void cfgEncoder() {
  strcpy(menuopts[0], "CUI");
  strcpy(menuopts[1], "ALPS");
  encMode = scrollMenu("Select Encoder Type:", menuopts, 2);
  initEncoder();
}
