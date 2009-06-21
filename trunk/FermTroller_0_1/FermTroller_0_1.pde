#define BUILD 230 
/*
FermTroller - Open Source Fermentation Computer
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
// UNIT (Metric/US)
//**********************************************************************************
// By default BrewTroller will use US Units
// Uncomment USEMETRIC below to use metric instead
//
//#define USEMETRIC
//**********************************************************************************


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

//Heat Output Pin Array
byte heatPin[4] = { 0, 3, 28, 30 };
byte coolPin[4] = { 1, 27, 29, 31 };

//Encoder Globals
int encCount;
byte encMin;
byte encMax;
byte enterStatus = 0;

//8-byte Temperature Sensor Address x6 Sensors
byte tSensor[5][8];
float temp[5];
unsigned long convStart = 0;

//Shared menuOptions Array
char menuopts[30][20];

//Common Buffer
char buf[11];

//Output Globals
double PIDInput[4], PIDOutput[4], setpoint[4];
byte PIDp[4], PIDi[4], PIDd[4], PIDCycle[4], hysteresis[4];
unsigned long cycleStart[4];
boolean heatStatus[4];
boolean coolStatus[4];
boolean PIDEnabled[4];

PID pid[4] = {
  PID(&PIDInput[0], &PIDOutput[0], &setpoint[0], 3, 4, 1),
  PID(&PIDInput[1], &PIDOutput[1], &setpoint[1], 3, 4, 1),
  PID(&PIDInput[2], &PIDOutput[2], &setpoint[2], 3, 4, 1),
  PID(&PIDInput[3], &PIDOutput[3], &setpoint[3], 3, 4, 1)
};

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;

char msg[25][21];
byte msgField = 0;
boolean msgQueued = 0;

byte pwrRecovery;

unsigned long lastLog;
byte logCount;

const char BT[] PROGMEM = "FermTroller";
const char BTVER[] PROGMEM = "v0.1";

//Log Message Classes
const char LOGCMD[] PROGMEM = "CMD";
const char LOGDEBUG[] PROGMEM = "DEBUG";
const char LOGMENU[] PROGMEM = "MENU";
const char LOGSYS[] PROGMEM = "SYSTEM";
const char LOGGLB[] PROGMEM = "GLOBAL";
const char LOGDATA[] PROGMEM = "DATA";

//Other PROGMEM Repeated Strings
const char PWRLOSSRECOVER[] PROGMEM = "PLR";
const char INIT_EEPROM[] PROGMEM = "Initialize EEPROM";
const char CANCEL[] PROGMEM = "Cancel";
const char SPACE[] PROGMEM = " ";
const char LOGSCROLLP[] PROGMEM = "PROMPT";
const char LOGSCROLLR[] PROGMEM = "RESULT";
const char LOGCHOICE[] PROGMEM = "CHOICE";
const char LOGGETVAL[] PROGMEM = "GETVAL";
const char LOGSPLASH[] PROGMEM = "SPLASH";
const char CONTINUE[] PROGMEM = "Continue";
const char ABORT[] PROGMEM = "Abort";
        
#ifdef USEMETRIC
const char VOLUNIT[] PROGMEM = "l";
const char WTUNIT[] PROGMEM = "kg";
const char TUNIT[] PROGMEM = "C";
const char PUNIT[] PROGMEM = "kPa";
#else
const char VOLUNIT[] PROGMEM = "gal";
const char WTUNIT[] PROGMEM = "lb";
const char TUNIT[] PROGMEM = "F";
const char PUNIT[] PROGMEM = "psi";
#endif

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
  Serial.begin(9600);
  Serial.println();

  logStart_P(LOGSYS);
  logField_P(PSTR("VER"));
  logField_P(BTVER);
  logField(itoa(BUILD, buf, 10));
  logEnd();
  
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
  for (byte i = 0; i < 4; i++) {
    pinMode(heatPin[i], OUTPUT);
    pinMode(coolPin[i], OUTPUT);
  }
  resetOutputs();
  
  for (byte i = 0; i < 4; i++) {
    if (PIDEnabled[i]) {
      pid[i].SetInputLimits(0, 255);
      pid[i].SetOutputLimits(0, PIDCycle[i] * 1000);
    }
  }
  
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
  
  if (pwrRecovery == 1) {
    logPLR();
    doMon();
  } else {
    splashScreen();
  }
}

void loop() {
  strcpy_P(menuopts[0], PSTR("Start"));
  strcpy_P(menuopts[1], PSTR("System Setup"));
 
  byte lastoption = scrollMenu("FermTroller", 2, 0);
  if (lastoption == 0) doMon();
  else if (lastoption == 1) menuSetup();
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
      } else rejectMsg(LOGSCROLLP);
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

