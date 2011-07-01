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

#include "Config.h"
#include "Enum.h"

void eventHandler(byte eventID, int eventParam) {
  //Global Event handler
  if (eventID == EVENT_ALARM_TSENSOR) {
    if (millis() < ALARM_BOOTUP_DELAY) return;
    if (!bitRead(alarmStatus[eventParam], ALARM_STATUS_TSENSOR)) {
      bitSet(alarmStatus[eventParam], ALARM_ACK_TSENSOR);
      bitSet(alarmStatus[eventParam], ALARM_STATUS_TSENSOR);
      saveAlarmStatus(eventParam);
    } else bitSet(alarmStatus[eventParam], ALARM_STATUS_TSENSOR);
  }
  else if (eventID == EVENT_ALARM_TEMPHOT) {
    if (millis() < ALARM_BOOTUP_DELAY) return;
    if (!bitRead(alarmStatus[eventParam], ALARM_STATUS_TEMPHOT)) {
      bitSet(alarmStatus[eventParam], ALARM_ACK_TEMPHOT);
      bitSet(alarmStatus[eventParam], ALARM_STATUS_TEMPHOT);
      saveAlarmStatus(eventParam);
    } else bitSet(alarmStatus[eventParam], ALARM_STATUS_TEMPHOT);
  }
  else if (eventID == EVENT_ALARM_TEMPCOLD) {
    if (millis() < ALARM_BOOTUP_DELAY) return;
    if (!bitRead(alarmStatus[eventParam], ALARM_STATUS_TEMPCOLD)) {
      bitSet(alarmStatus[eventParam], ALARM_ACK_TEMPCOLD);
      bitSet(alarmStatus[eventParam], ALARM_STATUS_TEMPCOLD);
      saveAlarmStatus(eventParam);
    } else bitSet(alarmStatus[eventParam], ALARM_STATUS_TEMPCOLD);
  }
  else if (eventID == EVENT_NALARM_TSENSOR) bitClear(alarmStatus[eventParam], ALARM_STATUS_TSENSOR);
  else if (eventID == EVENT_NALARM_TEMPHOT) bitClear(alarmStatus[eventParam], ALARM_STATUS_TEMPHOT);  
  else if (eventID == EVENT_NALARM_TEMPCOLD) bitClear(alarmStatus[eventParam], ALARM_STATUS_TEMPCOLD);  
  
  #ifndef NOUI
  //Pass Event Info to UI Event Handler
  uiEvent(eventID, eventParam);
  //Pass Event Info to Com Event Handler
  comEvent(eventID, eventParam);
#endif
}
