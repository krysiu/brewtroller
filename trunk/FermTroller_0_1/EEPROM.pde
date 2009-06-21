#include <avr/EEPROM.h>
#include <EEPROM.h>

void saveSetup() {
  //Walk through the 5 tSensor elements and store 8-byte address of each
  //Zone 0 - Zone 4 (0-39)
  for (byte i = 0; i < 5; i++) PROMwriteBytes(i * 8, tSensor[i], 8);

   //Option Array (40)
  byte options = B00000000;
  //Bits 1, 2, 4, 8 = Pid Enabled for Zones 1-4
  for (byte i = 0; i < 4; i++) if (PIDEnabled[i]) options |= 1<<i;
  EEPROM.write(40, options);
  
  //Output Settings for Zones (41-60)
  for (byte i = 0; i < 4; i++) {
    EEPROM.write(i * 5 + 41, PIDp[i]);
    EEPROM.write(i * 5 + 42, PIDi[i]);
    EEPROM.write(i * 5 + 43, PIDd[i]);
    EEPROM.write(i * 5 + 44, PIDCycle[i]);
    EEPROM.write(i * 5 + 45, hysteresis[i]);
  }
  
  //61 - 67 Reserved for Power Recovery

  //2046 FermTroller FingerPrint
  //2047 EEPROM Version
}

void loadSetup() {
  //Walk through the 5 tSensor elements and store 8-byte address of each
  //Zone 0 - Zone 4 (0-39)
  for (byte i = 0; i < 5; i++) PROMreadBytes(i * 8, tSensor[i], 8);
 
  //Option Array (40)
  byte options = EEPROM.read(40);
  //Bits 1, 2, 4, 8 = Pid Enabled for Zones 1-4
  for (byte i = 0; i < 4; i++) if (options | 1<<i) PIDEnabled[i] = 1;
  
  //Output Settings for Zones (41-60)
  for (byte i = 0; i < 4; i++) {
    PIDp[i] = EEPROM.read(i * 5 + 41);
    PIDi[i] = EEPROM.read(i * 5 + 42);
    PIDd[i] = EEPROM.read(i * 5 + 43);
    PIDCycle[i] = EEPROM.read(i * 5 + 44);
    hysteresis[i] = EEPROM.read(i * 5 + 45);
  }

  pwrRecovery = EEPROM.read(61); 
  for (byte i = 0; i < 4; i++) setpoint[i] = EEPROM.read(62 + i);
  
  //61 - 67 Reserved for Power Recovery

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

#ifdef DEBUG
  logStart_P(LOGDEBUG);
  logField_P(PSTR("CFGVER"));
  logFieldI(cfgVersion);
  logEnd();
#endif

  if (cfgVersion == 255) cfgVersion = 0;
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
      //Set cfgVersion = 1
      EEPROM.write(2047, 1);
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
  EEPROM.write(61, funcValue);
}

void saveSetpoints() { for (byte i = 0; i < 4; i++) { EEPROM.write(62 + i, setpoint[i]); } }

unsigned int getTimerRecovery() { return PROMreadInt(66); }
void setTimerRecovery(unsigned int newMins) { PROMwriteInt(66, newMins); }
