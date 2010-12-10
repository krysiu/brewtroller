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


//*****************************************************************************************************************************
// Special thanks to Jason von Nieda (vonnieda) for the design and code for this cool add-on to BrewTroller.
//*****************************************************************************************************************************


#ifdef BTPD_SUPPORT
#include "Config.h"
#include "Enum.h"
#include <Wire.h>

unsigned long lastBTPD;

void btpdInit() {
  Wire.begin();
}

void updateBTPD() {
  if (millis() - lastBTPD > BTPD_INTERVAL) {
    #ifdef BTPD_ZONE1
      sendVsTemp(BTPD_ZONE1, 0);
    #endif
    #ifdef BTPD_ZONE2
      sendVsTemp(BTPD_ZONE2, 1);
    #endif
    #ifdef BTPD_ZONE3
      sendVsTemp(BTPD_ZONE3, 2);
    #endif
    #ifdef BTPD_ZONE4
      sendVsTemp(BTPD_ZONE4, 3);
    #endif
    #ifdef BTPD_ZONE5
      sendVsTemp(BTPD_ZONE5, 4);
    #endif
    #ifdef BTPD_ZONE6
      sendVsTemp(BTPD_ZONE6, 5);
    #endif
    #ifdef BTPD_ZONE7
      sendVsTemp(BTPD_ZONE7, 6);
    #endif
    #ifdef BTPD_ZONE8
      sendVsTemp(BTPD_ZONE8, 7);
    #endif
    lastBTPD = millis();
  }
}

void sendVsTemp(byte chan, byte vessel) {
  sendFloatsBTPD(chan, setpoint[vessel] / 100.0, temp[vessel] / 100.0);  
}

void sendFloatsBTPD(byte chan, float line1, float line2) {
  Wire.beginTransmission(chan);
  Wire.send(0xff);
  Wire.send(0x00);
  Wire.send((uint8_t *) &line1, 4);
  Wire.send((uint8_t *) &line2, 4);
  Wire.endTransmission();
}


#endif
