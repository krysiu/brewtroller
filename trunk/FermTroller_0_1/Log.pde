void(* softReset) (void) = 0;

void logPLR() {
  logStart_P(LOGGLB);
  logField_P(PSTR("PLR"));
  logFieldI(pwrRecovery);
  logEnd();
}

void logPgm() {
  logStart_P(LOGDATA);
  logField_P(PSTR("PGM"));
  logFieldI(pwrRecovery);
  logEnd();
}

void logString_P (const char *sType, const char *sText) {
 logStart_P(sType);
 logField_P(sText);
 logEnd();
}

void logStart_P (const char *sType) {
 Serial.print(millis(),DEC);
 Serial.print("\t");
 while (pgm_read_byte(sType) != 0) Serial.print(pgm_read_byte(sType++)); 
 Serial.print("\t");
}

void logEnd () {
 Serial.println();
}

void logField (char sText[]) {
  Serial.print(sText);
  Serial.print("\t");
}

void logFieldI (unsigned long value) {
  Serial.print(value, DEC);
  Serial.print("\t");
}

void logField_P (const char *sText) {
  while (pgm_read_byte(sText) != 0) Serial.print(pgm_read_byte(sText++));
  Serial.print("\t");
}

boolean chkMsg() {
  if (!msgQueued) {
    while (Serial.available()) {
      byte byteIn = Serial.read();
      if (byteIn == '\r') { 
        msgQueued = 1;
        //Check for Global Commands
        if       (strcasecmp(msg[0], "GET_TS") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 1 && val < 5) {
            logTSensor(val);
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_TS") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 9 && val < 5) {
            for (byte i=0; i<8; i++) tSensor[val][i] = (byte)atoi(msg[i+2]);
            saveSetup();
            clearMsg();
            logTSensor(val);
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "GET_OSET") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 1 && val < 4) {
            logOSet(val);
            clearMsg();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "SET_OSET") == 0) {
          byte val = atoi(msg[1]);
          if (msgField == 7 && val < 4) {
            PIDEnabled[val] = (byte)atoi(msg[2]);
            PIDCycle[val] = (byte)atoi(msg[3]);
            PIDp[val] = (byte)atoi(msg[4]);
            PIDi[val] = (byte)atoi(msg[5]);
            PIDd[val] = (byte)atoi(msg[6]);
            hysteresis[val] = (byte)atoi(msg[7]);
            saveSetup();
            clearMsg();
            logOSet(val);
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "GET_UNIT") == 0) {
          clearMsg();
          logStart_P(LOGGLB);
          logField_P(PSTR("UNIT"));
          #ifdef USEMETRIC
            logFieldI(0);
          #else
            logFieldI(1);
          #endif
          logEnd();
        } else if(strcasecmp(msg[0], "RESET") == 0) {
          if (msgField == 1 && strcasecmp(msg[1], "SURE") == 0) {
            clearMsg();
            logStart_P(LOGSYS);
            logField_P(PSTR("SOFT_RESET"));
            logEnd();
            softReset();
          }
        } else if(strcasecmp(msg[0], "GET_PLR") == 0) {
          clearMsg();
          logPLR();
        } else if(strcasecmp(msg[0], "SET_PLR") == 0) {
          byte PLR = atoi(msg[1]);
          if (msgField == 1 && PLR >= 0 && PLR <= 2) {
            setPwrRecovery(PLR);
            clearMsg();
            logPLR();
          } else rejectParam(LOGGLB);
        } else if(strcasecmp(msg[0], "PING") == 0) {
          clearMsg();
          logStart_P(LOGGLB);
          logField_P(PSTR("PONG"));
          logEnd();
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
  for (byte i = 0; i < msgField; i++) logField(msg[i]);
  logEnd();
  clearMsg();
}

void logTSensor(byte sensor) {
  logStart_P(LOGGLB);
  logField_P(PSTR("TS_ADDR"));
  logFieldI(sensor);
  for (byte i=0; i<8; i++) logFieldI(tSensor[sensor][i]);
  logEnd();
}

void logOSet(byte zone) {
  logStart_P(LOGGLB);
  logField_P(PSTR("OUTPUT_SET"));
  logFieldI(zone);
  logFieldI(PIDEnabled[zone]);
  logFieldI(PIDCycle[zone]);
  logFieldI(PIDp[zone]);
  logFieldI(PIDi[zone]);
  logFieldI(PIDd[zone]);
  logFieldI(hysteresis[zone]);
  logEnd();
}

