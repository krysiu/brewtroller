#include <EEPROM.h>

void saveSetup() {
  PROMwriteBytes(tsHLT, 0, 8);
  PROMwriteBytes(tsMash, 8, 8);
  PROMwriteBytes(tsKettle, 16, 8);
  PROMwriteBytes(tsCFCH2OIn, 24, 8);
  PROMwriteBytes(tsCFCH2OOut, 32, 8);
  PROMwriteBytes(tsCFCBeerOut, 40, 8);

  //Set Option Array  
  byte options = B00000000;
  if (tempUnit == TEMPF) options |= 1;
  if (hltPIDEnabled) options |= 2;
  if (mashPIDEnabled) options |= 4;
  if (kettlePIDEnabled) options |= 8;
  EEPROM.write(48, options);
  
  EEPROM.write(49, hltPIDp);
  EEPROM.write(50, hltPIDi);
  EEPROM.write(51, hltPIDd);
  EEPROM.write(52, hltPIDCycle);
  EEPROM.write(53, hltHysteresis);

  EEPROM.write(54, mashPIDp);
  EEPROM.write(55, mashPIDi);
  EEPROM.write(56, mashPIDd);
  EEPROM.write(57, mashPIDCycle);
  EEPROM.write(58, mashHysteresis);

  EEPROM.write(59, kettlePIDp);
  EEPROM.write(60, kettlePIDi);
  EEPROM.write(61, kettlePIDd);
  EEPROM.write(62, kettlePIDCycle);
  EEPROM.write(63, kettleHysteresis);
}

void loadSetup() {
  PROMreadBytes(tsHLT, 0, 8);
  PROMreadBytes(tsMash, 8, 8);
  PROMreadBytes(tsKettle, 16, 8);
  PROMreadBytes(tsCFCH2OIn, 24, 8);
  PROMreadBytes(tsCFCH2OOut, 32, 8);
  PROMreadBytes(tsCFCBeerOut, 40, 8);
  
  //Read Option Array  
  byte options = EEPROM.read(48);
  
  if (options & 1) tempUnit = TEMPF;
  if (options & 2) hltPIDEnabled = 1;
  if (options & 4) mashPIDEnabled = 1;
  if (options & 8) kettlePIDEnabled = 1;
  
  hltPIDp = EEPROM.read(49);
  hltPIDi = EEPROM.read(50);
  hltPIDd = EEPROM.read(51);
  hltPIDCycle = EEPROM.read(52);
  hltHysteresis = EEPROM.read(53);
  
  mashPIDp = EEPROM.read(54);
  mashPIDi = EEPROM.read(55);
  mashPIDd = EEPROM.read(56);
  mashPIDCycle = EEPROM.read(57);
  mashHysteresis = EEPROM.read(58);
  
  kettlePIDp = EEPROM.read(59);
  kettlePIDi = EEPROM.read(60);
  kettlePIDd = EEPROM.read(61);
  kettlePIDCycle = EEPROM.read(62);
  kettleHysteresis = EEPROM.read(63);
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
