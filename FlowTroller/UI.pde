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

#ifndef NOUI
#include "Config.h"
#include <encoder.h>

//*****************************************************************************************************************************
// UI COMPILE OPTIONS
//*****************************************************************************************************************************

//**********************************************************************************
// ENCODER TYPE
//**********************************************************************************
// You must uncomment one and only one of the following ENCODER_ definitions
// Use ENCODER_ALPS for ALPS and Panasonic Encoders
// Use ENCODER_CUI for older CUI encoders
//
#define ENCODER_TYPE ALPS
//#define ENCODER_TYPE CUI
//**********************************************************************************


//*****************************************************************************************************************************
// Begin UI Code
//*****************************************************************************************************************************


//**********************************************************************************
// UI Strings
//**********************************************************************************
const char CANCEL[] PROGMEM = "Cancel";
const char EXIT[] PROGMEM = "Exit";
const char SPACE[] PROGMEM = " ";
const char INIT_EEPROM[] PROGMEM = "Initialize EEPROM";
const char SKIPSTEP[] PROGMEM = "Skip Step";
const char CONTINUE[] PROGMEM = "Continue";
const char ABORT[] PROGMEM = "Abort";

#ifndef UI_NO_SETUP
const char PIDCYCLE[] PROGMEM = "PID Cycle";
const char PIDGAIN[] PROGMEM = "PID Gain";
const char HYSTERESIS[] PROGMEM = "Hysteresis";
#endif

const char SEC[] PROGMEM = "s";
#ifdef USEMETRIC
const char TUNIT[] PROGMEM = "C";
#else
const char TUNIT[] PROGMEM = "F";
#endif

