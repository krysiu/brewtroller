void chkMsg() {
  while (Serial.available()) {
    byte byteIn = Serial.read();
    if (byteIn == '\r' || byteIn == '\n') {
      //Read Jumpers and Set Mode
      
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
