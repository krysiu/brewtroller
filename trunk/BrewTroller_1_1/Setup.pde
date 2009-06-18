void menuSetup() {
  byte lastOption = 0;
  while(1) {
    strcpy_P(menuopts[0], PSTR("Assign Temp Sensor"));
    strcpy_P(menuopts[1], PSTR("Configure Outputs"));
    strcpy_P(menuopts[2], PSTR("Volume/Capacity"));
    strcpy_P(menuopts[3], PSTR("Configure Valves"));
    strcpy_P(menuopts[4], PSTR("Exit Setup"));
    
    lastOption = scrollMenu("System Setup", 5, lastOption);
    if (lastOption == 0) assignSensor();
    else if (lastOption == 1) cfgOutputs();
    else if (lastOption == 2) cfgVolumes();
    else if (lastOption == 3) cfgValves();
    else return;
  }
}

void assignSensor() {
  encMin = 0;
  encMax = 5;
  encCount = 0;
  byte lastCount = 1;
  
  char dispTitle[6][21];
  strcpy_P(dispTitle[0], PSTR("Hot Liquor Tank"));
  strcpy_P(dispTitle[1], PSTR("Mash Tun"));
  strcpy_P(dispTitle[2], PSTR("Brew Kettle"));
  strcpy_P(dispTitle[3], PSTR("H2O In"));
  strcpy_P(dispTitle[4], PSTR("H2O Out"));
  strcpy_P(dispTitle[5], PSTR("Beer Out"));
  
  while (1) {
    if (encCount != lastCount) {
      lastCount = encCount;
      clearLCD();
      printLCD_P(0, 0, PSTR("Assign Temp Sensor"));
      printLCDCenter(1, 0, dispTitle[lastCount], 20);
      for (byte i=0; i<8; i++) printLCDLPad(2,i*2+2,itoa(tSensor[lastCount][i], buf, 16), 2, '0');  
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
      byte selected = scrollMenu(dispTitle[lastCount], 4, 0);
      if (selected == 0) {
        clearLCD();
        printLCDCenter(0, 0, dispTitle[lastCount], 20);
        printLCD_P(1,0,PSTR("Disconnect all other"));
        printLCD_P(2,2,PSTR("temp sensors now"));
        {
          strcpy_P(menuopts[0], PSTR("Continue"));
          strcpy_P(menuopts[1], CANCEL);
          if (getChoice(2, 3) == 0) getDSAddr(tSensor[lastCount]);
        }
      } else if (selected == 1) for (byte i = 0; i <8; i++) tSensor[lastCount][i] = 0;
      else if (selected > 2) return;

      saveSetup();
      encMin = 0;
      encMax = 5;
      encCount = lastCount;
      lastCount += 1;
    }
  }
}