//**********************************************************************************
// UI Custom LCD Chars
//**********************************************************************************
const byte CHARFIELD[] PROGMEM = {B11111, B00000, B00000, B00000, B00000, B00000, B00000, B00000};
const byte CHARCURSOR[] PROGMEM = {B11111, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
const byte CHARSEL[] PROGMEM = {B10001, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
const byte BMP0[] PROGMEM = {B00000, B00000, B00000, B00000, B00011, B01111, B11111, B11111};
const byte BMP1[] PROGMEM = {B00000, B00000, B00000, B00000, B11100, B11110, B11111, B11111};
const byte BMP2[] PROGMEM = {B00001, B00011, B00111, B01111, B00001, B00011, B01111, B11111};
const byte BMP3[] PROGMEM = {B11111, B11111, B10001, B00011, B01111, B11111, B11111, B11111};
const byte BMP4[] PROGMEM = {B01111, B01110, B01100, B00001, B01111, B00111, B00011, B11101};
const byte BMP5[] PROGMEM = {B11111, B00111, B00111, B11111, B11111, B11111, B11110, B11001};
const byte BMP6[] PROGMEM = {B11111, B11111, B11110, B11101, B11011, B00111, B11111, B11111};

//**********************************************************************************
// UI Globals
//**********************************************************************************
byte timerLastPrint;

//**********************************************************************************
// uiInit:  One time intialization of all UI logic
//**********************************************************************************
void uiInit() {
  initLCD();
  Encoder.begin(ENCODER_TYPE, false, ENTER_PIN, ENCA_PIN, ENCB_PIN, ENTER_INT, ENCA_INT);

  //Check to see if EEPROM Initialization is needed
  if (checkConfig()) {
    clearLCD();
    printLCD_P(0, 0, PSTR("Missing Config"));
    strcpy_P(menuopts[0], INIT_EEPROM);
    strcpy_P(menuopts[1], CANCEL);
    if (getChoice(2, 3) == 0) {
      clearLCD();
      printLCD_P(1, 0, INIT_EEPROM);
      printLCD_P(2, 3, PSTR("Please Wait..."));
      initEEPROM();
      //Apply any EEPROM updates
      checkConfig();
    }
    clearLCD();
    //splashScreen();
  }

  screenInit();
}

void uiEvent(byte eventID, byte eventParam) {
  if (eventID == EVENT_STEPINIT) {
    screenInit();
  }
  else if (eventID == EVENT_STEPEXIT) {
    screenInit();
  }
}

//**********************************************************************************
// screenCore: Called in main loop to handle all UI functions
//**********************************************************************************
void uiCore() {
  screenEnter();
  screenRefresh();
}

//**********************************************************************************
// screenInit: Initialize active screen
//**********************************************************************************
void splashScreen() {
  clearLCD();
  
  lcdSetCustChar_P(0, BMP0);
  lcdSetCustChar_P(1, BMP1);
  lcdSetCustChar_P(2, BMP2);
  lcdSetCustChar_P(3, BMP3);
  lcdSetCustChar_P(4, BMP4);
  lcdSetCustChar_P(5, BMP5);
  lcdSetCustChar_P(6, BMP6);
  lcdWriteCustChar(0, 1, 0);
  lcdWriteCustChar(0, 2, 1);
  lcdWriteCustChar(1, 0, 2); 
  lcdWriteCustChar(1, 1, 3); 
  lcdWriteCustChar(1, 2, 255); 
  lcdWriteCustChar(2, 0, 4); 
  lcdWriteCustChar(2, 1, 5); 
  lcdWriteCustChar(2, 2, 6); 
  printLCD_P(3, 0, BT);
  printLCD_P(3, 12, BTVER);
  printLCDLPad(3, 16, itoa(BUILD, buf, 10), 4, '0');
  while (!Encoder.ok()) flowCore();
}

void screenInit() {
  clearLCD();
  if (actProgram != PROGRAM_IDLE) {
    getProgName(actProgram, buf);
    printLCD(0, 0, buf);
      if (actStep != PROGRAM_IDLE) {
        printLCD_P(1, 2, PSTR("Step: "));
        printLCD(1, 8, itoa(actStep + 1, buf, 10));
      }
  } else printLCD_P(0, 0, PSTR("Manual Control"));
  printLCD_P(2, 0, PSTR("Setpoint:"));
  printLCD_P(3, 1, PSTR("Current:"));
  
  printLCD_P(2, 12, TUNIT);
  printLCD_P(3, 12, TUNIT);
}

//**********************************************************************************
// screenRefresh:  Refresh active screen
//**********************************************************************************
void screenRefresh(){
  printTimer(1, 14);
  printLCDLPad(2, 9, itoa(setpoint, buf, 10), 3, ' ');
  printLCDLPad(3, 9, itoa(temp, buf, 10), 3, ' ');
}


//**********************************************************************************
// screenEnter:  Check enterStatus and handle based on screenLock and activeScreen
//**********************************************************************************
void screenEnter() {
  if (Encoder.ok()) {
    if (alarmStatus) setAlarm(0);
    else {
      strcpy_P(menuopts[0], CANCEL);
      strcpy_P(menuopts[1], PSTR("Edit Program"));
      strcpy_P(menuopts[2], PSTR("Start Program"));
      strcpy_P(menuopts[3], PSTR("Setpoint: "));
      strcat(menuopts[3], itoa(setpoint, buf, 10));
      strcat_P(menuopts[3], TUNIT);
      strcpy_P(menuopts[4], PSTR("Set Timer"));
      if (timerStatus) strcpy_P(menuopts[5], PSTR("Pause Timer"));
      else strcpy_P(menuopts[5], PSTR("Start Timer"));
      strcpy_P(menuopts[6], SKIPSTEP);
      strcpy_P(menuopts[7], PSTR("Reset All"));
      strcpy_P(menuopts[8], PSTR("System Setup"));
      #ifdef UI_NO_SETUP
        byte lastOption = scrollMenu("Main Menu", 8, 0);
      #else
        byte lastOption = scrollMenu("Main Menu", 9, 0);
      #endif

      if (lastOption == 1) editProgramMenu();
      else if (lastOption == 2) startProgramMenu();
      else if (lastOption == 3) setSetpoint(getValue(PSTR("Setpoint"), setpoint, 3, 0, 999, TUNIT));
      else if (lastOption == 4) {
        setTimer(getTimerValue(PSTR("Set Timer"), timerValue / 60000));
        //Force Preheated
        preheated = 1;
      }
      else if (lastOption == 5) {
        pauseTimer();
        //Force Preheated
        preheated = 1;
      }
      else if (lastOption == 6) {
        if(actProgram != PROGRAM_IDLE) {
          if (stepAdvance(actStep)) {
            //Failed to advance step
            stepAdvanceFailDialog();
          }
        }
      }
      else if (lastOption == 7) {
        //Reset All
        if (confirmAbort()) {
          setProgramStep(PROGRAM_IDLE, PROGRAM_IDLE);
          resetOutputs();
          clearTimer();
        }
      }
#ifndef UI_NO_SETUP        
      else if (lastOption == 8) menuSetup();
#endif
      screenInit();
    }
  }
}

void printTimer(byte iRow, byte iCol) {
  if (timerValue > 0 && !timerStatus) printLCD(iRow, iCol, "PAUSED");
  else if (alarmStatus || timerStatus) {
    byte timerHours = timerValue / 3600000;
    byte timerMins = (timerValue - timerHours * 3600000) / 60000;
    byte timerSecs = (timerValue - timerHours * 3600000 - timerMins * 60000) / 1000;

    //Update LCD once per second
    if (timerLastPrint != timerSecs) {
      timerLastPrint = timerSecs;
      printLCDRPad(iRow, iCol, "", 6, ' ');
      printLCD_P(iRow, iCol+2, PSTR(":"));
      if (timerHours > 0) {
        printLCDLPad(iRow, iCol, itoa(timerHours, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol + 3, itoa(timerMins, buf, 10), 2, '0');
      } else {
        printLCDLPad(iRow, iCol, itoa(timerMins, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol+ 3, itoa(timerSecs, buf, 10), 2, '0');
      }
      if (alarmStatus) printLCD(iRow, iCol + 5, "!");
    }
  } else printLCDRPad(iRow, iCol, "", 6, ' ');
}

void stepAdvanceFailDialog() {
  clearLCD();
  printLCD_P(0, 0, PSTR("Failed to advance"));
  printLCD_P(1, 0, PSTR("program."));
  printLCD(3, 4, ">");
  printLCD_P(3, 6, CONTINUE);
  printLCD(3, 15, "<");
  while (!Encoder.ok()) flowCore();
}

void editProgramMenu() {
  for (byte i = 0; i < 20; i++) getProgName(i, menuopts[i]);
  byte profile = scrollMenu("Edit Program", 20, profile);
  if (profile < 20) {
    getString(PSTR("Program Name:"), menuopts[profile], 19);
    setProgName(profile, menuopts[profile]);
    editProgram(profile);
  }
}

void startProgramMenu() {
  for (byte i = 0; i < 20; i++) getProgName(i, menuopts[i]);
  byte profile = scrollMenu("Start Program", 20, 0);
  if (profile < 20) {
    if (zoneIsActive()) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Cannot start program"));
      printLCD_P(1, 0, PSTR("while program is"));
      printLCD_P(2, 0, PSTR("active."));
      printLCD(3, 4, ">");
      printLCD_P(3, 6, CONTINUE);
      printLCD(3, 15, "<");
      while (!Encoder.ok()) flowCore();
    } else {
      if (stepInit(profile, 0)) {
        clearLCD();
        printLCD_P(1, 0, PSTR("Program start failed"));
        printLCD(3, 4, ">");
        printLCD_P(3, 6, CONTINUE);
        printLCD(3, 15, "<");
        while (!Encoder.ok()) flowCore();
      }
    }
  }
}

void editProgram(byte pgm) {
  byte lastOption = 0;
  while (1) {
    for (byte flowStep = 0; flowStep < NUM_FLOW_STEPS; flowStep++) {
      strcpy_P(menuopts[flowStep * 2], PSTR("Step "));
      strcat(menuopts[flowStep * 2], itoa(flowStep + 1, buf, 10));
      strcat(menuopts[flowStep * 2], ": ");
      strcat(menuopts[flowStep * 2], itoa(getProgMins(pgm, flowStep), buf, 10));
      strcat(menuopts[flowStep * 2], " min");
      
      strcpy_P(menuopts[flowStep * 2 + 1], PSTR("Step "));
      strcat(menuopts[flowStep * 2 + 1], itoa(flowStep + 1, buf, 10));
      strcat(menuopts[flowStep * 2 + 1], ": ");
      strcat(menuopts[flowStep * 2 + 1], itoa(getProgTemp(pgm, flowStep), buf, 10));
      strcat_P(menuopts[flowStep * 2 + 1], TUNIT);
    }
    strcpy_P(menuopts[NUM_FLOW_STEPS * 2], PSTR("Exit"));
    lastOption = scrollMenu("Edit Program", NUM_FLOW_STEPS * 2 + 1, lastOption);
    
    if (lastOption >= NUM_FLOW_STEPS * 2) return;
    else if (lastOption / 2.0 == lastOption / 2) setProgMins(pgm, lastOption / 2, getTimerValue(PSTR("Step Mins"), getProgMins(pgm, lastOption / 2)));
    else setProgTemp(pgm, lastOption / 2, getValue(PSTR("Step Temp"), getProgTemp(pgm, lastOption / 2), 3, 0, 999, TUNIT));
  }
}


//*****************************************************************************************************************************
//Generic Menu Functions
//*****************************************************************************************************************************
byte scrollMenu(char sTitle[], byte numOpts, byte defOption) {
  //Uses Global menuopts[][20]
  Encoder.setMin(0);
  Encoder.setMax(numOpts - 1);
  Encoder.setCount(defOption);
  byte topItem = numOpts;
  boolean redraw = 1;
  
  while(1) {
    int encValue;
    if (redraw) {
            redraw = 0;
            encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      if (encValue < topItem) {
        clearLCD();
        if (sTitle != NULL) printLCD(0, 0, sTitle);
        if (numOpts <= 3) topItem = 0;
        else topItem = encValue;
        drawItems(numOpts, topItem);
      } else if (encValue > topItem + 2) {
        clearLCD();
        if (sTitle != NULL) printLCD(0, 0, sTitle);
        topItem = encValue - 2;
        drawItems(numOpts, topItem);
      }
      for (byte i = 1; i <= 3; i++) if (i == encValue - topItem + 1) printLCD(i, 0, ">"); else printLCD(i, 0, " ");
    }
    
    //If Enter
    if (Encoder.ok()) {
      return Encoder.getCount();
    } else if (Encoder.cancel()) {
      return numOpts;
    }
    flowCore();
  }
}

void drawItems(byte numOpts, byte topItem) {
  //Uses Global menuopts[][20]
  byte maxOpt = topItem + 2;
  if (maxOpt > numOpts - 1) maxOpt = numOpts - 1;
  for (byte i = topItem; i <= maxOpt; i++) printLCD(i-topItem+1, 1, menuopts[i]);
}

byte getChoice(byte numChoices, byte iRow) {
  //Uses Global menuopts[][20]
  //Force 18 Char Limit
  for (byte i = 0; i < numChoices; i++) menuopts[i][18] = '\0';
  printLCD_P(iRow, 0, PSTR(">"));
  printLCD_P(iRow, 19, PSTR("<"));
  Encoder.setMin(0);
  Encoder.setMax(numChoices - 1);
  Encoder.setCount(0);
  boolean redraw = 1;
  
  while(1) {
    int encValue;
    if (redraw) {
      redraw = 0;
      encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      printLCDCenter(iRow, 1, menuopts[encValue], 18);
    }
    
    //If Enter
    if (Encoder.ok()) {
      printLCD_P(iRow, 0, SPACE);
      printLCD_P(iRow, 19, SPACE);
      return Encoder.getCount();
    } else if (Encoder.cancel()) {
      return numChoices;
    }
    flowCore();
  }
}

boolean confirmAbort() {
  clearLCD();
  printLCD_P(0, 0, PSTR("Abort operation and"));
  printLCD_P(1, 0, PSTR("reset setpoints,"));
  printLCD_P(2, 0, PSTR("timers and outputs?"));
  strcpy_P(menuopts[0], CANCEL);
  strcpy_P(menuopts[1], PSTR("Reset"));
  if(getChoice(2, 3) == 1) return 1; else return 0;
}

boolean confirmDel() {
  clearLCD();
  printLCD_P(1, 0, PSTR("Delete Item?"));
  
  strcpy_P(menuopts[0], CANCEL);
  strcpy_P(menuopts[1], PSTR("Delete"));
  if(getChoice(2, 3) == 1) return 1; else return 0;
}

unsigned long getValue(const char *sTitle, unsigned long defValue, byte digits, byte precision, unsigned long maxValue, const char *dispUnit) {
  unsigned long retValue = defValue;
  byte cursorPos = 0; 
  boolean cursorState = 0; //0 = Unselected, 1 = Selected

  //Workaround for odd memory issue
  //availableMemory();

  Encoder.setMin(0);
  Encoder.setMax(digits);
  Encoder.setCount(0);

  lcdSetCustChar_P(0, CHARFIELD);
  lcdSetCustChar_P(1, CHARCURSOR);
  lcdSetCustChar_P(2, CHARSEL);
   
  clearLCD();
  printLCD_P(0, 0, sTitle);
  printLCD_P(1, (20 - digits + 1) / 2 + digits + 1, dispUnit);
  printLCD(3, 9, "OK");
  unsigned long whole, frac;
  boolean redraw = 1;
  
  while(1) {
    int encValue;
    if (redraw) {
      redraw = 0;
      encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      if (cursorState) {
        unsigned long factor = 1;
        for (byte i = 0; i < digits - cursorPos - 1; i++) factor *= 10;
        //Subtract old digit value
        retValue -= (int (retValue / factor) - int (retValue / (factor * 10)) * 10) * factor;
        //Add new value
        retValue += encValue * factor;
        retValue = min(retValue, maxValue);
      } else {
        cursorPos = encValue;
        for (byte i = (20 - digits + 1) / 2 - 1; i < (20 - digits + 1) / 2 - 1 + digits - precision; i++) lcdWriteCustChar(2, i, 0);
        if (precision) for (byte i = (20 - digits + 1) / 2 + digits - precision; i < (20 - digits + 1) / 2 + digits; i++) lcdWriteCustChar(2, i, 0);
        printLCD(3, 8, " ");
        printLCD(3, 11, " ");
        if (cursorPos == digits) {
          printLCD(3, 8, ">");
          printLCD(3, 11, "<");
        } else {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 1);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 1);
        }
      }
      whole = retValue / pow(10, precision);
      frac = retValue - (whole * pow(10, precision)) ;
      printLCDLPad(1, (20 - digits + 1) / 2 - 1, ltoa(whole, buf, 10), digits - precision, ' ');
      if (precision) {
        printLCD(1, (20 - digits + 1) / 2 + digits - precision - 1, ".");
        printLCDLPad(1, (20 - digits + 1) / 2 + digits - precision, ltoa(frac, buf, 10), precision, '0');
      }
    }
    
    if (Encoder.ok()) {
      if (cursorPos == digits) break;
      else {
        cursorState = cursorState ^ 1;
        if (cursorState) {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 2);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 2);
          Encoder.setMin(0);
          Encoder.setMax(9);

          if (cursorPos < digits - precision) {
            ltoa(whole, buf, 10);
            if (cursorPos < digits - precision - strlen(buf)) Encoder.setCount(0); else  Encoder.setCount(buf[cursorPos - (digits - precision - strlen(buf))] - '0');
          } else {
            ltoa(frac, buf, 10);
            if (cursorPos < digits - strlen(buf)) Encoder.setCount(0); else  Encoder.setCount(buf[cursorPos - (digits - strlen(buf))] - '0');
          }
        } else {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 1);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 1);
          Encoder.setMin(0);
          Encoder.setMax(digits);
          Encoder.setCount(cursorPos);
        }
      }
    } else if (Encoder.cancel()) {
      retValue = defValue;
      break;
    }
    flowCore();
  }
  return retValue;
}

