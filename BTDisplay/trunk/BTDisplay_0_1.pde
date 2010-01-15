#define BUILD 321 
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

BTDisplay - Auxillary LCD Display for BrewTroller
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

// Supported LCD Displays (Use only 1)
//
#define DISPLAY_20x4
//#define DISPLAY_16x2

#include <avr/pgmspace.h>

char buf[11];
char msg[25][21];
byte msgField = 0;

void setup() {
  //Mode Jumpers
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  Serial.begin(9600);
  initLCD();  
  initBigFont();
}

void loop() {
  clearLCD();
  printLCD_BigFont(0, 0, "12345");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "67890");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "97.2C");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "152.6F");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "24.3L");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "12.4G");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "1:25");
  delay(3000);

  chkMsg();
}

