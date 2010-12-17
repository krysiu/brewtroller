/*  
  Copyright (C) 2010 Jason von Nieda

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.


BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com
*/

#include <LiquidCrystal.h>
#include <Wire.h>
#include <EEPROM.h>

#define LCDRS_PIN 3
#define LCDENABLE_PIN 4
#define LCDDATA1_PIN 5
#define LCDDATA2_PIN 6
#define LCDDATA3_PIN 7
#define LCDDATA4_PIN 8
#define LCDDATA5_PIN 9
#define LCDDATA6_PIN 14
#define LCDDATA7_PIN 15
#define LCDDATA8_PIN 16
#define LCDBRIGHT_PIN 10
#define LCDCONTRAST_PIN 11

#define REQ_BRIGHT 0
#define REQ_CONTRAST 1
#define NUM_REQ 2

LiquidCrystal lcd(LCDRS_PIN, LCDENABLE_PIN, LCDDATA1_PIN, LCDDATA2_PIN, LCDDATA3_PIN, LCDDATA4_PIN, LCDDATA5_PIN, LCDDATA6_PIN, LCDDATA7_PIN, LCDDATA8_PIN);

byte i2cAddr = 0x01;
byte brightness = 0;
byte contrast = 255;
byte i2cBuffer[32];
byte reqField = REQ_BRIGHT;

void setup() {
  loadEEPROM();
  pinMode(LCDBRIGHT_PIN, OUTPUT);
  pinMode(LCDCONTRAST_PIN, OUTPUT);

  lcd.begin(20, 4);
  lcd.setCursor(0, 0);
  lcd.print("I2CLCD");
  lcd.setCursor(0, 1);
  lcd.print("v1");
  lcd.setCursor(0, 2);
  lcd.print("Address: 0x");
  lcd.print(i2cAddr, HEX);
  
  Wire.onReceive(onReceive);
  Wire.onRequest(onRequest);
  Wire.begin(i2cAddr);
}

void onReceive(int numBytes) {
  memset(i2cBuffer, 0, 32);
  for (byte i = 0; i < numBytes; i++) {
    i2cBuffer[i] = Wire.receive();
  }
  switch (i2cBuffer[0]) {
    case 0x01: // begin(cols, rows)
      //
      break;
    case 0x02: // clear
      lcd.clear();
      break;
    case 0x03: // setCursor(col, row)
      lcd.setCursor(i2cBuffer[1], i2cBuffer[2]);
      break;
    case 0x04: // print(col, row, char* s)
      lcd.setCursor(i2cBuffer[1], i2cBuffer[2]);
      lcd.print((char*) &i2cBuffer[3]);
      break;
    case 0x05: // setCustChar(slot, unsigned char data[8])
      lcd.createChar(i2cBuffer[1], &i2cBuffer[2]);
      break;
    case 0x06: // writeCustChar(col, row, slot)
      lcd.setCursor(i2cBuffer[1], i2cBuffer[2]);
      lcd.write(i2cBuffer[3]);
      break;
    case 0x07: // setBright(value)
      setBright(i2cBuffer[2]);
      EEPROM.write(2, i2cBuffer[2]); //Save to EEPROM
      break;
    case 0x08: // setContrast(value)
      setContrast(i2cBuffer[2]);
      EEPROM.write(2, i2cBuffer[3]); //Save to EEPROM
      break;
    case 0x09: // getBright(value)
      reqField = REQ_BRIGHT;
      break;
    case 0x0A: // getContrast(value)
      reqField = REQ_CONTRAST;
      break;
  }
}

void onRequest() {
  if (reqField == REQ_BRIGHT) Wire.send(brightness);
  else if (reqField == REQ_CONTRAST) Wire.send(contrast);
  else Wire.send(1);
  reqField++;
  if (reqField >= NUM_REQ) reqField = 0;
}
void loop() {

}

void panAnalog(byte pin, byte startValue, byte endValue, int delayValue) {
  if (startValue < endValue) for (int i = startValue; i <= endValue; i++) { analogWrite(pin, i); delay(delayValue); }
  else if (startValue > endValue) for (int i = startValue; i >= endValue; i--) { analogWrite(pin, i); delay(delayValue); }
  else analogWrite(pin, startValue);
}

void setBright(byte value) {
  panAnalog(LCDBRIGHT_PIN, brightness, value, 2);
  brightness = value;
}

void setContrast(byte value) {
  panAnalog(LCDCONTRAST_PIN, contrast, value, 2);
  contrast = value;
}

void loadEEPROM() {
  //Look for I2CLCD "fingerprint"
  if (EEPROM.read(0) == 123 && EEPROM.read(1) == 45)  {
    setBright(EEPROM.read(2));
    setContrast(EEPROM.read(3));
  }
  else {
    //Set initial EEPROM values
    EEPROM.write(0, 123);
    EEPROM.write(0, 45);
    EEPROM.write(0, 255); //Max
    setBright(255);
    EEPROM.write(0, 0); //Max
    setContrast(0);
  }
}
