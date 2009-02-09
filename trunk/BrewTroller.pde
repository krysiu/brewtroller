#include <PID.h>

//Pin and Interrupt Definitions
#define HLTHEAT_PIN 0
#define MASHHEAT_PIN 1
#define ENCA_PIN 2
#define KETTLEHEAT_PIN 3
#define ENCB_PIN 4
#define TEMP_PIN 5
#define VALVE1_PIN 6
#define VALVE2_PIN 7
#define VALVE3_PIN 8
#define VALVE4_PIN 9
#define VALVE5_PIN 10
#define ENTER_PIN 11
#define VALVE6_PIN 12
#define VALVE7_PIN 13
#define VALVE8_PIN 14
#define ALARM_PIN 15
#define VALVE9_PIN 16
#define VALVE10_PIN 18
#define VALVE11_PIN 24
#define ENTER_INT 1
#define ENCA_INT 2

//Temperature Unit Definitions
#define TEMPF 1
#define TEMPC 0

//Encoder Globals
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
unsigned int enterStatus = 0;

//TSensor Globals
byte tsHLT[8], tsMash[8], tsKettle[8], tsCFCH2OIn[8], tsCFCH2OOut[8], tsCFCBeerOut[8];
boolean tempUnit = TEMPC;

//PID Globals
boolean hltPIDEnabled = 0;
boolean mashPIDEnabled = 0;
boolean kettlePIDEnabled = 0;
double hltPIDInput, hltPIDOutput, hltSetpoint, mashPIDInput, mashPIDOutput, mashSetpoint, kettlePIDInput, kettlePIDOutput, kettleSetpoint;
PID hltPID(&hltPIDInput, &hltPIDOutput, &hltSetpoint, 3,4,1);
PID mashPID(&mashPIDInput, &mashPIDOutput, &mashSetpoint, 3,4,1);
PID kettlePID(&kettlePIDInput, &kettlePIDOutput, &kettleSetpoint, 3,4,1);

//Timer Globals
unsigned long timerValue = 0;
unsigned long lastTime = 0;
unsigned long timerLastWrite = 0;
boolean timerStatus = 0;
boolean alarmStatus = 0;
  
void setup() {
  loadSetup();
  initLCD();
  
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
  pinMode(HLTHEAT_PIN, OUTPUT);
  pinMode(MASHHEAT_PIN, OUTPUT);
  pinMode(KETTLEHEAT_PIN, OUTPUT);
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
  resetOutputs();
  
  attachInterrupt(ENCA_INT, doEncoderA, RISING);
  attachInterrupt(ENTER_INT, doEnter, CHANGE);
}

void loop() {  
  menuMain();
}




