typedef void (*pt2Func)();

struct menuItem {
  char title[20];
  pt2Func execFunc;
};

void menuMain()
{
  struct menuItem mainMenu[4];
  strcpy(mainMenu[0].title, "AutoBrew          ");
  mainMenu[0].execFunc = &doAutoBrew;
  strcpy(mainMenu[1].title, "Brew Monitor      ");
  mainMenu[1].execFunc = &doMon;
  strcpy(mainMenu[2].title, "Fermentation      ");
  mainMenu[2].execFunc = &doFerm;
  strcpy(mainMenu[3].title, "System Setup      ");
  mainMenu[3].execFunc = &menuSetup;
  scrollMenu("BrewTroller         ", mainMenu, 4);
}

void menuSetup()
{
  struct menuItem setupMenu[5];
  strcpy(setupMenu[0].title, "Assign Temp Sensor ");
  setupMenu[0].execFunc = &assignSensor;
  strcpy(setupMenu[1].title, "Set Temp Unit (C/F)");
  setupMenu[1].execFunc = &setTempUnit;
  strcpy(setupMenu[2].title, "Save Settings      ");
  setupMenu[2].execFunc = &saveSetup;
  strcpy(setupMenu[3].title, "Load Settings      ");
  setupMenu[3].execFunc = &loadSetup;
  strcpy(setupMenu[4].title, "Exit Setup         ");
  setupMenu[4].execFunc = NULL;
  scrollMenu("System Setup        ", setupMenu, 5);
}

//NOTE Make struct array a pointer pass

void scrollMenu(char sTitle[], struct menuItem menuItems[], int numOpts) {
  while(1) {
    clearLCD();
    if (sTitle != NULL) printLCD(0, 0, sTitle);

    encMin = 0;
    encMax = numOpts-1;
  
    encCount = 0;
    lastCount = 1;
    unsigned int topItem = 1;

    unsigned int inLoop = 1;
    while(inLoop) {
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
          if (menuItems[encCount].execFunc != NULL) {
            (*menuItems[encCount].execFunc)();
            inLoop = 0;
          } else return;
      } else if (enterStatus == 2) {
        enterStatus = 0;
        return;
      }
    }
  }
}

void menuSetCursor(int iPos) {
  for (int i=1; i<=3; i++) {
    if (i == iPos) printLCD(i, 0, ">"); else printLCD(i, 0, " ");
  }
}

void drawItems(struct menuItem menuItems[], int numOpts, int topItem) {
  int maxOpt = topItem + 2;
  if (maxOpt > numOpts) maxOpt = numOpts;
  for (int i = topItem; i <= maxOpt; i++) printLCD(i-topItem+1, 1, menuItems[i].title);
}

int getChoice(char choices[][19], int numChoices, int iRow, int defValue = 0) {
  printLCD(iRow, 0, ">                  <");

  encMin = 0;
  encMax = numChoices-1;
 
  encCount = defValue;
  lastCount = encCount+1;

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
