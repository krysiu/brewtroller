//Declare Globals
#define encAPin 2
#define encBPin 4

volatile unsigned int  encCount = 0;
volatile unsigned int  lastCount = 0;
volatile unsigned int encMin = 0;
volatile unsigned int encMax = 255;
volatile unsigned int encBounceDelay;
unsigned long lastEncUpd;
unsigned long enterStart;
volatile unsigned int enterStatus = 0;

byte tsensor1[8]  = {0x10, 0x04, 0x64, 0x37, 0x01, 0x08, 0x0, 0x3A};
byte tsensor2[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};
byte tsensor3[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};

//Declare Platform Specific Globals (Set in P_Arduino:platformSetup or P_Sanguino:platformSetup) 
int tempPin;
int enterPin;
int encAInt;
int enterInt;

void setup()
{
  platformSetup();
  loadSetup();
  initLCD();
  initEnc();

  pinMode(encAPin, INPUT);
  pinMode(encBPin, INPUT);
  pinMode(enterPin, INPUT);
  
  attachInterrupt(2, doEncoderA, RISING);
  attachInterrupt(1, doEnter, CHANGE);

  lastEncUpd = millis();
}

void loop()
{  
//lcdPrintFloat(get_temp(1,tsensor1),0,0,0); // for testing purposes only
menuMain();
}




