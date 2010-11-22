/*  
   Copyright (C) 2009, 2010 Matt Reba, Jermeiah Dillingham

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.


BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com
*/

#include "Config.h"
#include "Enum.h"
#include <avr/eeprom.h>
#include <EEPROM.h>

void loadSetup() {
  //**********************************************************************************
  //TSensors: HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39),
  //          BEEROUT (40-47), AUX1 (48-55), AUX2 (56-63), AUX3 (64-71)
  //**********************************************************************************
  for (byte i = TS_PIT_1; i <= TS_AUX3; i++) PROMreadBytes(i * 8, tSensor[i], 8);
  #ifdef HLT_AS_KETTLE
    PROMreadBytes(0, tSensor[TS_PIT_3], 8);
  #endif
 
  //**********************************************************************************
  //PID Enabled (72); Bit 1 = HLT, Bit 2 = Mash, Bit 3 = Kettle, Bit 4 = Steam
  //PIDp HLT (73), Mash (78), Kettle (83), Steam (88)
  //PIDi HLT (74), Mash (79), Kettle (84), Steam (89)
  //PIDd HLT (75), Mash (80), Kettle (85), Steam (90)
  //PIDCycle HLT (76), Mash (81), Kettle (86), Steam (91)
  //Hysteresis HLT (77), Mash (82), Kettle (87), Steam (92)
  //**********************************************************************************
  {
    byte options = EEPROM.read(72);
    for (byte i = PIT_1; i <= PIT_3; i++) {
      PIDEnabled[i] = bitRead(options, i);
      PIDCycle[i] = EEPROM.read(76 + i * 5);
      hysteresis[i] = EEPROM.read(77 + i * 5);
    }
  }
  
  //**********************************************************************************
  //boilPwr (112)
  //**********************************************************************************
  boilPwr = EEPROM.read(112);
  //**********************************************************************************
  //steamZero (114)
  //**********************************************************************************
  steamZero = PROMreadInt(114);
  //**********************************************************************************
  //steamPSens (117-118)
  //**********************************************************************************
  steamPSens = PROMreadInt(117);

  //**********************************************************************************
  //calibVols HLT (119-158), Mash (159-198), Kettle (199-238)
  //calibVals HLT (239-258), Mash (259-278), Kettle (279-298)
  //**********************************************************************************
  for (byte smokerPit = PIT_1; smokerPit <= PIT_3; smokerPit++) {
    for (byte slot = 0; slot < 10; slot++) {
      calibVols[smokerPit][slot] = PROMreadLong(119 + smokerPit * 40 + slot * 4);
      calibVals[smokerPit][slot] = PROMreadInt(239 + smokerPit * 20 + slot * 2);
    }
  }

  //**********************************************************************************
  //setpoints (299-301)
  //**********************************************************************************
  for (byte i=PIT_1; i<=PIT_3; i++) { 
    setpoint[i] = EEPROM.read(299 + i) * 100;
    eventHandler(EVENT_SETPOINT, i);
  }
  
  //**********************************************************************************
  //timers (302-307)
  //**********************************************************************************
  for (byte i=TIMER_S1; i<=TIMER_S3; i++) { timerValue[i] = PROMreadInt(302 + i * 2) * 60000; }

  //**********************************************************************************
  //Timer/Alarm Status (308)
  //**********************************************************************************
  byte options = EEPROM.read(308);
  for (byte i = TIMER_S1; i <= TIMER_S3; i++) {
    timerStatus[i] = bitRead(options, i);
    lastTime[i] = millis();
  }
  alarmStatus = bitRead(options, 2);
  alarmPin.set(alarmStatus);
  
  #ifdef DEBUG_TIMERALARM
    logStart_P(LOGDEBUG);
    logField("TimerAlarmStatus");
    logFieldI(bitRead(options, 0));
    logFieldI(bitRead(options, 1));
    logFieldI(bitRead(options, 2));
    logEnd();
  #endif
  

  //**********************************************************************************
  //Step (313-327) NUM_BREW_STEPS (15)
  //**********************************************************************************
  for(byte brewStep = 0; brewStep < NUM_BREW_STEPS; brewStep++) stepInit(EEPROM.read(313 + brewStep), brewStep);

  //**********************************************************************************
  //401-456 Valve Profiles
  //**********************************************************************************
  for (byte profile = VLV_FILLHLT; profile <= VLV_HLTHEAT; profile++) vlvConfig[profile] = PROMreadLong(401 + profile * 4);

}


