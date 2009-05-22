#define BUILD 205 
/*
BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0015 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

//*****************************************************************************************************************************
// USER COMPILE OPTIONS
//*****************************************************************************************************************************


//**********************************************************************************
// ENCODER TYPE
//**********************************************************************************
// You must uncomment one and only one of the following ENCODER_ definitions
// Use ENCODER_ALPS for ALPS and Panasonic Encoders
// Use ENCODER_CUI for older CUI encoders
//
#define ENCODER_ALPS
//#define ENCODER_CUI
//**********************************************************************************


//**********************************************************************************
// P/V 3-4 Serial Fix
//**********************************************************************************
// BrewTroller 1.0 - 2.0 boards share the output pins used for pump/valve outputs
// 3 and 4 with the serial connection used to flash the board with new software. 
// Newer boards use pins xx and xx for P/V 3 & 4 to avoid a conflict that causes
// these outputs to be momentarily switched on during boot up causing unexpected
// results.
// If you are using a newer board or have implemented a fix to connect P/V to the new
// pins, uncomment the following line. 
// Note: This option is not used when MUXBOARDS is enabled.
//
//#define PV34REMAP
//**********************************************************************************


//**********************************************************************************
// USEMUX
//**********************************************************************************
// Uncomment one of the following lines to enable MUX'ing of Pump/Valve Outputs
// Note: MUX'ing requires 1-4 expansion boards providing 8-32 pump/valve outputs
// To use the original 11 Pump/valve outputs included in BrewTroller 1.0 - 2.0 leave
// all lines commented
//
//#define MUXBOARDS 1
//#define MUXBOARDS 2
//#define MUXBOARDS 3
//#define MUXBOARDS 4
//**********************************************************************************

//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************
#include <avr/pgmspace.h>
#include <PID_Beta6.h>

//#define DEBUG

//Pin and Interrupt Definitions
#define ENCA_PIN 2
#define ENCB_PIN 4
#define TEMP_PIN 5
#define ENTER_PIN 11
#define ALARM_PIN 15
#define ENTER_INT 1
#define ENCA_INT 2

//Standard 11 P/V Ouput Defines
#ifdef MUXBOARDS
  #define MUX_LATCH_PIN 12
  #define MUX_CLOCK_PIN 13
  #define MUX_DATA_PIN 14
#else
  #define VALVE1_PIN 6
  #define VALVE2_PIN 7

#ifdef PV34REMAP
  #define VALVE3_PIN 26
  #define VALVE4_PIN 25
#else
  #define VALVE3_PIN 8
  #define VALVE4_PIN 9
#endif

  #define VALVE5_PIN 10
  #define VALVE6_PIN 12
  #define VALVE7_PIN 13
  #define VALVE8_PIN 14
  #define VALVE9_PIN 24
  #define VALVEA_PIN 18
  #define VALVEB_PIN 16
#endif

#define HLTHEAT_PIN 0
#define MASHHEAT_PIN 1
#define KETTLEHEAT_PIN 3
#define HLTVOL_APIN 0
#define MASHVOL_APIN 1
#define KETTLEVOL_APIN 2

//TSensor and Output (0-2) Array Element Constants
#define TS_HLT 0
#define TS_MASH 1
#define TS_KETTLE 2
#define TS_H2OIN 3
#define TS_H2OOUT 4
#define TS_BEEROUT 5

//Valve Array Element Constants and Variables
#define VLV_FILLHLT 0
#define VLV_FILLMASH 1
#define VLV_MASHHEAT 2
#define VLV_MASHIDLE 3
#define VLV_SPARGEIN 4
#define VLV_SPARGEOUT 5
#define VLV_CHILLH2O 6
#define VLV_CHILLBEER 7

//Unit Definitions
//International: Celcius, Liter, Kilogram
//US: Fahrenheit, Gallon, US Pound
#define UNIT_INTL 0
#define UNIT_US 1

//System Types
#define SYS_DIRECT 0
#define SYS_HERMS 1
#define SYS_STEAM 2

//Heat Output Pin Array
byte heatPin[3] = { HLTHEAT_PIN, MASHHEAT_PIN, KETTLEHEAT_PIN };

//Volume Sensor Pin Array
byte vSensor[3] = { HLTVOL_APIN, MASHVOL_APIN, KETTLEVOL_APIN};

//Encoder Globals
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
//Rate of Evaporation (Percent per hour)
byte evapRate;

//Output Globals
byte sysType = SYS_DIRECT;
boolean PIDEnabled[3] = { 0, 0, 0 };

//Shared menuOptions Array
char menuopts[30][20];

double PIDInput[3], PIDOutput[3], setpoint[3];
byte PIDp[3], PIDi[3], PIDd[3], PIDCycle[3], hysteresis[3];

PID pid[3] = {
  PID(&PIDInput[TS_HLT], &PIDOutput[TS_HLT], &setpoint[TS_HLT], 3, 4, 1),
  PID(&PIDInput[TS_MASH], &PIDOutput[TS_MASH], &setpoint[TS_MASH], 3, 4, 1),
  PID(&PIDInput[TS_KETTLE], &PIDOutput[TS_KETTLE], &setpoint[TS_KETTLE], 3, 4, 1)
};

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;
  
void setup() {
#ifdef DEBUG
  Serial.begin(9600);
#endif
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
#ifdef MUXBOARDS
  pinMode(MUX_LATCH_PIN, OUTPUT);
  pinMode(MUX_CLOCK_PIN, OUTPUT);
  pinMode(MUX_DATA_PIN, OUTPUT);
#else
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
  pinMode(VALVEB_PIN, OUTPUT);
#endif
  pinMode(HLTHEAT_PIN, OUTPUT);
  pinMode(MASHHEAT_PIN, OUTPUT);
  pinMode(KETTLEHEAT_PIN, OUTPUT);
  resetOutputs();
  initLCD();
  
  //Encoder Setup
  #ifdef ENCODER_ALPS
      attachInterrupt(2, doEncoderALPS, CHANGE);
  #endif
  #ifdef ENCODER_CUI
      attachInterrupt(2, doEncoderCUI, RISING);
  #endif
  attachInterrupt(1, doEnter, CHANGE);

  //Memory Check
  //char buf[6]; printLCD(0,0,itoa(availableMemory(), buf, 10)); delay (5000);
  
  //Check for cfgVersion variable and format EEPROM if necessary
  checkConfig();
  
  //Load global variable values stored in EEPROM
  loadSetup();

  switch(getPwrRecovery()) {
    case 1: doAutoBrew(); break;
    case 2: doMon(); break;
    default:
      splashScreen();
      break;
  }
}

void loop() {
  strcpy_P(menuopts[0], PSTR("AutoBrew"));
  strcpy_P(menuopts[1], PSTR("Brew Monitor"));
  strcpy_P(menuopts[2], PSTR("System Setup"));
 
  switch (scrollMenu("BrewTroller", menuopts, 3, 0)) {
    case 0: doAutoBrew(); break;
    case 1: doMon(); break;
    case 2: menuSetup(); break;
  }
}

void splashScreen() {
  char buf[6];
  clearLCD();
  { 
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
    const byte bmpByte[] = {
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
  printLCD_P(0, 4, PSTR("BrewTroller v1.1"));
  printLCD_P(1, 10, PSTR("Build "));
  printLCDPad(1, 16, itoa(BUILD, buf, 10), 4, '0');
  printLCD_P(3, 1, PSTR("www.brewtroller.com"));
  while(!enterStatus) delay(250);
  enterStatus = 0;
}
