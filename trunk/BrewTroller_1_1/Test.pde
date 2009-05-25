void menuTest() {
//Program memory used: <1KB (as of Build 205)
#ifdef MODULE_SYSTEST
  byte lastOption = 0;
  
  while(1) {
    strcpy_P(menuopts[0], PSTR("HLT Volume"));
    strcpy_P(menuopts[1], PSTR("Mash Volume"));
    strcpy_P(menuopts[2], PSTR("Kettle Volume"));
    strcpy_P(menuopts[3], PSTR("Exit Test"));
    
    lastOption = scrollMenu("Test Menu", menuopts, 4, lastOption);
    switch(lastOption) {
      case 0: volumeTest(TS_HLT); break;
      case 1: volumeTest(TS_MASH); break;
      case 2: volumeTest(TS_KETTLE); break;
      default: return;
    }
  }
#endif
}

void volumeTest(byte vessel) {
#ifdef MODULE_SYSTEST
  setZeroVol(vessel, analogRead(vSensor[vessel]));
  unsigned int calibVals[10];
  unsigned long calibVols[10];
  unsigned int zero;
  unsigned long vol;
  char buf[8];
  unsigned long lastUpdate = 0;

  zero = getZeroVol(vessel);
  getVolCalibs(vessel, calibVols, calibVals);
  clearLCD();
  printLCD(0, 0, "Zero: ");
  printLCD(0, 11, itoa(zero, buf, 10));
  printLCD(1, 0, "Raw: ");
  printLCD(2, 0, "Corrected: ");
  printLCD(3, 0, "Volume: ");
      
  while (1) {
    if (millis() - lastUpdate > 750) {
      vol = readVolume(vSensor[vessel], calibVols, calibVals, zero);
      printLCD_P(1, 11, PSTR("        "));
      printLCD(1, 11, itoa(digitalRead(vSensor[vessel]), buf, 10));
      printLCD_P(2, 11, PSTR("        "));
      printLCD(2, 11, itoa(digitalRead(vSensor[vessel] - zero), buf, 10));
      ftoa(vol/1000.0, buf, 2);
      printLCD_P(3, 11, PSTR("        "));
      printLCD(3, 11, buf);
      lastUpdate = millis();
    }
    if (enterStatus == 2) { enterStatus = 0; return; }
  }
#endif
}
