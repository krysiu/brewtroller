#include <PID.h>

//Pin and Interrupt Definitions
const byte ENCA_PIN = 2;
const byte ENCB_PIN = 4;
const byte TEMP_PIN = 5;
const byte ENTER_PIN = 11;
const byte ALARM_PIN = 15;
const byte ENTER_INT = 1;
const byte ENCA_INT = 2;

//TSensor Array Element Constants
const byte HLT = 0;
const byte MASH = 1;
const byte KETTLE = 2;
const byte H2OIN = 3;
const byte H2OOUT = 4;
const byte BEEROUT = 5;

//Valve Array Element Constants and Variables
const byte ALLOFF = 0;
const byte FILLHLT = 1;
const byte FILLMASH = 2;
const byte MASHHEAT = 3;
const byte MASHIDLE = 4;
const byte SPARGEIN = 5;
const byte SPARGEOUT = 6;
const byte CHILLH2O = 7;
const byte CHILLBEER = 8;

unsigned int valveCfg[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};

//Loop-friendly Output Consts
const byte OUTPUT_PIN[3] = { 0, 1, 3 };
const byte VALVE_PIN[11] = { 6, 7, 8, 9, 10, 12, 13, 14, 16, 18, 24};

//Encoder Globals
byte encMode = 0;
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
unsigned int enterStatus = 0;

const byte CUI = 0;
const byte ALPS = 1;

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
boolean sysHERMS = 0;
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
  for (int i = 0; i < 11; i++) pinMode(VALVE_PIN[i], OUTPUT);
  for (int i = HLT; i <= KETTLE; i++) pinMode(OUTPUT_PIN[i], OUTPUT);
  resetOutputs();
  initLCD();

  //Check for cfgVersion variable and format EEPROM if necessary
  checkConfig();
  
  //Load global variable values stored in EEPROM
  loadSetup();
  initEncoder();

  switch(getPwrRecovery()) {
    case 1: doAutoBrew(); break;
    case 2: doMon(); break;
    default: splashScreen(); break;
  }
}

void loop() {
  char mainMenu[3][20] = {
    "AutoBrew",
    "Brew Monitor",
    "System Setup"
  };
  while(1) {
    switch (scrollMenu("BrewTroller", mainMenu, 3)) {
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
      B00000,
      B00000, 
      B00000, 
      B00011, 
      B01111, 
      B11111, 
      B11111
    }; 
    lcdSetCustChar(0, bmpByte);
  }
  { 
    byte bmpByte[] = {
      B00000, 
      B00000, 
      B00000, 
      B00000, 
      B11100, 
      B11110, 
      B11111, 
      B11111
    };
    lcdSetCustChar(1, bmpByte);
  }
  { 
    byte bmpByte[] = {
      B00001, 
      B00011, 
      B00111, 
      B01111, 
      B00001, 
      B00011, 
      B01111, 
      B11111
    }; 
    lcdSetCustChar(2, bmpByte); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B11111, 
      B10001, 
      B00011, 
      B01111, 
      B11111, 
      B11111, 
      B11111
    }; 
    lcdSetCustChar(3, bmpByte); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B11111, 
      B11111
    }; 
    lcdSetCustChar(4, bmpByte); 
  }
  { 
    byte bmpByte[] = {
      B01111, 
      B01110, 
      B01100, 
      B00001, 
      B01111, 
      B00111, 
      B00011, 
      B11101
    }; 
    lcdSetCustChar(5, bmpByte); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B00111, 
      B00111, 
      B11111, 
      B11111, 
      B11111, 
      B11110, 
      B11001
    }; 
    lcdSetCustChar(6, bmpByte); 
  }
  { 
    byte bmpByte[] = {
      B11111, 
      B11111, 
      B11110, 
      B11101, 
      B11011, 
      B00111, 
      B11111, 
      B11111
    }; 
    lcdSetCustChar(7, bmpByte); 
  }

  lcdWriteCustChar(0, 1, 0);
  lcdWriteCustChar(0, 2, 1);
  lcdWriteCustChar(1, 0, 2); 
  lcdWriteCustChar(1, 1, 3); 
  lcdWriteCustChar(1, 2, 4); 
  lcdWriteCustChar(2, 0, 5); 
  lcdWriteCustChar(2, 1, 6); 
  lcdWriteCustChar(2, 2, 7); 
  printLCD(0, 4, "BrewTroller v1.0");
  printLCD(1, 10, "Build 0134");
  printLCD(3, 1, "www.brewtroller.com");
  while(!enterStatus) delay(250);
  enterStatus = 0;
}
