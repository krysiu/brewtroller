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

BTDisplay - Auxillary LCD Display for BrewTroller
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

const byte FONT2X2_0[] PROGMEM = {B00000, B00000, B00000, B00000, B00000, B01110, B01110, B01110};
const byte FONT2X2_1[] PROGMEM = {B11111, B11111, B11111, B00000, B00000, B00000, B11111, B11111};
const byte FONT2X2_2[] PROGMEM = {B11110, B11110, B11110, B11110, B11110, B11111, B11111, B11111};
const byte FONT2X2_3[] PROGMEM = {B00000, B00000, B00000, B00000, B00000, B11111, B11111, B11111};
const byte FONT2X2_4[] PROGMEM = {B11111, B11111, B11111, B00000, B00000, B00000, B00000, B00000};
const byte FONT2X2_5[] PROGMEM = {B11111, B11111, B11111, B11110, B11110, B11110, B11111, B11111};
const byte FONT2X2_6[] PROGMEM = {B11111, B11111, B11111, B01111, B01111, B01111, B11111, B11111};
const byte FONT2X2_7[] PROGMEM = {B11111, B11111, B11111, B11110, B11110, B11110, B11110, B11110};

//10-digits 2x2 as Row 1/Col 1, Row 1/Col 2, Row 2/Col 1 and Row 2/Col 2 (0-9, C, F, L, G, SPACE)
byte font2x2Map[15][4] = {
//0
  {7, 255, 
   2, 255},
//1
  {254, 255, 
   254, 255},
//2
  {1, 6, 
   255, 3},
//3
  {1, 6, 
   3, 255},
//4
  {2, 255, 
   254, 255},
//5
  {5, 1, 
   3, 255},
//6
  {5, 1, 
   2, 255},
//7
  {4, 6, 
   254, 255},
//8
  {5, 6, 
   5, 6},
//9
  {5, 6, 
   254, 255},
//C
  {7, 4, 
   2, 3},
//F
  {255, 1, 
   255, 254},
//L
  {255, 254, 
   255, 3},
//G
  {7, 4, 
   2, 6},
//SPACE
  {254, 254, 
   254, 254}
};

byte punc2x2Map[3][2] = {
//SEPERATOR
  {254, 
   254},
//Decimal
  {254, 
   0},
//Colon
  {0, 
   0}
};

void initFont2x2() {
  lcdSetCustChar_P(0, FONT2X2_0);
  lcdSetCustChar_P(1, FONT2X2_1);
  lcdSetCustChar_P(2, FONT2X2_2);
  lcdSetCustChar_P(3, FONT2X2_3);
  lcdSetCustChar_P(4, FONT2X2_4);
  lcdSetCustChar_P(5, FONT2X2_5);
  lcdSetCustChar_P(6, FONT2X2_6);
  lcdSetCustChar_P(7, FONT2X2_7);
}

void printFont2x2(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 2; irow++) {
    for (byte icol = 0; icol < 2; icol++) {
      //0-7: Custom Chars
      if (font2x2Map[digit][irow * 2 + icol] < 8) lcdWriteCustChar(row + irow, col + icol, font2x2Map[digit][irow * 2 + icol]);
      //Otherwise print char by number
      else lcdPrintChar(row + irow, col + icol, font2x2Map[digit][irow * 2 + icol]);
    }
  }
}

void printPunc2x2(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 2; irow++) {
    if (punc2x2Map[digit][irow] < 8) lcdWriteCustChar(row + irow, col, punc2x2Map[digit][irow]);
    //Otherwise print char by number
    else lcdPrintChar(row + irow, col, punc2x2Map[digit][irow]);
  }
}

