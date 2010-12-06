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
  // TSensors: Pit1 (0-7), Pit2 (8-15), Pit3 (16-23), Food1 (24-31), Food2 (32-39),
  //          Food3 (40-47), AUX1 (48-55), AUX2 (56-63), AUX3 (64-71)
  //**********************************************************************************
  for (byte i = TS_PIT_1; i <= TS_AUX3; i++) PROMreadBytes(i * 8, tSensor[i], 8);
 
  //**********************************************************************************
  // PID Enabled (72); Bit 1 = HLT, Bit 2 = Mash, Bit 3 = Kettle, Bit 4 = Steam
  // PIDp       Pit1 (73), Pit2 (78), Pit3 (83)
  // PIDi       Pit1 (74), Pit2 (79), Pit3 (84)
  // PIDd       Pit1 (75), Pit2 (80), Pit3 (85)
  // PIDCycle   Pit1 (76), Pit2 (81), Pit3 (86)
  // Hysteresis Pit1 (77), Pit2 (82), Pit3 (87)
  //**********************************************************************************
  byte pidOptions = EEPROM.read(72);
  for (byte i = PIT_1; i <= PIT_3; i++) {
    PIDEnabled[i] = bitRead(pidOptions, i);
    PIDCycle[i] = EEPROM.read(76 + i * 5);
    hysteresis[i] = EEPROM.read(77 + i * 5);
  }   
 
  //**********************************************************************************
  // ***OPEN*** (88-295)
  //**********************************************************************************
   
  //**********************************************************************************
  // Setpoints (296-301)
  //**********************************************************************************
  for (byte i=PIT_1; i<=FOOD_3; i++) { 
    setpoint[i] = EEPROM.read(296 + i) * 100;
    eventHandler(EVENT_SETPOINT, i);
  }
  
  //**********************************************************************************
  // Timers (302-307)
  //**********************************************************************************
  for (byte i=TIMER_S1; i<=TIMER_S3; i++) { timerValue[i] = PROMreadInt(302 + i * 2) * 60000; }

  //**********************************************************************************
  // Timer/Alarm Status (308)
  //**********************************************************************************
  byte timerOptions = EEPROM.read(308);
  for (byte i = TIMER_S1; i <= TIMER_S3; i++) {
    timerStatus[i] = bitRead(timerOptions, i);
    lastTime[i] = millis();
  }
  alarmStatus = bitRead(timerOptions, 2);
  alarmPin.set(alarmStatus);
  
  #ifdef DEBUG_TIMERALARM
    logStart_P(LOGDEBUG);
    logField("TimerAlarmStatus");
    logFieldI(bitRead(timerOptions, 0));
    logFieldI(bitRead(timerOptions, 1));
    logFieldI(bitRead(timerOptions, 2));
    logEnd();
  #endif  
 
  //**********************************************************************************
  // Steps (313-327) NUM_BREW_STEPS (15)
  //**********************************************************************************
  //for(byte brewStep = 0; brewStep < NUM_BREW_STEPS; brewStep++) stepInit(EEPROM.read(313 + brewStep), brewStep);

  //**********************************************************************************
  // Valve Profiles (401-456)
  //**********************************************************************************
  //for (byte profile = VLV_FILLHLT; profile <= VLV_HLTHEAT; profile++) vlvConfig[profile] = PROMreadLong(401 + profile * 4);

}

//*****************************************************************************************************************************
// Individual EEPROM Get/Set Variable Functions
//*****************************************************************************************************************************

//**********************************************************************************
// TSensors: HLT (0-7), MASH (8-15), KETTLE (16-23), H2OIN (24-31), H2OOUT (32-39), 
//          BEEROUT (40-47), AUX1 (48-55), AUX2 (56-63), AUX3 (64-71)
//**********************************************************************************
void setTSAddr(byte sensor, byte addr[8]) {
  for (byte i = 0; i<8; i++) tSensor[sensor][i] = addr[i];
  PROMwriteBytes(sensor * 8, addr, 8);
}

//**********************************************************************************
//PID Enabled (72); Bit 1 = Pit1, Bit 2 = Pit2, Bit 3 = Pit3
//**********************************************************************************
void setPIDEnabled(byte smokerPit, boolean setting) {
  PIDEnabled[smokerPit] = setting;
  byte options = EEPROM.read(72);
  bitWrite(options, smokerPit, setting);
  EEPROM.write(72, options);
}

//**********************************************************************************
//PIDp Pit1 (73), Pit2 (78), Pit3 (83)
//**********************************************************************************
void setPIDp(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(value, pid[smokerPit].GetI_Param(), pid[smokerPit].GetD_Param());
  EEPROM.write(73 + smokerPit * 5, value);
}
byte getPIDp(byte smokerPit) { return EEPROM.read(73 + smokerPit * 5); }

//**********************************************************************************
//PIDi Pit1 (74), Pit2 (79), Pit3 (84)
//**********************************************************************************
void setPIDi(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(pid[smokerPit].GetP_Param(), value, pid[smokerPit].GetD_Param());
  EEPROM.write(74 + smokerPit * 5, value);
}
byte getPIDi(byte smokerPit) { return EEPROM.read(74 + smokerPit * 5); }

//**********************************************************************************
//PIDd Pit1 (75), Pit2 (80), Pit3 (85)
//**********************************************************************************
void setPIDd(byte smokerPit, byte value) {
  pid[smokerPit].SetTunings(pid[smokerPit].GetP_Param(), pid[smokerPit].GetI_Param(), value);
  EEPROM.write(75 + smokerPit * 5, value);
}
byte getPIDd(byte smokerPit) { return EEPROM.read(75 + smokerPit * 5); }

