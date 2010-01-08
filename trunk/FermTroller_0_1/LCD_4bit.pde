/*
   Copyright (C) 2009, 2010 Matt Reba, Jermeiah Dillingham

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

FermTroller - Open Source Fermentation Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 17	  (LCD pin 4 ) aka DI
// rw on pin 18	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)

#ifdef BTBOARD_3
  LiquidCrystal lcd(18, 19, 20, 21, 22, 23);
#else
  LiquidCrystal lcd(17, 19, 20, 21, 22, 23);
#endif 

void initLCD(){
  lcd.begin(20, 4);
}

void printLCD(byte iRow, byte iCol, char sText[]){
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
}  

//Version of PrintLCD reading from PROGMEM
void printLCD_P(byte iRow, byte iCol, const char *sText){
  lcd.setCursor(iCol, iRow);
  while (pgm_read_byte(sText) != 0) {
    lcd.print(pgm_read_byte(sText++)); 
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
} 

void clearLCD(){ lcd.clear(); }

void printLCDCenter(byte iRow, byte iCol, char sText[], byte fieldWidth){
  printLCDRPad(iRow, iCol, "", fieldWidth, ' ');
  if (strlen(sText) < fieldWidth) lcd.setCursor(iCol + ((fieldWidth - strlen(sText)) / 2), iRow);
  else lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif

  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }

} 

char printLCDLPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  if (strlen(sText) < length) {
    for (byte i=0; i < length-strlen(sText); i++) {
      lcd.print(pad);
      #ifdef LCD_DELAY_CHAR
        delayMicroseconds(LCD_DELAY_CHAR);
      #endif
    }
  }
  
  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }

}  

char printLCDRPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif

  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
  
  if (strlen(sText) < length) {
    for (byte i=0; i < length-strlen(sText) ; i++) {
      lcd.print(pad);
      #ifdef LCD_DELAY_CHAR
        delayMicroseconds(LCD_DELAY_CHAR);
      #endif
    }
  }
}  

void lcdSetCustChar_P(byte slot, const byte *charDef) {
  lcd.command(64 | (slot << 3));
  for (byte i = 0; i < 8; i++) {
    lcd.write(pgm_read_byte(charDef++));
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
  lcd.command(B10000000);
}

void lcdWriteCustChar(byte iRow, byte iCol, byte slot) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  lcd.write(slot);
}
