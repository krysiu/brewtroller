// Supported LCD Displays (Use only 1)
//
//#define DISPLAY_20x4
#define DISPLAY_16x2

#include <avr/pgmspace.h>

char buf[11];
char msg[25][21];
byte msgField = 0;

void setup() {
  //Mode Jumpers
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  Serial.begin(9600);
  initLCD();  
  initBigFont();
}

void loop() {
  clearLCD();
  printLCD_BigFont(0, 0, "12345");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "67890");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "97.2C");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "152.6F");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "24.3L");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "12.4G");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "1:25");
  delay(3000);

  chkMsg();
}

