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

#include "Config.h"

byte lastEEPROMWrite;

void setTimer(unsigned int tenthMins) {
  timerValue = tenthMins * 6000;
  lastTime = millis();
  timerStatus = 1;
  setTimerRecovery(tenthMins);
}

void pauseTimer() {
  if (timerStatus) {
    //Pause
    timerStatus = 0;
  } else {
    //Unpause
    timerStatus = 1;
    lastTime = millis();
  }
}

void clearTimer() {
  setTimerStatus(0);
  setTimerRecovery(0);
  timerValue = 0;
}

void updateTimers() {
  if (timerStatus) {
    unsigned long now = millis();
    if (timerValue > now - lastTime) {
      timerValue -= now - lastTime;
    } else {
      setTimerStatus(0);
      setTimerRecovery(0);
      timerValue = 0;
      setAlarm(1);
    }
    lastTime = now;
  }

  byte timerHours = timerValue / 3600000;
  byte timerMins = (timerValue - timerHours * 3600000) / 60000;

  //Update EEPROM once per minute
  if (timerMins != lastEEPROMWrite) {
    lastEEPROMWrite = timerMins;
    setTimerRecovery(min(timerValue/6000 + 10, 255));
  }
}

