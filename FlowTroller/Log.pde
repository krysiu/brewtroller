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

void logInit() {
  #if defined USESERIAL
    Serial.begin(115200);
    Serial.println();
  #endif
  logStart_P(LOGSYS);
  logField_P(PSTR("VER"));
  logField_P(BTVER);
  logField(itoa(BUILD, buf, 10));
  logEnd();
}

void logString_P (const char *sType, const char *sText) {
 logStart_P(sType);
 logField_P(sText);
 logEnd();
}

void logStart_P (const char *sType) {
#if defined USESERIAL
 Serial.print(millis(),DEC);
 Serial.print("\t");
 while (pgm_read_byte(sType) != 0) Serial.print(pgm_read_byte(sType++)); 
 Serial.print("\t");
#endif
}

void logEnd () {
#if defined USESERIAL
 Serial.println();
#endif
}

void logField (char sText[]) {
#if defined USESERIAL
  Serial.print(sText);
  Serial.print("\t");
#endif
}

void logFieldI (unsigned long value) {
#if defined USESERIAL
  Serial.print(value, DEC);
  Serial.print("\t");
#endif
}

void logField_P (const char *sText) {
#if defined USESERIAL
  while (pgm_read_byte(sText) != 0) Serial.print(pgm_read_byte(sText++));
  Serial.print("\t");
#endif
}

