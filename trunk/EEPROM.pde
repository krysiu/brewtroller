#include <avr/EEPROM.h>
#include <EEPROM.h>

void saveSetup() {
  //Walk through the 6 tSensor elements and store 8-byte address of each
  //HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), BEEROUT (40-47)
  for (int i = HLT; i <= BEEROUT; i++) PROMwriteBytes(i * 8, tSensor[i], 8);

  //Option Array (48)
  byte options = B00000000;
  if (unit) options |= 1;
  if (PIDEnabled[HLT]) options |= 2;
  if (PIDEnabled[MASH]) options |= 4;
  if (PIDEnabled[KETTLE]) options |= 8;
  if (sysHERMS) options |= 16;
  EEPROM.write(48, options);
  
  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  //Volume Settings for HLT (64-71), MASH (72 - 79) and KETTLE (80 - 87)
  for (int i = HLT; i <= KETTLE; i++) {
    EEPROM.write(i * 5 + 49, PIDp[i]);
    EEPROM.write(i * 5 + 50, PIDi[i]);
    EEPROM.write(i * 5 + 51, PIDd[i]);
    EEPROM.write(i * 5 + 52, PIDCycle[i]);
    EEPROM.write(i * 5 + 53, hysteresis[i]);
    PROMwriteLong(i * 8 + 64, capacity[i]);
    PROMwriteLong(i * 8 + 68, volLoss[i]);
  }
  //Default Batch size (88-91)
  PROMwriteLong(88, defBatchVol);
  EEPROM.write(92, evapRate);
  EEPROM.write(93, encMode);

  //94 Reserved for Power Recovery
  //95 - 131 Reserved for AutoBrew Recovery
  //132 - 133 Reserved for Timer Recovery
}

void loadSetup() {
  //Walk through the 6 tSensor elements and load 8-byte address of each
  //HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), BEEROUT (40-47)
  for (int i = HLT; i <= BEEROUT; i++) PROMreadBytes(i * 8, tSensor[i], 8);
 
  //Option Array (48)
  byte options = EEPROM.read(48);
  if (options & 1) unit = 1;
  if (options & 2) PIDEnabled[HLT] = 1;
  if (options & 4) PIDEnabled[MASH] = 1;
  if (options & 8) PIDEnabled[KETTLE] = 1;
  if (options & 16) sysHERMS = 1;
  
  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  //Volume Settings for HLT (64-71), MASH (72 - 79) and KETTLE (80 - 87)
  for (int i = HLT; i <= KETTLE; i++) {
    PIDp[i] = EEPROM.read(i * 5 + 49);
    PIDi[i] = EEPROM.read(i * 5 + 50);
    PIDd[i] = EEPROM.read(i * 5 + 51);
    PIDCycle[i] = EEPROM.read(i * 5 + 52);
    hysteresis[i] = EEPROM.read(i * 5 + 53);
    capacity[i] = PROMreadLong(i * 8 + 64);
    volLoss[i] = PROMreadLong(i * 8 + 68);
  }
  //Default Batch size (88-91)
  defBatchVol = PROMreadLong(88);
  evapRate = EEPROM.read(92);
  encMode = EEPROM.read(93);

  //94 Reserved for Power Recovery
  //95 - 131 Reserved for AutoBrew Recovery
  //132 - 133 Reserved for Timer Recovery
}

void PROMwriteBytes(int addr, byte bytes[], int numBytes) {
  for (int i = 0; i < numBytes; i++) {
    EEPROM.write(addr + i, bytes[i]);
  }
}

void PROMreadBytes(int addr, byte bytes[], int numBytes) {
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
        PROMwriteBytes(49, defOutputSettings, 5);
        PROMwriteBytes(54, defOutputSettings, 5);
        PROMwriteBytes(59, defOutputSettings, 5);
      }
      //Set cfgVersion = 1
      EEPROM.write(64, 1);
    default:
      //No EEPROM Upgrade Required
      return;
  }
}

long PROMreadLong(int address) {
  long out;
  eeprom_read_block((void *) &out, (unsigned char *) address, 4);
  return out;
}

void PROMwriteLong(int address, long value) {
  eeprom_write_block((void *) &value, (unsigned char *) address, 4);
}

int PROMreadInt(int address) {
  int out;
  eeprom_read_block((void *) &out, (unsigned char *) address, 2);
  return out;
}

void PROMwriteInt(int address, int value) {
  eeprom_write_block((void *) &value, (unsigned char *) address, 2);
}

byte getPwrRecovery() { return EEPROM.read(94); }
void setPwrRecovery(byte funcValue) {  EEPROM.write(94, funcValue); }

byte getABRecovery() { return EEPROM.read(95); }
void setABRecovery(byte recoveryStep) { EEPROM.write(95, recoveryStep); }
byte getABSparge() { return EEPROM.read(96); }
void setABSparge(byte spargeTemp) { EEPROM.write(96, spargeTemp); }
byte getABHLT() { return EEPROM.read(97); }
void setABHLT(byte setHLT) { EEPROM.write(97, setHLT); }
unsigned long getABGrain() { return PROMreadLong(98); }
void setABGrain(unsigned long grainWeight) { PROMwriteLong(98, grainWeight); }
unsigned int getABDelay() { return PROMreadInt(102); }
void setABDelay(unsigned int delayMins) { PROMwriteInt(102, delayMins); }
unsigned int getABBoil() { return PROMreadInt(104); }
void setABBoil(unsigned int boilMins) { PROMwriteInt(104, boilMins); }
unsigned int getABRatio() { return PROMreadInt(106); }
void setABRatio(unsigned int mashRatio) { PROMwriteInt(106, mashRatio); }
void loadABSteps(byte stepTemp[4], byte stepMins[4]) { 
  for (int i=0; i<4; i++) {
    stepTemp[i] = EEPROM.read(108 + i);
    stepMins[i] = EEPROM.read(112 + i);
  }
}
void saveABSteps(byte stepTemp[4], byte stepMins[4]) {
  for (int i=0; i<4; i++) {
    EEPROM.write(108 + i, stepTemp[i]);
    EEPROM.write(112 + i, stepMins[i]);
  }  
}
void loadABVols(unsigned long tgtVol[3]) { for (int i=0; i<3; i++) { tgtVol[i] = PROMreadLong(116 + i * 4); } }
void saveABVols(unsigned long tgtVol[3]) { for (int i=0; i<3; i++) { PROMwriteLong(116 + i * 4, tgtVol[i]); } }

unsigned int getTimerRecovery() { return PROMreadInt(132); }
void setTimerRecovery(int newMins) { PROMwriteInt(132, newMins); }
