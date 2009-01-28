#include <EEPROM.h>

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

byte tsHLT[8], tsMash[8], tsKettle[8], tsCFCH2OIn[8], tsCFCH2OOut[8], tsCFCBeerOut[8];

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




