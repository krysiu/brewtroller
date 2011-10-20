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


#include <avr/eeprom.h>
#include <EEPROM.h>
#include "Config.h"

void loadSetup() {
  //**********************************************************************************
  //PID Enabled (72)
  //PIDCycle (76)
  //Hysteresis (77)
  //PIDp (78-79)
  //PIDi (80-81)
  //PIDd (82-83)
  //**********************************************************************************
  PIDEnabled = EEPROM.read(72);
  PIDCycle = EEPROM.read(76);
  hysteresis = EEPROM.read(77);
  pwmFanPwr = EEPROM.read(74);
  coolThresh = EEPROM.read(75);
  alarmSound = EEPROM.read(73);
  //**********************************************************************************
  //setpoint (299)
  //**********************************************************************************
  setpoint = EEPROM.read(299);
  
  //**********************************************************************************
  //timer (302)
  //**********************************************************************************
  timerValue = EEPROM.read(302) * 6000;

  //**********************************************************************************
  //Timer/Alarm Status (306)
  //**********************************************************************************
  alarmStatus = EEPROM.read(304);
  if (alarmStatus) startAlarm();
  timerStatus = EEPROM.read(306);
  lastTime = millis();


  //**********************************************************************************
  //actStep (313)
  //actProgram (314)
  //**********************************************************************************
  stepInit(EEPROM.read(314), EEPROM.read(313));
}


//*****************************************************************************************************************************
// Individual EEPROM Get/Set Variable Functions
//*****************************************************************************************************************************

//**********************************************************************************
//PID Enabled (72)
//**********************************************************************************
void setPIDEnabled(boolean setting) {
  PIDEnabled = setting;
  EEPROM.write(72, PIDEnabled);
}

//**********************************************************************************
//PID Enabled (73)
//**********************************************************************************
void setAlarmSound(byte value) {
  alarmSound = value;
  EEPROM.write(73, value);
}

//**********************************************************************************
//PIDp (78-79)
//**********************************************************************************
void setPIDp(int value) {
  pid.SetTunings(value / 100.0, pid.GetKi(), pid.GetKd());
  PROMwriteInt(78, value);
}
int getPIDp() { return PROMreadInt(78); }

//**********************************************************************************
//PIDi (80-81)
//**********************************************************************************
void setPIDi(int value) {
  pid.SetTunings(pid.GetKp(), value / 100.0, pid.GetKd());
  PROMwriteInt(80, value);
}
int getPIDi() { return PROMreadInt(80); }

//**********************************************************************************
//PIDd (82-83)
//**********************************************************************************
void setPIDd(int value) {
  pid.SetTunings(pid.GetKp(), pid.GetKi(), value / 100.0);
  PROMwriteInt(82, value);
}
int getPIDd() { return PROMreadInt(82); }

//**********************************************************************************
//PIDCycle (76)
//**********************************************************************************
void setPIDCycle(byte value) {
  PIDCycle = value;
  EEPROM.write(76, value);
}

//**********************************************************************************
//Hysteresis (77)
//**********************************************************************************
void setHysteresis(byte value) {
  hysteresis = value;
  EEPROM.write(77, value);
}

//**********************************************************************************
//PWM Fan Power (74)
//**********************************************************************************
void setPWMFanPower(byte value) {
  pwmFanPwr = value;
  EEPROM.write(74, value);
}

//**********************************************************************************
//Cool Threshhold (75)
//**********************************************************************************
void setCoolThresh(byte value) {
  coolThresh = value;
  EEPROM.write(75, value);
}

//*****************************************************************************************************************************
// Power Loss Recovery Functions
//*****************************************************************************************************************************

//**********************************************************************************
//setpoint (299-300)
//**********************************************************************************
void setSetpoint(int value) { 
  setpoint = value;
  PROMwriteInt(299, value);
}

//**********************************************************************************
//timer (302)
//**********************************************************************************
void setTimerRecovery(unsigned int tenthMins) { 
  timerValue = tenthMins * 6000;
  EEPROM.write(302, tenthMins); 
}


void setAlarmStatus(boolean value) {
  alarmStatus = value;
  EEPROM.write(304, value);
}


//**********************************************************************************
//Timer/Alarm Status (306)
//**********************************************************************************
void setTimerStatus(boolean value) {
  timerStatus = value;
  EEPROM.write(306, value);
}

//**********************************************************************************
//Step (313-314) NUM_FLOW_STEPS (5)
//**********************************************************************************
void setProgramStep(byte flowStep, byte actPgm) {
  actStep = flowStep;
  actProgram = actPgm;
  EEPROM.write(313, actStep); 
  EEPROM.write(314, actProgram); 
}

//**********************************************************************************
//Reserved (328-399)
//**********************************************************************************

//*****************************************************************************************************************************
// Program Load/Save Functions (786- 2045)
//*****************************************************************************************************************************
#define PROGRAM_SIZE 56
#define PROGRAM_START_ADDR 786

//**********************************************************************************
//Program Name (P:0-20)
//**********************************************************************************
void setProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + i, name[i]);
}

void getProgName(byte preset, char name[20]) {
  for (byte i = 0; i < 19; i++) name[i] = EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + i);
  name[19] = '\0';
}

//**********************************************************************************
//Flow Temps (P:21-30) NUM_FLOW_STEPS (5) * 2
//**********************************************************************************
void setProgTemp(byte preset, byte flowStep, int flowTemp) { PROMwriteInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 21 + flowStep * 2, flowTemp); }
int getProgTemp(byte preset, byte flowStep) { return PROMreadInt(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 21 + flowStep * 2); }

//**********************************************************************************
//Flow Times (P:41-45) NUM_FLOW_STEPS (5)
//**********************************************************************************
void setProgMins(byte preset, byte flowStep, byte flowMins) { EEPROM.write(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 41 + flowStep, flowMins); }
byte getProgMins(byte preset, byte flowStep) { return EEPROM.read(PROGRAM_START_ADDR + preset * PROGRAM_SIZE + 41 + flowStep); }

//**********************************************************************************
//OPEN (P:46-55)
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

  //If the fingerprint is missing force a init of EEPROM
  if (BTFinger != 251 || cfgVersion == 255) return 1;

  //In the future, incremental EEPROM settings will be included here
  
  return 0;
}

void initEEPROM() {
  //Format EEPROM to 0's
  for (int i=0; i<2048; i++) EEPROM.write(i, 0);

  //Set BT 1.3 Fingerprint (252)
  EEPROM.write(2046, 251);

  //Default Output Settings: p: 3, i: 4, d: 2, cycle: 4s, Hysteresis 0.3C(0.5F)

    setPIDp(3);
    setPIDi(4);
    setPIDd(2);
    setPIDCycle(4);
    #ifdef USEMETRIC
      setHysteresis(3);
    #else
      setHysteresis(5);      
    #endif

  //Set step/pgm idle
  setProgramStep(PROGRAM_IDLE, PROGRAM_IDLE);

  //Set cfgVersion = 0
  EEPROM.write(2047, 0);
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