//*****************************************************************************************************************************
// Individual EEPROM Get/Set Variable Functions
//*****************************************************************************************************************************

//**********************************************************************************
//TSensors: HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), 
//          BEEROUT (40-47), AUX1 (48-55), AUX2 (56-63), AUX3 (64-71)
//**********************************************************************************
void setTSAddr(byte sensor, byte addr[8]) {
  for (byte i = 0; i<8; i++) tSensor[sensor][i] = addr[i];
  PROMwriteBytes(sensor * 8, addr, 8);
}

//**********************************************************************************
//PID Enabled (72); Bit 1 = HLT, Bit 2 = Mash, Bit 3 = Kettle, Bit 4 = Steam
//**********************************************************************************
void setPIDEnabled(byte smokerPit, boolean setting) {
  PIDEnabled[smokerPit] = setting;
  byte options = EEPROM.read(72);
  bitWrite(options, smokerPit, setting);
  EEPROM.write(72, options);
}


//**********************************************************************************
//PIDp Smoker1 (73), Smoker2 (78), Smoker3 (83)
//**********************************************************************************
void setPIDp(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(value, pid[smokerPit].GetI_Param(), pid[smokerPit].GetD_Param());
  EEPROM.write(73 + smokerPit * 5, value);
}
byte getPIDp(byte smokerPit) { return EEPROM.read(73 + smokerPit * 5); }

//**********************************************************************************
//PIDi Smoker1 (74), Smoker2 (79), Smoker3 (84)
//**********************************************************************************
void setPIDi(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(pid[smokerPit].GetP_Param(), value, pid[smokerPit].GetD_Param());
  EEPROM.write(74 + smokerPit * 5, value);
}
byte getPIDi(byte smokerPit) { return EEPROM.read(74 + smokerPit * 5); }

//**********************************************************************************
//PIDd Smoker1 (75), Smoker2 (80), Smoker3 (85)
//**********************************************************************************
void setPIDd(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(pid[smokerPit].GetP_Param(), pid[smokerPit].GetI_Param(), value);
  EEPROM.write(75 + smokerPit * 5, value);
}
byte getPIDd(byte smokerPit) { return EEPROM.read(75 + smokerPit * 5); }

//**********************************************************************************
//PIDCycle Smoker1 (76), Smoker2 (81), Smoker3 (86)
//**********************************************************************************
void setPIDCycle(byte smokerPit, byte value) {
  PIDCycle[smokerPit] = value;
  EEPROM.write(76 + smokerPit * 5, value);
}

//**********************************************************************************
//Hysteresis Smoker1 (77), Smoker2 (82), Smoker3 (87)
//**********************************************************************************
void setHysteresis(byte smokerPit, byte value) {
  hysteresis[smokerPit] = value;
  EEPROM.write(77 + smokerPit * 5, value);
}

//**********************************************************************************
//Capacity Smoker1 (93-96), Smoker2 (97-100), Smoker3 (101-104)
//**********************************************************************************
void setCapacity(byte smokerPit, unsigned long value) {
  PROMwriteLong(93 + smokerPit * 4, value);
}
unsigned long getCapacity(byte smokerPit) { return PROMreadLong(93 + smokerPit * 4); }

//**********************************************************************************
//volLoss Smoker1 (105-106), Smoker2 (107-108), Smoker3 (109-110)
//**********************************************************************************
void setVolLoss(byte smokerPit, unsigned int value) {
  PROMwriteInt(105 + smokerPit * 2, value);
}
unsigned int getVolLoss(byte smokerPit) { return PROMreadInt(105 + smokerPit * 2); }

