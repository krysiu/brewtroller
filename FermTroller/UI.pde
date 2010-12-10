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

#ifdef ENCODER_CUI
#define ENTER_BOUNCE_DELAY 50
#endif

#ifdef ENCODER_ALPS
#define ENTER_BOUNCE_DELAY 30
#endif

volatile unsigned long lastEncUpd = millis();
unsigned long enterStart;

void doEncoderALPS() {
  if (digitalRead(2) != digitalRead(4)) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 
void doEncoderCUI() {
  if (millis() - lastEncUpd < 50) return;
  //Read EncB
  if (digitalRead(4) == LOW) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 

void doEnter() {
  if (digitalRead(11) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else if (millis() - enterStart > ENTER_BOUNCE_DELAY) {
      enterStatus = 1;
    }
  }
}

void uiInit() {
  initLCD();
  
  //Encoder Setup
  #ifdef ENCODER_ALPS
    attachInterrupt(2, doEncoderALPS, CHANGE);
  #endif
  #ifdef ENCODER_CUI
    attachInterrupt(2, doEncoderCUI, RISING);
  #endif
  attachInterrupt(1, doEnter, CHANGE);
}

void doMon() {
  encMin = 0;
  encMax = NUM_ZONES;
  encCount = 0;
  byte lastCount = 1;
  setPwrRecovery(1);
  
  while (1) {
    if (enterStatus == 2) {
      enterStatus = 0;
      if (confirmExit()) {
          resetOutputs();
          setPwrRecovery(0); 
          return;
      } else {
        encCount = lastCount;
        lastCount += 1;
      }
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (alarmStatus) {
        setAlarm(0);
      } else {
        //Pop-Up Menu
        byte pos = 0;
        if (lastCount > 0) {
          strcpy_P(menuopts[pos++], PSTR("Adjust Set Point"));
          strcpy_P(menuopts[pos++], PSTR("Clear Set Point"));
        }
        strcpy_P(menuopts[pos++], PSTR("Close Menu"));
        strcpy_P(menuopts[pos++], PSTR("Quit"));

        boolean inMenu = 1;
        byte lastOption = 0;
        while(inMenu) {
          lastOption = scrollMenu("Ferm Monitor Menu", pos, lastOption);
          if (pos == 2) lastOption += 2;
          if (lastOption == 0) {
            setpoint[lastCount - 1] = getValue("Enter New Temp:", setpoint[lastCount - 1] / 100, 3, 0, 255, TUNIT) * 100;
            inMenu = 0;
          } else if (lastOption == 1) {
            setpoint[lastCount - 1] = 0;
            inMenu = 0;
          } else if (lastOption == 2) inMenu = 0;
          else if (lastOption == 3) {
            if (confirmExit()) {
              resetOutputs();
              setPwrRecovery(0);
              return;
            } else break;
          }
          saveSetpoints();
        }
        encMin = 0;
        encMax = NUM_ZONES;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    
    if (chkMsg()) rejectMsg(LOGGLB);
    fermCore();
    
    if (encCount == 0) {
      //Summary Screen: Display up to the first six zones (or less based on NUM_ZONES)
      if (encCount != lastCount) {
        lastCount = encCount;
        clearLCD();
        printLCD_P(0, 4, PSTR("Ambient:"));
        printLCD_P(0, 16, TUNIT);

        if (NUM_ZONES > 0) {
          printLCD(1, 0, "1>");
          printLCD_P(1, 5, TUNIT);
          printLCD(1, 6, "[");
          printLCD(1, 8, "]");
        }
        if (NUM_ZONES > 1) {
          printLCD(2, 0, "2>");
          printLCD_P(2, 5, TUNIT);
          printLCD(2, 6, "[");
          printLCD(2, 8, "]");
        }
        if (NUM_ZONES > 2) {
          printLCD(3, 0, "3>");
          printLCD_P(3, 5, TUNIT);
          printLCD(3, 6, "[");
          printLCD(3, 8, "]");
        }
        if (NUM_ZONES > 3) {
          printLCD(1, 11, "4>");
          printLCD_P(1, 16, TUNIT);
          printLCD(1, 17, "[");
          printLCD(1, 19, "]");
        }
        if (NUM_ZONES > 4) {
          printLCD(2, 11, "5>");
          printLCD_P(2, 16, TUNIT);
          printLCD(2, 17, "[");
          printLCD(2, 19, "]");
        }
        if (NUM_ZONES > 5) {
          printLCD(3, 11, "6>");
          printLCD_P(3, 16, TUNIT);
          printLCD(3, 17, "[");
          printLCD(3, 19, "]");
        }
        timerLastWrite = 0;
      }

      for (byte i = 0; i < NUM_ZONES + 1; i++) {
        if (temp[i] == -32768) strcpy_P(menuopts[i], PSTR("---"));
        else { 
          itoa(temp[i] / 100, buf, 10); 
          strcpy(menuopts[i], buf); 
        } 
      }
      
      printLCDLPad(0, 13, menuopts[NUM_ZONES], 3, ' ');

      if (NUM_ZONES > 0) printLCDLPad(1,  2, menuopts[0], 3, ' ');
      if (NUM_ZONES > 1) printLCDLPad(2,  2, menuopts[1], 3, ' ');
      if (NUM_ZONES > 2) printLCDLPad(3,  2, menuopts[2], 3, ' ');
      if (NUM_ZONES > 3) printLCDLPad(1, 13, menuopts[3], 3, ' ');
      if (NUM_ZONES > 4) printLCDLPad(2, 13, menuopts[4], 3, ' ');
      if (NUM_ZONES > 5) printLCDLPad(3, 13, menuopts[5], 3, ' ');
      
      for (byte i = 0; i < 6; i++) {
        if (coolStatus[i]) strcpy_P(menuopts[i], PSTR("C"));
        else if ((PIDEnabled[i] && PIDOutput[i] > 0) || heatStatus[i]) strcpy_P(menuopts[i], PSTR("H"));
        else strcpy_P(menuopts[i], PSTR(" "));
      }
      
      if (NUM_ZONES > 0) printLCD(1,  7, menuopts[0]);
      if (NUM_ZONES > 1) printLCD(2,  7, menuopts[1]);
      if (NUM_ZONES > 2) printLCD(3,  7, menuopts[2]);
      if (NUM_ZONES > 3) printLCD(1, 18, menuopts[3]);
      if (NUM_ZONES > 4) printLCD(2, 18, menuopts[4]);
      if (NUM_ZONES > 5) printLCD(3, 18, menuopts[5]);

    } else {
      //Zone 1 - 6 Detail
      if (encCount != lastCount) {
        lastCount = encCount;
        clearLCD();
        printLCD_P(0, 7, PSTR("Zone"));
        printLCD(0, 12, itoa(lastCount, buf, 10));
        printLCD_P(1, 0, PSTR("Current Temp:"));        
        printLCD_P(1, 17, TUNIT);
        printLCD_P(2, 0,PSTR("Set Point:"));
        printLCD_P(2, 17, TUNIT);
        printLCD_P(3, 0,PSTR("Output:"));
        timerLastWrite = 0;
      }

      if (temp[lastCount - 1] == -32768) printLCD_P(1, 14, PSTR("---")); else printLCDLPad(1, 14, itoa(temp[lastCount - 1] / 100, buf, 10), 3, ' ');
      printLCDLPad(2, 14, itoa(setpoint[lastCount - 1] / 100, buf, 10), 3, ' ');
      if (PIDEnabled[lastCount - 1]) {
        byte pct = PIDOutput[lastCount - 1] / PIDCycle[lastCount - 1] / 10;
        if (pct == 0) strcpy_P(buf, PSTR("Off"));
        else if (pct == 100) strcpy_P(buf, PSTR("Heat On"));
        else {
          strcpy_P(buf, PSTR("Heat "));
          itoa(pct, buf, 10);
          strcat(buf, "%");
        }
      } else if (heatStatus[lastCount - 1]) strcpy_P(buf, PSTR("Heat On")); else strcpy_P(buf, PSTR("Off"));
      if (coolStatus[lastCount - 1]) strcpy_P(buf, PSTR("Cool On"));
      printLCDRPad(3, 8, buf, 7, ' ');
    }
  }
}

void menuSetup() {
  byte lastOption = 0;
  while(1) {
    strcpy_P(menuopts[0], PSTR("Assign Temp Sensor"));
    strcpy_P(menuopts[1], PSTR("Configure Outputs"));
    strcpy_P(menuopts[2], INIT_EEPROM);
    strcpy_P(menuopts[3], PSTR("Exit Setup"));
    
    lastOption = scrollMenu("System Setup", 4, lastOption);
    if (lastOption == 0) assignSensor();
    else if (lastOption == 1) cfgOutputs();
    else if (lastOption == 2) {
      clearLCD();
      printLCD_P(0, 0, PSTR("Reset Configuration?"));
      strcpy_P(menuopts[0], INIT_EEPROM);
        strcpy_P(menuopts[1], CANCEL);
        if (getChoice(2, 3) == 0) {
          EEPROM.write(2047, 0);
          checkConfig();
          loadSetup();
        }
    } else return;
    saveSetup();
  }
}

void assignSensor() {
  encMin = 0;
  encMax = NUM_ZONES;
  encCount = 0;
  byte lastCount = 1;
  
  char dispTitle[NUM_ZONES + 1][21];
  for (byte i = 0; i < NUM_ZONES; i++) {
    strcpy_P(dispTitle[i], PSTR("Zone "));
    strcat(dispTitle[i], itoa(i + 1, buf, 10));
  }
  strcpy_P(dispTitle[NUM_ZONES], PSTR("Ambient"));
  
  while (1) {
    if (encCount != lastCount) {
      lastCount = encCount;
      clearLCD();
      printLCD_P(0, 0, PSTR("Assign Temp Sensor"));
      printLCDCenter(1, 0, dispTitle[lastCount], 20);
      for (byte i=0; i<8; i++) printLCDLPad(2,i*2+2,itoa(tSensor[lastCount][i], buf, 16), 2, '0');  
    }
    if (enterStatus == 2) {
      enterStatus = 0;
      return;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      //Pop-Up Menu
      strcpy_P(menuopts[0], PSTR("Scan Bus"));
      strcpy_P(menuopts[1], PSTR("Delete Address"));
      strcpy_P(menuopts[2], PSTR("Close Menu"));
      strcpy_P(menuopts[3], PSTR("Exit"));
      byte selected = scrollMenu(dispTitle[lastCount], 4, 0);
      if (selected == 0) {
        clearLCD();
        printLCDCenter(0, 0, dispTitle[lastCount], 20);
        printLCD_P(1,0,PSTR("Disconnect all other"));
        printLCD_P(2,2,PSTR("temp sensors now"));
        {
          strcpy_P(menuopts[0], PSTR("Continue"));
          strcpy_P(menuopts[1], CANCEL);
          if (getChoice(2, 3) == 0) getDSAddr(tSensor[lastCount]);
        }
      } else if (selected == 1) for (byte i = 0; i <8; i++) tSensor[lastCount][i] = 0;
      else if (selected > 2) return;
      saveSetup();
      encMin = 0;
      encMax = NUM_ZONES;
      encCount = lastCount;
      lastCount += 1;
    }
  }
}

void cfgOutputs() {
  byte lastOption = 0;
  while(1) {
    if (NUM_PID_OUTS > 0) {
      for (byte i = 0; i < NUM_PID_OUTS; i++) {
        for (byte j = 0; j < 4; j++) {
          strcpy_P(menuopts[i * 4 + j], PSTR("Zone "));
          strcat(menuopts[i * 4 + j], itoa(i + 1, buf, 10));
        }
        strcat_P(menuopts[i * 4], PSTR(" Mode: "));
        if (PIDEnabled[i]) strcat_P(menuopts[i * 4], PSTR("PID")); 
          else strcat_P(menuopts[i * 4], PSTR("On/Off"));
        strcat_P(menuopts[i * 4 + 1], PSTR(" PID Cycle"));
        strcat_P(menuopts[i * 4 + 2], PSTR(" PID Gain"));
        strcat_P(menuopts[i * 4 + 3], PSTR(" Hysteresis"));
      }
    }
    if (NUM_ZONES - NUM_PID_OUTS > 0) {
      for (byte i = NUM_PID_OUTS; i < NUM_ZONES; i++) {
        strcpy_P(menuopts[NUM_PID_OUTS * 3 + i], PSTR("Zone "));
        strcat(menuopts[NUM_PID_OUTS * 3 + i], itoa(i + 1, buf, 10));
        strcat_P(menuopts[NUM_PID_OUTS * 3 + i], PSTR(" Hysteresis"));
      }
    }
    strcpy_P(menuopts[NUM_PID_OUTS * 3 + NUM_ZONES], PSTR("Exit"));
    lastOption = scrollMenu("Configure Outputs", NUM_PID_OUTS * 3 + NUM_ZONES + 1, lastOption);
    byte zone;
    char strZone[2];
    if (lastOption < NUM_PID_OUTS * 4) zone = lastOption / 4;
      else zone = (lastOption - NUM_PID_OUTS * 3);
    itoa(zone + 1, strZone, 10);
    if (lastOption >= NUM_PID_OUTS * 3 + NUM_ZONES) return;
    else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 == lastOption) PIDEnabled[zone] = PIDEnabled[zone] ^ 1;
    else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 + 1 == lastOption) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" Cycle Time"));
      PIDCycle[zone] = getValue(buf, PIDCycle[zone], 3, 0, 255, PSTR("s"));
      pid[zone].SetOutputLimits(0, PIDCycle[zone] * 1000);
    } else if (zone < NUM_PID_OUTS && lastOption / 4 * 4 + 2 == lastOption) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" PID Gain"));
      setPIDGain(buf, &PIDp[zone], &PIDi[zone], &PIDd[zone]);
      pid[zone].SetTunings(PIDp[zone], PIDi[zone], PIDd[zone]);
    } else if ((zone < NUM_PID_OUTS && lastOption / 4 * 4 + 3 == lastOption) || zone >= NUM_PID_OUTS) {
      strcpy_P(buf, PSTR("Zone "));
      strcat(buf, strZone);
      strcat_P(buf, PSTR(" Hysteresis"));
      hysteresis[zone] = getValue(buf, hysteresis[zone], 3, 1, 255, TUNIT);
    }
  } 
}