unsigned int getTimerValue(const char *sTitle, unsigned int defMins) {
  byte hours = defMins / 60;
  byte mins = defMins - hours * 60;
  byte cursorPos = 0; //0 = Hours, 1 = Mins, 2 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  Encoder.setMin(0);
  Encoder.setMax(2);
  Encoder.setCount(0);
  
  clearLCD();
  printLCD_P(0,0,sTitle);
  printLCD(1, 9, ":");
  printLCD(1, 13, "(hh:mm)");
  printLCD(3, 8, "OK");
  boolean redraw = 1;
  while(1) {
    int encValue;
    if (redraw) {
      redraw = 0;
      encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      if (cursorState) {
        if (cursorPos) mins = encValue; else hours = encValue;
      } else {
        cursorPos = encValue;
        if (cursorPos == 0) {
            printLCD(1, 6, ">");
            printLCD(1, 12, " ");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
        } else if (cursorPos == 1) {
            printLCD(1, 6, " ");
            printLCD(1, 12, "<");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
        } else if (cursorPos == 2) {
          printLCD(1, 6, " ");
            printLCD(1, 12, " ");
            printLCD(3, 7, ">");
            printLCD(3, 10, "<");
        }
      }
      printLCDLPad(1, 7, itoa(hours, buf, 10), 2, '0');
      printLCDLPad(1, 10, itoa(mins, buf, 10), 2, '0');
    }
    
    if (Encoder.ok()) {
      if (cursorPos == 2) return hours * 60 + mins;
      cursorState = cursorState ^ 1;
      if (cursorState) {
        Encoder.setMin(0);
        Encoder.setMax(99);
        if (cursorPos) Encoder.setCount(mins); else Encoder.setCount(hours);
      } else {
        Encoder.setMin(0);
        Encoder.setMax(2);
        Encoder.setCount(cursorPos);
      }
    } else if (Encoder.cancel()) return NULL;
    flowCore();
  }
}

