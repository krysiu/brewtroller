#define BUILD 666
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
#include "ByteBuffer.h"
#include <util/atomic.h>

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
#define DEBUG_PIN 13

#define REQ_BRIGHT 0
#define REQ_CONTRAST 1
#define NUM_REQ 2

#define EEPROM_FINGERPRINT0 0
#define EEPROM_FINGERPRINT1 1
#define EEPROM_BRIGHT 2
#define EEPROM_CONTRAST 3
#define EEPROM_ROWS 4
#define EEPROM_COLS 5

#define FINGER0 123
#define FINGER1 46
#define DEFAULT_BRIGHT 192
#define DEFAULT_CONTRAST 64
#define DEFAULT_ROWS 4
#define DEFAULT_COLS 20

LiquidCrystal lcd(LCDRS_PIN, LCDENABLE_PIN, LCDDATA1_PIN, LCDDATA2_PIN, LCDDATA3_PIN, LCDDATA4_PIN, LCDDATA5_PIN, LCDDATA6_PIN, LCDDATA7_PIN, LCDDATA8_PIN);

byte i2cAddr = 0x01;
byte brightness = 0;
byte contrast = 255;
byte rows = 4;
byte cols = 20;
byte reqField = REQ_BRIGHT;
ByteBuffer i2cBuffer;

void setup() {
  pinMode(LCDBRIGHT_PIN, OUTPUT);
  pinMode(LCDCONTRAST_PIN, OUTPUT);
  pinMode(DEBUG_PIN, OUTPUT);
  loadEEPROM();
  
  //Serial.begin(115200);
  
  i2cBuffer.init(128);

  lcd.begin(cols, rows);
  lcd.setCursor(0, 0);
  lcd.print("I2CLCD");
  lcd.setCursor(0, 1);
  lcd.print("Build ");
  lcd.print(BUILD, DEC);
  lcd.setCursor(0, 2);
  lcd.print("Address: 0x");
  lcd.print(i2cAddr, HEX);
  
  Wire.onReceive(onReceive);
  Wire.onRequest(onRequest);
  Wire.begin(i2cAddr);
}

void loop() {
  /**
  * Each time through the loop we make an atomic copy of the I2C buffer
  * and then process any commands that are in it. This allows I2C receive
  * happen quickly to avoid overflows and allows us to process commands
  * in the "background". 
  */
  
  byte buffer[128];
  byte length;
  byte *p = buffer;
  
  memset(buffer, 0, 128);
  
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    length = (byte) i2cBuffer.getSize();
  }
  
  for (byte i = 0; i < length; i++) {
    buffer[i] = i2cBuffer.get();
  }

  while ((p - buffer) < length) {
    if ((p[0] >= 0x01 && p[0] <= 0x0C) || p[0] == 0x14) digitalWrite(DEBUG_PIN, HIGH);
    if (p[0] == 0x01) { // begin(cols, rows)
      cols = p[1];
      rows = p[2];
      lcd.begin(cols, rows);
      p += 2;
    }
    else if (p[0] == 0x02) // clear
      lcd.clear();
    else if (p[0] == 0x03) // setCursor(col, row)
    {
      lcd.setCursor(p[1], p[2]);
      p += 2;
    }
    else if (p[0] == 0x04) // print(col, row, char* s)
    {
      lcd.setCursor(p[1], p[2]);
      lcd.print((char *) &p[3]);
      p += 2 + strlen((char *) &p[3]) + 1;
    }
    else if (p[0] == 0x05) // setCustChar(slot, unsigned char data[8])
    {
      lcd.createChar(p[1], &p[2]);
      p += 1 + 8;
    }
    else if (p[0] == 0x06) // writeCustChar(col, row, slot)
    {
      lcd.setCursor(p[1], p[2]);
      lcd.write(p[3]);
      p += 3;
    }
    else if (p[0] == 0x07) // setBright(value)
    {
      p++;
      if (brightness != *p) {
        setBright(*p);
        //delay(10);
      }
    }
    else if (p[0] == 0x08) // setContrast(value)
    {
      p++;
      if (contrast != *p) {
        setContrast(*p++);
        //delay(10);
      }
    }
    else if (p[0] == 0x09) // getBright(value)
    {
      reqField = REQ_BRIGHT;
      delay(10);
    }
    else if (p[0] == 0x0A) // getContrast(value)
    {
      reqField = REQ_CONTRAST;
      delay(10);
    }
    else if (p[0] == 0x0B) saveEEPROM();
    else if (p[0] == 0x0C) loadEEPROM();
    
    else if (p[0] == 0x14) // write(col, row, len, char* s)
    {
      lcd.setCursor(p[1], p[2]);
      byte len = min(p[3], 20 - p[1]); //Do not overwrite row length (20)
      for (byte i = 0; i < len; i++) lcd.write(p[4 + i]);
      p += p[3] + 3;
    }

    // increment for the command byte that was read
    p++;
    digitalWrite(DEBUG_PIN, LOW);
  }
}

void onReceive(int numBytes) {
  for (byte i = 0; i < numBytes; i++) {
    i2cBuffer.put(Wire.receive());
  }
}

void onRequest() {
  if (reqField == REQ_BRIGHT) Wire.send(brightness);
  else if (reqField == REQ_CONTRAST) Wire.send(contrast);
  else Wire.send(1);
  reqField++;
  if (reqField >= NUM_REQ) reqField = 0;
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

void saveEEPROM() {
  EEPROM.write(EEPROM_BRIGHT, brightness);
  EEPROM.write(EEPROM_CONTRAST, contrast);
  EEPROM.write(EEPROM_ROWS, rows);
  EEPROM.write(EEPROM_COLS, cols);
}

void loadEEPROM() {
  //Look for I2CLCD "fingerprint"
  if (EEPROM.read(EEPROM_FINGERPRINT0) == FINGER0 && EEPROM.read(EEPROM_FINGERPRINT1) == FINGER1)  {
    setBright(EEPROM.read(EEPROM_BRIGHT));
    setContrast(EEPROM.read(EEPROM_CONTRAST));
    rows = EEPROM.read(EEPROM_ROWS);
    cols = EEPROM.read(EEPROM_COLS);
  }
  else {
    //Set initial EEPROM values
    EEPROM.write(EEPROM_FINGERPRINT0, FINGER0);
    EEPROM.write(EEPROM_FINGERPRINT1, FINGER1);
    EEPROM.write(EEPROM_BRIGHT, DEFAULT_BRIGHT); //Max
    setBright(DEFAULT_BRIGHT);
    EEPROM.write(EEPROM_CONTRAST, DEFAULT_CONTRAST); //Max
    setContrast(DEFAULT_CONTRAST);
    EEPROM.write(EEPROM_ROWS, DEFAULT_ROWS);
    rows = DEFAULT_ROWS;
    EEPROM.write(EEPROM_COLS, DEFAULT_COLS);
    cols = DEFAULT_COLS;
  }
}


