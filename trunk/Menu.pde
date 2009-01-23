void dispMenu(char sTitle[], char sOpt1[], void (*fOpt1)(), char sOpt2[], void (*fOpt2)(), char sOpt3[], void (*fOpt3)(), void (*fNext)(), void (*fPrev)());

void menuMain()
{
  dispMenu(
    "BrewTroller      1/2",
    "Auto Brew", &doAutoBrew,
    "Monitor Mode", &doMon,
    "Fermentation", &doFerm,
    &menuMain2,
    NULL
  );
}

void menuMain2()
{
  dispMenu(
    "BrewTroller      2/2",
    "System Setup", &menuSetup,
    NULL, NULL,
    NULL, NULL,
    NULL,
    &menuMain
  );
}

void menuSetup()
{
  dispMenu(
    "System Setup (1/2)",
    "Hot Liquor Tank", &hltSetup,
    "Mash Tun", &mtSetup,
    "Fermentation", &fermSetup,
    &menuSetup2,
    NULL
  );
}

void menuSetup2()
{
  dispMenu(
    "System Setup (2/2)",
    "Save Settings", &saveSetup,
    "Load Settings", &loadSetup,
    NULL, NULL,
    NULL,
    &menuSetup
  );
}

void dispMenu(char sTitle[], char sOpt1[], void (*fOpt1)(), char sOpt2[], void (*fOpt2)(), char sOpt3[], void (*fOpt3)(), void (*fNext)(), void (*fPrev)())
{
  int curMax = 0;
  
  encMin = 0;
  encMax = 4;
  
  clearLCD();
  
  if (sTitle != NULL) printLCD(0, 0, sTitle);
  
  if (sOpt1 != NULL) {
    printLCD(1, 1, sOpt1);
    curMax = 1;
  }
  
  if (sOpt2 != NULL) {
    printLCD(2, 1, sOpt2);
    curMax = 2;
  }
  
  if (sOpt3 != NULL) {
    printLCD(3, 1, sOpt3);
    curMax = 3;
  }

  //Put cursor at first option
  encCount = 1;
  lastCount = 1;
  menuSetCursor(encCount);


  do {
    if (encCount != lastCount) {
      if (encCount < 1) 
        if (fPrev != NULL) fPrev(); 
          else encCount = 1;
      else if (encCount > curMax)
        if(fNext != NULL) fNext();
          else encCount = curMax;
      else menuSetCursor(encCount);
      lastCount = encCount;
    }
    
    //If Enter
    if (enterStatus == 1) {
        enterStatus = 0;
        
        switch (encCount) {
        case 1:
          fOpt1();
          return;
        case 2:
          fOpt2();
          return;
        case 3:
          fOpt3();
          return;
        }
        
    }
    
    //If Cancel (Hold Enter)
    if (enterStatus == 2) {
      enterStatus = 0;
      return;
    }
  } while (1);
}

void menuSetCursor(int iPos) {
  for (int i=1; i<=3; i++) {
    if (iPos == i) { printLCD(i, 0, ">"); } else { printLCD(i, 0, " "); }
  }
}
