//Declare Globals
#define encAPin 2
#define encBPin 4
#define encAInt 2
#define enterPin 11
#define enterInt 1
#define tempPin 31
  
unsigned int encCount;
unsigned int lastCount;
unsigned int encMin;
unsigned int encMax;
volatile unsigned int enterStatus = 0;

byte tsensor1[8]  = {0x10, 0x04, 0x64, 0x37, 0x01, 0x08, 0x0, 0x3A};
byte tsensor2[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};
byte tsensor3[8] = {0x10, 0xC0, 0x08, 0x64, 0x00, 0x08, 0x00, 0xB2};

void setup()
{
  loadSetup();
  initLCD();

  pinMode(encAPin, INPUT);
  pinMode(encBPin, INPUT);
  pinMode(enterPin, INPUT);
  
  attachInterrupt(2, doEncoderA, RISING);
  attachInterrupt(1, doEnter, CHANGE);
}

void loop()
{  
  //lcdPrintFloat(get_temp(1,tsensor1),0,0,0); // for testing purposes only
  menuMain();
}




