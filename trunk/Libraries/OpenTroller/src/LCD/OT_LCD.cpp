/*
    Copyright (C) 2011 Matt Reba (mattreba at oscsys dot com)
    Copyright (C) 2011 Timothy Reaves (treaves at silverfieldstech dot com)

    This file is part of OpenTroller.

    OpenTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenTroller.  If not, see <http://www.gnu.org/licenses/>.


*/

#include "OT_LCD.h"
#include "OT_Util.h"
using namespace OpenTroller;

void LCD_Generic::begin(uint8_t columnCount, uint8_t rowCount) {
    columns = columnCount;
    rows = rowCount;
    screen = (uint8_t *) malloc(rows * columns * sizeof(uint8_t));
	init();
	clear();
    memset(characters, 0, 64);
}

void LCD_Generic::print(const char *sText) {
	while (*sText) write(*sText++);
}

void LCD_Generic::write(uint8_t data) {
    if (data == '\n') position = position / columns * columns + columns;
    else screen[position++] = data;
    if (position >= rows * columns) position = 0;
}  

void LCD_Generic::setCursor(uint8_t row, uint8_t col) { 
    position = col + row * columns;
    if (position >= rows * columns) position = 0;
}

void LCD_Generic::clear() { position = 0; memset(screen, ' ', rows * columns); }

void LCD_Generic::printPad(const char *sText, uint8_t fieldWidth, uint8_t padMode, char pad) {
    uint8_t endPos = position + fieldWidth;
    memset(screen + position, pad, fieldWidth);
    if (padMode == PAD_CENTER) position += (fieldWidth - strlen(sText)) / 2;
    else if (padMode == PAD_LEFT) position += fieldWidth - strlen(sText);
	print(sText);
    position = endPos;
}

void LCD_Generic::printPad(long value,
                           uint8_t fieldWidth,
                           uint8_t padMode,
                           char pad,
                           uint8_t base) {
	char sText[11];
	ltoa(value, sText, base);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::printPad(unsigned long value,
                           uint8_t fieldWidth,
                           uint8_t padMode,
                           char pad,
                           uint8_t base) {
	char sText[11];
	ultoa(value, sText, base);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::printPad(uint8_t value,
                           uint8_t fieldWidth,
                           uint8_t padMode,
                           char pad,
                           uint8_t base) {
    printPad((unsigned long) value, fieldWidth, padMode, pad, base);
}

void LCD_Generic::printPad(int value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) {
    printPad((long) value, fieldWidth, padMode, pad, base);
}

void LCD_Generic::printPad(unsigned int value,
                           uint8_t fieldWidth,
                           uint8_t padMode,
                           char pad,
                           uint8_t base) {
    printPad((unsigned long) value, fieldWidth, padMode, pad, base);
}

//Version of PrintLCD reading from PROGMEM
void LCD_Generic::print_P(const char *pText){
	while (pgm_read_byte(pText)) write(pgm_read_byte(pText++));
} 

void LCD_Generic::printPad_P(const char *pText, uint8_t fieldWidth, uint8_t padMode, char pad) {
	char sText[fieldWidth];
	strcpy_P(sText, pText);
	printPad(sText, fieldWidth, padMode, pad);
} 

void LCD_Generic::printVFloat(unsigned long val, unsigned int divisor, uint8_t fieldWidth) {
	char sText[11];
	Utility.vftoa(val, sText, divisor, 1);
	Utility.truncFloat(sText, fieldWidth);
	print(sText);
}

void LCD_Generic::printVFloatPad(unsigned long val,
                                 unsigned int divisor,
                                 uint8_t fieldWidth,
                                 uint8_t padMode,
                                 char pad) {
	char sText[11];
	Utility.vftoa(val, sText, divisor, 1);
	Utility.truncFloat(sText, fieldWidth);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::setCustChar_P(uint8_t index, const uint8_t *charDef) {
	for (uint8_t i = 0; i < 8; i++) {
        characters[index][i] = pgm_read_byte(charDef++);
	}
}

void LCD_Generic::getScreen(uint8_t * retString) {
    memcpy(retString, screen, 80);
}
void LCD_Generic::getCustChars(uint8_t * retString) {
    memcpy(retString, characters, 64);
}

