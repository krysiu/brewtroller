void logVolume (byte vessel, unsigned long value) {
  logStart_P(PSTR("DATA"));
  logField_P(PSTR("VOL"));
  logFieldI(vessel);
  ftoa(value/1000.0, buf, 3);
  logField(buf);
  logFieldI(unit);
  logEnd();
}

void logTemp (byte tempSensor, float value) {
  logStart_P(PSTR("DATA"));
  logField_P(PSTR("TEMP"));
  logFieldI(tempSensor);
  ftoa(value, buf, 3);
  logField(buf);
  logFieldI(unit);
  logEnd();
}

void logABStep (byte numstep) {
  logStart_P(LOGAB);
  logField_P(PSTR("STEP"));
  logFieldI(numstep);
  logEnd();
}

void logString_P (const char *sType, const char *sText) {
 logStart_P(sType);
 logField_P(sText);
 logEnd();
}

void logStart_P (const char *sType) {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
 Serial.print(millis(),DEC);
 Serial.print("\t");
 while (pgm_read_byte(sType) != 0) Serial.print(pgm_read_byte(sType++)); 
 Serial.print("\t");
#endif
}

void logEnd () {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
 Serial.println();
#endif
}

void logField (char sText[]) {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
  Serial.print(sText);
  Serial.print("\t");
#endif
}

void logFieldI (unsigned long value) {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
  Serial.print(value, DEC);
  Serial.print("\t");
#endif
}

void logField_P (const char *sText) {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
  while (pgm_read_byte(sText) != 0) Serial.print(pgm_read_byte(sText++));
  Serial.print("\t");
#endif
}

boolean chkMsg() {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
  if (!msgQueued) {
    while (Serial.available()) {
      byte byteIn = Serial.read();
      if (byteIn == '\r') { 
        msgQueued = 1;
        break;
      } else if (byteIn == '\t') {
        if (msgField < 20) {
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

void rejectMsg() {
  logStart_P(LOGCMD);
  logField_P(PSTR("UNKNOWN_CMD"));
  for (byte i = 0; i < msgField; i++) logField(msg[i]);
  logEnd();

  clearMsg();
}
