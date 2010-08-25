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

char msg[25][21];
byte msgField = 0;

void chkMsg() {
  while (Serial.available()) {
    byte byteIn = Serial.read();
    if (byteIn == '\r' || byteIn == '\n') {

      //Check for Global Commands
      if (strcasecmp(msg[1], "DATA") == 0 && strcasecmp(msg[2], "PGM") == 0) {
      }
      clearMsg();
    } else if (byteIn == '\t') {
      if (msgField < 25) {
        msgField++;
      } else {
        //Message Overflow
        clearMsg();
      }
    } else {
      byte charCount = strlen(msg[msgField]);
      if (charCount < 20) { 
        msg[msgField][charCount] = byteIn; 
        msg[msgField][charCount + 1] = '\0';
      } else {
        //Field Overflow
        clearMsg();
      }
    }
  }
}

void clearMsg() {
  msgField = 0;
  for (byte i = 0; i < 20; i++) msg[i][0] = '\0';
}