boolean chkMsg() {
#if defined USESERIAL
  if (!msgQueued) {
    while (Serial.available()) {
      byte byteIn = Serial.read();
      if (byteIn == '\r') { 
        msgQueued = 1;
        //Configuration Class (CFG) Commands
        if(strcasecmp(msg[0], "GET_OSET") == 0) {
          logOSet();
          clearMsg();
        } else if(strcasecmp(msg[0], "GET_PROG") == 0) {
          byte program = atoi(msg[1]);
          if (msgField == 1 && program >= 0 && program < 20) {
            logProgram(program);
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "INIT_EEPROM") == 0) {
          clearMsg();
          initEEPROM();
        } else if(strcasecmp(msg[0], "SET_OSET") == 0) {
          if (msgField == 6) {
            setPIDEnabled((byte)atoi(msg[2]));
            setPIDCycle((byte)atoi(msg[2]));
            setPIDp((byte)atoi(msg[3]));
            setPIDi((byte)atoi(msg[4]));
            setPIDd((byte)atoi(msg[5]));
            setHysteresis((byte)atoi(msg[6]));
            clearMsg();
            logOSet();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_PROG") == 0) {
          byte program = atoi(msg[1]);
          if (msgField == (NUM_FLOW_STEPS * 2 + 2) && program >= 0 && program < 20) {
            setProgName(program, msg[2]);

            for (byte i = 0; i < NUM_FLOW_STEPS; i++) {
              setProgTemp(program, i, atoi(msg[i * 2 + 3]));
              setProgMins(program, i, atoi(msg[i * 2 + 4]));
            }

            clearMsg();
            logProgram(program);
          } else rejectParam(LOGGLB);

        //Data Class (DATA) Commands
        } else if(strcasecmp(msg[0], "ADV_STEP") == 0) {
          if (msgField == 1) {
            stepAdvance((byte)atoi(msg[1]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "EXIT_STEP") == 0) {
          if (msgField == 1) {
            stepExit((byte)atoi(msg[1]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "INIT_STEP") == 0) {
          if (msgField == 2) {
            stepInit((byte)atoi(msg[1]), (byte)atoi(msg[2]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_ALARM") == 0) {
          if (msgField == 1) {
            setAlarm((boolean)atoi(msg[1]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_SETPOINT") == 0) {
          if (msgField == 1) {
            setSetpoint((byte)atoi(msg[1]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_TIMERSTATUS") == 0) {
          if (msgField == 1) {
            setTimerStatus((boolean)atoi(msg[1]));
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_TIMERVALUE") == 0) {
          if (msgField == 1) {
            timerValue = strtoul(msg[1], NULL, 10);
            lastTime = millis();
            clearMsg();
          } else rejectParam(LOGGLB);

        //System Class (SYS) Commands
        } else if(strcasecmp(msg[0], "RESET") == 0) {
          byte level = atoi(msg[1]);
          if (msgField == 1 && level >= 0 && level <= 1) {
            clearMsg();
            if (level == 0) {
              resetOutputs();
              clearTimer();
            } else if (level == 1) {
              logStart_P(LOGSYS);
              logField_P(PSTR("SOFT_RESET"));
              logEnd();
              softReset();
            }
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_LOGSTATUS") == 0) {
          if (msgField == 1) {
            logData = (boolean)atoi(msg[1]);
            clearMsg();
          } else rejectParam(LOGGLB);

        //End of Commands
        }
        break;

      } else if (byteIn == '\t') {
        if (msgField < 25) {
          msgField++;
        } else {
          logString_P(LOGCMD, PSTR("MSG_OVERFLOW"));
          clearMsg();
        }
      } else {
        byte charCount = strlen(msg[msgField]);
        if (charCount < 20) { 
          msg[msgField][charCount] = byteIn; 
          msg[msgField][charCount + 1] = '\0';
        } else {
          logString_P(LOGCMD, PSTR("FIELD_OVERFLOW"));
          clearMsg();
        }
      }
    }
  }
  if (msgQueued) return 1; else return 0;
#endif
}

void clearMsg() {
  msgQueued = 0;
  msgField = 0;
  for (byte i = 0; i < 20; i++) msg[i][0] = '\0';
}

void rejectMsg(const char *handler) {
  logStart_P(LOGCMD);
  logField_P(PSTR("UNKNOWN_CMD"));
  logField_P(handler);
  for (byte i = 0; i < msgField; i++) logField(msg[i]);
  logEnd();
  clearMsg();
}

void rejectParam(const char *handler) {
  logStart_P(LOGCMD);
  logField_P(PSTR("BAD_PARAM"));
  logField_P(handler);
  for (byte i = 0; i <= msgField; i++) logField(msg[i]);
  logEnd();
  clearMsg();
}

void updateLog() {
  //Log data every 2s
  //Log 1 of 6 chunks per cycle to improve responsiveness to calling function
  if (logData) {
    if (millis() - lastLog > LOG_INTERVAL) {
      if (logCount == 0) {
        logStart_P(LOGDATA);
        logField_P(PSTR("STEPPRG"));
        logFieldI(actStep);
        logFieldI(actProgram);
        logEnd();
      } else if (logCount == 1) {
        logStart_P(LOGDATA);
        logField_P(PSTR("TIMER"));
        logFieldI(timerValue);
        logFieldI(timerStatus);
        logEnd();

        logStart_P(LOGDATA);
        logField_P(PSTR("ALARM"));
        logFieldI(alarmStatus);
        logEnd();
      } else if (logCount == 2) {
        logStart_P(LOGDATA);
        logField_P(PSTR("TEMP"));
        ftoa(temp, buf, 3);
        logField(buf);
        #ifdef USEMETRIC
          logFieldI(0);
        #else
          logFieldI(1);
        #endif
        logEnd();
      } else if (logCount == 3) {
        byte pct;
        if (PIDEnabled) pct = PIDOutput / PIDCycle / 10;
        else if (heatStatus) pct = 100;
        else pct = 0;
        logStart_P(LOGDATA);
        logField_P(PSTR("HEATPWR"));
        logFieldI(pct);
        logEnd();
      } else if (logCount == 4) {
        logStart_P(LOGDATA);
        logField_P(PSTR("SETPOINT"));
        ftoa(setpoint, buf, 0);
        logField(buf);
        #ifdef USEMETRIC
          logFieldI(0);
        #else
          logFieldI(1);
        #endif
        logEnd();

        //Logic below times start of log to start of log. Interval is reset if exceeds two intervals.
        if (millis() - lastLog > LOG_INTERVAL * 2) lastLog = millis(); else lastLog += LOG_INTERVAL;
      }
      logCount++;
      if (logCount > 4) logCount = 0;
    }
  }
  if (chkMsg()) rejectMsg(LOGGLB);
}

#if defined USESERIAL

void logOSet() {
  logStart_P(LOGGLB);
  logField_P(PSTR("OUTPUT_SET"));
  logFieldI(PIDEnabled);
  logFieldI(PIDCycle);
  logFieldI(getPIDp());
  logFieldI(getPIDi());
  logFieldI(getPIDd());
  logFieldI(hysteresis);
  logEnd();
}

void logProgram(byte program) {
  logStart_P(LOGGLB);
  logField_P(PSTR("PROG_SET"));
  logFieldI(program);
  getProgName(program, buf);
  logField(buf);
  
  for (byte i = 0; i < NUM_FLOW_STEPS; i++) {
    logFieldI(getProgTemp(program, i));
    logFieldI(getProgMins(program, i));
  }
  logEnd();
}

#endif
