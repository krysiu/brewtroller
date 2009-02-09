void doAutoBrew()
{
  //To do: Prompt for values
  delayStart(60);
  preheat(104);
  mashStep("Dough In", 104, 20);
  mashStep("Protein Rest", 140, 20);
  mashStep("Sacch Rest", 158, 60);
  mashStep("Mash Out", 170, 20);
}

void delayStart(int iMins)
{
}

void preheat(int iTemp)
{
}

void mashStep(char sTitle[ ], int iTemp, int iMins)
{
  clearLCD();
  printLCD(0,0,sTitle);
  delay(3000);
}
