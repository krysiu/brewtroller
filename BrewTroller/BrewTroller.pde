#define BUILD 970
/*  
  Copyright (C) 2009, 2010 Matt Reba, Jeremiah Dillingham

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
Compiled on Arduino-0022 (http://arduino.cc/en/Main/Software)
  With Sanguino Software "Sanguino-0018r2_1_4.zip" (http://code.google.com/p/sanguino/downloads/list)

  Using the following libraries:
    PID  v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
    OneWire 2.0 (http://www.pjrc.com/teensy/arduino_libraries/OneWire.zip)
    Encoder by CodeRage ()
    FastPin and modified LiquidCrystal with FastPin by CodeRage (http://www.brewtroller.com/forum/showthread.php?t=626)
*/



//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************

#include <avr/pgmspace.h>
#include <PID_Beta6.h>
#include <pin.h>
#include <menu.h>
#include <avr/eeprom.h>
#include <ModbusMaster.h>

#include "HWProfile.h"
#include "Config.h"
#include "Global.h"
#include "Outputs.cpp"

#include "UI_LCD.h"
#include "wiring_private.h"
#include <encoder.h>
#include "Com_RGBIO8.h"

void(* softReset) (void) = 0;

#ifdef I2C_SUPPORT
  #include <Wire.h>
#endif

const char BT[] PROGMEM = "BrewTroller";
const char BTVER[] PROGMEM = "3.0";

//**********************************************************************************
// Globals
//**********************************************************************************

//Define 1-Wire Bus Object
#ifdef TS_ONEWIRE
  #if defined TS_ONEWIRE_GPIO
    #include <OneWire.h>
    OneWire ds(TEMP_PIN);
  #elif defined TS_ONEWIRE_I2C
    #include <DS2482.h>
    DS2482 ds(DS2482_ADDR);
  #endif
#endif


btConfig_t Configuration EEMEM;

outputs Outputs;

#ifdef HEARTBEAT
  heartBeat HeartBeat(HEARTBEAT_PIN);
#endif

//Create the appropriate 'LCD' object for the hardware configuration (4-Bit GPIO, I2C)
#if defined UI_LCD_4BIT
  #include <LiquidCrystalFP.h>
  
  #ifndef UI_DISPLAY_SETUP
    LCD4Bit LCD(LCD_RS_PIN, LCD_ENABLE_PIN, LCD_DATA4_PIN, LCD_DATA5_PIN, LCD_DATA6_PIN, LCD_DATA7_PIN);
  #else
    LCD4Bit LCD(LCD_RS_PIN, LCD_ENABLE_PIN, LCD_DATA4_PIN, LCD_DATA5_PIN, LCD_DATA6_PIN, LCD_DATA7_PIN, LCD_BRIGHT_PIN, LCD_CONTRAST_PIN);
  #endif
  
#elif defined UI_LCD_I2C
  LCDI2C LCD(UI_LCD_I2CADDR);
#endif

//Log Strings
const char LOGCMD[] PROGMEM = "CMD";
const char LOGDEBUG[] PROGMEM = "DEBUG";
const char LOGSYS[] PROGMEM = "SYS";
const char LOGCFG[] PROGMEM = "CFG";
const char LOGDATA[] PROGMEM = "DATA";


//**********************************************************************************
// Setup
//**********************************************************************************

void setUnit(boolean unitMetric) {
  tSensor::setUnit(unitMetric);
}

void setup() {
  #ifdef I2C_SUPPORT
    Wire.begin(BT_I2C_ADDR);
    #ifdef TS_ONEWIRE_I2C
      ds.configure(DS2482_CONFIG_APU | DS2482_CONFIG_SPU);
    #endif
  #endif
  


  
  
  
  
  
  //Initialize Brew Steps to 'Idle'
  for(byte brewStep = 0; brewStep < NUM_BREW_STEPS; brewStep++) stepProgram[brewStep] = PROGRAM_IDLE;
  
  //Log initialization (Log.pde)
  comInit();

  //Pin initialization (Outputs.pde)
  pinInit();


  tempInit();
  
  //Check for cfgVersion variable and update EEPROM if necessary (EEPROM.pde)
  checkConfig();

  
  //Load global variable values stored in EEPROM (EEPROM.pde)
  loadSetup();
  
  #ifdef DIGITAL_INPUTS
    //Digital Input Interrupt Setup
    triggerSetup();
  #endif
  
  //PID Initialization (Outputs.pde)
  pidInit();
  
  #ifdef PWM_BY_TIMER
    pwmInit();
  #endif

  //User Interface Initialization (UI.pde)
  //Moving this to last of setup() to allow time for I2CLCD to initialize
  #ifndef NOUI
    uiInit();
  #endif
}


//**********************************************************************************
// Loop
//**********************************************************************************

void loop() {
  //User Interface Processing (UI.pde)
  #ifndef NOUI
    uiCore();
  #endif
  
  //Core BrewTroller process code (BrewCore.pde)
  brewCore();
}

boolean loadConfig() {

}

void initConfig() {
  
}
