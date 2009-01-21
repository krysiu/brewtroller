//Declare Platform Specific Globals (Set in P_Arduino:platformSetup or P_Sanguino:platformSetup) 
int tempPin;
byte tsensor1[8]  = {0x10, 0x04, 0x64, 0x37, 0x01, 0x08, 0x0, 0x3A};
byte tsensor2[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};
byte tsensor3[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};

void setup()
{
  platformSetup();
  loadSetup();
  initLCD();

}

void loop()
{  
//lcdPrintFloat(get_temp(1,tsensor1),0,0,0); // for testing purposes only
menuMain();
}




