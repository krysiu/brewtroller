#include <avr/EEPROM.h>
#include <EEPROM.h>

void saveSetup() {
  //Walk through the 5 tSensor elements and store 8-byte address of each
  //Zone 0 - Zone 4 (0-55)
  for (byte i = 0; i < 7; i++) PROMwriteBytes(i * 8, tSensor[i], 8);

   //Option Array (57)
  byte options = B00000000;
  //Bits 1, 2, 4, 8, 16, 32 = Pid Enabled for Zones 1-6
  for (byte i = 0; i < 6; i++) if (PIDEnabled[i]) options |= 1<<i;
  EEPROM.write(57, options);
  
  //Output Settings for Zones (58-87)
  for (byte i = 0; i < 6; i++) {
    EEPROM.write(i * 5 + 58, PIDp[i]);
    EEPROM.write(i * 5 + 59, PIDi[i]);
    EEPROM.write(i * 5 + 60, PIDd[i]);
    EEPROM.write(i * 5 + 61, PIDCycle[i]);
    EEPROM.write(i * 5 + 62, hysteresis[i]);
  }
  
  //88-96 Reserved for Power Recovery

  //2046 FermTroller FingerPrint
  //2047 EEPROM Version
}

void loadSetup() {
  //Walk through the 5 tSensor elements and store 8-byte address of each
  //Zone 0 - Zone 4 (0-55)
  for (byte i = 0; i < 7; i++) PROMreadBytes(i * 8, tSensor[i], 8);
 
  //Option Array (57)
  byte options = EEPROM.read(57);
  //Bits 1, 2, 4, 8, 16, 32 = Pid Enabled for Zones 1-6
  for (byte i = 0; i < 6; i++) if (options & 1<<i) PIDEnabled[i] = 1;
  
  //Output Settings for Zones (58-87)
  for (byte i = 0; i < 6; i++) {
    PIDp[i] = EEPROM.read(i * 5 + 58);
    PIDi[i] = EEPROM.read(i * 5 + 59);
    PIDd[i] = EEPROM.read(i * 5 + 60);
    PIDCycle[i] = EEPROM.read(i * 5 + 61);
    hysteresis[i] = EEPROM.read(i * 5 + 62);
  }

  //Power Recovery(88)
  pwrRecovery = EEPROM.read(88);
  
  //Setpoints (89-94)
  for (byte i = 0; i < 6; i++) setpoint[i] = EEPROM.read(89 + i);
  
  //95 - 96 Timer Recovery

  //2046 FermTroller FingerPrint
  //2047 EEPROM Version
}

void PROMwriteBytes(int addr, byte bytes[], byte numBytes) {
  for (byte i = 0; i < numBytes; i++) {
    EEPROM.write(addr + i, bytes[i]);
  }
}

void PROMreadBytes(int addr, byte bytes[], byte numBytes) {
  for (byte i = 0; i < numBytes; i++) {
    bytes[i] = EEPROM.read(addr + i);
  }
}

void checkConfig() {
  byte cfgVersion = EEPROM.read(2047);
  byte FTfingerprint = EEPROM.read(2046); //253 = FermTroller

#ifdef DEBUG
  logStart_P(LOGDEBUG);
  logField_P(PSTR("CFGVER"));
  logFieldI(cfgVersion);
  logEnd();
#endif

  if (cfgVersion == 255 || FTfingerprint != 253) cfgVersion = 0;
  switch(cfgVersion) {
    case 0:
      clearLCD();
      printLCD_P(0, 0, PSTR("Missing Config"));
      {
        strcpy_P(menuopts[0], INIT_EEPROM);
        strcpy_P(menuopts[1], CANCEL);
        if (!getChoice(2, 3)) {
          clearLCD();
          logString_P(LOGSYS, INIT_EEPROM);
          printLCD_P(1, 0, INIT_EEPROM);
          printLCD_P(2, 3, PSTR("Please Wait..."));
          //Format EEPROM to 0's
          for (int i=0; i<2048; i++) EEPROM.write(i, 0);
          {
            //Default Output Settings: p: 3, i: 4, d: 2, cycle: 4s, Hysteresis 0.3C(0.5F)
            #ifdef USEMETRIC
              byte defOutputSettings[5] = {3, 4, 2, 4, 3};
            #else
              byte defOutputSettings[5] = {3, 4, 2, 4, 5};
            #endif
            PROMwriteBytes(41, defOutputSettings, 5);
            PROMwriteBytes(46, defOutputSettings, 5);
            PROMwriteBytes(51, defOutputSettings, 5);
            PROMwriteBytes(56, defOutputSettings, 5);
          }
        }
      }
      //Set FermTroller Fingerprint
      EEPROM.write(2046, 253);
      //Set cfgVersion = 1
      EEPROM.write(2047, 1);
    case 1:
      //Bump cfgVersion up to 7 to resolve EEPROM mismatch with BT
      EEPROM.write(2047, 7);
    case 7:
      //Next Update
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

void setPwrRecovery(byte funcValue) {
  pwrRecovery = funcValue;
  EEPROM.write(88, funcValue);
}

void saveSetpoints() { for (byte i = 0; i < 6; i++) { EEPROM.write(89 + i, setpoint[i]); } }

unsigned int getTimerRecovery() { return PROMreadInt(95); }
void setTimerRecovery(unsigned int newMins) { PROMwriteInt(95, newMins); }
