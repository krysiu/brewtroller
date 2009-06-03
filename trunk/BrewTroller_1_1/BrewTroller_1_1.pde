#define BUILD 216 
/*
BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0015 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
using LiquidCrystal Fix by Donald Weiman:
  Download fix: http://web.alfredstate.edu/weimandn/arduino/LiquidCrystal_library/LiquidCrystal.cpp
  Replace arduino-0015\hardware\libraries\LiquidCrystal\LiquidCrystal.cpp
  Delete arduino-0015\hardware\libraries\LiquidCrystal\LiquidCrystal.o if it exists
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


//**********************************************************************************
// OPTIONAL MODULES
//**********************************************************************************
// Comment out any of the following lines to disable a module. This is handy to see
// how much space these chunks of code use.
//
#define MODULE_BREWMONITOR
#define MODULE_SYSTEST
#define MODULE_EEPROMUPGRADE

//The following module converts all EEPROM settings between US and Metric when system unit setting is altered (5.6KB)
#define MODULE_UNITCONV
//**********************************************************************************


//**********************************************************************************
// DEBUG
//**********************************************************************************
// Enables Serial Out with Additional Debug Data
//
//#define DEBUG
//**********************************************************************************


//*****************************************************************************************************************************
// BEGIN CODE
//*****************************************************************************************************************************
#include <avr/pgmspace.h>
#include <PID_Beta6.h>

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
#define STEAMHEAT_PIN 27
#define HLTVOL_APIN 0
#define MASHVOL_APIN 1
#define KETTLEVOL_APIN 2
#define STEAMPRESS_APIN 3

//TSensor and Output (0-2) Array Element Constants
#define TS_HLT 0
#define TS_MASH 1
#define TS_KETTLE 2
#define TS_H2OIN 3
#define TS_H2OOUT 4
#define TS_BEEROUT 5

#define VS_HLT 0
#define VS_MASH 1
#define VS_KETTLE 2
#define VS_STEAM 3

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
byte heatPin[4] = { HLTHEAT_PIN, MASHHEAT_PIN, KETTLEHEAT_PIN, STEAMHEAT_PIN };

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
boolean PIDEnabled[4] = { 0, 0, 0, 0 };

//Shared menuOptions Array
char menuopts[30][20];

//Common Buffer
char buf[11];

double PIDInput[4], PIDOutput[4], setpoint[4];
byte PIDp[4], PIDi[4], PIDd[4], PIDCycle[4], hysteresis[4];

PID pid[4] = {
  PID(&PIDInput[VS_HLT], &PIDOutput[VS_HLT], &setpoint[VS_HLT], 3, 4, 1),
  PID(&PIDInput[VS_MASH], &PIDOutput[VS_MASH], &setpoint[VS_MASH], 3, 4, 1),
  PID(&PIDInput[VS_KETTLE], &PIDOutput[VS_KETTLE], &setpoint[VS_KETTLE], 3, 4, 1),
  PID(&PIDInput[VS_STEAM], &PIDOutput[VS_STEAM], &setpoint[VS_STEAM], 3, 4, 1)
};

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;

char msg[20][21];
byte msgField = 0;
boolean msgQueued = 0;

//Log Message Classes
const char LOGAB[] PROGMEM = "AB";
const char LOGCMD[] PROGMEM = "CMD";
const char LOGDEBUG[] PROGMEM = "DEBUG";
const char LOGMENU[] PROGMEM = "MENU";
const char LOGSYS[] PROGMEM = "SYSTEM";

//Other PROGMEM Repeated Strings
const char PWRLOSSRECOVER[] PROGMEM = "PLR";
const char BT[] PROGMEM = "BrewTroller";
const char BTVER[] PROGMEM = "v1.1";
const char CANCEL[] PROGMEM = "Cancel";
const char SPACE[] PROGMEM = " ";
const char INIT_EEPROM[] PROGMEM = "Initialize EEPROM";
const char LOGSCROLLP[] PROGMEM = "PROMPT";
const char LOGSCROLLR[] PROGMEM = "RESULT";
const char LOGCHOICE[] PROGMEM = "CHOICE";
const char SKIPSTEP[] PROGMEM = "Skip Step";
const char ABORTAB[] PROGMEM = "Abort AutoBrew";
const char LOGSPLASH[] PROGMEM = "Splash Screen";

//Custom LCD Chars
const byte CHARFIELD[] PROGMEM = {B11111, B00000, B00000, B00000, B00000, B00000, B00000, B00000};
const byte CHARCURSOR[] PROGMEM = {B11111, B11111, B00000, B00000, B00000, B00000, B00000, B00000};
const byte BMP0[] PROGMEM = {B00000, B00000, B00000, B00000, B00011, B01111, B11111, B11111};
const byte BMP1[] PROGMEM = {B00000, B00000, B00000, B00000, B11100, B11110, B11111, B11111};
const byte BMP2[] PROGMEM = {B00001, B00011, B00111, B01111, B00001, B00011, B01111, B11111};
const byte BMP3[] PROGMEM = {B11111, B11111, B10001, B00011, B01111, B11111, B11111, B11111};
const byte BMP4[] PROGMEM = {B11111, B11111, B11111, B11111, B11111, B11111, B11111, B11111};
const byte BMP5[] PROGMEM = {B01111, B01110, B01100, B00001, B01111, B00111, B00011, B11101};
const byte BMP6[] PROGMEM = {B11111, B00111, B00111, B11111, B11111, B11111, B11110, B11001};
const byte BMP7[] PROGMEM = {B11111, B11111, B11110, B11101, B11011, B00111, B11111, B11111};
  
  
void setup() {
#if defined DEBUG || defined MUXBOARDS || defined PV34REMAP
  Serial.begin(9600);
  Serial.println();
#endif
  logStart_P(LOGSYS);
  logField_P(PSTR("VER"));
  logField_P(BTVER);
  logField(itoa(BUILD, buf, 10));
  logEnd();
  
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
  pinMode(STEAMHEAT_PIN, OUTPUT);
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
  //printLCD(0,0,itoa(availableMemory(), buf, 10)); delay (5000);
  
  //Check for cfgVersion variable and format EEPROM if necessary
  checkConfig();
  
  //Load global variable values stored in EEPROM
  loadSetup();
  
  if (getPwrRecovery() == 1) {
    logString_P(LOGSYS, PWRLOSSRECOVER);
    doAutoBrew();
  } else if (getPwrRecovery() == 2) {
      logString_P(LOGSYS, PWRLOSSRECOVER);
      doMon();
  } else {
    for (byte i = VS_HLT; i <= VS_KETTLE; i++) setZeroVol(i, analogRead(vSensor[i]));
    splashScreen();
  }
}

void loop() {
  strcpy_P(menuopts[0], PSTR("AutoBrew"));
  strcpy_P(menuopts[1], PSTR("Brew Monitor"));
  strcpy_P(menuopts[2], PSTR("System Setup"));
  strcpy_P(menuopts[3], PSTR("System Tests"));
 
  byte lastoption = scrollMenu("BrewTroller", 4, 0);
  if (lastoption == 0) doAutoBrew();
  else if (lastoption == 1) doMon();
  else if (lastoption == 2) menuSetup();
  else if (lastoption == 3) menuTest();
}

void splashScreen() {
  clearLCD();
  lcdSetCustChar_P(0, BMP0);
  lcdSetCustChar_P(1, BMP1);
  lcdSetCustChar_P(2, BMP2);
  lcdSetCustChar_P(3, BMP3);
  lcdSetCustChar_P(4, BMP4);
  lcdSetCustChar_P(5, BMP5);
  lcdSetCustChar_P(6, BMP6);
  lcdSetCustChar_P(7, BMP7);
  lcdWriteCustChar(0, 1, 0);
  lcdWriteCustChar(0, 2, 1);
  lcdWriteCustChar(1, 0, 2); 
  lcdWriteCustChar(1, 1, 3); 
  lcdWriteCustChar(1, 2, 4); 
  lcdWriteCustChar(2, 0, 5); 
  lcdWriteCustChar(2, 1, 6); 
  lcdWriteCustChar(2, 2, 7); 
  printLCD_P(0, 4, BT);
  printLCD_P(0, 16, BTVER);
  printLCD_P(1, 10, PSTR("Build "));
  printLCDLPad(1, 16, itoa(BUILD, buf, 10), 4, '0');
  printLCD_P(3, 1, PSTR("www.brewtroller.com"));
  logStart_P(LOGMENU);
  logField_P(LOGSCROLLP);
  logField_P(LOGSPLASH);
  logField_P(PSTR("0"));
  logEnd();
  while(!enterStatus) {
     if (chkMsg()) {
      if (strcasecmp(msg[0], "SELECT") == 0) {
        enterStatus = 1;
        clearMsg();
      } else rejectMsg();
    }
    delay(250);
  }
  enterStatus = 0;
  logStart_P(LOGMENU);
  logField_P(LOGSCROLLR);
  logField_P(LOGSPLASH);
  logFieldI(0);
  logEnd();
}
