void dispMenu(char sTitle[], char sOpt1[], void (*fOpt1)(), char sOpt2[], void (*fOpt2)(), char sOpt3[], void (*fOpt3)(), void (*fNext)(), void (*fPrev)());

void menuMain()
{
  dispMenu(
    "Main Menu 1/2",
    "Auto Brew", &doAuto,
    "Monitor Mode", &doMon,
    "Fermentation", &doFerm,
    &menuMain2,
    NULL
  );
}

void menuMain2()
{
  dispMenu(
    "Main Menu 2/2",
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
  int curPos;
  int curMax = 0;
  
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
  curPos = 1;
  menuSetCursor(curPos);

  do {
    //If rotory +/-: Update cursor position
    if (0) {
      if (curPos < 1) 
        if (fPrev != NULL) fPrev(); 
          else curPos = 1;
      else if (curPos > curMax)
        if(fNext != NULL) fNext();
          else curPos = curMax;
      else menuSetCursor(curPos);
    }
    
    //If Enter
    if (0) {
      switch (curPos) {
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
    if (0) {
      return;
    }
  } while (1);
}

void menuSetCursor(int iPos) {
  for (int i=1; i<=3; i++) {
    if (iPos == i) { printLCD(i, 0, ">"); } else { printLCD(i, 0, " "); }
  }
}