void setPIDGain(char sTitle[], byte* p, byte* i, byte* d) {
  byte retP = *p;
  byte retI = *i;
  byte retD = *d;
  byte cursorPos = 0; //0 = p, 1 = i, 2 = d, 3 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  encMin = 0;
  encMax = 3;
  encCount = 0;
  byte lastCount = 1;
  
  clearLCD();
  printLCD(0,0,sTitle);
  printLCD_P(1, 0, PSTR("P:     I:     D:    "));
  printLCD_P(3, 8, PSTR("OK"));
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        if (cursorPos == 0) retP = encCount;
        else if (cursorPos == 1) retI = encCount;
        else if (cursorPos == 2) retD = encCount;
      } else {
        cursorPos = encCount;
        if (cursorPos == 0) {
          printLCD_P(1, 2, PSTR(">"));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 1) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(">"));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 2) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(">"));
          printLCD_P(3, 7, PSTR(" "));
          printLCD_P(3, 10, PSTR(" "));
        } else if (cursorPos == 3) {
          printLCD_P(1, 2, PSTR(" "));
          printLCD_P(1, 9, PSTR(" "));
          printLCD_P(1, 16, PSTR(" "));
          printLCD_P(3, 7, PSTR(">"));
          printLCD_P(3, 10, PSTR("<"));
        }
      }
      printLCDLPad(1, 3, itoa(retP, buf, 10), 3, ' ');
      printLCDLPad(1, 10, itoa(retI, buf, 10), 3, ' ');
      printLCDLPad(1, 17, itoa(retD, buf, 10), 3, ' ');
      lastCount = encCount;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (cursorPos == 3) {
        *p = retP;
        *i = retI;
        *d = retD;
        return;
      }
      cursorState = cursorState ^ 1;
      if (cursorState) {
        encMin = 0;
        encMax = 255;
        if (cursorPos == 0) encCount = retP;
        else if (cursorPos == 1) encCount = retI;
        else if (cursorPos == 2) encCount = retD;
      } else {
        encMin = 0;
        encMax = 3;
        encCount = cursorPos;
      }
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return;
    }
  }
}

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
