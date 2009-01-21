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






