#define BUILD 623
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

FermTroller - Open Source Fermentation Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

#include "Config.h"
#include "Enum.h"

void(* softReset) (void) = 0;

//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************
#include <avr/pgmspace.h>
#include <PID_Beta6.h>

//Output Pin Array
//BTBOARD_3 uses only the first four pins and uses MUX for the remaining outputs
byte outputPin[12] = { 0, 1, 3, 6, 7, 10, 12, 13, 14, 24, 18, 16 };

#ifdef USE_MUX
  boolean muxOuts[32] = {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
#else
  boolean muxOuts[32] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
#endif

//Encoder Globals
int encCount;
byte encMin;
byte encMax;
byte enterStatus = 0;

//8-byte Temperature Sensor Address x6 Sensors
byte tSensor[NUM_ZONES + 1][8];
float temp[NUM_ZONES + 1];

//Shared menuOptions Array
char menuopts[45][20];

//Common Buffer
char buf[11];

//Output Globals
double PIDInput[NUM_PID_OUTS], PIDOutput[NUM_PID_OUTS], setpoint[NUM_ZONES];
byte PIDp[NUM_PID_OUTS], PIDi[NUM_PID_OUTS], PIDd[NUM_PID_OUTS], PIDCycle[NUM_PID_OUTS], hysteresis[NUM_ZONES];
unsigned long cycleStart[NUM_PID_OUTS];
boolean heatStatus[NUM_ZONES];
boolean coolStatus[NUM_ZONES];
boolean PIDEnabled[32];
unsigned long coolOnTime[32];

PID pid[NUM_PID_OUTS] = {
  #if NUM_PID_OUTS > 0
    PID(&PIDInput[0], &PIDOutput[0], &setpoint[0], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 1
    PID(&PIDInput[1], &PIDOutput[1], &setpoint[1], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 2
    PID(&PIDInput[2], &PIDOutput[2], &setpoint[2], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 3
    PID(&PIDInput[3], &PIDOutput[3], &setpoint[3], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 4
    PID(&PIDInput[4], &PIDOutput[4], &setpoint[4], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 5
    PID(&PIDInput[5], &PIDOutput[5], &setpoint[5], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 6
    PID(&PIDInput[6], &PIDOutput[6], &setpoint[6], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 7
    PID(&PIDInput[7], &PIDOutput[7], &setpoint[7], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 8
    PID(&PIDInput[8], &PIDOutput[8], &setpoint[8], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 9
    PID(&PIDInput[9], &PIDOutput[9], &setpoint[9], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 10
    PID(&PIDInput[10], &PIDOutput[10], &setpoint[10], 3, 4, 1),
  #endif
  #if NUM_PID_OUTS > 11
    PID(&PIDInput[11], &PIDOutput[11], &setpoint[11], 3, 4, 1),
  #endif 
};

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;

char msg[25][21];
byte msgField = 0;
boolean msgQueued = 0;

byte pwrRecovery;

unsigned long lastLog;
byte logCount;

const char BT[] PROGMEM = "FermTroller";
const char BTVER[] PROGMEM = "v1.0";

//Log Message Classes
const char LOGCMD[] PROGMEM = "CMD";
const char LOGDEBUG[] PROGMEM = "DEBUG";
const char LOGSYS[] PROGMEM = "SYSTEM";
const char LOGGLB[] PROGMEM = "GLOBAL";
const char LOGDATA[] PROGMEM = "DATA";

//Other PROGMEM Repeated Strings
const char PWRLOSSRECOVER[] PROGMEM = "PLR";
const char INIT_EEPROM[] PROGMEM = "Initialize EEPROM";
const char CANCEL[] PROGMEM = "Cancel";
const char EXIT[] PROGMEM = "Exit";
const char SPACE[] PROGMEM = " ";
const char CONTINUE[] PROGMEM = "Continue";
const char ABORT[] PROGMEM = "Abort";
        
#ifdef USEMETRIC
const char VOLUNIT[] PROGMEM = "l";
const char WTUNIT[] PROGMEM = "kg";
const char TUNIT[] PROGMEM = "C";
const char PUNIT[] PROGMEM = "kPa";
#else
const char VOLUNIT[] PROGMEM = "gal";
const char WTUNIT[] PROGMEM = "lb";
const char TUNIT[] PROGMEM = "F";
const char PUNIT[] PROGMEM = "psi";
#endif

//Custom LCD Chars
const byte CHARFIELD[] PROGMEM = {B11111, B00000, B00000, B00000, B00000, B00000, B00000, B00000};
const byte CHARCURSOR[] PROGMEM = {B11111, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
const byte CHARSEL[] PROGMEM = {B10001, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
const byte BMP0[] PROGMEM = {B00000, B00000, B00000, B00000, B00011, B01111, B11111, B11111};
const byte BMP1[] PROGMEM = {B00000, B00000, B00000, B00000, B11100, B11110, B11111, B11111};
const byte BMP2[] PROGMEM = {B00001, B00011, B00111, B01111, B00001, B00011, B01111, B11111};
const byte BMP3[] PROGMEM = {B11111, B11111, B10001, B00011, B01111, B11111, B11111, B11111};
const byte BMP4[] PROGMEM = {B11111, B11111, B11111, B11111, B11111, B11111, B11111, B11111};
const byte BMP5[] PROGMEM = {B01111, B01110, B01100, B00001, B01111, B00111, B00011, B11101};
const byte BMP6[] PROGMEM = {B11111, B00111, B00111, B11111, B11111, B11111, B11110, B11001};
const byte BMP7[] PROGMEM = {B11111, B11111, B11110, B11101, B11011, B00111, B11111, B11111};
  
void setup() {
  logInit();
  pinInit();
  tempInit();

  //User Interface Initialization (UI.pde)
  #ifndef NOUI
    uiInit();
  #endif

  #ifdef BTPD_SUPPORT
    btpdInit();
  #endif

  //Check for cfgVersion variable and format EEPROM if necessary
  checkConfig();
  
  //Load global variable values stored in EEPROM
  loadSetup();

  pidInit();
  
  if (pwrRecovery == 1) {
    logPLR();
    doMon();
  } else {
    splashScreen();
  }
}

void loop() {
  strcpy_P(menuopts[0], PSTR("Start"));
  strcpy_P(menuopts[1], PSTR("System Setup"));
 
  byte lastoption = scrollMenu("FermTroller", 2, 0);
  if (lastoption == 0) doMon();
  else if (lastoption == 1) menuSetup();
}

void splashScreen() {
  clearLCD();
  lcdSetCustChar_P(0, BMP0);
  lcdSetCustChar_P(1, BMP1);
  lcdSetCustChar_P(2, BMP2);
  lcdSetCustChar_P(3, BMP3);
  lcdSetCustChar_P(4, BMP4);
  lcdSetCustChar_P(5, BMP5);
  lcdSetCustChar_P(6, BMP6);
  lcdSetCustChar_P(7, BMP7);
  lcdWriteCustChar(0, 1, 0);
  lcdWriteCustChar(0, 2, 1);
  lcdWriteCustChar(1, 0, 2); 
  lcdWriteCustChar(1, 1, 3); 
  lcdWriteCustChar(1, 2, 4); 
  lcdWriteCustChar(2, 0, 5); 
  lcdWriteCustChar(2, 1, 6); 
  lcdWriteCustChar(2, 2, 7); 
  printLCD_P(0, 4, BT);
  printLCD_P(0, 16, BTVER);
  printLCD_P(1, 10, PSTR("Build "));
  printLCDLPad(1, 16, itoa(BUILD, buf, 10), 4, '0');
  printLCD_P(3, 1, PSTR("www.brewtroller.com"));
  while(!enterStatus) {
    if (chkMsg()) rejectMsg(LOGGLB);
    fermCore();
  }
  enterStatus = 0;
}