void cfgOutputs() {
  byte lastOption = 0;
  while(1) {
    if (PIDEnabled[VS_HLT]) strcpy_P(menuopts[0], PSTR("HLT Mode: PID")); else strcpy_P(menuopts[0], PSTR("HLT Mode: On/Off"));
    strcpy_P(menuopts[1], PSTR("HLT PID Cycle"));
    strcpy_P(menuopts[2], PSTR("HLT PID Gain"));
    strcpy_P(menuopts[3], PSTR("HLT Hysteresis"));
    if (PIDEnabled[VS_MASH]) strcpy_P(menuopts[4], PSTR("Mash Mode: PID")); else strcpy_P(menuopts[4], PSTR("Mash Mode: On/Off"));
    strcpy_P(menuopts[5], PSTR("Mash PID Cycle"));
    strcpy_P(menuopts[6], PSTR("Mash PID Gain"));
    strcpy_P(menuopts[7], PSTR("Mash Hysteresis"));
    if (PIDEnabled[VS_KETTLE]) strcpy_P(menuopts[8], PSTR("Kettle Mode: PID")); else strcpy_P(menuopts[8], PSTR("Kettle Mode: On/Off"));
    strcpy_P(menuopts[9], PSTR("Kettle PID Cycle"));
    strcpy_P(menuopts[10], PSTR("Kettle PID Gain"));
    strcpy_P(menuopts[11], PSTR("Kettle Hysteresis"));
    strcpy_P(menuopts[12], PSTR("Boil Temp: "));
    strcat(menuopts[12], itoa(getBoilTemp(), buf, 10));
    strcat_P(menuopts[12], TUNIT);
    if (PIDEnabled[VS_STEAM]) strcpy_P(menuopts[13], PSTR("Steam Mode: PID")); else strcpy_P(menuopts[12], PSTR("Steam Mode: On/Off"));
    strcpy_P(menuopts[14], PSTR("Steam PID Cycle"));
    strcpy_P(menuopts[15], PSTR("Steam PID Gain"));
    strcpy_P(menuopts[16], PSTR("Steam Pressure"));
    strcpy_P(menuopts[17], PSTR("Steam Sensor Sens"));
    strcpy_P(menuopts[18], PSTR("Exit"));

    lastOption = scrollMenu("Configure Outputs", 19, lastOption);
    if (lastOption == 0) PIDEnabled[VS_HLT] = PIDEnabled[VS_HLT] ^ 1;
    else if (lastOption == 1) PIDCycle[VS_HLT] = getValue("HLT Cycle Time", PIDCycle[VS_HLT], 3, 0, 255, "s");
    else if (lastOption == 2) setPIDGain("HLT PID Gain", &PIDp[VS_HLT], &PIDi[VS_HLT], &PIDd[VS_HLT]);
    else if (lastOption == 3) hysteresis[VS_HLT] = getValue("HLT Hysteresis", hysteresis[VS_HLT], 3, 1, 255, TUNIT);
    else if (lastOption == 4) PIDEnabled[VS_MASH] = PIDEnabled[VS_MASH] ^ 1;
    else if (lastOption == 5) PIDCycle[VS_MASH] = getValue("Mash Cycle Time", PIDCycle[VS_MASH], 3, 0, 255, "s");
    else if (lastOption == 6) setPIDGain("Mash PID Gain", &PIDp[VS_MASH], &PIDi[VS_MASH], &PIDd[VS_MASH]);
    else if (lastOption == 7) hysteresis[VS_MASH] = getValue("Mash Hysteresis", hysteresis[VS_MASH], 3, 1, 255, TUNIT);
    else if (lastOption == 8) PIDEnabled[VS_KETTLE] = PIDEnabled[VS_KETTLE] ^ 1;
    else if (lastOption == 9) PIDCycle[VS_KETTLE] = getValue("Kettle Cycle Time", PIDCycle[VS_KETTLE], 3, 0, 255, "s");
    else if (lastOption == 10) setPIDGain("Kettle PID Gain", &PIDp[VS_KETTLE], &PIDi[VS_KETTLE], &PIDd[VS_KETTLE]);
    else if (lastOption == 11) hysteresis[VS_KETTLE] = getValue("Kettle Hysteresis", hysteresis[VS_KETTLE], 3, 1, 255, TUNIT);
    else if (lastOption == 12) setBoilTemp(getValue("Boil Temp", getBoilTemp(), 3, 0, 255, TUNIT));
    else if (lastOption == 13) PIDEnabled[VS_STEAM] = PIDEnabled[VS_STEAM] ^ 1;
    else if (lastOption == 14) PIDCycle[VS_STEAM] = getValue("Steam Cycle Time", PIDCycle[VS_STEAM], 3, 0, 255, "s");
    else if (lastOption == 15) setPIDGain("Steam PID Gain", &PIDp[VS_STEAM], &PIDi[VS_STEAM], &PIDd[VS_STEAM]);
    else if (lastOption == 16) hysteresis[VS_STEAM] = getValue("Steam Pressure", hysteresis[VS_STEAM], 3, 0, 255, PUNIT);
    else return;
    saveSetup();
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
  byte lastCount = 1;
  
  clearLCD();
  printLCD(0,0,sTitle);
  printLCD_P(1, 0, PSTR("P:     I:     D:    "));
  printLCD_P(3, 8, PSTR("OK"));
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        if (cursorPos == 0) retP = encCount;
        else if (cursorPos == 1) retI = encCount;
        else if (cursorPos == 2) retD = encCount;
      } else {
        cursorPos = encCount;
        if (cursorPos == 0) {
          printLCD_P(1, 2, PSTR(">"));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 1) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(">"));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 2) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(">"));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 3) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(">"));
          printLCD_P(3, 10, PSTR("<"));
        }
      }
      printLCDLPad(1, 3, itoa(retP, buf, 10), 3, ' ');
      printLCDLPad(1, 10, itoa(retI, buf, 10), 3, ' ');
      printLCDLPad(1, 17, itoa(retD, buf, 10), 3, ' ');
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
        if (cursorPos == 0) encCount = retP;
        else if (cursorPos == 1) encCount = retI;
        else if (cursorPos == 2) encCount = retD;
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
  byte lastOption = 0;
  while(1) {
    strcpy_P(menuopts[0], PSTR("HLT Capacity       "));
    strcpy_P(menuopts[1], PSTR("HLT Dead Space     "));
    strcpy_P(menuopts[2], PSTR("HLT Calibration    "));
    strcpy_P(menuopts[3], PSTR("Mash Capacity      "));
    strcpy_P(menuopts[4], PSTR("Mash Dead Space    "));
    strcpy_P(menuopts[5], PSTR("Mash Calibration   "));
    strcpy_P(menuopts[6], PSTR("Kettle Capacity    "));
    strcpy_P(menuopts[7], PSTR("Kettle Dead Space  "));
    strcpy_P(menuopts[8], PSTR("Kettle Calibration "));
    strcpy_P(menuopts[9], PSTR("Evaporation Rate   "));
    strcpy_P(menuopts[10], PSTR("Exit               "));

    lastOption = scrollMenu("Volume/Capacity", 11, lastOption);
    if (lastOption == 0) capacity[TS_HLT] = getValue("HLT Capacity", capacity[TS_HLT], 7, 3, 9999999, VOLUNIT);
    else if (lastOption == 1) volLoss[TS_HLT] = getValue("HLT Dead Space", volLoss[TS_HLT], 5, 3, 65535, VOLUNIT);
    else if (lastOption == 2) volCalibMenu(TS_HLT);
    else if (lastOption == 3) capacity[TS_MASH] = getValue("Mash Capacity", capacity[TS_MASH], 7, 3, 9999999, VOLUNIT);
    else if (lastOption == 4) volLoss[TS_MASH] = getValue("Mash Dead Space", volLoss[TS_MASH], 5, 3, 65535, VOLUNIT);
    else if (lastOption == 5) volCalibMenu(TS_MASH);
    else if (lastOption == 6) capacity[TS_KETTLE] = getValue("Kettle Capacity", capacity[TS_KETTLE], 7, 3, 9999999, VOLUNIT);
    else if (lastOption == 7) volLoss[TS_KETTLE] = getValue("Kettle Dead Space", volLoss[TS_KETTLE], 5, 3, 65535, VOLUNIT);
    else if (lastOption == 8) volCalibMenu(TS_KETTLE);
    else if (lastOption == 9) evapRate = getValue("Evaporation Rate", evapRate, 3, 0, 100, PSTR("%/hr"));
    else return;
    saveSetup();
  } 
}

