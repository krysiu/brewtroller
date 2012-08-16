#define BUILD 969
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

#include <LiquidCrystalFP.h>
#include <Wire.h>
#include <EEPROM.h>
#include <pin.h>
#include <encoder.h>
  
//#define I2CLCD_VERSION 1
#define I2CLCD_VERSION 2

#if I2CLCD_VERSION == 1
  #define LCD_8BIT
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
#elif I2CLCD_VERSION == 2
  #define LCD_4BIT
  #define LCDRS_PIN 3
  #define LCDENABLE_PIN 4
  #define LCDDATA5_PIN 5
  #define LCDDATA6_PIN 6
  #define LCDDATA7_PIN 7
  #define LCDDATA8_PIN 8
  #define LCDBRIGHT_PIN 10
  #define LCDCONTRAST_PIN 11
  #define DEBUG_PIN 13
  #define ENCODER_SUPPORT
  #define ENCODER_TYPE 0
  #define ENCODER_ACTIVELOW
  #define ENCA_PIN 14
  #define ENCB_PIN 15
  #define ENTER_PIN 16
#endif

typedef enum {
  REQ_BRIGHT,
  REQ_CONTRAST,
  REQ_VERSION,
#ifdef ENCODER_SUPPORT
  REQ_ENCCOUNT,
  REQ_ENCCHANGE,
  REQ_ENCDELTA,
  REQ_ENCENTERSTATE,
  REQ_ENCOK,
  REQ_ENCCANCEL,
#endif
  NUM_REQ
} RequestType;


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

#if defined LCD_8BIT
  LiquidCrystal lcd(LCDRS_PIN, LCDENABLE_PIN, LCDDATA1_PIN, LCDDATA2_PIN, LCDDATA3_PIN, LCDDATA4_PIN, LCDDATA5_PIN, LCDDATA6_PIN, LCDDATA7_PIN, LCDDATA8_PIN);
#elif defined LCD_4BIT
  LiquidCrystal lcd(LCDRS_PIN, LCDENABLE_PIN, LCDDATA5_PIN, LCDDATA6_PIN, LCDDATA7_PIN, LCDDATA8_PIN);
#endif

byte i2cAddr = 0x01;
byte brightness = 0;
byte contrast = 255;
byte rows = 4;
byte cols = 20;
byte reqField = REQ_BRIGHT;

#ifdef DEBUG_PIN
  pin debug;
#endif

