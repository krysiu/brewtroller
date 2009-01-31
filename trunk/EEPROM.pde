void saveSetup() {
  PROMwriteBytes(tsHLT, 0, 8);
  PROMwriteBytes(tsMash, 8, 8);
  PROMwriteBytes(tsKettle, 16, 8);
  PROMwriteBytes(tsCFCH2OIn, 24, 8);
  PROMwriteBytes(tsCFCH2OOut, 32, 8);
  PROMwriteBytes(tsCFCBeerOut, 40, 8);

  //Set Option Array  
  byte options = B00000000;
  if (tempUnit == TEMPF) options |= B00000001;
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
