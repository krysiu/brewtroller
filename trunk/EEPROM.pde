#include <EEPROM.h>

void saveSetup() {
  for (int i = HLT; i <= BEEROUT; i++) PROMwriteBytes(tSensor[i], i * 8, 8);

  //Set Option Array  
  byte options = B00000000;
  if (tempUnit == TEMPF) options |= 1;
  if (PIDEnabled[HLT]) options |= 2;
  if (PIDEnabled[MASH]) options |= 4;
  if (PIDEnabled[KETTLE]) options |= 8;
  EEPROM.write(48, options);
  
  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  for (int i = HLT; i <= KETTLE; i++) {
    EEPROM.write(i * 5 + 49, PIDp[i]);
    EEPROM.write(i * 5 + 50, PIDi[i]);
    EEPROM.write(i * 5 + 51, PIDd[i]);
    EEPROM.write(i * 5 + 52, PIDCycle[i]);
    EEPROM.write(i * 5 + 53, hysteresis[i]);
  }
}

void loadSetup() {
  for (int i = HLT; i <= BEEROUT; i++) PROMreadBytes(tSensor[i], i * 8, 8);
 
  //Read Option Array  
  byte options = EEPROM.read(48);
  
  if (options & 1) tempUnit = TEMPF;
  if (options & 2) PIDEnabled[HLT] = 1;
  if (options & 4) PIDEnabled[MASH] = 1;
  if (options & 8) PIDEnabled[KETTLE] = 1;

  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  for (int i = HLT; i <= KETTLE; i++) {
    PIDp[i] = EEPROM.read(i * 5 + 49);
    PIDi[i] = EEPROM.read(i * 5 + 50);
    PIDd[i] = EEPROM.read(i * 5 + 51);
    PIDCycle[i] = EEPROM.read(i * 5 + 52);
    hysteresis[i] = EEPROM.read(i * 5 + 53);
  }
}

void PROMwriteBytes(byte bytes[], int addr, int numBytes) {
  for (int i = 0; i < numBytes; i++) {
    EEPROM.write(addr + i, bytes[i]);
  }
}

void PROMreadBytes(byte bytes[], int addr, int numBytes) {
  for (int i = 0; i < numBytes; i++) {
    bytes[i] = EEPROM.read(addr + i);
  }
}

void checkConfig() {
  byte cfgVersion = EEPROM.read(64);
  if (cfgVersion == 255) cfgVersion = 0;
  switch(cfgVersion) {
    case 0:
      clearLCD();
      printLCD(1, 0, "Initializing EEPROM ");
      printLCD(2, 0, "   Please Wait...   ");
      //Format EEPROM to 0's
      for (int i=0; i<2048; i++) EEPROM.write(i, 0);
      {
        //Default Output Settings: p: 3, i: 4, d: 2, cycle: 4s, Hysteresis 0.3C(0.5F)
        byte defOutputSettings[5] = {3, 4, 2, 4, 3};
        PROMwriteBytes(defOutputSettings, 49, 5);
        PROMwriteBytes(defOutputSettings, 54, 5);
        PROMwriteBytes(defOutputSettings, 59, 5);
      }
      //Set cfgVersion = 1
      EEPROM.write(64, 1);
    default:
      //No EEPROM Upgrade Required
      return;
  }
}
