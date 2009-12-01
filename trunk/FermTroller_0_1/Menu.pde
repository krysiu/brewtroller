byte scrollMenu(char sTitle[], byte numOpts, byte defOption) {
  //Uses Global menuopts[][20]
  encMin = 0;
  encMax = numOpts-1;
  
  encCount = defOption;
  byte lastCount = encCount + 1;
  byte topItem = numOpts;
  
  while(1) {
    if (encCount != lastCount) {
      lastCount = encCount;
      if (lastCount < topItem) {
        clearLCD();
        if (sTitle != NULL) printLCD(0, 0, sTitle);
        if (numOpts <= 3) topItem = 0;
        else topItem = lastCount;
        drawItems(numOpts, topItem);
      } else if (lastCount > topItem + 2) {
        clearLCD();
        if (sTitle != NULL) printLCD(0, 0, sTitle);
        topItem = lastCount - 2;
        drawItems(numOpts, topItem);
      }
      for (byte i = 1; i <= 3; i++) if (i == lastCount - topItem + 1) printLCD(i, 0, ">"); else printLCD(i, 0, " ");
    }
    
    if (chkMsg()) rejectMsg(LOGGLB);
    
    //If Enter
    if (enterStatus) {
      if (enterStatus == 1) {
        enterStatus = 0;
        return encCount;
      } else if (enterStatus == 2) {
        enterStatus = 0;
        return numOpts;
      }
    }
    fermCore();
  }
}

void drawItems(byte numOpts, byte topItem) {
  //Uses Global menuopts[][20]
  byte maxOpt = topItem + 2;
  if (maxOpt > numOpts - 1) maxOpt = numOpts - 1;
  for (byte i = topItem; i <= maxOpt; i++) printLCD(i-topItem+1, 1, menuopts[i]);
}

byte getChoice(byte numChoices, byte iRow) {
  //Uses Global menuopts[][20]
  //Force 18 Char Limit
  for (byte i = 0; i < numChoices; i++) menuopts[i][18] = '\0';
  printLCD_P(iRow, 0, PSTR(">"));
  printLCD_P(iRow, 19, PSTR("<"));
  encMin = 0;
  encMax = numChoices - 1;
 
  encCount = 0;
  byte lastCount = encCount + 1;

  while(1) {
    if (encCount != lastCount) {
      printLCDCenter(iRow, 1, menuopts[encCount], 18);
      lastCount = encCount;
    }
    
    if (chkMsg()) rejectMsg(LOGGLB);
    
    //If Enter
    if (enterStatus) {
      printLCD_P(iRow, 0, SPACE);
      printLCD_P(iRow, 19, SPACE);
      if (enterStatus == 1) {
        enterStatus = 0;
        return encCount;
      } else if (enterStatus == 2) {
        enterStatus = 0;
        return numChoices;
      }
    }
    fermCore();
  }
}

boolean confirmExit() {
  clearLCD();
  printLCD_P(0, 0, PSTR("Exiting will reset"));
  printLCD_P(1, 0, PSTR("outputs, setpoints"));
  printLCD_P(2, 0, PSTR("and timers."));
  strcpy_P(menuopts[0], CANCEL);
  strcpy_P(menuopts[1], EXIT);
  if(getChoice(2, 3) == 1) return 1; else return 0;
}

boolean confirmDel() {
  clearLCD();
  printLCD_P(1, 0, PSTR("Delete Item?"));
  
  strcpy_P(menuopts[0], CANCEL);
  strcpy_P(menuopts[1], PSTR("Delete"));
  if(getChoice(2, 3) == 1) return 1; else return 0;
}

unsigned long getValue(char sTitle[], unsigned long defValue, byte digits, byte precision, unsigned long maxValue, const char *dispUnit) {
  unsigned long retValue = defValue;
  byte cursorPos = 0; 
  boolean cursorState = 0; //0 = Unselected, 1 = Selected

  //Workaround for odd memory issue
  availableMemory();

  encMin = 0;
  encMax = digits;
  encCount = 0;
  byte lastCount = 1;

  lcdSetCustChar_P(0, CHARFIELD);
  lcdSetCustChar_P(1, CHARCURSOR);
  lcdSetCustChar_P(2, CHARSEL);
   
  clearLCD();
  printLCD(0, 0, sTitle);
  printLCD_P(1, (20 - digits + 1) / 2 + digits + 1, dispUnit);
  printLCD(3, 9, "OK");
  unsigned long whole, frac;
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        unsigned long factor = 1;
        for (byte i = 0; i < digits - cursorPos - 1; i++) factor *= 10;
        if (encCount > lastCount) retValue += (encCount-lastCount) * factor; else retValue -= (lastCount-encCount) * factor;
        lastCount = encCount;
        if (retValue > maxValue) retValue = maxValue;
      } else {
        lastCount = encCount;
        cursorPos = lastCount;
        for (byte i = (20 - digits + 1) / 2 - 1; i < (20 - digits + 1) / 2 - 1 + digits - precision; i++) lcdWriteCustChar(2, i, 0);
        if (precision) for (byte i = (20 - digits + 1) / 2 + digits - precision; i < (20 - digits + 1) / 2 + digits; i++) lcdWriteCustChar(2, i, 0);
        printLCD(3, 8, " ");
        printLCD(3, 11, " ");
        if (cursorPos == digits) {
          printLCD(3, 8, ">");
          printLCD(3, 11, "<");
        } else {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 1);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 1);
        }
      }
      lastCount = encCount;
      whole = retValue / pow(10, precision);
      frac = retValue - (whole * pow(10, precision)) ;
      printLCDLPad(1, (20 - digits + 1) / 2 - 1, ltoa(whole, buf, 10), digits - precision, ' ');
      if (precision) {
        printLCD(1, (20 - digits + 1) / 2 + digits - precision - 1, ".");
        printLCDLPad(1, (20 - digits + 1) / 2 + digits - precision, ltoa(frac, buf, 10), precision, '0');
      }
    }
    
    if (chkMsg()) rejectMsg(LOGGLB);

    if (enterStatus == 1) {
      enterStatus = 0;
      if (cursorPos == digits) break;
      else {
        cursorState = cursorState ^ 1;
        if (cursorState) {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 2);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 2);
          encMin = 0;
          encMax = 9;
          if (cursorPos < digits - precision) {
            ltoa(whole, buf, 10);
            if (cursorPos < digits - precision - strlen(buf)) encCount = 0; else  encCount = buf[cursorPos - (digits - precision - strlen(buf))] - '0';
          } else {
            ltoa(frac, buf, 10);
            if (cursorPos < digits - strlen(buf)) encCount = 0; else  encCount = buf[cursorPos - (digits - strlen(buf))] - '0';
          }
        } else {
          if (cursorPos < digits - precision) lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos - 1, 1);
          else lcdWriteCustChar(2, (20 - digits + 1) / 2 + cursorPos, 1);
          encMin = 0;
          encMax = digits;
          encCount = cursorPos;
        }
        lastCount = encCount;
      }
    } else if (enterStatus == 2) {
      enterStatus = 0;
      retValue = defValue;
      break;
    }
    fermCore();
  }
  return retValue;
}

