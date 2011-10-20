#define BUILD 803
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

/*
Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
  With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)

  Using the following libraries:
    PID  v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
    OneWire (http://www.arduino.cc/playground/Learning/OneWire)
    Encoder by CodeRage ()
    FastPin and modified LiquidCrystal with FastPin by CodeRage (http://www.brewtroller.com/forum/showthread.php?t=626)
*/

//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************
#include "Config.h"
#include <avr/pgmspace.h>
#include <PID_v1.h>
#include <pin.h>
#include <Tone.h>

void(* softReset) (void) = 0;

//**********************************************************************************
//Compile Time Logic
//**********************************************************************************

//Pin and Interrupt Definitions
#define HEAT_PIN 0
#define PWMFAN_PIN 14

#define ENCB_PIN 1

#define ENCA_PIN 2


#define SPI_MISO_PIN 6    // MISO
#define SPI_CLK_PIN 7   // Serial Clock

#define TC_0 4  // CS Pin of MAX6607

#define ENTER_PIN 11
#define ALARM_PIN 15

#define ENTER_INT 1
#define ENCA_INT 2

//Steps
#define NUM_FLOW_STEPS 5

//Events
#define EVENT_STEPINIT 0
#define EVENT_STEPEXIT 1

//Heat Output, alarm Pins
pin heatPin;

Tone alarmTone;

float temp;
unsigned long tcUpdate = 0;

//Shared buffers
char menuopts[21][20], buf[20];

//Output Globals
double PIDInput, PIDOutput, setpoint;
byte PIDCycle, hysteresis, pwmFanPwr, coolThresh;
unsigned long cycleStart;
boolean heatStatus, coolStatus, PIDEnabled;

PID pid(&PIDInput, &PIDOutput, &setpoint, 3, 4, 1, DIRECT);

//Timer Globals
unsigned long timerValue, lastTime;
boolean timerStatus, alarmStatus;
byte alarmSound;

//Log Globals
boolean logData = LOG_INITSTATUS;
boolean msgQueued;
unsigned long lastLog;
byte logCount, msgField;
char msg[25][21];

//Brew Step Logic Globals
//Active program for each brew step
#define PROGRAM_IDLE 255
byte actProgram = PROGRAM_IDLE;
byte actStep = PROGRAM_IDLE;
boolean preheated;

const char BT[] PROGMEM = "FlowTroller";
const char BTVER[] PROGMEM = "1.0";

//Log Strings
const char LOGCMD[] PROGMEM = "CMD";
const char LOGDEBUG[] PROGMEM = "DEBUG";
const char LOGSYS[] PROGMEM = "SYSTEM";
const char LOGGLB[] PROGMEM = "GLOBAL";
const char LOGDATA[] PROGMEM = "DATA";

void setup() {
  //Log initialization (Log.pde)
  logInit();

  //Pin initialization (Outputs.pde)
  pinInit();
  alarmTone.begin(ALARM_PIN, 1);  //Force Timer1

  //Pin initialization for temp chip (Temp.pde)
  tempInit();
  
  //User Interface Initialization (UI.pde)
  #ifndef NOUI
    uiInit();
  #endif

  //Check for cfgVersion variable and update EEPROM if necessary (EEPROM.pde)
  checkConfig();

  //Load global variable values stored in EEPROM (EEPROM.pde)
  loadSetup();

  //PID Initialization (Outputs.pde)
  pidInit();
}

void loop() {
  //User Interface Processing (UI.pde)
  #ifndef NOUI
    uiCore();
  #endif
  
  //Core BrewTroller process code (BrewCore.pde)
  flowCore();
}
