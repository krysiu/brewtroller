#include <PID.h>

//TSensor Array Element Constants
#define HLT 0
#define MASH 1
#define KETTLE 2
#define H2OIN 3
#define H2OOUT 4
#define BEEROUT 5

//Valve Array Element Constants and Variables
#define FILLHLT 0
#define FILLMASH 1
#define MASHHEAT 2
#define MASHIDLE 3
#define SPARGEIN 4
#define SPARGEOUT 5
#define CHILLH2O 6
#define CHILLBEER 7

//Loop-friendly Output Consts
const byte OUTPUT_PIN[3] = { 0, 1, 3 };

//Encoder Globals
byte encMode = 0;
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
unsigned int enterStatus = 0;

#define CUI 0
#define ALPS 1

//8-byte Temperature Sensor Address x6 Sensors
byte tSensor[6][8];

//Unit Definitions
//International: Celcius, Liter, Kilogram
//US: Fahrenheit, Gallon, US Pound
#define INTL 0
#define US 1

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
  //EncA, EncB, Enter
  pinMode(2, INPUT);
  pinMode(4, INPUT);
  pinMode(11, INPUT);
  //Alarm
  pinMode(15, OUTPUT);
  //Valves 0-9, A
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
  pinMode(14, OUTPUT);
  pinMode(16, OUTPUT);
  pinMode(18, OUTPUT);
  pinMode(24, OUTPUT);
  
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
  char buf[6];
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