void getString(const char *sTitle, char defValue[], byte chars) {
  char retValue[20];
  strcpy(retValue, defValue);
  
  //Right-Pad with spaces
  boolean doWipe = 0;
  for (byte i = 0; i < chars; i++) {
    if (retValue[i] < 32 || retValue[i] > 126) doWipe = 1;
    if (doWipe) retValue[i] = 32;
  }
  retValue[chars] = '\0';
  
  byte cursorPos = 0; 
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  Encoder.setMin(0);
  Encoder.setMax(chars);
  Encoder.setCount(0);


  lcdSetCustChar_P(0, CHARFIELD);
  lcdSetCustChar_P(1, CHARCURSOR);
  lcdSetCustChar_P(2, CHARSEL);
  
  clearLCD();
  printLCD_P(0,0,sTitle);
  printLCD(3, 9, "OK");
  boolean redraw = 1;
  while(1) {
    int encValue;
    if (redraw) {
      redraw = 0;
      encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      if (cursorState) {
        retValue[cursorPos] = enc2ASCII(encValue);
      } else {
        cursorPos = encValue;
        for (byte i = (20 - chars + 1) / 2 - 1; i < (20 - chars + 1) / 2 - 1 + chars; i++) lcdWriteCustChar(2, i, 0);
        printLCD(3, 8, " ");
        printLCD(3, 11, " ");
        if (cursorPos == chars) {
          printLCD(3, 8, ">");
          printLCD(3, 11, "<");
        } else {
          lcdWriteCustChar(2, (20 - chars + 1) / 2 + cursorPos - 1, 1);
        }
      }
      printLCD(1, (20 - chars + 1) / 2 - 1, retValue);
    }
    
    if (Encoder.ok()) {
      if (cursorPos == chars) {
        strcpy(defValue, retValue);
        return;
      }
      else {
        cursorState = cursorState ^ 1;
        if (cursorState) {
          Encoder.setMin(0);
          Encoder.setMax(94);
          Encoder.setCount(ASCII2enc(retValue[cursorPos]));
          lcdWriteCustChar(2, (20 - chars + 1) / 2 + cursorPos - 1, 2);
        } else {
          Encoder.setMin(0);
          Encoder.setMax(chars);
          Encoder.setCount(cursorPos);
          lcdWriteCustChar(2, (20 - chars + 1) / 2 + cursorPos - 1, 1);
        }
      }
    } else if (Encoder.cancel()) return;
    flowCore();
  }
}

