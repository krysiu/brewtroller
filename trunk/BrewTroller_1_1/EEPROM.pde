#include <avr/EEPROM.h>
#include <EEPROM.h>

void saveSetup() {
  //Walk through the 6 tSensor elements and store 8-byte address of each
  //HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), BEEROUT (40-47)
  for (byte i = TS_HLT; i <= TS_BEEROUT; i++) PROMwriteBytes(i * 8, tSensor[i], 8);

  //Option Array (48)
  byte options = B00000000;
  if (PIDEnabled[VS_HLT]) options |= 2;
  if (PIDEnabled[VS_MASH]) options |= 4;
  if (PIDEnabled[VS_KETTLE]) options |= 8;
  if (PIDEnabled[VS_STEAM]) options |= 16;
  EEPROM.write(48, options);
  
  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  //Volume Settings for HLT (64-71), MASH (72 - 79) and KETTLE (80 - 87)
  for (byte i = VS_HLT; i <= VS_KETTLE; i++) {
    EEPROM.write(i * 5 + 49, PIDp[i]);
    EEPROM.write(i * 5 + 50, PIDi[i]);
    EEPROM.write(i * 5 + 51, PIDd[i]);
    EEPROM.write(i * 5 + 52, PIDCycle[i]);
    EEPROM.write(i * 5 + 53, hysteresis[i]);
    PROMwriteLong(i * 8 + 64, capacity[i]);
    PROMwriteLong(i * 8 + 68, volLoss[i]);
  }
  
  //88-91, 93 Output Settings for Steam
  EEPROM.write(88, PIDp[VS_STEAM]);
  EEPROM.write(89, PIDi[VS_STEAM]);
  EEPROM.write(90, PIDd[VS_STEAM]);
  EEPROM.write(91, PIDCycle[VS_STEAM]);
  EEPROM.write(93, hysteresis[VS_STEAM]);
    
  EEPROM.write(92, evapRate);

  //94 - 129 Reserved for Power Recovery
  //130 Boil Temp
  //131 - 135 Reserved for Power Recovery
  //136 - 141 Zero Volumes

  EEPROM.write(142, steamTgt);
  PROMwriteInt(143, steamPSens);
  
  //145 - 151 ***OPEN***
  //152-155 Power Recovery
  //156-1805 Saved Programs

  //1806-1849 Valve Profiles
  for (byte profile = VLV_FILLHLT; profile <= VLV_CHILLBEER; profile ++) PROMwriteLong(1806 + (profile) * 4, vlvConfig[profile]);
  
  //1850-1860 ***OPEN***
  
  //Set all Volume Calibrations for a given vessel (EEPROM Bytes 1861 - 2040)
  // vessel: 0-2 Corresponding to TS_HLT, TS_MASH, TS_KETTLE
  // slot: 0-9 Individual slots representing a single volume/value pairing
  // vol: The volume for this calibration as a long in thousandths (1000 = 1)
  // val: An int representing the analogReadValue() to pair to the given volume
  for (byte vessel = VS_HLT; vessel <= VS_KETTLE; vessel++) {
    for (byte slot = 0; slot < 10; slot++) {
      PROMwriteLong(1861 + slot * 4 + vessel * 60, calibVols[vessel][slot]);
      PROMwriteInt(1901 + slot * 2 + vessel * 60, calibVals[vessel][slot]);
    }
  }
  //2041-2045 ***OPEN***
  //2046 BrewTroller Fingerprint
  //2047 EEPROM Version
}