void volCalibMenu(byte vessel) {
  byte lastOption = 0;
  char sVessel[7];
  char sTitle[20];
  if (vessel == TS_HLT) strcpy_P(sVessel, PSTR("HLT"));
  else if (vessel == TS_MASH) strcpy_P(sVessel, PSTR("Mash"));
  else if (vessel == TS_KETTLE) strcpy_P(sVessel, PSTR("Kettle"));

  while(1) {
    for(byte i = 0; i < 10; i++) {
      if (calibVals[vessel][i] > 0) {
        ftoa(calibVols[vessel][i] / 1000.0, buf, 3);
        truncFloat(buf, 6);
        strcpy(menuopts[i], buf);
        strcat_P(menuopts[i], SPACE);
        strcat_P(menuopts[i], VOLUNIT);
        strcat_P(menuopts[i], PSTR(" ("));
        strcat(menuopts[i], itoa(calibVals[vessel][i], buf, 10));
        strcat_P(menuopts[i], PSTR(")"));
      } else strcpy_P(menuopts[i], PSTR("OPEN"));
    }
    strcpy_P(menuopts[10], PSTR("Exit"));
    strcpy(sTitle, sVessel);
    strcat_P(sTitle, PSTR(" Calibration"));
    lastOption = scrollMenu(sTitle, 11, lastOption);
    if (lastOption > 9) return; 
    else {
      if (calibVols[vessel][lastOption] > 0) {
        if(confirmDel()) {
          calibVals[vessel][lastOption] = 0;
          calibVols[vessel][lastOption] = 0;
          saveSetup();
        }
      } else {
        strcpy_P(sTitle, PSTR("Current "));
        strcat(sTitle, sVessel);
        strcat_P(sTitle, PSTR(" Vol:"));
        calibVols[vessel][lastOption] = getValue(sTitle, 0, 7, 3, 9999999, VOLUNIT);
        calibVals[vessel][lastOption] = analogRead(vSensor[vessel]) - zeroVol[vessel];
        saveSetup();
      }
    }
  }
}

