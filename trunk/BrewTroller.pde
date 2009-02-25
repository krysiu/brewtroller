#include <PID.h>

//Pin and Interrupt Definitions
const byte ENCA_PIN = 2;
const byte ENCB_PIN = 4;
const byte TEMP_PIN = 5;
const byte VALVE1_PIN = 6;
const byte VALVE2_PIN = 7;
const byte VALVE3_PIN = 8;
const byte VALVE4_PIN = 9;
const byte VALVE5_PIN = 10;
const byte ENTER_PIN = 11;
const byte VALVE6_PIN = 12;
const byte VALVE7_PIN = 13;
const byte VALVE8_PIN = 14;
const byte ALARM_PIN = 15;
const byte VALVE9_PIN = 16;
const byte VALVE10_PIN = 18;
const byte VALVE11_PIN = 24;
const byte ENTER_INT = 1;
const byte ENCA_INT = 2;

//Array Element Constants
const byte HLT = 0;
const byte MASH = 1;
const byte KETTLE = 2;
const byte H2OIN = 3;
const byte H2OOUT = 4;
const byte BEEROUT = 5;

//Loop-friendly Output Consts
const byte OUTPUT_PIN[3] = { 0, 1, 3 };

//Encoder Globals
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
unsigned int enterStatus = 0;

//8-byte Temperature Sensor Address x6 Sensors
byte tSensor[6][8];

//Unit Definitions
//International: Celcius, Liter, Kilogram
//US: Fahrenheit, Gallon, US Pound
const byte INTL = 0;
const byte US = 1;

//Unit Globals (Volume in thousandths)
boolean unit;
unsigned long capacity[3];
unsigned long volume[3];
unsigned int volLoss[3];
unsigned long defBatchVol;
//Rate of Evaporation (Percent per hour)
byte evapRate;

//Output Globals
boolean PIDEnabled[3] = { 0, 0, 0 };

double PIDInput[3], PIDOutput[3], setpoint[3];
byte PIDp[3], PIDi[3], PIDd[3], PIDCycle[3], hysteresis[3];

PID pid[3] = {
  PID(&PIDInput[HLT], &PIDOutput[HLT], &setpoint[HLT], 3, 4, 1),
  PID(&PIDInput[MASH], &PIDOutput[MASH], &setpoint[MASH], 3, 4, 1),
  PID(&PIDInput[KETTLE], &PIDOutput[KETTLE], &setpoint[KETTLE], 3, 4, 1)
};

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;
  
void setup() {
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
  pinMode(VALVE1_PIN, OUTPUT);
  pinMode(VALVE2_PIN, OUTPUT);
  pinMode(VALVE3_PIN, OUTPUT);
  pinMode(VALVE4_PIN, OUTPUT);
  pinMode(VALVE5_PIN, OUTPUT);
  pinMode(VALVE6_PIN, OUTPUT);
  pinMode(VALVE7_PIN, OUTPUT);
  pinMode(VALVE8_PIN, OUTPUT);
  pinMode(VALVE9_PIN, OUTPUT);
  pinMode(VALVE10_PIN, OUTPUT);
  pinMode(VALVE11_PIN, OUTPUT);
  for (int i = HLT; i <= KETTLE; i++) pinMode(OUTPUT_PIN[i], OUTPUT);
  resetOutputs();

  attachInterrupt(ENCA_INT, doEncoderA, RISING);
  attachInterrupt(ENTER_INT, doEnter, CHANGE);

  initLCD();
  splashScreen();
  
  //Check for cfgVersion variable and format EEPROM if necessary
  checkConfig();
  
  //Load global variable values stored in EEPROM
  loadSetup();
}

void loop() {  
  char mainMenu[3][20] = {
    "AutoBrew          ",
    "Brew Monitor      ",
    "System Setup      "
  };
  while(1) {
    switch (scrollMenu("BrewTroller         ", mainMenu, 3)) {
      case 0: doAutoBrew(); break;
      case 1: doMon(); break;
      case 2: menuSetup(); break;
    }
  }
}

void splashScreen() {
  clearLCD();
  { 
    byte bmpByte[] = {
      B00000,
      B00001,
      B00001, 
      B00001, 
      B00011, 
      B00011, 
      B00011, 
      B00111
    }; 
    lcdSetCustChar(0, bmpByte);
    lcdWriteCustChar(0, 0, 0);
  }
  { 
    byte bmpByte[] = {
      B11100, 
      B11100, 
      B01010, 
      B11110, 
      B00011, 
      B10011, 
      B11111, 
      B11111
    };
    lcdSetCustChar(1, bmpByte);
    lcdWriteCustChar(0, 1, 1);
  }
  { 
    byte bmpByte[] = {
      B00000, 
      B00000, 
      B00000, 
      B11000, 
      B11100, 
      B11110, 
      B11111, 
      B11111
    }; 
    lcdSetCustChar(2, bmpByte); 
    lcdWriteCustChar(0, 2, 2); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B01111, 
      B01111, 
      B11110, 
      B11110
    }; 
    lcdSetCustChar(3, bmpByte); 
    lcdWriteCustChar(1, 0, 3); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B11100, 
      B11011, 
      B11011, 
      B01101
    }; 
    lcdSetCustChar(4, bmpByte); 
    lcdWriteCustChar(1, 1, 4); 
  }
  { 
    byte bmpByte[] = {
      B10111, 
      B11011, 
      B00111, 
      B11111, 
      B11110, 
      B11100, 
      B11000, 
      B00000
    }; 
    lcdSetCustChar(5, bmpByte); 
    lcdWriteCustChar(1, 2, 5); 
  }
  { 
    byte bmpByte[] = {
      B11110, 
      B11110, 
      B11111, 
      B01111, 
      B01111, 
      B01100, 
      B01101, 
      B00111
    }; 
    lcdSetCustChar(6, bmpByte); 
    lcdWriteCustChar(2, 0, 6); 
  }
  { 
    byte bmpByte[] = {
      B01111, 
      B01111, 
      B11111, 
      B11110, 
      B11110, 
      B11111, 
      B01111, 
      B01111
    }; 
    lcdSetCustChar(7, bmpByte); 
    lcdWriteCustChar(2, 1, 7); 
  }
  printLCD(0, 5, "BrewTroller 1.0");
  printLCD(1, 14, "Beta 1");
  printLCD(3, 1, "www.brewtroller.com");
  while(!enterStatus) delay(250);
  enterStatus = 0;
}
