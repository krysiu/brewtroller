#include <PID.h>

//Declare Globals
#define ENCA_PIN 2
#define ENCB_PIN 4
#define TEMP_PIN 5
#define ENTER_PIN 11
#define ALARM_PIN 15
#define ENTER_INT 1
#define ENCA_INT 2
  
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
volatile unsigned int enterStatus = 0;

byte tsHLT[8], tsMash[8], tsKettle[8], tsCFCH2OIn[8], tsCFCH2OOut[8], tsCFCBeerOut[8];

#define TEMPF 1
#define TEMPC 0
volatile int tempUnit = TEMPC;

boolean hltPIDEnabled = 0;
boolean mashPIDEnabled = 0;
boolean kettlePIDEnabled = 0;
double hltPIDInput, hltPIDOutput, hltPIDSetpoint, mashPIDInput, mashPIDOutput, mashPIDSetpoint, kettlePIDInput, kettlePIDOutput, kettlePIDSetpoint;
PID hltPID(&hltPIDInput, &hltPIDOutput, &hltPIDSetpoint, -3,4,1);
PID mashPID(&mashPIDInput, &mashPIDOutput, &mashPIDSetpoint, -3,4,1);
PID kettlePID(&kettlePIDInput, &kettlePIDOutput, &kettlePIDSetpoint, -3,4,1);

void setup()
{
  //Serial.begin(9600);
  loadSetup();
  initLCD();
  initPID();
  
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
  digitalWrite(ALARM_PIN, LOW);
  
  attachInterrupt(ENCA_INT, doEncoderA, RISING);
  attachInterrupt(ENTER_INT, doEnter, CHANGE);
}

void loop()
{  
  menuMain();
}




