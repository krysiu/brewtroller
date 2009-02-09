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
