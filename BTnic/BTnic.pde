#define BUILD 354 
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

BrewLogger - SD Card Logger for BrewTroller
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

#include "WProgram.h"
#include <avr/pgmspace.h>
#include <microfat2.h>
#include <mmc.h>
#include <DevicePrint.h>

#define PIN_LEDRED 3
#define PIN_LEDGRN 4
#define PIN_SWITCH 2
#define SWITCH_INT 0

char buf[11];
boolean enterStatus;
DevicePrint dp;

void setup() {
  Serial.begin(9600);
  pinMode(PIN_LEDRED, OUTPUT);
  pinMode(PIN_LEDGRN, OUTPUT);
  pinMode(PIN_SWITCH, INPUT);
  attachInterrupt(SWITCH_INT, doEnter, CHANGE);
  //initSD();
}

void loop() {
  chkMsg();

}
