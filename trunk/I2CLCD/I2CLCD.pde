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

LiquidCrystal lcd(3, 4, 5, 6, 7, 8, 9, 14, 15, 16);

byte i2cAddr = 0x01;

void setup() {
  pinMode(10, OUTPUT);
  analogWrite(10, 255);
  lcd.begin(20, 4);
  lcd.setCursor(0, 0);
  lcd.print("I2CLCD");
  lcd.setCursor(0, 1);
  lcd.print("v1");
  lcd.setCursor(0, 2);
  lcd.print("Address: 0x");
  lcd.print(i2cAddr, HEX);
  
  Wire.onReceive(onReceive);
  Wire.begin(i2cAddr);
}

byte i2cBuffer[32];

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
  }
}

void loop() {
}











