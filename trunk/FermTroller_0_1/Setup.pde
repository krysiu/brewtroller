void menuSetup() {
  byte lastOption = 0;
  while(1) {
    strcpy_P(menuopts[0], PSTR("Assign Temp Sensor"));
    strcpy_P(menuopts[1], PSTR("Configure Outputs"));
    strcpy_P(menuopts[2], INIT_EEPROM);
    strcpy_P(menuopts[3], PSTR("Exit Setup"));
    
    lastOption = scrollMenu("System Setup", 4, lastOption);
    if (lastOption == 0) assignSensor();
    else if (lastOption == 1) cfgOutputs();
    else if (lastOption == 2) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Reset Configuration?"));
      strcpy_P(menuopts[0], INIT_EEPROM);
        strcpy_P(menuopts[1], CANCEL);
        if (getChoice(2, 3) == 0) {
          EEPROM.write(2047, 0);
          checkConfig();
          loadSetup();
        }
    } else return;
  }
}

void assignSensor() {
  encMin = 0;
  encMax = 4;
  encCount = 0;
  byte lastCount = 1;
  
  char dispTitle[5][21];
  strcpy_P(dispTitle[0], PSTR("Zone 1"));
  strcpy_P(dispTitle[1], PSTR("Zone 2"));
  strcpy_P(dispTitle[2], PSTR("Zone 3"));
  strcpy_P(dispTitle[3], PSTR("Zone 4"));
  strcpy_P(dispTitle[4], PSTR("Ambient"));
  
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
      encMax = 4;
      encCount = lastCount;
      lastCount += 1;
    }
  }
}

void cfgOutputs() {
  byte lastOption = 0;
  while(1) {
    if (PIDEnabled[0]) strcpy_P(menuopts[0], PSTR("Zone 1 Mode: PID")); else strcpy_P(menuopts[0], PSTR("Zone 1 Mode: On/Off"));
    strcpy_P(menuopts[1], PSTR("Zone 1 PID Cycle"));
    strcpy_P(menuopts[2], PSTR("Zone 1 PID Gain"));
    strcpy_P(menuopts[3], PSTR("Zone 1 Hysteresis"));
    if (PIDEnabled[1]) strcpy_P(menuopts[4], PSTR("Zone 2 Mode: PID")); else strcpy_P(menuopts[4], PSTR("Zone 2 Mode: On/Off"));
    strcpy_P(menuopts[5], PSTR("Zone 2 PID Cycle"));
    strcpy_P(menuopts[6], PSTR("Zone 2 PID Gain"));
    strcpy_P(menuopts[7], PSTR("Zone 2 Hysteresis"));
    if (PIDEnabled[2]) strcpy_P(menuopts[8], PSTR("Zone 3 Mode: PID")); else strcpy_P(menuopts[8], PSTR("Zone 3 Mode: On/Off"));
    strcpy_P(menuopts[9], PSTR("Zone 3 PID Cycle"));
    strcpy_P(menuopts[10], PSTR("Zone 3 PID Gain"));
    strcpy_P(menuopts[11], PSTR("Zone 3 Hysteresis"));
    if (PIDEnabled[3]) strcpy_P(menuopts[12], PSTR("Zone 4 Mode: PID")); else strcpy_P(menuopts[12], PSTR("Zone 4 Mode: On/Off"));
    strcpy_P(menuopts[13], PSTR("Zone 4 PID Cycle"));
    strcpy_P(menuopts[14], PSTR("Zone 4 PID Gain"));
    strcpy_P(menuopts[15], PSTR("Zone 4 Hysteresis"));
    strcpy_P(menuopts[16], PSTR("Exit"));

    lastOption = scrollMenu("Configure Outputs", 17, lastOption);
    if (lastOption == 0) PIDEnabled[0] = PIDEnabled[0] ^ 1;
    else if (lastOption == 1) PIDCycle[0] = getValue("Zone 1 Cycle Time", PIDCycle[0], 3, 0, 255, "s");
    else if (lastOption == 2) setPIDGain("Zone 1 PID Gain", &PIDp[0], &PIDi[0], &PIDd[0]);
    else if (lastOption == 3) hysteresis[0] = getValue("Zone 1 Hysteresis", hysteresis[0], 3, 1, 255, TUNIT);
    else if (lastOption == 4) PIDEnabled[1] = PIDEnabled[1] ^ 1;
    else if (lastOption == 5) PIDCycle[1] = getValue("Zone 2 Cycle Time", PIDCycle[1], 3, 0, 255, "s");
    else if (lastOption == 6) setPIDGain("Zone 2 PID Gain", &PIDp[1], &PIDi[1], &PIDd[1]);
    else if (lastOption == 7) hysteresis[1] = getValue("Zone 2 Hysteresis", hysteresis[1], 3, 1, 255, TUNIT);
    else if (lastOption == 8) PIDEnabled[2] = PIDEnabled[2] ^ 1;
    else if (lastOption == 9) PIDCycle[2] = getValue("Zone 3 Cycle Time", PIDCycle[2], 3, 0, 255, "s");
    else if (lastOption == 10) setPIDGain("Zone 3 PID Gain", &PIDp[2], &PIDi[2], &PIDd[2]);
    else if (lastOption == 11) hysteresis[2] = getValue("Zone 3 Hysteresis", hysteresis[2], 3, 1, 255, TUNIT);
    else if (lastOption == 12) PIDEnabled[3] = PIDEnabled[3] ^ 1;
    else if (lastOption == 13) PIDCycle[3] = getValue("Zone 4 Cycle Time", PIDCycle[3], 3, 0, 255, "s");
    else if (lastOption == 14) setPIDGain("Zone 4 PID Gain", &PIDp[3], &PIDi[3], &PIDd[3]);
    else if (lastOption == 15) hysteresis[3] = getValue("Zone 4 Hysteresis", hysteresis[3], 3, 0, 255, PUNIT);
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