//**********************************************************************************
//Boil Temp (111)
//**********************************************************************************
byte getBoilTemp() { return EEPROM.read(111); }
void setBoilTemp(byte boilTemp) { EEPROM.write(111, boilTemp); }

//**********************************************************************************
//Boil Power (112)
//**********************************************************************************
void setBoilPwr(byte value) { 
  boilPwr = value;
  EEPROM.write(112, value); 
}

//**********************************************************************************
//evapRate (113)
//**********************************************************************************
void setEvapRate(byte value) {
  EEPROM.write(113, value);
}
byte getEvapRate() { return EEPROM.read(113); }

//**********************************************************************************
//steamZero (114-115)
//**********************************************************************************
void setSteamZero(unsigned int value) {
  steamZero = value;
  PROMwriteInt(114, value);
}

//**********************************************************************************
//steamTgt (116)
//**********************************************************************************
void setSteamTgt(byte value) { EEPROM.write(116, value); }
byte getSteamTgt() { return EEPROM.read(116); }

//**********************************************************************************
//steamPSens (117-118)
//**********************************************************************************
void setSteamPSens(unsigned int value) {
  steamPSens = value;
  #ifndef PID_FLOW_CONTROL
  #ifdef USEMETRIC
    pid[PIT_3].SetInputLimits(0, 50000 / steamPSens);
  #else
    pid[PIT_3].SetInputLimits(0, 7250 / steamPSens);
  #endif
  #endif
  PROMwriteInt(117, value);
}

//**********************************************************************************
//calibVols HLT (119-158), Mash (159-198), Kettle (199-238)
//calibVals HLT (239-258), Mash (259-278), Kettle (279-298)
//**********************************************************************************
void setVolCalib(byte smokerPit, byte slot, unsigned int value, unsigned long vol) {
  calibVols[smokerPit][slot] = vol;
  calibVals[smokerPit][slot] = value;
  #ifdef HLT_AS_KETTLE
    if (smokerPit == PIT_1) {
      //Also copy HLT setting to Kettle
      calibVols[PIT_3][slot] = vol;
      calibVals[PIT_3][slot] = value;  
    }
    if (smokerPit == PIT_3) {
      //Store actual calibration in HLT EEPROM Table
      smokerPit = PIT_1;
      calibVols[smokerPit][slot] = vol;
      calibVals[smokerPit][slot] = value;  
    } 
  #endif
  PROMwriteLong(119 + smokerPit * 40 + slot * 4, vol);
  PROMwriteInt(239 + smokerPit * 20 + slot * 2, value);
}

//*****************************************************************************************************************************
// Power Loss Recovery Functions
//*****************************************************************************************************************************

//**********************************************************************************
//setpoints (299-301)
//**********************************************************************************
void setSetpoint(byte object, byte value) { 
  setpoint[object] = value * 100;
  EEPROM.write(299 + object, value);
  eventHandler(EVENT_SETPOINT, object);
}

//**********************************************************************************
//timers (302-307)
//**********************************************************************************
void setTimerRecovery(byte timer, unsigned int newMins) { 
  if(newMins != -1) PROMwriteInt(302 + timer * 2, newMins); 
}

//**********************************************************************************
//Timer/Alarm Status (308)
//**********************************************************************************
void setTimerStatus(byte timer, boolean value) {
  timerStatus[timer] = value;
  byte options = EEPROM.read(308);
  bitWrite(options, timer, value);
  EEPROM.write(308, options);
  
  #ifdef DEBUG_TIMERALARM
    logStart_P(LOGDEBUG);
    logField("setTimerStatus");
    logFieldI(value);
    options = EEPROM.read(308);
    logFieldI(bitRead(options, timer));    
    logEnd();
  #endif
}

void setAlarmStatus(boolean value) {
  alarmStatus = value;
  byte options = EEPROM.read(308);
  bitWrite(options, 2, value);
  EEPROM.write(308, options);
  
  #ifdef DEBUG_TIMERALARM
    logStart_P(LOGDEBUG);
    logField("setAlarmStatus");
    logFieldI(value);
    options = EEPROM.read(308);
    logFieldI(bitRead(options, 2));
    logEnd();
  #endif
}



