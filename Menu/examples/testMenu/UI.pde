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
#include <menu.h>

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

menu MainMenu;

//*****************************************************************************************************************************
// Begin UI Code
//*****************************************************************************************************************************

void testMenu() {
  Serial.println("Start");
  Serial.println(availableMemory());
  MainMenu.clear();
  for (byte i = 0; i < 11; i++) {
    strcpy(buf, "Item ");
    char strIndex[3];
    itoa(i, strIndex, 10);
    strcat(buf, strIndex);
    MainMenu.addItem(buf, i * 2);
  }
  MainMenu.setSelectedByValue(10);
  Serial.println("Ready");
  Serial.println(availableMemory());
  byte val = scrollMenu("Test Title", 3);
  clearLCD();
  printLCD(0, 0, itoa(val, buf, 10));
  delay(3000);
}


//**********************************************************************************
// uiInit:  One time intialization of all UI logic
//**********************************************************************************
void uiInit() {
  initLCD();
  Encoder.begin(ENCA_PIN, ENCB_PIN, ENTER_PIN, ENTER_INT, ENCODER_TYPE);
  //Create a main menu displayed as 3 rows of 19 char menu options
  MainMenu.begin(3, 19);
}

byte scrollMenu(char sTitle[], byte numOpts) {
  Encoder.setMin(0);
  Encoder.setMax(MainMenu.getItemCount() - 1);
  Encoder.setCount(MainMenu.getSelected());
  //Force refresh in case selected value was set
  MainMenu.refreshDisp();
  drawMenu(sTitle);
  
  while(1) {
    if (Encoder.getDelta()) {
      MainMenu.setSelected(Encoder.getCount());
      if (MainMenu.refreshDisp()) drawMenu(sTitle);
      for (byte i = 0; i < 3; i++) printLCD(i + 1, 0, " ");
      printLCD(MainMenu.getCursor() + 1, 0, ">");
    }
    
    //If Enter
    if (Encoder.ok()) {
      return MainMenu.getValue();
    } else if (Encoder.cancel()) {
      return numOpts;
    }
    brewCore();
  }
}

void drawMenu(char sTitle[]) {
  clearLCD();
  if (sTitle != NULL) printLCD(0, 0, sTitle);

  for (byte i = 0; i < 3; i++) {
    MainMenu.getRow(i, buf);
    printLCD(i + 1, 1, buf);
  }
  printLCD(MainMenu.getCursor() + 1, 0, ">");
}
#endif