void cfgValves() {
  byte lastOption = 0;
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
    
    lastOption = scrollMenu("Valve Configuration", 9, lastOption);
    if (lastOption > 7) return;
    vlvConfig[lastOption] = cfgValveProfile(menuopts[lastOption], vlvConfig[lastOption]);
    saveSetup();
  }
}

unsigned long cfgValveProfile (char sTitle[], unsigned long defValue) {
  unsigned long retValue = defValue;
  encMin = 0;

#ifdef MUXBOARDS
  encMax = MUXBOARDS * 8;
#else
  encMax = 11;
#endif

  //The left most bit being displayed (Set to MAX + 1 to force redraw)
  byte firstBit = encMax + 1;
  encCount = 0;
  byte lastCount = 1;

  clearLCD();
  printLCD(0,0,sTitle);
  printLCD_P(3, 8, PSTR("OK"));
  
  while(1) {
    if (encCount != lastCount) {
      lastCount = encCount;
      
      if (lastCount < firstBit || lastCount > firstBit + 17) {
        if (lastCount < firstBit) firstBit = lastCount; else if (lastCount < encMax ) firstBit = lastCount - 17;
        for (byte i = firstBit; i < min(encMax, firstBit + 18); i++) if (retValue & ((unsigned long)1<<i)) printLCD_P(1, i - firstBit + 1, PSTR("1")); else printLCD_P(1, i - firstBit + 1, PSTR("0"));
      }

      for (byte i = firstBit; i < min(encMax, firstBit + 18); i++) {
        if (i < 9) itoa(i + 1, buf, 10); else buf[0] = i + 56;
        buf[1] = '\0';
        printLCD(2, i - firstBit + 1, buf);
      }

      if (firstBit > 0) printLCD_P(2, 0, PSTR("<")); else printLCD_P(2, 0, PSTR(" "));
      if (firstBit + 18 < encMax) printLCD_P(2, 19, PSTR(">")); else printLCD_P(2, 19, PSTR(" "));
      if (lastCount == encMax) {
        printLCD_P(3, 7, PSTR(">"));
        printLCD_P(3, 10, PSTR("<"));
      } else {
        printLCD_P(3, 7, PSTR(" "));
        printLCD_P(3, 10, PSTR(" "));
        printLCD_P(2, lastCount - firstBit + 1, PSTR("^"));
      }
    }
    
    if (enterStatus == 1) {
      enterStatus = 0;
      if (lastCount == encMax) return retValue;
      retValue = retValue ^ ((unsigned long)1<<lastCount);
      for (byte i = firstBit; i < min(encMax, firstBit + 18); i++) if (retValue & ((unsigned long)1<<i)) printLCD_P(1, i - firstBit + 1, PSTR("1")); else printLCD_P(1, i - firstBit + 1, PSTR("0"));
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return defValue;
    }
  }
}
