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
  hltInput = analogRead(0);
  hltSetpoint = 100;
  mtInput = analogRead(1);
  mtSetpoint = 100;

  //turn the PID on
  hltPID.SetMode(AUTO);
  mtPID.SetMode(AUTO);
  
}
