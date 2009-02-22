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

//Temperature Unit Definitions
const boolean TEMPF = 1;
const boolean TEMPC = 0;

//Loop-friendly Output Consts
const byte OUTPUT_PIN[3] = { 0, 1, 3 };

//Encoder Globals
unsigned int encCount;
unsigned int encMin;
unsigned int encMax;
unsigned int enterStatus = 0;

//TSensor Globals
byte tSensor[6][8];
boolean tempUnit = TEMPC;

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
  checkConfig();
  loadSetup();
  initLCD();
  for (int i = HLT; i <= KETTLE; i++) pinMode(OUTPUT_PIN[i], OUTPUT);
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
  resetOutputs();
  
  attachInterrupt(ENCA_INT, doEncoderA, RISING);
  attachInterrupt(ENTER_INT, doEnter, CHANGE);
}

void loop() {  
  menuMain();
}




