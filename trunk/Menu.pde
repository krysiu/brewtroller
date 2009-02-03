void menuMain()
{
  char mainMenu[4][20] = {
    "AutoBrew          ",
    "Brew Monitor      ",
    "Fermentation      ",
    "System Setup      "
  };
  while(1) {
    switch (scrollMenu("BrewTroller         ", mainMenu, 4)) {
      case 0:
        doAutoBrew();
        break;
      case 1:
        doMon();
        break;
      case 2:
        doFerm();
        break;
      case 3:
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
