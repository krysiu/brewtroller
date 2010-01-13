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

#ifdef DISPLAY_20x4
  #define CHAR_INCREMENT 3
#else
  #define CHAR_INCREMENT 2
#endif

void initBigFont() {
  #ifdef DISPLAY_20x4
    initFont3x4();
  #else
    initFont2x2();
  #endif
}

void printLCD_BigFont(byte row, byte col, char sText[]){
  byte pos = 0;
  byte i = 0;
  while (sText[i] != 0)  {
    byte punc = puncLookUp(sText[i]);
    if (punc > 0 || i > 0) {
      #ifdef DISPLAY_20x4
        printPunc3x4(0, pos, punc);
      #else
        printPunc2x2(0, pos, punc);
      #endif
      pos++;
    }
    if (punc > 0) i++;
    if (sText[i] != 0)  {
      #ifdef DISPLAY_20x4
        printFont3x4(0, pos, fontLookUp(sText[i]));
      #else
        printFont2x2(0, pos, fontLookUp(sText[i]));
      #endif
      pos = pos + CHAR_INCREMENT;
      i++;
    }
  }
}

byte fontLookUp(char textChar) {
  if (textChar == '0') return 0;
  else if (textChar == '1') return 1;
  else if (textChar == '2') return 2;
  else if (textChar == '3') return 3;
  else if (textChar == '4') return 4;
  else if (textChar == '5') return 5;
  else if (textChar == '6') return 6;
  else if (textChar == '7') return 7;
  else if (textChar == '8') return 8;
  else if (textChar == '9') return 9;
  else if (textChar == 'C') return 10;
  else if (textChar == 'F') return 11;
  else if (textChar == 'L') return 12;
  else if (textChar == 'G') return 13;
  else return 14;  //SPACE
}

byte puncLookUp(char textChar) {
  if (textChar == '.') return 1;
  else if (textChar == ':') return 2;
  else return 0;  //SEPARATOR
}