void loadSetup() {
  //Walk through the 6 tSensor elements and load 8-byte address of each
  //HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), BEEROUT (40-47)
  for (byte i = TS_HLT; i <= TS_BEEROUT; i++) PROMreadBytes(i * 8, tSensor[i], 8);
 
  //Option Array (48)
  byte options = EEPROM.read(48);
  if (options & 2) PIDEnabled[VS_HLT] = 1;
  if (options & 4) PIDEnabled[VS_MASH] = 1;
  if (options & 8) PIDEnabled[VS_KETTLE] = 1;
  if (options & 16) PIDEnabled[VS_STEAM] = 1;
  
  //Output Settings for HLT (49-53), MASH (54 - 58) and KETTLE (59 - 63)
  //Volume Settings for HLT (64-71), MASH (72 - 79) and KETTLE (80 - 87)
  for (byte i = VS_HLT; i <= VS_KETTLE; i++) {
    PIDp[i] = EEPROM.read(i * 5 + 49);
    PIDi[i] = EEPROM.read(i * 5 + 50);
    PIDd[i] = EEPROM.read(i * 5 + 51);
    PIDCycle[i] = EEPROM.read(i * 5 + 52);
    hysteresis[i] = EEPROM.read(i * 5 + 53);
    capacity[i] = PROMreadLong(i * 8 + 64);
    volLoss[i] = PROMreadLong(i * 8 + 68);
  }

  //88-91, 93 Output Settings for Steam
  PIDp[VS_STEAM] = EEPROM.read(88);
  PIDi[VS_STEAM] = EEPROM.read(89);
  PIDd[VS_STEAM] = EEPROM.read(90);
  PIDCycle[VS_STEAM] = EEPROM.read(91);
  hysteresis[VS_STEAM] = EEPROM.read(93);
  
  evapRate = EEPROM.read(92);
  pwrRecovery = EEPROM.read(94); 
  recoveryStep = EEPROM.read(95); 
  //94 - 129 Reserved for Power Recovery
  //130 Boil Temp
  //131 - 135 Reserved for Power Recovery
  //136 - 141 Zero Volumes

  steamTgt = EEPROM.read(142);
  steamPSens = PROMreadInt(143);

  //145 - 151 ***OPEN***
  //152-155 Power Recovery
  //156-1805 Saved Programs

  //1806-1849 Valve Profiles
  for (byte profile = VLV_FILLHLT; profile <= VLV_CHILLBEER; profile ++) vlvConfig[profile] = PROMreadLong(1806 + (profile) * 4);

  //1850-1860 ***OPEN***

  //Get all Volume Calibrations for a given vessel (EEPROM Bytes 1861 - 2040)
  // vessel: 0-2 Corresponding to TS_HLT, TS_MASH, TS_KETTLE
  // vol: The volume for this calibration as a long in thousandths (1000 = 1)
  // val: An int representing the analogReadValue() to pair to the given volume
  for (byte vessel = VS_HLT; vessel <= VS_KETTLE; vessel++) {
    for (byte slot = 0; slot < 10; slot++) {
      calibVols[vessel][slot] = PROMreadLong(1861 + slot * 4 + vessel * 60);
      calibVals[vessel][slot] = PROMreadInt(1901 + slot * 2 + vessel * 60);
    }
  }
  
  //2041-2045 ***OPEN***
  //2046 BrewTroller Fingerprint
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
  byte BTFinger = EEPROM.read(2046);
  
#ifdef DEBUG
  logStart_P(LOGDEBUG);
  logField_P(PSTR("CFGVER"));
  logFieldI(cfgVersion);
  logEnd();
#endif

  //If the cfgVersion is newer than 6 and the BT fingerprint is missing force a init of EEPROM
  //FermTroller will bump to a cfgVersion starting at 7
  if (BTFinger != 254 && cfgVersion > 6) cfgVersion = 0;
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
            PROMwriteBytes(49, defOutputSettings, 5);
            PROMwriteBytes(54, defOutputSettings, 5);
            PROMwriteBytes(59, defOutputSettings, 5);
          }
        }
      }
      //Set cfgVersion = 1
      EEPROM.write(2047, 1);
    case 1:
      //Default Grain Temp = 60F/16C
      //If F else C
      #ifdef USEMETRIC
        EEPROM.write(156, 16);
      #else
        EEPROM.write(156, 60);
      #endif
      EEPROM.write(2047, 2);
    case 2:
      //Default Programs
#ifdef MODULE_DEFAULTABPROGS
      {
        setProgName(0, "Single Infusion");
        #ifdef USEMETRIC
          byte temps[4] = {0, 0, 67, 0};
          byte mins[4] = {0, 0, 60, 0};
          setProgSchedule(0, temps, mins);
          setProgSparge(0, 76);
          setProgHLT(0, 82);
          setProgRatio(0, 277);
          setProgPitch(0, 21);
          setProgGrainT(0, 16);
        #else
          byte temps[4] = {0, 0, 153, 0};
          byte mins[4] = {0, 0, 60, 0};
          setProgSchedule(0, temps, mins);
          setProgSparge(0, 168);
          setProgHLT(0, 180);
          setProgRatio(0, 133);
          setProgPitch(0, 70);
          setProgGrainT(0, 60);
        #endif
        setProgBoil(0, 60);
        setProgGrain(0, 0);
        setProgDelay(0, 0);
        unsigned long vols[3] = {0, 0, 0};
        setProgVols(0, vols);
        setProgAdds(0, 0);
      }
      {
        setProgName(1, "Multi-Rest");
        #ifdef USEMETRIC
          byte temps[4] = {40, 50, 67, 0};
          byte mins[4] = {20, 20, 60, 0};
          setProgSchedule(1, temps, mins);
          setProgSparge(1, 76);
          setProgHLT(1, 82);
          setProgRatio(1, 277);
          setProgPitch(1, 21);
          setProgGrainT(1, 16);
        #else
          byte temps[4] = {104, 122, 153, 0};
          byte mins[4] = {20, 20, 60, 0};
          setProgSchedule(1, temps, mins);
          setProgSparge(1, 168);
          setProgHLT(1, 180);
          setProgRatio(1, 133);
          setProgPitch(1, 70);
          setProgGrainT(1, 60);
        #endif

        setProgBoil(1, 60);
        setProgGrain(1, 0);
        setProgDelay(1, 0);
        unsigned long vols[3] = {0, 0, 0};
        setProgVols(1, vols);
        setProgAdds(1, 0);
      }
