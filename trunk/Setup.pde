void menuSetup()
{
  


  while(1) {
    if (unit) strcpy_P(menuopts[0], PSTR("Unit: US")); else strcpy_P(menuopts[0], PSTR("Unit: Metric"));
    if (sysHERMS) strcpy_P(menuopts[1], PSTR("System Type: HERMS")); else strcpy_P(menuopts[1], PSTR("System Type: Direct"));
      
    switch (encMode) {
      case CUI:
        strcpy_P(menuopts[2], PSTR("Encoder: CUI"));
        break;
      case ALPS:
        strcpy_P(menuopts[2], PSTR("Encoder: ALPS"));
        break;
    }
    
    strcpy_P(menuopts[3], PSTR("Assign Temp Sensor"));
    strcpy_P(menuopts[4], PSTR("Configure Outputs"));
    strcpy_P(menuopts[5], PSTR("Volume/Capacity"));
    strcpy_P(menuopts[6], PSTR("Configure Valves"));
    strcpy_P(menuopts[7], PSTR("Save Settings"));
    strcpy_P(menuopts[8], PSTR("Load Settings"));
    strcpy_P(menuopts[9], PSTR("Exit Setup"));
  
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
          setDefBatch(round(getDefBatch() * 0.26417));
        } else {
          for (int i = HLT; i <= KETTLE; i++) {
            hysteresis[i] = round(hysteresis[i] / 1.8);
            capacity[i] = round(capacity[i] / 0.26417);
            volume[i] = round(volume[i] / 0.26417);
            volLoss[i] = round(volLoss[i] / 0.26417);
          }
          setDefBatch(round(getDefBatch() / 0.26417));
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
      printLCD_P(0, 0, PSTR("Assign Temp Sensor"));
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
      strcpy_P(menuopts[0], PSTR("Scan Bus"));
      strcpy_P(menuopts[1], PSTR("Delete Address"));
      strcpy_P(menuopts[2], PSTR("Close Menu"));
      strcpy_P(menuopts[3], PSTR("Exit"));
      switch (scrollMenu(dispTitle[lastCount], menuopts, 4)) {
        case 0:
          clearLCD();
          printLCD(0,0, dispTitle[lastCount]);
          printLCD_P(1,0,PSTR("Disconnect all other"));
          printLCD_P(2,0,PSTR("  temp sensors now  "));
          {
            char conExit[2][19] = {
              "     Continue     ",
              "      Cancel      "};
            if (getChoice(conExit, 2, 3) == 0) getDSAddr(tSensor[lastCount]);
          }
          break;
        case 1:
          for (int i = 0; i <8; i++) tSensor[lastCount][i] = 0; break;
        case 2: break;
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
  if (unit) strcpy_P(dispUnit, PSTR("F"));

  while(1) {
    if (PIDEnabled[HLT]) strcpy_P(menuopts[0], PSTR("HLT Mode: PID")); else strcpy_P(menuopts[0], PSTR("HLT Mode: On/Off"));
    strcpy_P(menuopts[1], PSTR("HLT PID Cycle"));
    strcpy_P(menuopts[2], PSTR("HLT PID Gain"));
    strcpy_P(menuopts[3], PSTR("HLT Hysteresis"));
    if (PIDEnabled[MASH]) strcpy_P(menuopts[4], PSTR("Mash Mode: PID")); else strcpy_P(menuopts[4], PSTR("Mash Mode: On/Off"));
    strcpy_P(menuopts[5], PSTR("Mash PID Cycle"));
    strcpy_P(menuopts[6], PSTR("Mash PID Gain"));
    strcpy_P(menuopts[7], PSTR("Mash Hysteresis"));
    if (PIDEnabled[KETTLE]) strcpy_P(menuopts[8], PSTR("Kettle Mode: PID")); else strcpy_P(menuopts[8], PSTR("Kettle Mode: On/Off"));
    strcpy_P(menuopts[9], PSTR("Kettle PID Cycle"));
    strcpy_P(menuopts[10], PSTR("Kettle PID Gain"));
    strcpy_P(menuopts[11], PSTR("Kettle Hysteresis"));
    strcpy_P(menuopts[12], PSTR("Exit"));

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
  printLCD_P(1, 0, PSTR("P:     I:     D:    "));
  printLCD_P(3, 8, PSTR("OK"));
  
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
            printLCD_P(1, 2, PSTR(">"));
            printLCD_P(1, 9, PSTR(" "));
            printLCD_P(1, 16, PSTR(" "));
            printLCD_P(3, 7, PSTR(" "));
            printLCD_P(3, 10, PSTR(" "));
            break;
          case 1:
            printLCD_P(1, 2, PSTR(" "));
            printLCD_P(1, 9, PSTR(">"));
            printLCD_P(1, 16, PSTR(" "));
            printLCD_P(3, 7, PSTR(" "));
            printLCD_P(3, 10, PSTR(" "));
            break;
          case 2:
            printLCD_P(1, 2, PSTR(" "));
            printLCD_P(1, 9, PSTR(" "));
            printLCD_P(1, 16, PSTR(">"));
            printLCD_P(3, 7, PSTR(" "));
            printLCD_P(3, 10, PSTR(" "));
            break;
          case 3:
            printLCD_P(1, 2, PSTR(" "));
            printLCD_P(1, 9, PSTR(" "));
            printLCD_P(1, 16, PSTR(" "));
            printLCD_P(3, 7, PSTR(">"));
            printLCD_P(3, 10, PSTR("<"));
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
    strcpy_P(menuopts[0], PSTR("HLT Capacity       "));
    strcpy_P(menuopts[1], PSTR("HLT Dead Space     "));
    strcpy_P(menuopts[2], PSTR("Mash Capacity      "));
    strcpy_P(menuopts[3], PSTR("Mash Dead Space    "));
    strcpy_P(menuopts[4], PSTR("Kettle Capacity    "));
    strcpy_P(menuopts[5], PSTR("Kettle Dead Space  "));
    strcpy_P(menuopts[6], PSTR("Batch Size         "));
    strcpy_P(menuopts[7], PSTR("Evaporation Rate   "));
    strcpy_P(menuopts[8], PSTR("Exit               "));

    char volUnit[5] = "L";
    if (unit) strcpy_P(volUnit, PSTR("Gal"));
    switch(scrollMenu("Volume/Capacity", menuopts, 9)) {
      case 0: capacity[HLT] = getValue("HLT Capacity", capacity[HLT], 7, 3, 9999999, volUnit); break;
      case 1: volLoss[HLT] = getValue("HLT Dead Space", volLoss[HLT], 5, 3, 65535, volUnit); break;
      case 2: capacity[MASH] = getValue("Mash Capacity", capacity[MASH], 7, 3, 9999999, volUnit); break;
      case 3: volLoss[MASH] = getValue("Mash Dead Spac", volLoss[MASH], 5, 3, 65535, volUnit); break;
      case 4: capacity[KETTLE] = getValue("Kettle Capacity", capacity[KETTLE], 7, 3, 9999999, volUnit); break;
      case 5: volLoss[KETTLE] = getValue("Kettle Dead Spac", volLoss[KETTLE], 5, 3, 65535, volUnit); break;
      case 6: setDefBatch(getValue("Batch Size", getDefBatch(), 7, 3, 9999999, volUnit)); break;
      case 7: evapRate = getValue("Evaporation Rate", evapRate, 3, 0, 100, "%/hr");
      default: return;
    }
  } 
}

void cfgValves() {
  while (1) {
    strcpy_P(menuopts[0], PSTR("HLT Fill           "));
    strcpy_P(menuopts[1], PSTR("Mash Fill          "));
    strcpy_P(menuopts[2], PSTR("Mash Heat          "));
    strcpy_P(menuopts[3], PSTR("Mash Idle          "));
    strcpy_P(menuopts[4], PSTR("Sparge In          "));
    strcpy_P(menuopts[5], PSTR("Sparge Out         "));
    strcpy_P(menuopts[6], PSTR("Chiller H2O In     "));
    strcpy_P(menuopts[7], PSTR("Chiller Beer In    "));
    strcpy_P(menuopts[8], PSTR("Exit               "));
    
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
      if (retValue & bit) printLCD_P(1, i + 4, PSTR("1")); else printLCD_P(1, i + 4, PSTR("0"));
      bit *= 2;
    }
  }
  printLCD_P(3, 8, PSTR("OK"));
  
  while(1) {
    if (encCount != lastCount) {
      printLCD_P(2, 0, PSTR("    0123456789A     "));
      if (encCount == 11) {
        printLCD_P(3, 7, PSTR(">"));
        printLCD_P(3, 10, PSTR("<"));
      } else {
        printLCD_P(3, 7, PSTR(" "));
        printLCD_P(3, 10, PSTR(" "));
        printLCD_P(2, encCount + 4, PSTR("^"));
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
          if (retValue & bit) printLCD_P(1, i + 4, PSTR("1")); else printLCD_P(1, i + 4, PSTR("0"));
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
  strcpy_P(menuopts[0], PSTR("CUI"));
  strcpy_P(menuopts[1], PSTR("ALPS"));
  encMode = scrollMenu("Select Encoder Type:", menuopts, 2);
  initEncoder();
}
