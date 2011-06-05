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

void ftoa(float val, char retStr[], byte precision) {
  char lbuf[11];
  itoa(val, retStr, 10);  
  if(val < 0) val = -val;
  if( precision > 0) {
    strcat(retStr, ".");
    unsigned int mult = 1;
    for(byte i = 0; i< precision; i++) mult *=10;
    unsigned int frac = (val - int(val)) * mult;
    itoa(frac, lbuf, 10);
    for(byte i = 0; i < precision - (int)strlen(lbuf); i++) strcat(retStr, "0");
    strcat(retStr, lbuf);
  }
}

//Truncate a string representation of a float to (length) chars but do not end string with a decimal point
void truncFloat(char string[], byte length) {
  if (strlen(string) > length) {
    if (string[length - 1] == '.') string[length - 1] = '\0';
    else string[length] = '\0';
  }
}

int availableMemory() {
  int size = 4096;
  byte *buf;
  while ((buf = (byte *) malloc(--size)) == NULL);
  free(buf);
  return size;
}

void setTimer(unsigned int minutes) {
  timerValue = minutes * 60000;
  lastTime = millis();
  timerStatus = 1;
}

void pauseTimer() {
  if (timerStatus) {
    //Pause
    timerStatus = 0;
  } else {
    //Unpause
    timerStatus = 1;
    lastTime = millis();
    timerLastWrite = 0;
  }
}

void clearTimer() {
  timerValue = 0;
  timerStatus = 0;
}

void printTimer(byte iRow, byte iCol) {
  if (alarmStatus || timerValue > 0) {
    if (timerStatus) {
      unsigned long now = millis();
      if (timerValue > now - lastTime) {
        timerValue -= now - lastTime;
      } else {
        timerValue = 0;
        timerStatus = 0;
        setAlarm(1);
        printLCD(iRow, iCol + 5, "!");
      }
      lastTime = now;
    } else if (!alarmStatus) printLCD(iRow, iCol, "PAUSED");

    unsigned int timerHours = timerValue / 3600000;
    unsigned int timerMins = (timerValue - timerHours * 3600000) / 60000;
    unsigned int timerSecs = (timerValue - timerHours * 3600000 - timerMins * 60000) / 1000;

    //Update EEPROM once per minute
    if (timerLastWrite/60 != timerValue/60000) setTimerRecovery(timerValue/60000 + 1);
    //Update LCD once per second
    if (timerLastWrite != timerValue/1000) {
      printLCDRPad(iRow, iCol, "", 6, ' ');
      printLCD_P(iRow, iCol+2, PSTR(":"));
      if (timerHours > 0) {
        printLCDLPad(iRow, iCol, itoa(timerHours, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol + 3, itoa(timerMins, buf, 10), 2, '0');
      } else {
        printLCDLPad(iRow, iCol, itoa(timerMins, buf, 10), 2, '0');
        printLCDLPad(iRow, iCol+ 3, itoa(timerSecs, buf, 10), 2, '0');
      }
      timerLastWrite = timerValue/1000;
    }
  } else printLCDRPad(iRow, iCol, "", 6, ' ');
}

void setAlarm(boolean value) {
  alarmStatus = value;
  digitalWrite(ALARM_PIN, value);
}