//**********************************************************************************
//Triggered Boil Addition Alarms (309-310)
//**********************************************************************************
unsigned int getBoilAddsTrig() { return PROMreadInt(309); }
void setBoilAddsTrig(unsigned int adds) { PROMwriteInt(309, adds); }

//**********************************************************************************
// ***OPEN*** (311-312)
//**********************************************************************************


//**********************************************************************************
//Step (313-327) NUM_BREW_STEPS (15)
//**********************************************************************************
void setProgramStep(byte brewStep, byte actPgm) {
  stepProgram[brewStep] = actPgm;
  EEPROM.write(313 + brewStep, actPgm); 
}

//**********************************************************************************
//Reserved (328-397)
//**********************************************************************************

//**********************************************************************************
//Delay Start (Mins) (398-399)
//**********************************************************************************
unsigned int getDelayMins() { return PROMreadInt(398); }
void setDelayMins(unsigned int mins) { 
  if(mins != -1) PROMwriteInt(398, mins); 
}

//**********************************************************************************
//Grain Temp (400)
//**********************************************************************************
void setGrainTemp(byte grainTemp) { EEPROM.write(400, grainTemp); }
byte getGrainTemp() { return EEPROM.read(400); }

//*****************************************************************************************************************************
// Valve Profile Configuration (401-456; 457-785 Reserved)
//*****************************************************************************************************************************
void setValveCfg(byte profile, unsigned long value) {
  vlvConfig[profile] = value;
  PROMwriteLong(401 + profile * 4, value);
}

//*****************************************************************************************************************************
// Program Load/Save Functions (786-1985) - 20 Program Slots Total
//*****************************************************************************************************************************
#define PROGRAM_SIZE 60
#define PROGRAM_START_ADDR 786

//**********************************************************************************
//Program Name (P:1-19)
//**********************************************************************************
void setProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + i, name[i]);
}

void getProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) name[i] = EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + i);
  name[19] = '\0';
}

//**********************************************************************************
//OPEN (P:20)
//**********************************************************************************

//**********************************************************************************
//Sparge Temp (P:21)
//**********************************************************************************
void setProgSparge(byte preset, byte sparge) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 21, sparge); }
byte getProgSparge(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 21); }

//**********************************************************************************
//Boil Mins (P:22-23)
//**********************************************************************************
void setProgBoil(byte preset, int boilMins) { 
  if (boilMins != -1) PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 22, boilMins); 
}
unsigned int getProgBoil(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 22); }

//**********************************************************************************
//Mash Ratio (P:24-25)
//**********************************************************************************
void setProgRatio(byte preset, unsigned int ratio) { PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 24, ratio); }
unsigned int getProgRatio(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 24); }

//**********************************************************************************
//Mash Temps (P:26-31)
//**********************************************************************************
void setProgMashTemp(byte preset, byte mashStep, byte mashTemp) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 26 + mashStep, mashTemp); }
byte getProgMashTemp(byte preset, byte mashStep) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 26 + mashStep); }

//**********************************************************************************
//Mash Times (P:32-37)
//**********************************************************************************
void setProgMashMins(byte preset, byte mashStep, byte mashMins) { 
  //This one is very tricky. Since it is better to avoid memory allocation changes. Here is the trick. 
  //setProgMashMins is not supposed to received a value larger than 119 unless someone change it. But it can receive -1 
  //when the user CANCEL its action of editing the mashing time value. -1 is converted as 255 (in a byte format). That is why
  //the condition is set on 255 instead of -1. 
  if (mashMins != 255) EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 32 + mashStep, mashMins); 
}
byte getProgMashMins(byte preset, byte mashStep) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 32 + mashStep); }

//**********************************************************************************
//Batch Vol (P:38-41)
//**********************************************************************************
unsigned long getProgBatchVol(byte preset) { return PROMreadLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 38); }
void setProgBatchVol (byte preset, unsigned long vol) { PROMwriteLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 38, vol); }

