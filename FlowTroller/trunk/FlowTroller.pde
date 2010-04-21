#define BUILD 400 
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
// USER COMPILE OPTIONS
//*****************************************************************************************************************************

//**********************************************************************************
// UNIT (Metric/US)
//**********************************************************************************
// By default BrewTroller will use US Units
// Uncomment USEMETRIC below to use metric instead
//
//#define USEMETRIC
//**********************************************************************************

//**********************************************************************************
// PID Output Power Limit
//**********************************************************************************
// These settings can be used to limit the PID output of the the heat
// output. Enter a percentage (0-100)
//
#define PIDLIMIT 100
//**********************************************************************************

//**********************************************************************************
// LOG INTERVAL
//**********************************************************************************
// LOG_INTERVAL: Specifies how often data is logged via serial in milliseconds. If
// real time display of data is being used a smaller interval is best (1000 ms). A
// larger interval can be used for logging applications to reduce log file size 
// (5000 ms).
// LOG_INITSTATUS: Sets whether logging is enabled on bootup. Log status can be
// toggled using the SET_LOGSTATUS command.

#define LOG_INTERVAL 2000
#define LOG_INITSTATUS 1
//**********************************************************************************


//**********************************************************************************
// UI Support
//**********************************************************************************
// NOUI: Disable built-in user interface 
// UI_NO_SETUP: 'Light UI' removes system setup code to reduce compile size (~8 KB)
//
//#define NOUI
//#define UI_NO_SETUP
//**********************************************************************************

//**********************************************************************************
// DEBUG
//**********************************************************************************
// Enables Serial Out with Additional Debug Data
//
//#define DEBUG
//**********************************************************************************

//**********************************************************************************
//Enable Serial
//**********************************************************************************
// Comment out to disable use of serial

#define USESERIAL
//**********************************************************************************

//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************
#include <avr/pgmspace.h>
#include <PID_Beta6.h>
#include <pin.h>

void(* softReset) (void) = 0;

//**********************************************************************************
//Compile Time Logic
//**********************************************************************************

//Pin and Interrupt Definitions
#define HEAT_PIN 0

//#define ENCB_PIN 1
#define ENCB_PIN 4

#define ENCA_PIN 2


//#define SPI_MOSI_PIN 5
//#define SPI_MISO_PIN 6
//#define SPI_CLK_PIN 7

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
pin spiClk, spiMOSI, spiMISO, heatPin, alarmPin;

float temp;

//Shared buffers
char menuopts[21][20], buf[20];

//Output Globals
double PIDInput, PIDOutput, setpoint;
byte PIDCycle, hysteresis;
unsigned long cycleStart;
boolean heatStatus, PIDEnabled;

PID pid(&PIDInput, &PIDOutput, &setpoint, 3, 4, 1);

//Timer Globals
unsigned long timerValue, lastTime;
boolean timerStatus, alarmStatus;

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
