#define UI_LCD_I2C

#include <avr/pgmspace.h>

const byte BMP0[] PROGMEM = {B00000, B00000, B00000, B00000, B00011, B01111, B11111, B11111};
const byte BMP1[] PROGMEM = {B00000, B00000, B00000, B00000, B11100, B11110, B11111, B11111};
const byte BMP2[] PROGMEM = {B00001, B00011, B00111, B01111, B00001, B00011, B01111, B11111};
const byte BMP3[] PROGMEM = {B11111, B11111, B10001, B00011, B01111, B11111, B11111, B11111};
const byte BMP4[] PROGMEM = {B11111, B11111, B11111, B11111, B11111, B11111, B11111, B11111};
const byte BMP5[] PROGMEM = {B01111, B01110, B01100, B00001, B01111, B00111, B00011, B11101};
const byte BMP6[] PROGMEM = {B11111, B00111, B00111, B11111, B11111, B11111, B11110, B11001};
const byte BMP7[] PROGMEM = {B11111, B11111, B11110, B11101, B11011, B00111, B11111, B11111};

void setup() {
  Serial.begin(115200);
  Serial.println("Start");
  initLCD();
}

void loop() {
  clearLCD();
  lcdSetCustChar_P(0, BMP0);
  lcdSetCustChar_P(1, BMP1);
  lcdSetCustChar_P(2, BMP2);
  lcdSetCustChar_P(3, BMP3);
  lcdSetCustChar_P(4, BMP4);
  lcdSetCustChar_P(5, BMP5);
  lcdSetCustChar_P(6, BMP6);
  lcdSetCustChar_P(7, BMP7);

  printLCD(3, 0, "Test   /  : LCD");

  for (byte pos = 0; pos < 3; pos++) printLCD_P(pos, 0, PSTR(">"));
  for (byte pos = 0; pos < 3; pos++) printLCD_P(pos, 19, PSTR("<"));
  for (byte pos = 1; pos < 19; pos = pos + 3) {
    lcdWriteCustChar(0, pos + 1, 0);
    lcdWriteCustChar(0, pos + 2, 1);
    lcdWriteCustChar(1, pos, 2); 
    lcdWriteCustChar(1, pos + 1, 3); 
    lcdWriteCustChar(1, pos + 2, 4); 
    lcdWriteCustChar(2, pos, 5); 
    lcdWriteCustChar(2, pos + 1, 6); 
    lcdWriteCustChar(2, pos + 2, 7); 
  }
  updateLCD();
  delay(60);
}
 
