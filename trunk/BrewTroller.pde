#include <PID.h>

//Declare Globals
double hltSetpoint, hltInput, hltOutput;
double mtSetpoint, mtInput, mtOutput;
PID hltPID(&hltInput, &hltOutput, &hltSetpoint,2.1,5.4,0);
PID mtPID(&mtInput, &mtOutput, &mtSetpoint,2.1,5.4,0);

//Declare Platform Specific Globals (Set in P_Arduino:platformSetup or P_Sanguino:platformSetup) 
int tempPin;

void setup()
{
  platformSetup();
  loadSetup();
  initLCD();

}

void loop()
{
  menuMain(); 
}