//Next two functions used to change order of charactor scroll to (space), A-Z, a-z, 0-9, symbols
byte ASCII2enc(byte charin) {
  if (charin == 32) return 0;
  else if (charin >= 65 && charin <= 90) return charin - 64;
  else if (charin >= 97 && charin <= 122) return charin - 70;
  else if (charin >= 48 && charin <= 57) return charin + 5;
  else if (charin >= 33 && charin <= 47) return charin + 30;
  else if (charin >= 58 && charin <= 64) return charin + 20;
  else if (charin >= 91 && charin <= 96) return charin - 6;
  else if (charin >= 123 && charin <= 126) return charin - 32;
}

byte enc2ASCII(byte charin) {
  if (charin == 0) return 32;
  else if (charin >= 1 && charin <= 26) return charin + 64;
  else if (charin >= 27 && charin <= 52) return charin + 70;
  else if (charin >= 53 && charin <= 62) return charin - 5;
  else if (charin >= 63 && charin <= 77) return charin - 30;
  else if (charin >= 78 && charin <= 84) return charin - 20;
  else if (charin >= 85 && charin <= 90) return charin + 6;
  else if (charin >= 91 && charin <= 94) return charin + 32;
}


//*****************************************************************************************************************************
// System Setup Menus
//*****************************************************************************************************************************
#ifndef UI_NO_SETUP
void menuSetup() {
  byte lastOption = 0;
  while(1) {
    strcpy_P(menuopts[0], PSTR("Configure Outputs"));
    strcpy_P(menuopts[1], INIT_EEPROM);
    strcpy_P(menuopts[2], EXIT);
    
    lastOption = scrollMenu("System Setup", 3, lastOption);
    if (lastOption == 0) cfgOutputs();
    else if (lastOption == 1) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Reset Configuration?"));
      strcpy_P(menuopts[0], INIT_EEPROM);
        strcpy_P(menuopts[1], CANCEL);
        if (getChoice(2, 3) == 0) {
          EEPROM.write(2047, 0);
          initEEPROM();
          checkConfig();
        }
    } else return;
  }
}

