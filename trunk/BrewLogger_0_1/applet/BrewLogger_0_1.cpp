#include "WProgram.h"
#include <avr/pgmspace.h>
#include <microfat2.h>
#include <mmc.h>
#include <DevicePrint.h>

//#define PIN_LEDDBG 
#define PIN_LEDRED 3
#define PIN_LEDGRN 4
#define PIN_SWITCH 2
#define SWITCH_INT 0

#include "WProgram.h"
void setup();
void loop();
void chkMsg();
void clearMsg();
void initSD();
uint8_t proxyWriter(const uint8_t* buffer, unsigned long sector, uint8_t count);
void error(byte blinkCode);
void doButton();
char buf[11];
boolean enterStatus;
DevicePrint dp;

void setup() {
  Serial.begin(9600);
  //pinMode(PIN_LEDDBG, OUTPUT);
  pinMode(PIN_LEDRED, OUTPUT);
  pinMode(PIN_LEDGRN, OUTPUT);
  pinMode(PIN_SWITCH, INPUT);
  attachInterrupt(SWITCH_INT, doButton, CHANGE);
  //initSD();
}

void loop() {
  chkMsg();
  if (enterStatus == 1) {
    digitalWrite(PIN_LEDGRN, HIGH);
    digitalWrite(PIN_LEDRED, LOW);
  } else if (enterStatus == 2) {
    digitalWrite(PIN_LEDGRN, LOW);
    digitalWrite(PIN_LEDRED, HIGH);
  }
  enterStatus = 0;
}
char msg[25][21];
byte msgField = 0;

void chkMsg() {
  while (Serial.available()) {
    byte byteIn = Serial.read();
    if (byteIn == '\r' || byteIn == '\n') {

      //Check for Global Commands
      if (strcasecmp(msg[1], "DATA") == 0 && strcasecmp(msg[2], "PGM") == 0) {
      }
      clearMsg();
    } else if (byteIn == '\t') {
      if (msgField < 25) {
        msgField++;
      } else {
        //Message Overflow
        clearMsg();
      }
    } else {
      byte charCount = strlen(msg[msgField]);
      if (charCount < 20) { 
        msg[msgField][charCount] = byteIn; 
        msg[msgField][charCount + 1] = '\0';
      } else {
        //Field Overflow
        clearMsg();
      }
    }
  }
}

void clearMsg() {
  msgField = 0;
  for (byte i = 0; i < 20; i++) msg[i][0] = '\0';
}
uint8_t sectorBuffer[512];

void initSD() {
  // some users have reported cards which won't initialise 1st time
  //
  int n = 0;
  while (mmc::initialize() != RES_OK) {
    if (++n == 10)
      error(1); //Couldn't initialise card
    delay(500);
  }

  if (!microfat2::initialize(sectorBuffer, &mmc::readSectors))
    error(2); //Couldn't initialise microfat

  // find the start sector and length of the data we'll be overwriting
  unsigned long sector, fileSize;

  if(!microfat2::locateFileStart(PSTR("DATA    TXT"), sector, fileSize))
    error(3); //Couldn't find data.txt on the card
  
  dp.initialize(sector, fileSize / 512, sectorBuffer, proxyWriter);
  memset(sectorBuffer, '.', 512);
}

// Proxy write function
// Use a proxi if:
//  > you need to adapt to a particular function's signature
//  > you want to do some processing on the buffer as it's written
//
uint8_t proxyWriter(const uint8_t* buffer, unsigned long sector, uint8_t count)
{
  // I could have just used this function to pass as the sector write...
  //
  uint8_t val = mmc::writeSectors(buffer, sector, count);

  // ... but I want to process the buffer after each write to the card!
  //
  if (dp.m_bufferIndex == 512)
  {
    // we've written a full buffer so clear it out ready for the next
    // writes - the device print variables will be updated after we return
    // from this function.
    //
    memset(sectorBuffer, '.', 512);
  }

  return val;
}

#define ENTER_BOUNCE_DELAY 30
unsigned long enterStart;

// Error hang, flashing the on-board led
void error(byte blinkCode) { 
  while(1) {
    for (byte n = 0; n < blinkCode; n++) {
      digitalWrite(PIN_LEDRED, HIGH);
      delay(250);
      digitalWrite(PIN_LEDRED, LOW);
      delay(250);
    }
    delay(2000);
  }
}

void doButton() {
  if (digitalRead(PIN_SWITCH) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else if (millis() - enterStart > ENTER_BOUNCE_DELAY) {
      enterStatus = 1;
    }
  }
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

