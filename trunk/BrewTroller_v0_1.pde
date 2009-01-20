#include <PID.h>

double hltSetpoint, hltInput, hltOutput;
double mtSetpoint, mtInput, mtOutput;
PID hltPID(&hltInput, &hltOutput, &hltSetpoint,2.1,5.4,0);
PID mtPID(&mtInput, &mtOutput, &mtSetpoint,2.1,5.4,0);

void setup()
{
  loadSetup();
  initLCD();

}

void loop()
{
  menuMain(); 
}