//**********************************************************************************
//PIDCycle Pit1 (76), Pit2 (81), Pit3 (86)
//**********************************************************************************
void setPIDCycle(byte smokerPit, byte value) {
  PIDCycle[smokerPit] = value;
  EEPROM.write(76 + smokerPit * 5, value);
}

//**********************************************************************************
//Hysteresis Pit1 (77), Pit2 (82), Pit3 (87)
//**********************************************************************************
void setHysteresis(byte smokerPit, byte value) {
  hysteresis[smokerPit] = value;
  EEPROM.write(77 + smokerPit * 5, value);
}

//**********************************************************************************
// ***OPEN*** (88-295)
//**********************************************************************************

//*****************************************************************************************************************************
// Power Loss Recovery Functions
//*****************************************************************************************************************************

//**********************************************************************************
//setpoints (296-301)
//**********************************************************************************
void setSetpoint(byte object, byte value) { 
  setpoint[object] = value * 100;
  EEPROM.write(296 + object, value);
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
//unsigned int getBoilAddsTrig() { return PROMreadInt(309); }
//void setBoilAddsTrig(unsigned int adds) { PROMwriteInt(309, adds); }

//**********************************************************************************
// ***OPEN*** (311-312)
//**********************************************************************************

//**********************************************************************************
//Step (313-327) NUM_BREW_STEPS (15)
//**********************************************************************************
//void setProgramStep(byte brewStep, byte actPgm) {
//  stepProgram[brewStep] = actPgm;
//  EEPROM.write(313 + brewStep, actPgm); 
//}

//**********************************************************************************
//Reserved (328-397)
//**********************************************************************************

//**********************************************************************************
//Delay Start (Mins) (398-399)
//**********************************************************************************
//unsigned int getDelayMins() { return PROMreadInt(398); }
//void setDelayMins(unsigned int mins) { 
//  if(mins != -1) PROMwriteInt(398, mins); 
//}

//**********************************************************************************
//Grain Temp (400)
//**********************************************************************************
//void setGrainTemp(byte grainTemp) { EEPROM.write(400, grainTemp); }
//byte getGrainTemp() { return EEPROM.read(400); }

//*****************************************************************************************************************************
// Valve Profile Configuration (401-456; 457-785 Reserved)
//*****************************************************************************************************************************
//void setValveCfg(byte profile, unsigned long value) {
//  vlvConfig[profile] = value;
//  PROMwriteLong(401 + profile * 4, value);
//}

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
//OPEN (P:21)
//**********************************************************************************

////**********************************************************************************
////Boil Mins (P:22-23)
////**********************************************************************************
////void setProgBoil(byte preset, int boilMins) { 
////  if (boilMins != -1) PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 22, boilMins); 
////}
////unsigned int getProgBoil(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 22); }
//
////**********************************************************************************
////Mash Ratio (P:24-25)
////**********************************************************************************
////void setProgRatio(byte preset, unsigned int ratio) { PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 24, ratio); }
////unsigned int getProgRatio(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 24); }
//
//**********************************************************************************
//Step Temps (P:26-31)
//**********************************************************************************
void setProgStepTemp(byte preset, byte pitStep, byte pitTemp) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 26 + pitStep, pitTemp); }
byte getProgStepTemp(byte preset, byte pitStep) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 26 + pitStep); }

//**********************************************************************************
//Step Times (P:32-37)
//**********************************************************************************
void setProgStepMins(byte preset, byte pitStep, byte pitMins) { 
  //This one is very tricky. Since it is better to avoid memory allocation changes. Here is the trick. 
  //setProgMashMins is not supposed to received a value larger than 119 unless someone change it. But it can receive -1 
  //when the user CANCEL its action of editing the mashing time value. -1 is converted as 255 (in a byte format). That is why
  //the condition is set on 255 instead of -1. 
  if (pitMins != 255) EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 32 + pitStep, pitMins); 
}
byte getProgStepMins(byte preset, byte pitStep) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 32 + pitStep); }

////**********************************************************************************
////Batch Vol (P:38-41)
////**********************************************************************************
////unsigned long getProgBatchVol(byte preset) { return PROMreadLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 38); }
////void setProgBatchVol (byte preset, unsigned long vol) { PROMwriteLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 38, vol); }
//
////**********************************************************************************
////Mash Liquor Heat Source (P:42)
////**********************************************************************************
////void setProgMLHeatSrc(byte preset, byte smokerPit) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 42, smokerPit); }
////byte getProgMLHeatSrc(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 42); }
//

//**********************************************************************************
//Food Temp (P:43)
//**********************************************************************************
void setProgFoodTemp(byte preset, byte foodTemp) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 43, foodTemp); }
byte getProgFoodTemp(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 43); }

//**********************************************************************************
//Pit Temp (P:44)
//**********************************************************************************
void setProgPitTemp(byte preset, byte pitTemp) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 44, pitTemp); }
byte getProgPitTemp(byte preset) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 44); }

////**********************************************************************************
////Boil Addition Alarms (P:45-46)
////**********************************************************************************
////void setProgAdds(byte preset, unsigned int adds) { PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 45, adds); }
////unsigned int getProgAdds(byte preset) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 45); }
//
////**********************************************************************************
////Grain Weight (P:47-50)
////**********************************************************************************
////void setProgGrain(byte preset, unsigned long grain) { PROMwriteLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 47, grain); }
////unsigned long getProgGrain(byte preset) { return PROMreadLong(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 47); }
//
////**********************************************************************************
////OPEN (P:51-59)
////**********************************************************************************
//
////**********************************************************************************
////BrewTroller Fingerprint (2046)
////**********************************************************************************
//
////**********************************************************************************
////EEPROM Version (2047)
////**********************************************************************************
//
//

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

