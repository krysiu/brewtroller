#include "WProgram.h"
#include <avr/pgmspace.h>
#include <microfat2.h>
#include <mmc.h>
#include <DevicePrint.h>

#define PIN_LEDRED 3
#define PIN_LEDGRN 4
#define PIN_SWITCH 2
#define SWITCH_INT 0

char buf[11];
boolean enterStatus;
DevicePrint dp;

void setup() {
  Serial.begin(9600);
  pinMode(PIN_LEDRED, OUTPUT);
  pinMode(PIN_LEDGRN, OUTPUT);
  pinMode(PIN_SWITCH, INPUT);
  attachInterrupt(SWITCH_INT, doEnter, CHANGE);
  //initSD();
}

void loop() {
  chkMsg();

}