#endif
      EEPROM.write(2047, 3);
    case 3:
      //Move Valve Configs from old 2-Byte EEPROM (136-151) to new 4-Byte Locations
      for (byte profile = VLV_FILLHLT; profile <= VLV_CHILLBEER; profile ++) PROMwriteLong(1806 + (profile) * 4, PROMreadInt(136 + profile * 2));
      EEPROM.write(2047, 4);
    case 4:
      //Default Steam Output Settings
      EEPROM.write(88, 3);
      EEPROM.write(89, 4);
      EEPROM.write(90, 2);
      EEPROM.write(91, 4);
      #ifdef USEMETRIC
        EEPROM.write(93, 3);
      #else
        EEPROM.write(93, 5);
      #endif
      EEPROM.write(2047, 5);
    case 5:
      //Set Default Boil temp 212F/100C
      #ifdef USEMETRIC
        setBoilTemp(100);
      #else
        setBoilTemp(212);
      #endif
      EEPROM.write(2047, 6);
    case 6:
      //Add BT Fingerprint (254)
      EEPROM.write(2046, 254);
      EEPROM.write(2047, 7);
    case 7:
      //Move Profiles 6 & 7 +12 
      PROMwriteLong(1846, PROMreadLong(1834));
      PROMwriteLong(1842, PROMreadLong(1830));
      //Move Profiles 2 - 5 +4
      PROMwriteLong(1830, PROMreadLong(1826));
      PROMwriteLong(1826, PROMreadLong(1822));
      PROMwriteLong(1822, PROMreadLong(1818));
      PROMwriteLong(1818, PROMreadLong(1814));
      //Zero out new profiles
      PROMwriteLong(1814, 0);
      PROMwriteLong(1834, 0);
      PROMwriteLong(1838, 0);
      EEPROM.write(2047, 8);
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
  EEPROM.write(94, funcValue);
}

void setABRecovery(byte ABStep) { 
  recoveryStep = ABStep;
  EEPROM.write(95, ABStep);
}

byte getABSparge() { return EEPROM.read(96); }
void setABSparge(byte spargeTemp) { EEPROM.write(96, spargeTemp); }
unsigned long getABGrain() { return PROMreadLong(97); }
void setABGrain(unsigned long grainWeight) { PROMwriteLong(97, grainWeight); }
unsigned int getABDelay() { return PROMreadInt(101); }
void setABDelay(unsigned int delayMins) { PROMwriteInt(101, delayMins); }
unsigned int getABBoil() { return PROMreadInt(103); }
void setABBoil(unsigned int boilMins) { PROMwriteInt(103, boilMins); }
unsigned int getABRatio() { return PROMreadInt(105); }
void setABRatio(unsigned int mashRatio) { PROMwriteInt(105, mashRatio); }
void loadABSteps(byte stepTemp[4], byte stepMins[4]) { 
  for (byte i=0; i<4; i++) {
    stepTemp[i] = EEPROM.read(107 + i);
    stepMins[i] = EEPROM.read(111 + i);
  }
}
void saveABSteps(byte stepTemp[4], byte stepMins[4]) {
  for (byte i=0; i<4; i++) {
    EEPROM.write(107 + i, stepTemp[i]);
    EEPROM.write(111 + i, stepMins[i]);
  }  
}
void loadABVols(unsigned long tgtVol[3]) { for (byte i=0; i<3; i++) { tgtVol[i] = PROMreadLong(115 + i * 4); } }
void saveABVols(unsigned long tgtVol[3]) { for (byte i=0; i<3; i++) { PROMwriteLong(115 + i * 4, tgtVol[i]); } }

unsigned int getABAddsTrig() { return PROMreadInt(128); }
void setABAddsTrig(unsigned int adds) { PROMwriteInt(128, adds); }

byte getBoilTemp() { return EEPROM.read(130); }
void setBoilTemp(byte boilTemp) { EEPROM.write(130, boilTemp); }

