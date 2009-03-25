/*
BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0012 (http://arduino.cc/en/Main/Software)
With Sanguino Software (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/


#include <PID_Beta6.h>

//Pin and Interrupt Definitions
#define ENCA_PIN 2
#define ENCB_PIN 4
#define TEMP_PIN 5
#define ENTER_PIN 11
#define ALARM_PIN 15
#define ENTER_INT 1
#define ENCA_INT 2
#define VALVE0_PIN 6
#define VALVE1_PIN 7
#define VALVE2_PIN 8
#define VALVE3_PIN 9
#define VALVE4_PIN 10
#define VALVE5_PIN 12
#define VALVE6_PIN 13
#define VALVE7_PIN 14
#define VALVE8_PIN 16
#define VALVE9_PIN 18
#define VALVEA_PIN 24
#define HLTHEAT_PIN 0
#define MASHHEAT_PIN 1
#define KETTLEHEAT_PIN 3

//TSensor Array Element Constants
#define HLT 0
#define MASH 1
#define KETTLE 2
#define H2OIN 3
#define H2OOUT 4
#define BEEROUT 5

//Valve Array Element Constants and Variables
#define ALLOFF 0
#define FILLHLT 1
#define FILLMASH 2
#define MASHHEAT 3
#define MASHIDLE 4
#define SPARGEIN 5
#define SPARGEOUT 6
#define CHILLH2O 7
#define CHILLBEER 8

//Unit Definitions
//International: Celcius, Liter, Kilogram
//US: Fahrenheit, Gallon, US Pound
#define INTL 0
#define US 1

//Encoder Types
#define CUI 0
#define ALPS 1

//Encoder Globals
byte encMode = 0;
int encCount;
byte encMin;
byte encMax;
byte enterStatus = 0;

//8-byte Temperature Sensor Address x6 Sensors
byte tSensor[6][8];

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

//Shared menuOptions Array
char menuopts[16][20];

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
  pinMode(VALVE0_PIN, OUTPUT);
  pinMode(VALVE1_PIN, OUTPUT);
  pinMode(VALVE2_PIN, OUTPUT);
  pinMode(VALVE3_PIN, OUTPUT);
  pinMode(VALVE4_PIN, OUTPUT);
  pinMode(VALVE5_PIN, OUTPUT);
  pinMode(VALVE6_PIN, OUTPUT);
  pinMode(VALVE7_PIN, OUTPUT);
  pinMode(VALVE8_PIN, OUTPUT);
  pinMode(VALVE9_PIN, OUTPUT);
  pinMode(VALVEA_PIN, OUTPUT);
  pinMode(HLTHEAT_PIN, OUTPUT);
  pinMode(MASHHEAT_PIN, OUTPUT);
  pinMode(KETTLEHEAT_PIN, OUTPUT);
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
  strcpy(menuopts[0], "AutoBrew");
  strcpy(menuopts[1], "Brew Monitor");
  strcpy(menuopts[2], "System Setup");
 
  switch (scrollMenu("BrewTroller", menuopts, 3)) {
    case 0: doAutoBrew(); break;
    case 1: doMon(); break;
    case 2: menuSetup(); break;
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
  printLCD(1, 10, "Build 0138");
  printLCD(3, 1, "www.brewtroller.com");
  while(!enterStatus) delay(250);
  enterStatus = 0;
}
