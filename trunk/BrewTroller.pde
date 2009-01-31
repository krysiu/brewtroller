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

#define TEMPF 1
#define TEMPC 0
volatile int tempUnit = TEMPC;

void setup()
{
  //setDS9bit();
  loadSetup();
  initLCD();
  setDS9bit();
  
  pinMode(encAPin, INPUT);
  pinMode(encBPin, INPUT);
  pinMode(enterPin, INPUT);
  
  attachInterrupt(2, doEncoderA, RISING);
  attachInterrupt(1, doEnter, CHANGE);
}

void loop()
{  
  //printLCD(0,0,"HLT = ");
  //lcdPrintFloat(get_temp(1,tsHLT),1,0,6); // for testing purposes only
  //printLCD(1,0,"MLT = ");
  //lcdPrintFloat(get_temp(1,tsMash),1,1,6); // for testing purposes only
  menuMain();
}




