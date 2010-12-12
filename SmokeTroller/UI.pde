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

//#ifndef NOUI
  #include "Config.h"
  #include "Enum.h"
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
  // UI Definitions
  //**********************************************************************************
  #define SCREEN_HOME 0
  #define SCREEN_PIT1 1
  #define SCREEN_PIT2 2
  #define SCREEN_PIT3 3
  #define SCREEN_AUX 4
  
  //**********************************************************************************
  // UI Strings
  //**********************************************************************************
  const char OK[] PROGMEM = "Ok";
  const char CANCEL[] PROGMEM = "Cancel";
  const char EXIT[] PROGMEM = "Exit";
  const char MENU[] PROGMEM = "Menu";
  const char SPACE[] PROGMEM = " ";
  const char INIT_EEPROM[] PROGMEM = "Initialize EEPROM";
  const char CONTINUE[] PROGMEM = "Continue";  
  const char ALLOFF[] PROGMEM = "All Off";
  const char ABORT[] PROGMEM = "Abort";
  const char SEC[] PROGMEM = "s";  
  const char ASSIGNPGM[] PROGMEM = "Assign Program";
  const char STOPPGM[] PROGMEM = "Stop Program";
  const char PIT1HEAT[] PROGMEM = "Pit 1 Heat";
  const char PIT1IDLE[] PROGMEM = "Pit 1 Idle";
  const char PIT2HEAT[] PROGMEM = "Pit 2 Heat";
  const char PIT2IDLE[] PROGMEM = "Pit 2 Idle";
  const char PIT3HEAT[] PROGMEM = "Pit 3 Heat";
  const char PIT3IDLE[] PROGMEM = "Pit 3 Idle";  
    
  #ifndef UI_NO_SETUP
    const char HLTCYCLE[] PROGMEM = "Pit 1 PID Cycle";
    const char HLTGAIN[] PROGMEM = "Pit 1 PID Gain";
    const char HLTHY[] PROGMEM = "Pit 1 Hysteresis";
    const char MASHCYCLE[] PROGMEM = "Pit 2 PID Cycle";
    const char MASHGAIN[] PROGMEM = "Pit 2 PID Gain";
    const char MASHHY[] PROGMEM = "Pit 2 Hysteresis";
    const char KETTLECYCLE[] PROGMEM = "Pit 3 PID Cycle";
    const char KETTLEGAIN[] PROGMEM = "Pit 3 PID Gain";
    const char KETTLEHY[] PROGMEM = "Pit 3 Hysteresis"; 
  #endif  

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
  
  //**********************************************************************************
  // UI Custom LCD Chars
  //**********************************************************************************
  const byte CHARFIELD[] PROGMEM = {B11111, B00000, B00000, B00000, B00000, B00000, B00000, B00000};
  const byte CHARCURSOR[] PROGMEM = {B11111, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
  const byte CHARSEL[] PROGMEM = {B10001, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
  const byte BMP0[] PROGMEM = {B01010, B01001, B10001, B10010, B01000, B00100, B01110, B11111};
  const byte BMP1[] PROGMEM = {B00111, B01111, B11100, B11011, B11011, B11011, B11100, B11111};
  const byte BMP2[] PROGMEM = {B11111, B11111, B00000, B11111, B11111, B11111, B00000, B11111};
  const byte BMP3[] PROGMEM = {B11100, B11110, B00111, B11011, B01011, B11011, B00111, B11111};
  const byte BMP4[] PROGMEM = {B11111, B11100, B11011, B11010, B11011, B11100, B01111, B00111};
  const byte BMP5[] PROGMEM = {B11111, B00000, B11111, B10101, B11111, B00000, B11111, B11111};
  const byte BMP6[] PROGMEM = {B11111, B00111, B11011, B01011, B11011, B00111, B11110, B11100};
  const byte UNLOCK_ICON[] PROGMEM = {B00110, B01001, B01001, B01000, B01111, B01111, B01111, B00000};
  const byte PROG_ICON[] PROGMEM = {B00001, B11101, B10101, B11101, B10001, B10001, B00001, B11111};
  const byte BELL[] PROGMEM = {B00100, B01110, B01110, B01110, B11111, B00000, B00100, B00000};
  
 
  //**********************************************************************************
  // UI Globals
  //**********************************************************************************
  byte activeScreen;
  boolean screenLock;
  unsigned long timerLastPrint;
  
  //**********************************************************************************
  // uiInit:  One time intialization of all UI logic
  //**********************************************************************************
  void uiInit() {
    initLCD();
    lcdSetCustChar_P(7, UNLOCK_ICON);
    Encoder.begin(ENCA_PIN, ENCB_PIN, ENTER_PIN, ENTER_INT, ENCODER_TYPE);
  
    //Check to see if EEPROM Initialization is needed
    if (checkConfig()) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Missing Config"));
      strcpy_P(menuopts[0], INIT_EEPROM);
      strcpy_P(menuopts[1], EXIT);
      if (getChoice(2, 3) == 0) {
        clearLCD();
        printLCD_P(1, 0, INIT_EEPROM);
        printLCD_P(2, 3, PSTR("Please Wait..."));
        initEEPROM();
        //Apply any EEPROM updates
        checkConfig();
      }
      clearLCD();
    }
  
    activeScreen = SCREEN_HOME;
    screenInit(SCREEN_HOME);
    unlockUI();
  }
  
  void uiEvent(byte eventID, byte eventParam) {
//    if (eventID == EVENT_STEPINIT) {
//      if (eventParam == STEP_FILL || eventParam == STEP_REFILL)
//        activeScreen = SCREEN_FILL;
//      else if (eventParam == STEP_DELAY || eventParam == STEP_PREHEAT || eventParam == STEP_DOUGHIN || eventParam == STEP_ACID || eventParam == STEP_PROTEIN 
//        || eventParam == STEP_SACCH || eventParam == STEP_SACCH2 || eventParam == STEP_MASHOUT || eventParam == STEP_MASHHOLD) 
//        activeScreen = SCREEN_MASH;
//      else if (eventParam == STEP_ADDGRAIN || eventParam == STEP_SPARGE) activeScreen = SCREEN_SPARGE;
//      else if (eventParam == STEP_BOIL) activeScreen = SCREEN_BOIL;
//      else if (eventParam == STEP_CHILL) activeScreen = SCREEN_CHILL;
//      screenInit(activeScreen);
//    }
  }
  
  //**********************************************************************************
  // unlockUI:  Unlock active screen to select another
  //**********************************************************************************
  void unlockUI() {  
    Encoder.setMin(SCREEN_HOME);
    Encoder.setMax(SCREEN_AUX);
    Encoder.setCount(activeScreen);
    screenLock = 0;
    //Reinit screen to show unlock icon hide parts not visible while locked
    screenInit(activeScreen);
  }
  
  void lockUI() {  
    screenLock = 1;
    //Recall screenInit to setup encoder and other functions available only when locked   
    screenInit(activeScreen);
  }
  
  //**********************************************************************************
  // screenCore: Called in main loop to handle all UI functions
  //**********************************************************************************
  void uiCore() {    
    if (!screenLock) {
      int encValue = Encoder.change();
      if (encValue >=0) {       
        activeScreen = encValue;
        screenInit(activeScreen);
      }
    }
    screenEnter(activeScreen);
    screenRefresh(activeScreen);
  }
  
  //**********************************************************************************
  // screenInit: Initialize active screen
  //**********************************************************************************
  void screenInit(byte screen) {
    clearLCD();
    //Print Program Active Char (Overwritten if no program active)
    if (screen != SCREEN_HOME) {
      lcdSetCustChar_P(6, PROG_ICON);
      lcdWriteCustChar(0, 0, 6);
      lcdSetCustChar_P(5, BELL);
    }
    
    if (screen == SCREEN_HOME) {
      //Screen Init: Home
      lcdSetCustChar_P(0, BMP0);
      lcdSetCustChar_P(1, BMP1);
      lcdSetCustChar_P(2, BMP2);
      lcdSetCustChar_P(3, BMP3);
      lcdSetCustChar_P(4, BMP4);
      lcdSetCustChar_P(5, BMP5);
      lcdSetCustChar_P(6, BMP6);
      lcdWriteCustChar(0, 1, 0);
      lcdWriteCustChar(1, 0, 1);
      lcdWriteCustChar(1, 1, 2); 
      lcdWriteCustChar(1, 2, 3); 
      lcdWriteCustChar(2, 0, 4); 
      lcdWriteCustChar(2, 1, 5); 
      lcdWriteCustChar(2, 2, 6); 
      printLCD_P(0, 5, BT);
      printLCD_P(1, 6, PSTR("Version :"));
      printLCD_P(1, 17, BTVER);
      printLCD_P(2, 6, PSTR("Build   :"));
      printLCDLPad(2, 16, itoa(BUILD, buf, 10), 4, '0');
      printLCD_P(3, 1, PSTR("www.brewtroller.com"));
      
    } else if (screen == SCREEN_PIT1) {
      //Screen Init: Pit 1
      initPitScreen(PIT_1);
     
    } else if (screen == SCREEN_PIT2) {
      //Screen Init: Pit 2
      initPitScreen(PIT_1);
      
    } else if (screen == SCREEN_PIT3) {
      //Screen Init: Pit 3      
      initPitScreen(PIT_3)
     
    } else if (screen == SCREEN_AUX) {
      //Screen Init: AUX
      printLCD_P(0,0,PSTR("AUX Temps"));
      printLCD_P(1,1,PSTR("AUX1"));
      printLCD_P(2,1,PSTR("AUX2"));
      printLCD_P(3,1,PSTR("AUX3"));
      printLCD_P(1, 11, TUNIT);
      printLCD_P(2, 11, TUNIT);
      printLCD_P(3, 11, TUNIT);
    }
    
    //Write Unlock symbol to upper right corner
    if (!screenLock) lcdWriteCustChar(0, 19, 7);
  }
  
  //**********************************************************************************
  // initPitScreen:  Common Init for all the Pit Screens
  //**********************************************************************************
  void initPitScreen(byte pit)
  {
    printLCD(0, 0, pitName[pit]);
    printLCD_P(0, 11, PSTR("Pit"));
    printLCD_P(0, 16, PSTR("Food"));
    printLCD_P(1, 1, PSTR("Target"));
    printLCD_P(2, 1, PSTR("Actual"));  
    printLCD(1, 11, itoa(pitSetPoint[pit], buf, 10));
    printLCD(1, 16, itoa(foodSetPoint[pit], buf, 10));  
  }
  
  //**********************************************************************************
  // screenRefresh:  Refresh active screen
  //**********************************************************************************
  void screenRefresh(byte screen) {
    if (screen == SCREEN_HOME) {
      //Refresh Screen: Home      

    } else if (screen == SCREEN_PIT1) {
      //Screen Init: Pit 1     
      refreshPitScreen(PIT_1);
      
    } else if (screen == SCREEN_PIT2) {
      //Screen Init: Pit 2
      refreshPitScreen(PIT_2);
   
    } else if (screen == SCREEN_PIT3) {
      //Screen Init: Pit 3
      refreshPitScreen(PIT_3);
  
    } else if (screen == SCREEN_AUX) {
      //Screen Refresh: AUX
      for (byte i = TS_AUX1; i <= TS_AUX3; i++) {
        if (temp[i] == -32768) printLCD_P(i - 5, 6, PSTR("---.-")); else {
          vftoa(temp[i], buf, 2);
          truncFloat(buf, 5);
          printLCDLPad(i - 5, 6, buf, 5, ' ');
        }
      }
    }
  }
  
  //**********************************************************************************
  // refreshPitScreen:  Common Refresh for all the Pit Screens
  //**********************************************************************************
  void refreshPitScreen(byte pit)
  {
     if (pitSetPoint[pit] > 0) printLCD(1, 11, itoa(pitSetPoint[pit], buf, 10));
      if (foodSetPoint[pit] > 0) printLCD(1, 16, itoa(foodSetPoint[pit], buf, 10));
      if (temp[TS_PIT_1] == -32768) printLCD_P(2, 11, PSTR("---")); else printLCD(2, 11, itoa(temp[TS_PIT_1], buf, 10));
      if (temp[TS_FOOD_1] == -32768) printLCD_P(2, 16, PSTR("---")); else printLCD(2, 16, itoa(temp[TS_FOOD_1], buf, 10));
      byte pct;
      if (PIDEnabled[pit]) {
        pct = PIDOutput[pit] / PIDCycle[pit];
        if (pct == 0) strcpy_P(buf, PSTR("Off"));
        else if (pct == 100) strcpy_P(buf, PSTR(" On"));
        else { itoa(pct, buf, 10); strcat(buf, "%"); }
      } else if (heatStatus[pit]) {
        strcpy_P(buf, PSTR(" On")); 
        pct = 100;
      } else {
        strcpy_P(buf, PSTR("Off"));
        pct = 0;
      }
      printLCDLPad(3, 11, buf, 3, ' ');
      printTimer(pit, 3, 0);
  }
  
  
  //**********************************************************************************
  // screenEnter:  Check enterStatus and handle based on screenLock and activeScreen
  //**********************************************************************************
  void screenEnter(byte screen) {  
    
    if (Encoder.cancel()) {
      //Unlock screens
      unlockUI();
    } else if (Encoder.ok()) {   
      if (alarmStatus) setAlarm(0);
      else if (!screenLock) lockUI();
      else {
        if (screen == SCREEN_HOME) {
          byte lastOption = 0;
          while(1) {
            //Screen Enter: Home
            strcpy_P(menuopts[0], EXIT);
            strcpy_P(menuopts[1], PSTR("Edit Program"));
            strcpy_P(menuopts[2], PSTR("Reset All"));
            strcpy_P(menuopts[3], PSTR("System Setup"));
            #ifdef UI_NO_SETUP
              lastOption = scrollMenu("Main Menu", 3, lastOption);
            #else
              lastOption = scrollMenu("Main Menu", 4, lastOption);
            #endif
            if (lastOption == 1) editProgramMenu();
            else if (lastOption == 2) {             
              //Reset All
              if (confirmAbort()) {
                for (byte pit = PIT_1; pit <= PIT_3; pit++) resetPit(pit);
                for (byte timer = PIT_1; timer <= PIT_3; timer++) clearTimer(timer);
              }
            }
            #ifndef UI_NO_SETUP        
              else if (lastOption == 3) menuSetup();
            #endif
            else if (lastOption == 0) {
              //On exit of the Main menu go back to Splash/Home screen.
              activeScreen = SCREEN_HOME;
              screenInit(activeScreen);
              unlockUI();
              break;
            }
          }
          screenInit(activeScreen);

        } else if (screen == SCREEN_PIT1) {
          //Sceeen Enter: Pit 1
          enterPitScreen(PIT_1);
          
        } else if (screen == SCREEN_PIT2) {
          //Screen Enter: Pit 2
          enterPitScreen(PIT_2);
                 
        } else if (screen == SCREEN_PIT3) {
          //Screen Enter: Pit 3
          enterPitScreen(PIT_3);
          
        }
      }
    }
  }

  //**********************************************************************************
  // enterPitScreen:  Common Refresh for all the Pit Screens
  //**********************************************************************************
  void enterPitScreen(byte pit) {
    strcpy_P(menuopts[0], ASSIGNPGM);
    strcpy_P(menuopts[1], PSTR("Pit Setpoint : "));
    strncat(menuopts[1], itoa(pitSetPoint[pit], buf, 10), 3);
    strcat_P(menuopts[1], TUNIT);         
    strcpy_P(menuopts[2], PSTR("Food Setpoint: "));
    strncat(menuopts[2], itoa(foodSetPoint[pit], buf, 10), 3);
    strcat_P(menuopts[2], TUNIT);
    strcpy_P(menuopts[3], PSTR("Set Timer"));
    if (timerStatus[pit]) strcpy_P(menuopts[4], PSTR("Pause Timer"));
    else strcpy_P(menuopts[4], PSTR("Start Timer"));
    strcpy_P(menuopts[5], PSTR("Clear Timer"));
    strcpy_P(menuopts[6], ABORT);
    strcpy_P(menuopts[7], EXIT);
    byte lastOption = scrollMenu("Smoker Menu", 8, lastOption);
    if (lastOption == 0) selectProgramMenu(pit);   
    else if (lastOption == 1) setPitSetPoint(pit, getValue(PSTR("Pit Setpoint"), pitSetPoint[pit], 3, 0, MAX_PIT_TEMP, TUNIT));
    else if (lastOption == 2) setFoodSetPoint(pit, getValue(PSTR("Food Setpoint"), foodSetPoint[pit], 3, 0, MAX_FOOD_TEMP, TUNIT));
    else if (lastOption == 3) { 
      setTimer(pit, getTimerValue(PSTR("Pit Timer"), timerValue[pit] / 60000, MAX_STEP_TIME_HOURS));
    } 
    else if (lastOption == 4) {
      pauseTimer(pit);
    } 
    else if (lastOption == 5) {
      // clear timer
      clearTimer(pit);
    } else if (lastOption == 6) {
      //abort
      if (confirmAbort()) {
        resetPit(pit);
        clearTimer(pit);
      }
    }
    screenInit(activeScreen);  
  }
  
//  void continueClick() {
//    screenInit(activeScreen); 
//  }
  
  void resetSpargeValves() {
//    autoValve[AV_SPARGEIN] = 0;
//    autoValve[AV_SPARGEOUT] = 0;
//    autoValve[AV_FLYSPARGE] = 0;
//    setValves(vlvConfig[VLV_SPARGEIN], 0);
//    setValves(vlvConfig[VLV_SPARGEOUT], 0);
//    setValves(vlvConfig[VLV_MASHHEAT], 0);
//    setValves(vlvConfig[VLV_MASHIDLE], 0);
  }
  
  void stepAdvanceFailDialog() {
    clearLCD();
    printLCD_P(0, 0, PSTR("Failed to advance"));
    printLCD_P(1, 0, PSTR("program."));
    printLCD(3, 4, ">");
    printLCD_P(3, 6, CONTINUE);
    printLCD(3, 15, "<");
    while (!Encoder.ok()) smokeCore();
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
  
  //TODO: set this as the active program for the selected smoker      
  void selectProgramMenu(byte pit) {
    byte pgm = 0;
    for (byte i = 0; i < 20; i++) getProgName(i, menuopts[i]);
    while (1) {
      pgm = scrollMenu("Select Program", 20, pgm);
      if (pgm >= 0 && pgm <= 20) {
        startProgram(pgm, pit);
        return;
      }
      smokeCore();
    }    
    screenInit(activeScreen);
    screenEnter(activeScreen);   
  }   
  
  void startProgram(byte pgm, byte pit) {
    setPitSetPoint(pit, getFirstStepTemp(pgm));
    setFoodSetPoint(pit, getProgFoodTemp(pgm)); 
    // Start the program's first step  
  }
  
  void editProgram(byte pgm) {
    byte lastOption = 0;
    while (1) {
      strcpy_P(menuopts[0], PSTR("Food Temp :"));
      strcpy_P(menuopts[1], PSTR("Step Schedule"));
      strcpy_P(menuopts[2], EXIT);
          
      // Food Temp 
      strncat(menuopts[0], itoa(getProgFoodTemp(pgm), buf, 10), 3);
      strcat_P(menuopts[0], TUNIT);
           
      lastOption = scrollMenu("Program Parameters", 3, lastOption);
      if (lastOption == 0) setProgFoodTemp(pgm, getValue(PSTR("Food Temp"), getProgFoodTemp(pgm), 3, 0, MAX_FOOD_TEMP, TUNIT));      
      else if (lastOption == 1) editStepSchedule(pgm);
      else return;      
    }
  }
  
  void editStepSchedule(byte pgm) {
    byte lastOption = 0;
    while (1) {
      strcpy_P(menuopts[0], PSTR("Step 1: "));
      strcpy_P(menuopts[1], PSTR("Step 1: "));
      strcpy_P(menuopts[2], PSTR("Step 2: "));
      strcpy_P(menuopts[3], PSTR("Step 2: "));
      strcpy_P(menuopts[4], PSTR("Step 3: "));
      strcpy_P(menuopts[5], PSTR("Step 3: "));
      strcpy_P(menuopts[6], PSTR("Step 4: "));
      strcpy_P(menuopts[7], PSTR("Step 4: "));     
      strcpy_P(menuopts[8], EXIT);
  
      for (byte i = STEP_ONE; i <= STEP_FOUR; i++) {  
        int stepTotalMins = getProgStepMins(pgm, i);
        int stepHours = round(stepTotalMins / 60);
        int stepMins = stepTotalMins - (stepHours * 60);
        strcat(menuopts[i * 2], itoa(stepHours, buf, 10));
        strcat(menuopts[i * 2], "hr ");
        strcat(menuopts[i * 2], itoa(stepMins, buf, 10));
        strcat(menuopts[i * 2], "min");
  
        strncat(menuopts[i * 2 + 1], itoa(getProgStepTemp(pgm, i), buf, 10), 3);
        strcat_P(menuopts[i * 2 + 1], TUNIT);
      }
      
      lastOption = scrollMenu("Step Schedule", 9, lastOption);
      if (lastOption == 0) setProgStepMins(pgm, STEP_ONE, getTimerValue(PSTR("Step 1"), getProgStepMins(pgm, STEP_ONE), MAX_STEP_TIME_HOURS));
      else if (lastOption == 1) setProgStepTemp(pgm, STEP_ONE, getValue(PSTR("Step 1"), getProgStepTemp(pgm, STEP_ONE), 3, 0, MAX_PIT_TEMP, TUNIT));
      else if (lastOption == 2) setProgStepMins(pgm, STEP_TWO, getTimerValue(PSTR("Step 2"), getProgStepMins(pgm, STEP_TWO), MAX_STEP_TIME_HOURS));
      else if (lastOption == 3) setProgStepTemp(pgm, STEP_TWO, getValue(PSTR("Step 2"), getProgStepTemp(pgm, STEP_TWO), 3, 0, MAX_PIT_TEMP, TUNIT));
      else if (lastOption == 4) setProgStepMins(pgm, STEP_THREE, getTimerValue(PSTR("Step 3"), getProgStepMins(pgm, STEP_THREE), MAX_STEP_TIME_HOURS));
      else if (lastOption == 5) setProgStepTemp(pgm, STEP_THREE, getValue(PSTR("Step 3"), getProgStepTemp(pgm, STEP_THREE), 3, 0, MAX_PIT_TEMP, TUNIT));
      else if (lastOption == 6) setProgStepMins(pgm, STEP_FOUR, getTimerValue(PSTR("Step 4"), getProgStepMins(pgm, STEP_FOUR), MAX_STEP_TIME_HOURS));
      else if (lastOption == 7) setProgStepTemp(pgm, STEP_FOUR, getValue(PSTR("Step 4"), getProgStepTemp(pgm, STEP_FOUR), 3, 0, MAX_PIT_TEMP, TUNIT));     
      else return;
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
    
    int encValue;
    while(1) {
      if (redraw) {
        redraw = 0;
        encValue = Encoder.getCount();
      } else encValue = Encoder.change();
      
      if (encValue >= 0) {
        //There is a new value for the encoder.
        if (encValue < topItem) {
          //Scrolling the menu up!
          topItem = encValue; //The first menu item to display.
        } else if (encValue > topItem + 2) {
          //Scrolling the menu down!
          topItem = encValue - 2; //Scroll the menu down by only one new menu item.
        }
        //Display a new menu or refresh the cursor location (encoder).
        drawMenu(sTitle, numOpts, topItem, encValue);
      }
      
      //If Enter
      if (Encoder.ok()) {
        return Encoder.getCount();
      } else if (Encoder.cancel()) {
        return numOpts;
      }
      smokeCore();
    }
  }
  
  void drawMenu(char sTitle[], byte numOpts, byte topItem, int encValue) {
    clearLCD();
    if (sTitle != NULL) printLCD(0, 0, sTitle);
    drawItems(numOpts, topItem, encValue);
  }
  
  void drawItems(byte numOpts, byte topItem, int encValue) {
    //numOpts: Total of menu items for that menu.
    //topItem: The first menu item to display using the list numeric value (from 0 - X) (not the position in the menu from 1 to X).
    //Uses Global menuopts[][20]
    byte maxOpt;
    
    if (numOpts < 3) {
      //Only two of less menu item to display.
      topItem = 0;
      maxOpt = numOpts - 1; 
    } else if (topItem > numOpts - 3){
      //The first item to display is at the bottom of the list. Move the selection sightly up do display a full page of menu items, meaning the last three.
      topItem = numOpts - 3; //Select a new top item to display in order to display a full page of menu items.
      maxOpt = topItem + 2;
    } else {
      //Will only display the first 3 menu items that includes the "topItem".
      maxOpt = topItem + 2;
    }
    //Display menu items.
    for (byte i = topItem; i <= maxOpt; i++) printLCD(i-topItem+1, 1, menuopts[i]);
  
    //Display encoder position ">".
    for (byte i = 1; i <= 3; i++) if (i == encValue - topItem + 1) printLCD(i, 0, ">"); else printLCD(i, 0, " "); 
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
      smokeCore();
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
    printLCD_P(3, 9, OK);
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
      smokeCore();
    }
    return retValue;
  }
  
  void printTimer(byte timer, byte iRow, byte iCol) {
    if (timerValue[timer] > 0 && !timerStatus[timer]) printLCD(iRow, iCol, "PAUSED");
    else if (alarmStatus || timerStatus[timer]) {
      byte hours = timerValue[timer] / 3600000;
      byte mins = (timerValue[timer] - hours * 3600000) / 60000;
      byte secs = (timerValue[timer] - hours * 3600000 - mins * 60000) / 1000;
  
      //Update LCD once per second
      if (millis() - timerLastPrint >= 1000) {
        timerLastPrint = millis();
        printLCDRPad(iRow, iCol, "", 6, ' ');
        printLCD_P(iRow, iCol+2, PSTR(":  :"));
        printLCDLPad(iRow, iCol, itoa(hours, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol + 3, itoa(mins, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol + 6, itoa(secs, buf, 10), 2, '0');
        if (alarmStatus) lcdWriteCustChar(iRow, iCol + 8, 5);
      }
    } else printLCDRPad(iRow, iCol, "", 9, ' ');
  }
  
  int getTimerValue(const char *sTitle, int defMins, byte maxHours) {
    byte hours = defMins / 60;
    byte mins = defMins - hours * 60;
    byte cursorPos = 0; //0 = Hours, 1 = Mins, 2 = OK
    boolean cursorState = 0; //0 = Unselected, 1 = Selected
    Encoder.setMin(0);
    Encoder.setMax(2);
    Encoder.setCount(0);
    
    clearLCD();
    printLCD_P(0,0,sTitle);
    printLCD(1, 7, "(hh:mm)");
    printLCD(2, 10, ":");
    printLCD_P(3, 9, OK);
    boolean redraw = 1;
    int encValue;
   
    while(1) {
      if (redraw) {
        redraw = 0;
        encValue = Encoder.getCount();
      } else encValue = Encoder.change();
      if (encValue >= 0) {
        if (cursorState) {
          if (cursorPos) mins = encValue; else hours = encValue;
        } else {
          cursorPos = encValue;
          switch (cursorPos) {
            case 0: //hours
              printLCD(2, 7, ">");
              printLCD(2, 13, " ");
              printLCD(3, 8, " ");
              printLCD(3, 11, " ");
              break;
            case 1: //mins
              printLCD(2, 7, " ");
              printLCD(2, 13, "<");
              printLCD(3, 8, " ");
              printLCD(3, 11, " ");
              break;
            case 2: //OK
              printLCD(2, 7, " ");
              printLCD(2, 13, " ");
              printLCD(3, 8, ">");
              printLCD(3, 11, "<");
              break;
          }
        }
        printLCDLPad(2, 8, itoa(hours, buf, 10), 2, '0');
        printLCDLPad(2, 11, itoa(mins, buf, 10), 2, '0');
      }
      
      if (Encoder.ok()) {
        if (cursorPos == 2) return hours * 60 + mins;
        cursorState = cursorState ^ 1; //Toggles between value editing mode and cursor navigation.
        if (cursorState) {
          //Edition mode
          Encoder.setMin(0);
          if (cursorPos) {
            //Editing minutes
            Encoder.setMax(59);
            Encoder.setCount(mins); 
          } else {
            //Editing hours
            Encoder.setMax(maxHours);
            Encoder.setCount(hours);
          }
        } else {
          Encoder.setMin(0);
          Encoder.setMax(2);
          Encoder.setCount(cursorPos);
        }
      } else if (Encoder.cancel()) return -1; //This value will be validated in SetTimerValue. SetTimerValue will reject the storage of the timer value. 
      smokeCore();
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
    printLCD_P(3, 9, OK);
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
      smokeCore();
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
    else if (charin >= 1 && charin <= 26) return charin + 64;  //Scan uper case alphabet
    else if (charin >= 27 && charin <= 52) return charin + 70; //Scan lower case alphabet
    else if (charin >= 53 && charin <= 62) return charin - 5;  //Scan number
    else if (charin >= 63 && charin <= 77) return charin - 30; //Scan special character from space
    else if (charin >= 78 && charin <= 84) return charin - 20; //Scan special character :
    else if (charin >= 85 && charin <= 90) return charin + 6;  //Scan special character from [
    else if (charin >= 91 && charin <= 94) return charin + 32; //Scan special character from {
  }
  
  //*****************************************************************************************************************************
  // System Setup Menus
  //*****************************************************************************************************************************

  void menuSetup() {
    byte lastOption = 0;
    while(1) {
      strcpy_P(menuopts[0], PSTR("Assign Temp Sensor"));
      strcpy_P(menuopts[1], PSTR("Set Pit Names"));
      strcpy_P(menuopts[2], PSTR("Configure Outputs"));
      strcpy_P(menuopts[3], INIT_EEPROM);
      strcpy_P(menuopts[4], EXIT);      
      lastOption = scrollMenu("System Setup", 5, lastOption);
      if (lastOption == 0) assignSensor();
      else if (lastOption == 1) cfgPitNames();
      else if (lastOption == 2) cfgOutputs();
      else if (lastOption == 3) {
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

  void assignSensor() {
    Encoder.setMin(0);
    Encoder.setMax(8);
    Encoder.setCount(0);
    
    char dispTitle[9][21];
    strcpy_P(dispTitle[0], PSTR("PIT 1"));
    strcpy_P(dispTitle[1], PSTR("PIT 2"));
    strcpy_P(dispTitle[2], PSTR("PIT 3"));
    strcpy_P(dispTitle[3], PSTR("FOOD 1"));
    strcpy_P(dispTitle[4], PSTR("FOOD 2"));
    strcpy_P(dispTitle[5], PSTR("FOOD 3"));
    strcpy_P(dispTitle[6], PSTR("AUX 1"));
    strcpy_P(dispTitle[7], PSTR("AUX 2"));
    strcpy_P(dispTitle[8], PSTR("AUX 3"));
    boolean redraw = 1;
    int encValue, oldEncValue;
  
    while (1) {
      if (redraw) {
        //First time entry or back from the sub-menu.
        redraw = 0;
        encValue = Encoder.getCount();
      } else encValue = Encoder.change();
    
      if (encValue >= 0) {
        //The user has navigated toward a new temperature probe screen.
        oldEncValue = encValue;  //Will allow partial screen refresh when viewing the same screen.
        clearLCD();
        printLCD_P(0, 0, PSTR("Assign Temp Sensor"));
        printLCDCenter(1, 0, dispTitle[encValue], 20);
        for (byte i=0; i<8; i++) printLCDLPad(2,i*2+2,itoa(tSensor[encValue][i], buf, 16), 2, '0');  
        displayAssignSensorTemp(encValue);
      } else {
        //The user is still viewing the same screen (no change on the static data but refresh the temperature value).
          displayAssignSensorTemp(oldEncValue);  //Only refresh the current screen.
      }
      
      if (Encoder.cancel()) return;
      else if (Encoder.ok()) {
        encValue = Encoder.getCount();
        //Pop-Up Menu
        strcpy_P(menuopts[0], PSTR("Scan Bus"));
        strcpy_P(menuopts[1], PSTR("Delete Address"));
        strcpy_P(menuopts[2], CANCEL);
        strcpy_P(menuopts[3], EXIT);
        byte selected = scrollMenu(dispTitle[encValue], 4, 0);
        if (selected == 0) {
          clearLCD();
          printLCDCenter(0, 0, dispTitle[encValue], 20);
          printLCD_P(1,0,PSTR("Disconnect all other"));
          printLCD_P(2,2,PSTR("temp sensors now"));            
          strcpy_P(menuopts[0], CONTINUE);
          strcpy_P(menuopts[1], CANCEL);
          if (getChoice(2, 3) == 0) {
            byte addr[8] = {0, 0, 0, 0, 0, 0, 0, 0};
//              getDSAddr(addr);
//              setTSAddr(encValue, addr);
          }            
        } else if (selected == 1) {
          byte addr[8] = {0, 0, 0, 0, 0, 0, 0, 0};
          //setTSAddr(encValue, addr);
        }
        else if (selected > 2) return;
  
        Encoder.setMin(0);
        Encoder.setMax(8);
        Encoder.setCount(encValue);
        redraw = 1;
      }
      smokeCore();
    }
  }

  void displayAssignSensorTemp(int encValue) {
    printLCD_P(3, 10, TUNIT); 
    if (temp[encValue] == -32768) {
      printLCD_P(3, 7, PSTR("---"));
    } else {
      printLCDLPad(3, 7, itoa(temp[encValue] / 100, buf, 10), 3, ' ');
    }
  }
  
  void cfgPitNames() {
    byte lastOption = 0;
    while (1) {
      strcpy_P(menuopts[0], PSTR("Pit 1: "));
      strcpy_P(menuopts[1], PSTR("Pit 2: "));
      strcpy_P(menuopts[2], PSTR("Pit 3: "));
      strcpy_P(menuopts[3], EXIT);
  
      for (byte i = PIT_1; i <= PIT_3; i++) strcat(menuopts[i], pitName[i]);       
      
      lastOption = scrollMenu("Set Pit Names", 4, lastOption);      
 
      if (lastOption > 2) return;
      getString(PSTR("Pit Name:"), pitName[lastOption], 10);
      setPitName(lastOption, pitName[lastOption]);
    }  
  }

  void cfgOutputs() {
      byte lastOption = 0;
      while(1) {
        if (PIDEnabled[PIT_1]) strcpy_P(menuopts[0], PSTR("Pit 1 Mode: PID")); else strcpy_P(menuopts[0], PSTR("Pit 1 Mode: On/Off"));
        strcpy_P(menuopts[1], HLTCYCLE);
        strcpy_P(menuopts[2], HLTGAIN);
        strcpy_P(menuopts[3], HLTHY);
        if (PIDEnabled[PIT_2]) strcpy_P(menuopts[4], PSTR("Pit 2 Mode: PID")); else strcpy_P(menuopts[4], PSTR("Pit 2 Mode: On/Off"));
        strcpy_P(menuopts[5], MASHCYCLE);
        strcpy_P(menuopts[6], MASHGAIN);
        strcpy_P(menuopts[7], MASHHY);
        if (PIDEnabled[PIT_3]) strcpy_P(menuopts[8], PSTR("Pit 3 Mode: PID")); else strcpy_P(menuopts[8], PSTR("Pit 3 Mode: On/Off"));
        strcpy_P(menuopts[9], KETTLECYCLE);
        strcpy_P(menuopts[10], KETTLEGAIN);
        strcpy_P(menuopts[11], KETTLEHY);    
        strcpy_P(menuopts[12], EXIT);
    
        lastOption = scrollMenu("Configure Outputs", 13, lastOption);
        if (lastOption == 0) {
          if (PIDEnabled[PIT_1]) 
            setPIDEnabled(PIT_1, 0); 
          else
            setPIDEnabled(PIT_1, 1);
        }
        
        else if (lastOption == 1) {     
          setPIDCycle(PIT_1, getValue(HLTCYCLE, PIDCycle[PIT_1], 3, 1, 255, SEC));
          pid[PIT_1].SetOutputLimits(0, PIDCycle[PIT_1] * PIDLIMIT_PIT1);     
        } 
        
        else if (lastOption == 2) {
          setPIDGain("PIT 1 PID Gain", PIT_1);
        } 
        
        else if (lastOption == 3) setHysteresis(PIT_1, getValue(HLTHY, hysteresis[PIT_1], 3, 1, 255, TUNIT));
          
        else if (lastOption == 4) {
          if (PIDEnabled[PIT_2]) setPIDEnabled(PIT_2, 0);
          else setPIDEnabled(PIT_2, 1);
        }
        
        else if (lastOption == 5) {      
          setPIDCycle(PIT_2, getValue(MASHCYCLE, PIDCycle[PIT_2], 3, 1, 255, SEC));
          pid[PIT_2].SetOutputLimits(0, PIDCycle[PIT_2] * PIDLIMIT_PIT2);     
        } 
        
        else if (lastOption == 6) setPIDGain("Pit 2 PID Gain", PIT_2);
          
        else if (lastOption == 7) setHysteresis(PIT_2, getValue(MASHHY, hysteresis[PIT_2], 3, 1, 255, TUNIT));
        
        else if (lastOption == 8) {
          if (PIDEnabled[PIT_3]) 
            setPIDEnabled(PIT_3, 0);
          else
            setPIDEnabled(PIT_3, 1);
        }
        
        else if (lastOption == 9) {      
          setPIDCycle(PIT_3, getValue(KETTLECYCLE, PIDCycle[PIT_3], 3, 1, 255, SEC));
          pid[PIT_3].SetOutputLimits(0, PIDCycle[PIT_3] * PIDLIMIT_PIT3); 
        } 
        
        else if (lastOption == 10) setPIDGain("Pit 3 PID Gain", PIT_3);
        
        else if (lastOption == 11) setHysteresis(PIT_3, getValue(KETTLEHY, hysteresis[PIT_3], 3, 1, 255, TUNIT));    
        
        else return;
        
        smokeCore();
      } 
  }

  void setPIDGain(char sTitle[], byte smokerPit) {
      byte retP = pid[smokerPit].GetP_Param();
      byte retI = pid[smokerPit].GetI_Param();
      byte retD = pid[smokerPit].GetD_Param();
      byte cursorPos = 0; //0 = p, 1 = i, 2 = d, 3 = OK
      boolean cursorState = 0; //0 = Unselected, 1 = Selected
      Encoder.setMin(0);
      Encoder.setMax(3);
      Encoder.setCount(0);
    
      clearLCD();
      printLCD(0,0,sTitle);
      printLCD_P(1, 0, PSTR("P:     I:     D:    "));
      printLCD_P(3, 8, OK);
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
          } 
          else {
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
            setPIDp(smokerPit, retP);
            setPIDi(smokerPit, retI);
            setPIDd(smokerPit, retD);
            #ifdef DEBUG_PID_GAIN
              logDebugPIDGain(smokerPit);
            #endif
            break;
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
        } else if (Encoder.cancel()) break;
        smokeCore();
      }
      smokeCore();
  } 
  
//#endif
