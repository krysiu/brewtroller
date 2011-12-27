/*  
   Copyright (C) 2011 Open Source Control Systems

    This file is part of OpenTroller Framework.

    OpenTroller Framework is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenTroller Framework is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenTroller Framework.  If not, see <http://www.gnu.org/licenses/>.


OpenTroller Framework - Open Source Control System Framework
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.oscsys.com
*/



#include "OT_LCD.h"
using namespace OpenTroller;

void LCD_Generic::begin(uint8_t cols, uint8_t rows) {
	_cols = cols;
	_rows = rows;
	_screen = (uint8_t *) malloc(_rows * _cols * sizeof(uint8_t));
	init();
	clear();
	memset(_custChars, 0, 64);
}

void LCD_Generic::print(const char *sText) {
	while (*sText) write(*sText++);
}

void LCD_Generic::write(uint8_t data) {
	if (data == '\n') _pos = _pos / _cols * _cols + _cols;
	else _screen[_pos++] = data;
	if (_pos >= _rows * _cols) _pos = 0;
}  

void LCD_Generic::setCursor(uint8_t row, uint8_t col) { 
	_pos = col + row * _cols; 
	if (_pos >= _rows * _cols) _pos = 0;
}

void LCD_Generic::clear() { _pos = 0; memset(_screen, ' ', _rows * _cols); }

void LCD_Generic::printPad(const char *sText, uint8_t fieldWidth, uint8_t padMode, char pad) {
	uint8_t endPos = _pos + fieldWidth;
	memset(_screen + _pos, pad, fieldWidth);
	if (padMode == PAD_CENTER) _pos += (fieldWidth - strlen(sText)) / 2;
	else if (padMode == PAD_LEFT) _pos += fieldWidth - strlen(sText);
	print(sText);
	_pos = endPos;
}