void cfgOutputs() {
  byte lastOption = 0;
  while(1) {
    if (PIDEnabled) strcpy_P(menuopts[0], PSTR("Mode: PID")); else strcpy_P(menuopts[0], PSTR("Mode: On/Off"));
    strcpy_P(menuopts[1], PIDCYCLE);
    strcpy_P(menuopts[2], PIDGAIN);
    strcpy_P(menuopts[3], HYSTERESIS);
    strcpy_P(menuopts[4], EXIT);

    lastOption = scrollMenu("Configure Outputs", 5, lastOption);
    if (lastOption == 0) {
      if (PIDEnabled) setPIDEnabled(0);
      else setPIDEnabled(1);
    }
    else if (lastOption == 1) {
      setPIDCycle(getValue(PIDCYCLE, PIDCycle, 3, 0, 255, SEC));
      pid.SetOutputLimits(0, PIDCycle * 10 * PIDLIMIT);
    } 
    else if (lastOption == 2) {
      setPIDGain("PID Gain");
    } 
    else if (lastOption == 3) setHysteresis(getValue(HYSTERESIS, hysteresis, 3, 1, 255, TUNIT));
    else return;
  } 
}

void setPIDGain(char sTitle[]) {
  byte retP = pid.GetP_Param();
  byte retI = pid.GetI_Param();
  byte retD = pid.GetD_Param();
  byte cursorPos = 0; //0 = p, 1 = i, 2 = d, 3 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  Encoder.setMin(0);
  Encoder.setMax(3);
  Encoder.setCount(0);
  
  clearLCD();
  printLCD(0,0,sTitle);
  printLCD_P(1, 0, PSTR("P:     I:     D:    "));
  printLCD_P(3, 8, PSTR("OK"));
  boolean redraw = 1;
  while(1) {
    int encValue;
    if (redraw) {
      redraw = 0;
      encValue = Encoder.getCount();
    }
    else encValue = Encoder.change();
    if (encValue >= 0) {
      if (cursorState) {
        if (cursorPos == 0) retP = encValue;
        else if (cursorPos == 1) retI = encValue;
        else if (cursorPos == 2) retD = encValue;
      } else {
        cursorPos = encValue;
        if (cursorPos == 0) {
          printLCD_P(1, 2, PSTR(">"));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 1) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(">"));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 2) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(">"));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 3) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(">"));
          printLCD_P(3, 10, PSTR("<"));
        }
      }
      printLCDLPad(1, 3, itoa(retP, buf, 10), 3, ' ');
      printLCDLPad(1, 10, itoa(retI, buf, 10), 3, ' ');
      printLCDLPad(1, 17, itoa(retD, buf, 10), 3, ' ');
    }
    if (Encoder.ok()) {
      if (cursorPos == 3) {
        setPIDp(retP);
        setPIDi(retI);
        setPIDd(retD);
        return;
      }
      cursorState = cursorState ^ 1;
      if (cursorState) {
        Encoder.setMin(0);
        Encoder.setMax(255);
        if (cursorPos == 0) Encoder.setCount(retP);
        else if (cursorPos == 1) Encoder.setCount(retI);
        else if (cursorPos == 2) Encoder.setCount(retD);
      } else {
        Encoder.setMin(0);
        Encoder.setMax(3);
        Encoder.setCount(cursorPos);
      }
    } else if (Encoder.cancel()) return;
  }
}
#endif
#endif
