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
    saveSetup();
  }
}

void assignSensor() {
  encMin = 0;
  encMax = NUM_ZONES;
  encCount = 0;
  byte lastCount = 1;
  
  char dispTitle[NUM_ZONES + 1][21];
  for (byte i = 0; i < NUM_ZONES; i++) {
    strcpy_P(dispTitle[i], PSTR("Zone "));
    strcat(dispTitle[i], itoa(i + 1, buf, 10));
  }
  strcpy_P(dispTitle[NUM_ZONES], PSTR("Ambient"));
  
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
      encMax = NUM_ZONES;
      encCount = lastCount;
      lastCount += 1;
    }
  }
}

void cfgOutputs() {
  byte lastOption = 0;
  while(1) {
    if (NUM_PID_OUTS > 0) {
      for (byte i = 0; i < NUM_PID_OUTS; i++) {
        for (byte j = 0; j < 4; j++) {
          strcpy_P(menuopts[i * 4 + j], PSTR("Zone "));
          strcat(menuopts[i * 4 + j], itoa(i + 1, buf, 10));
        }
        strcat_P(menuopts[i * 4], PSTR(" Mode: "));
        if (PIDEnabled[i]) strcat_P(menuopts[i * 4], PSTR("PID")); 
          else strcat_P(menuopts[i * 4], PSTR("On/Off"));
        strcat_P(menuopts[i * 4 + 1], PSTR(" PID Cycle"));
        strcat_P(menuopts[i * 4 + 2], PSTR(" PID Gain"));
        strcat_P(menuopts[i * 4 + 3], PSTR(" Hysteresis"));
      }
    }
    if (NUM_ZONES - NUM_PID_OUTS > 0) {
      for (byte i = NUM_PID_OUTS; i < NUM_ZONES; i++) {
        strcpy_P(menuopts[NUM_PID_OUTS * 3 + i], PSTR("Zone "));
        strcat(menuopts[NUM_PID_OUTS * 3 + i], itoa(i + 1, buf, 10));
        strcat_P(menuopts[NUM_PID_OUTS * 3 + i], PSTR(" Hysteresis"));
      }
    }
    strcpy_P(menuopts[NUM_PID_OUTS * 3 + NUM_ZONES], PSTR("Exit"));
    lastOption = scrollMenu("Configure Outputs", NUM_PID_OUTS * 3 + NUM_ZONES + 1, lastOption);
    byte zone;
    char strZone[2];
    if (lastOption < NUM_PID_OUTS * 4) zone = lastOption / 4;
      else zone = (lastOption - NUM_PID_OUTS * 3);
    itoa(zone + 1, strZone, 10);
    if (lastOption >= NUM_PID_OUTS * 3 + NUM_ZONES) return;
    else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 == lastOption) PIDEnabled[zone] = PIDEnabled[zone] ^ 1;
    else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 + 1 == lastOption) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" Cycle Time"));
      PIDCycle[zone] = getValue(buf, PIDCycle[zone], 3, 0, 255, PSTR("s"));
      pid[zone].SetOutputLimits(0, PIDCycle[zone] * 1000);
    } else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 + 2 == lastOption) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" PID Gain"));
      setPIDGain(buf, &PIDp[zone], &PIDi[zone], &PIDd[zone]);
      pid[zone].SetTunings(PIDp[zone], PIDi[zone], PIDd[zone]);
    } else if ((zone < NUM_PID_OUTS && lastOption / 4 * 4 + 3 == lastOption) || zone >= NUM_PID_OUTS) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" Hysteresis"));
      hysteresis[zone] = getValue(buf, hysteresis[zone], 3, 1, 255, TUNIT);
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