void LCD_Generic::printPad(long value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) {
	char sText[11];
	ltoa(value, sText, base);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::printPad(unsigned long value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) {
	char sText[11];
	ultoa(value, sText, base);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::printPad(uint8_t value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) { printPad((unsigned long) value, fieldWidth, padMode, pad, base); }
void LCD_Generic::printPad(int value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) { printPad((long) value, fieldWidth, padMode, pad, base); }
void LCD_Generic::printPad(unsigned int value, uint8_t fieldWidth, uint8_t padMode, char pad, uint8_t base) { printPad((unsigned long) value, fieldWidth, padMode, pad, base); }

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

void LCD_Generic::printVFloatPad(unsigned long val, unsigned int divisor, uint8_t fieldWidth, uint8_t padMode, char pad) {
	char sText[11];
	Utility.vftoa(val, sText, divisor, 1);
	Utility.truncFloat(sText, fieldWidth);
	printPad(sText, fieldWidth, padMode, pad);
}

void LCD_Generic::setCustChar_P(uint8_t index, const uint8_t *charDef) {
	for (uint8_t i = 0; i < 8; i++) {
		_custChars[index][i] = pgm_read_byte(charDef++);
	}
}

void LCD_Generic::getScreen(uint8_t * retString) {
	memcpy(retString, _screen, 80);
}
void LCD_Generic::getCustChars(uint8_t * retString) {
	memcpy(retString, _custChars, 64);
}



LCD4Bit::LCD4Bit(uint8_t rs, uint8_t enable, uint8_t d4, uint8_t d5, uint8_t d6, uint8_t d7) {
	_lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
	_bcControl = 0;
}
LCD4Bit::LCD4Bit(uint8_t rs, uint8_t enable, uint8_t d4, uint8_t d5, uint8_t d6, uint8_t d7, uint8_t b, uint8_t c) {
	_lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
	_brightPin = b;
	_contrastPin = c;
	_bcControl = 1;
}

void LCD4Bit::init() {
	TCCR2B = 0x01;
	pinMode(_brightPin, OUTPUT);
	pinMode(_contrastPin, OUTPUT);
    setBright(LCD_DEFAULTBRIGHT);
    setContrast(LCD_DEFAULTCONTRAST);
	_lcd->begin(_cols, _rows);
}

void LCD4Bit::update() {
	for (uint8_t cIndex = 0; cIndex < 8; cIndex++) {
		_lcd->command(64 | (cIndex << 3));
		for (uint8_t i = 0; i < 8; i++) _lcd->write(_custChars[cIndex][i]);
		_lcd->command(1<<7);
	}
	for (uint8_t row = 0; row < _rows; row++) {
		_lcd->setCursor(0, row);
		for (uint8_t i = 0; i < _cols; i++) _lcd->write(_screen[row * _cols + i]);
	}
}
  
void LCD4Bit::setBright(uint8_t val) {
	if (_bcControl) analogWrite(_brightPin, 255 - val);
	_bright = val;
}

void LCD4Bit::setContrast(uint8_t val) {
	if (_bcControl) analogWrite(_contrastPin, val);
	_contrast = val;
}

uint8_t LCD4Bit::getBright(void) { return _bright; }
uint8_t LCD4Bit::getContrast(void) { return _contrast; }
  
LCDI2C::LCDI2C(uint8_t addr) { i2cLCDAddr = addr; }

void LCDI2C::init() {
	//Initialize display on each update
	Wire.begin();
	Wire.beginTransmission(i2cLCDAddr);
	Wire.send(0x01);
	Wire.send(20);
	Wire.send(4);
	Wire.endTransmission();
	delay(5);
}

void LCDI2C::update() {
	//Send all custom chars
	for (uint8_t cIndex = 0; cIndex < 8; cIndex++) {
		Wire.beginTransmission(i2cLCDAddr);
		Wire.send(0x05);
		Wire.send(cIndex);
		for (uint8_t i = 0; i < 8; i++) Wire.send(_custChars[cIndex][i]);
		Wire.endTransmission();
		delay(5);
	}

	//Update screen data
	for (uint8_t row = 0; row < _rows; row++) {
		Wire.beginTransmission(i2cLCDAddr);
		Wire.send(0x14);
		Wire.send(0);
		Wire.send(row);
		Wire.send(_cols);
		for (uint8_t i = 0; i < _cols; i++) Wire.send(_screen[row * _cols + i]);
		Wire.endTransmission();
		delay(3);
	}
}

void LCDI2C::setBright(uint8_t val) {
	Wire.beginTransmission(i2cLCDAddr);
	Wire.send(0x07);
	Wire.send(val);
	Wire.endTransmission();
	delay(3);
}

void LCDI2C::setContrast(uint8_t val) {
	Wire.beginTransmission(i2cLCDAddr);
	Wire.send(0x08);
	Wire.send(val);
	Wire.endTransmission();
	delay(3);
}

uint8_t LCDI2C::getBright(void) {
	Wire.beginTransmission(i2cLCDAddr);
	Wire.send(0x09);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cLCDAddr, (int)1);
	if (Wire.available()) return Wire.receive();
}

uint8_t LCDI2C::getContrast(void) {
	Wire.beginTransmission(i2cLCDAddr);
	Wire.send(0x0A);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cLCDAddr, (int)1);
	if (Wire.available()) return Wire.receive();
}
//Create the appropriate 'LCD' object for the hardware configuration (4-Bit GPIO, I2C)

#if defined OPENTROLLER_LCD4BIT
  #ifndef UI_DISPLAY_SETUP
    OpenTroller::LCD4Bit OpenTroller::LCD(LCD_RS_PIN, LCD_ENABLE_PIN, LCD_DATA4_PIN, LCD_DATA5_PIN, LCD_DATA6_PIN, LCD_DATA7_PIN);
  #else
    OpenTroller::LCD4Bit OpenTroller::LCD(LCD_RS_PIN, LCD_ENABLE_PIN, LCD_DATA4_PIN, LCD_DATA5_PIN, LCD_DATA6_PIN, LCD_DATA7_PIN, LCD_BRIGHT_PIN, LCD_CONTRAST_PIN);
  #endif
  
#elif defined OPENTROLLER_LCDI2C
  OpenTroller::LCDI2C OpenTroller::LCD(UI_LCD_I2CADDR);
#endif