void loadSetpoints() { for (byte i=TS_HLT; i<=TS_KETTLE; i++) { setpoint[i] = EEPROM.read(131 + i); } }
void saveSetpoints() { for (byte i=TS_HLT; i<=TS_KETTLE; i++) { EEPROM.write(131 + i, setpoint[i]); } }

unsigned int getTimerRecovery() { return PROMreadInt(134); }
void setTimerRecovery(unsigned int newMins) { PROMwriteInt(134, newMins); }

//Zero Volumes 136-141 (analogRead of Empty Vessels)
unsigned int loadZeroVols() { for (byte vessel = VS_HLT; vessel <= VS_KETTLE; vessel++) zeroVol[vessel] = PROMreadInt(136 + vessel * 2); }
void saveZeroVols() { 
  for (byte vessel = VS_HLT; vessel <= VS_KETTLE; vessel++) {
    zeroVol[vessel] = analogRead(vSensor[vessel]);
    PROMwriteInt(136 + vessel * 2, zeroVol[vessel]);
  }
}

byte getABPitch() { return EEPROM.read(152); }
void setABPitch(byte pitchTemp) { EEPROM.write(152, pitchTemp); }

unsigned int getABAdds() { return PROMreadInt(153); }
void setABAdds(unsigned int adds) { PROMwriteInt(153, adds); }

byte getABGrainTemp() { return EEPROM.read(127); }
void setABGrainTemp(byte grainTemp) { EEPROM.write(127, grainTemp); }

byte getABHLTTemp() { return EEPROM.read(155); }
void setABHLTTemp(byte grainTemp) { EEPROM.write(155, grainTemp); }


void setProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) EEPROM.write(preset * 55 + 156 + i, name[i]);
}

void getProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) name[i] = EEPROM.read(preset * 55 + 156 + i);
  name[19] = '\0';
}

void setProgSparge(byte preset, byte sparge) { EEPROM.write(preset * 55 + 175, sparge); }
byte getProgSparge(byte preset) { return EEPROM.read(preset * 55 + 175); }

void setProgGrain(byte preset, unsigned long grain) { PROMwriteLong(preset * 55 + 176, grain); }
unsigned long getProgGrain(byte preset) { return PROMreadLong(preset * 55 + 176); }

void setProgDelay(byte preset, unsigned int delayMins) { PROMwriteInt(preset * 55 + 180, delayMins); }
unsigned int getProgDelay(byte preset) { return PROMreadInt(preset * 55 + 180); }

void setProgBoil(byte preset, unsigned int boilMins) { PROMwriteInt(preset * 55 + 182, boilMins); }
unsigned int getProgBoil(byte preset) { return PROMreadInt(preset * 55 + 182); }

void setProgRatio(byte preset, unsigned int ratio) { PROMwriteInt(preset * 55 + 184, ratio); }
unsigned int getProgRatio(byte preset) { return PROMreadInt(preset * 55 + 184); }

void setProgSchedule(byte preset, byte stepTemp[4], byte stepMins[4]) {
  for (byte i=0; i<4; i++) {
     EEPROM.write(preset * 55 + 186 + i, stepTemp[i]);
     EEPROM.write(preset * 55 + 190 + i, stepMins[i]);
  }
}

void getProgSchedule(byte preset, byte stepTemp[4], byte stepMins[4]) {
  for (byte i=0; i<4; i++) {
    stepTemp[i] = EEPROM.read(preset * 55 + 186 + i);
    stepMins[i] = EEPROM.read(preset * 55 + 190 + i);
  }
}

void getProgVols(byte preset, unsigned long vols[3]) { for (byte i=0; i<3; i++) vols[i] = PROMreadLong(preset * 55 + 194 + i * 4); }
void setProgVols(byte preset, unsigned long vols[3]) { for (byte i=0; i<3; i++) PROMwriteLong(preset * 55 + 194 + i * 4, vols[i]); }

void setProgHLT(byte preset, byte HLT) { EEPROM.write(preset * 55 + 206, HLT); }
byte getProgHLT(byte preset) { return EEPROM.read(preset * 55 + 206); }

void setProgPitch(byte preset, byte pitch) { EEPROM.write(preset * 55 + 207, pitch); }
byte getProgPitch(byte preset) { return EEPROM.read(preset * 55 + 207); }

void setProgAdds(byte preset, unsigned int adds) { PROMwriteInt(preset * 55 + 208, adds); }
unsigned int getProgAdds(byte preset) { return PROMreadInt(preset * 55 + 208); }

void setProgGrainT(byte preset, byte grain) { EEPROM.write(preset * 55 + 210, grain); }
byte getProgGrainT(byte preset) { return EEPROM.read(preset * 55 + 210); }