//**********************************************************************************
//Mash Liquor Heat Source (P:42)
//**********************************************************************************
void setProgMLHeatSrc(byte preset, byte smokerPit) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 42, smokerPit); }
byte getProgMLHeatSrc(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 42); }

//**********************************************************************************
//HLT Temp (P:43)
//**********************************************************************************
void setProgHLT(byte preset, byte HLT) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 43, HLT); }
byte getProgHLT(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 43); }

//**********************************************************************************
//Pitch Temp (P:44)
//**********************************************************************************
void setProgPitch(byte preset, byte pitch) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 44, pitch); }
byte getProgPitch(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 44); }

//**********************************************************************************
//Boil Addition Alarms (P:45-46)
//**********************************************************************************
void setProgAdds(byte preset, unsigned int adds) { PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 45, adds); }
unsigned int getProgAdds(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 45); }

//**********************************************************************************
//Grain Weight (P:47-50)
//**********************************************************************************
void setProgGrain(byte preset, unsigned long grain) { PROMwriteLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 47, grain); }
unsigned long getProgGrain(byte preset) { return PROMreadLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 47); }

//**********************************************************************************
//OPEN (P:51-59)
//**********************************************************************************

//**********************************************************************************
//BrewTroller Fingerprint (2046)
//**********************************************************************************

//**********************************************************************************
//EEPROM Version (2047)
//**********************************************************************************


//*****************************************************************************************************************************
// Check/Update/Format EEPROM
//*****************************************************************************************************************************
boolean checkConfig() {
  byte cfgVersion = EEPROM.read(2047);
  byte BTFinger = EEPROM.read(2046);

  //If the BT 1.3 fingerprint is missing force a init of EEPROM
  //FermTroller will bump to a cfgVersion starting at 7
  if (BTFinger != 252 || cfgVersion == 255) return 1;

  //In the future, incremental EEPROM settings will be included here
  switch(cfgVersion) {
    case 0:
      //Supported PID cycle is changing from 1-255 to .1-25.5
      //All current PID cycle settings will be multiplied by 10 to represent tenths (s)
      for (byte smokerPit = PIT_1; smokerPit <= PIT_3; smokerPit++) EEPROM.write(76 + smokerPit * 5, EEPROM.read(76 + smokerPit * 5) * 10);
      //Set cfgVersion = 1
      EEPROM.write(2047, 1);
  }
  return 0;
}

void initEEPROM() {
  //Format EEPROM to 0's
  for (int i=0; i<2048; i++) EEPROM.write(i, 0);

  //Set BT 1.3 Fingerprint (252)
  EEPROM.write(2046, 252);

  //Default Output Settings: p: 3, i: 4, d: 2, cycle: 4s, Hysteresis 0.3C(0.5F)
  for (byte smokerPit = PIT_1; smokerPit <= PIT_3; smokerPit++) {
    setPIDp(smokerPit, 3);
    setPIDi(smokerPit, 4);
    setPIDd(smokerPit, 2);
    setPIDCycle(smokerPit, 4);
    #ifdef USEMETRIC
      setHysteresis(smokerPit, 3);
    #else
      setHysteresis(smokerPit, 5);      
    #endif
  }

  //Default Grain Temp = 60F/16C
  //If F else C
  #ifdef USEMETRIC
    setGrainTemp(16);
  #else
    setGrainTemp(60);
  #endif

  //Set Default Boil temp 212F/100C
  #ifdef USEMETRIC
    setBoilTemp(100);
  #else
    setBoilTemp(212);
  #endif

  setBoilPwr(100);

  //Set all steps idle
  for (byte i = 0; i < NUM_BREW_STEPS; i++) setProgramStep(i, PROGRAM_IDLE);

  //Set cfgVersion = 0
  EEPROM.write(2047, 0);

  // re-load Setup 
  loadSetup();
}

//*****************************************************************************************************************************
// EEPROM Type Read/Write Functions
//*****************************************************************************************************************************
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

