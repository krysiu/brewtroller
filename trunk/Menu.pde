void menuMain()
{
  char mainMenu[3][20] = {
    "AutoBrew          ",
    "Brew Monitor      ",
    "System Setup      "
  };
  while(1) {
    switch (scrollMenu("BrewTroller         ", mainMenu, 3)) {
      case 0:
        doAutoBrew();
        break;
      case 1:
        doMon();
        break;
      case 2:
        menuSetup();
        break;
      default:
        return;
    }
  }
}

void menuSetup()
{
  char setupMenu[6][20] = {
    "Assign Temp Sensor ",
    "Set Temp Unit (C/F)",
    "Set Output Type    ",
    "Save Settings      ",
    "Load Settings      ",
    "Exit Setup         "
  };
  while(1) {
    switch(scrollMenu("System Setup        ", setupMenu, 6)) {
      case 0:
        assignSensor();
        break;
      case 1:
        setTempUnit();
        break;
      case 2:
        setPID();
        break;
      case 3:
        saveSetup();
        break;
      case 4:
        loadSetup();
        break;
      default:
        return;
    }
  }
}

int scrollMenu(char sTitle[], char menuItems[][20], int numOpts) {
  clearLCD();
  if (sTitle != NULL) printLCD(0, 0, sTitle);

  encMin = 0;
  encMax = numOpts-1;
  
  encCount = 0;
  int lastCount = 1;
  unsigned int topItem = 1;

  while(1) {
    if (encCount != lastCount) {
      if (encCount < topItem) {
        topItem = encCount;
        drawItems(menuItems, numOpts, topItem);
      } else if (encCount > topItem + 2) {
        topItem = encCount - 2;
        drawItems(menuItems, numOpts, topItem);
      }
      menuSetCursor(encCount-topItem+1);
      lastCount = encCount;
    }
    
    //If Enter
    if (enterStatus == 1) {
      enterStatus = 0;
      return encCount;
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return numOpts;
    }
  }
}

void menuSetCursor(int iPos) {
  for (int i=1; i<=3; i++) {
    if (i == iPos) printLCD(i, 0, ">"); else printLCD(i, 0, " ");
  }
}

void drawItems(char menuItems[][20], int numOpts, int topItem) {
  int maxOpt = topItem + 2;
  if (maxOpt > numOpts) maxOpt = numOpts;
  for (int i = topItem; i <= maxOpt; i++) printLCD(i-topItem+1, 1, menuItems[i]);
}

int getChoice(char choices[][19], int numChoices, int iRow, int defValue = 0) {
  printLCD(iRow, 0, ">                  <");

  encMin = 0;
  encMax = numChoices-1;
 
  encCount = defValue;
  int lastCount = encCount+1;

  while(1) {
    if (encCount != lastCount) {
      printLCD(iRow, 1, choices[encCount]);
      lastCount = encCount;
    }
    
    //If Enter
    if (enterStatus == 1) {
      enterStatus = 0;
      printLCD(iRow, 0, " ");
      printLCD(iRow, 19, " ");
      return encCount;
    } else if (enterStatus == 2) {
      enterStatus = 0;
      printLCD(iRow, 0, " ");
      printLCD(iRow, 19, " ");
      return NULL;
    }
  }
}

unsigned int getTimerValue(char sTitle[], unsigned int defMins = 0) {
  unsigned int hours = defMins / 60;
  unsigned int mins = defMins - hours * 60;
  byte cursorPos = 0; //0 = Hours, 1 = Mins, 2 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  encMin = 0;
  encMax = 2;
  encCount = 0;
  int lastCount = 1;
  char buf[3];
  
  clearLCD();
  printLCD(0,0,sTitle);
  printLCD(1, 9, ":");
  printLCD(1, 13, "(hh:mm)");
  printLCD(3, 8, "OK");
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        if (cursorPos) mins = encCount; else hours = encCount;
      } else {
        cursorPos = encCount;
        switch (cursorPos) {
          case 0:
            printLCD(1, 6, ">");
            printLCD(1, 12, " ");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 1:
            printLCD(1, 6, " ");
            printLCD(1, 12, "<");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 2:
            printLCD(1, 6, " ");
            printLCD(1, 12, " ");
            printLCD(3, 7, ">");
            printLCD(3, 10, "<");
            break;
        }
      }
      printLCDPad(1, 7, itoa(hours, buf, 10), 2, '0');
      printLCDPad(1, 10, itoa(mins, buf, 10), 2, '0');
      lastCount = encCount;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (cursorPos == 2) return hours * 60 + mins;
      cursorState = cursorState ^ 1;
      if (cursorState) {
        encMin = 0;
        encMax = 99;
        if (cursorPos)encCount = mins; else encCount = hours;
      } else {
        encMin = 0;
        encMax = 2;
        encCount = cursorPos;
      }
    } else if (enterStatus == 2) {
      enterStatus = 0;
      return NULL;
    }
  }
}

int getTempValue(char sTitle[], int defTemp, boolean defUnit, boolean dispOff = 0) {
  if (defUnit == TEMPC && tempUnit == TEMPF) defTemp = defTemp * 9 / 5 + 32;
  if (defUnit == TEMPF && tempUnit == TEMPC) defTemp = (defTemp - 32) * 5 / 9;
  
  byte cursorPos = 0; //0 = Temp, 1 = Turn Off, 2 = OK
  boolean cursorState = 0; //0 = Unselected, 1 = Selected
  encMin = 0;
  encMax = 2;
  encCount = 0;
  int lastCount = 1;
  char buf[4];
  
  clearLCD();
  printLCD(0,0,sTitle);
  if (tempUnit == TEMPF) printLCD(1, 11, "F"); else printLCD(1, 11, "C");
  if (dispOff) printLCD(2, 6, "Turn Off");
  printLCD(3, 8, "OK");
  
  while(1) {
    if (encCount != lastCount) {
      if (cursorState) {
        if (cursorPos == 0) defTemp = encCount;
      } else {
        cursorPos = encCount;
        switch (cursorPos) {
          case 0:
            printLCD(1, 7, ">");
            printLCD(2, 5, " ");
            printLCD(2, 14, " ");
            printLCD(3, 7, " ");
            printLCD(3, 10, " ");
            break;
          case 1:
            if (dispOff) {
              printLCD(1, 7, " ");
              printLCD(2, 5, ">");
              printLCD(2, 14, "<");
              printLCD(3, 7, " ");
              printLCD(3, 10, " ");
              break;
            }
          case 2:
            printLCD(1, 7, " ");
            printLCD(2, 5, " ");
            printLCD(2, 14, " ");
            printLCD(3, 7, ">");
            printLCD(3, 10, "<");
            break;
        }
      }
      printLCDPad(1, 8, itoa(defTemp, buf, 10), 3, ' ');
      lastCount = encCount;
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      switch (cursorPos) {
        case 0:
          cursorState = cursorState ^ 1;
          if (cursorState) {
            encMin = 0;
            encMax = 250;
            encCount = defTemp;
          } else {
            encMin = 0;
            encMax = 2;
            encCount = cursorPos;
          }
          break;
        case 1:
          if (dispOff) return 0;
        case 2:
          return defTemp;
      }
    } else if (enterStatus == 2) {
      //Ignore Cancel
      enterStatus = 0;
    }
  }
}

int confirmExit() {
  clearLCD();
  printLCD(0, 0, "Exiting will reset");
  printLCD(1, 0, "outputs, setpoints");
  printLCD(2, 0, "and timers.");
  
  char choices[2][19] = {
    "      Return      ",
    "   Exit Program   "};
  return getChoice(choices, 2, 3);;
}