void onReceive(int numBytes) {
#ifdef DEBUG_PIN
  debug.set();
#endif
  switch (Wire.receive()) {
    case 0x01: // begin(cols, rows)
      cols = Wire.receive();
      rows = Wire.receive();
      lcd.begin(cols, rows);
      break;
    case 0x02: // clear
      lcd.clear();
      break;
    case 0x03: // setCursor(col, row)
      {
          byte c = Wire.receive();
          byte r = Wire.receive();
          lcd.setCursor(c, r);
      }
      break;
    case 0x04: // print(col, row, char* s)
      {
        byte c = Wire.receive();
        byte r = Wire.receive();
        lcd.setCursor(c, r);
        while (Wire.available()) lcd.write(Wire.receive());
      }
      break;
    case 0x05: // setCustChar(slot, unsigned char data[8])
    {
      byte s = Wire.receive();
      byte c[8];
      for (byte i = 0; i < 8; i++) c[i] = Wire.receive();
      lcd.createChar(s, c);
      break;
    }
    case 0x06: // writeCustChar(col, row, slot)
      {
        byte c = Wire.receive();
        byte r = Wire.receive();
        lcd.setCursor(c, r);
        lcd.write(Wire.receive());
      }
      break;
    case 0x07: // setBright(value)
      {
        byte b = Wire.receive();
        if (brightness != b) {
          setBright(b);
        }
      }
      break;
    case 0x08: // setContrast(value)
      {
        byte c = Wire.receive();
        if (contrast != c) {
          setContrast(c);
        }
      }
      break;
    case 0x09: // getBright(value)
      reqField = REQ_BRIGHT;
      break;
    case 0x0A: // getContrast(value)
      reqField = REQ_CONTRAST;
      break;
    case 0x0B:
      saveEEPROM();
      break;
    case 0x0C: 
      loadEEPROM();
      break;
    case 0x14: // write(col, row, len, char* s)
      {
        byte c = Wire.receive();
        byte r = Wire.receive();
        lcd.setCursor(c, r);
        byte len = min(Wire.receive(), 20 - c); //Do not overwrite row length (20)
        for (byte i = 0; i < len; i++) lcd.write(Wire.receive());
      }
      break;
    case 0x15: // write(char c)
      lcd.write(Wire.receive());
      break;
    case 0x16: // getVersion()
      reqField = REQ_VERSION;
      break;
#ifdef ENCODER_SUPPORT
    case 0x40: //Encoder.setMin
      {
        int val = Wire.receive();
        val = (val<<8) + Wire.receive();
        Encoder.setMin(val);
      }
      break;
    case 0x41: //Encoder.setMax
      {
        int val = Wire.receive();
        val = (val<<8) + Wire.receive();
        Encoder.setMax(val);
      }
      break;
    case 0x42: //Encoder.setWrap
      Encoder.setWrap((bool) Wire.receive());
      break;
    case 0x43: //Encoder.setCount
      {
        int val = Wire.receive();
        val = (val<<8) + Wire.receive();
        Encoder.setCount(val);
      }
      break;
    case 0x44: //Encoder.clearCount
      Encoder.clearCount();
      break;
    case 0x45: //Encoder.clearEnterState
      Encoder.clearEnterState();
      break;
    case 0x46: // Encoder.getCount
      reqField = REQ_ENCCOUNT;
      break;
    case 0x47: // Encoder.change
      reqField = REQ_ENCCHANGE;
      break;
    case 0x48: // Encoder.getDelta
      reqField = REQ_ENCDELTA;
      break;
    case 0x49: // Encoder.getEnterState
      reqField = REQ_ENCENTERSTATE;
      break;
    case 0x4A: // Encoder.ok
      reqField = REQ_ENCOK;
      break;
    case 0x4B: // Encoder.cancel
      reqField = REQ_ENCCANCEL;
      break;
#endif
  }
#ifdef DEBUG_PIN
  debug.clear();
#endif
}

void onRequest() {
  switch (reqField) {
    case REQ_BRIGHT:
      Wire.send(brightness);
      break;
    case REQ_CONTRAST:
      Wire.send(contrast);
      break;
    case REQ_VERSION:
      {
        int value = BUILD;
        uint8_t * p = (uint8_t *) &value;
        Wire.send(p, 2);
      }
      break;
#ifdef ENCODER_SUPPORT
    case REQ_ENCCOUNT:
      {
        int value = Encoder.getCount();
        uint8_t * p = (uint8_t *) &value;
        Wire.send(p, 2);
      }
      break;
    case REQ_ENCCHANGE:
      {
        int value = Encoder.change();
        uint8_t * p = (uint8_t *) &value;
        Wire.send(p, 2);
      }
      break;
    case REQ_ENCDELTA:
      {
        int value = Encoder.getDelta();
        uint8_t * p = (uint8_t *) &value;
        Wire.send(p, 2);
      }
      break;  
    case REQ_ENCENTERSTATE:
      Wire.send(Encoder.getEnterState());
      break;
    case REQ_ENCOK:
      Wire.send(Encoder.ok());
      break;
    case REQ_ENCCANCEL:
      Wire.send(Encoder.cancel());
      break;
#endif
    default:
      Wire.send(255);
      break;
  }
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

void setup() {
  pinMode(LCDBRIGHT_PIN, OUTPUT);
  pinMode(LCDCONTRAST_PIN, OUTPUT);
#ifdef DEBUG_PIN
  debug.setup(DEBUG_PIN, OUTPUT);
#endif
  
  //Change PWM Freq for smooth contrast/brightness
  TCCR1B = 0x01;   // Timer 1: PWM 9 & 10 @ 32 kHz
  TCCR2B = 0x01;   // Timer 2: PWM 3 & 11 @ 32 kHz

#ifdef ENCODER_SUPPORT
  Encoder.begin(ENCODER_TYPE, ENTER_PIN, ENCA_PIN, ENCB_PIN);
  #ifdef ENCODER_ACTIVELOW
    Encoder.setActiveLow(1);
  #endif
#endif
  loadEEPROM();
  
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
 
}
