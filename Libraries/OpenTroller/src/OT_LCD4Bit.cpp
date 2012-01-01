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

#include "OT_LCD4Bit.h"

#if (defined OPENTROLLER_LCD && defined LCD_4BIT)

using namespace OpenTroller;

LCD4Bit::LCD4Bit(uint8_t rs, uint8_t enable, uint8_t d4, uint8_t d5, uint8_t d6, uint8_t d7) {
    _lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
    bcControl = 0;
}
LCD4Bit::LCD4Bit(uint8_t rs,
                 uint8_t enable,
                 uint8_t d4,
                 uint8_t d5,
                 uint8_t d6,
                 uint8_t d7,
                 uint8_t b,
                 uint8_t c) {
    _lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
    brightPin = b;
    contrastPin = c;
    bcControl = 1;
}

void LCD4Bit::init() {
    TCCR2B = 0x01;
    pinMode(brightPin, OUTPUT);
    pinMode(contrastPin, OUTPUT);
    setBright(LCD4BIT_DEFAULTBRIGHT);
    setContrast(LCD4BIT_DEFAULTCONTRAST);
    _lcd->begin(columns, rows);
}

void LCD4Bit::update() {
    for (uint8_t cIndex = 0; cIndex < 8; cIndex++) {
        _lcd->command(64 | (cIndex << 3));
        for (uint8_t i = 0; i < 8; i++) _lcd->write(characters[cIndex][i]);
        _lcd->command(1<<7);
    }
    for (uint8_t row = 0; row < rows; row++) {
        _lcd->setCursor(0, row);
        for (uint8_t i = 0; i < columns; i++) _lcd->write(screen[row * columns + i]);
    }
}

void LCD4Bit::setBright(uint8_t val) {
    if (bcControl) analogWrite(brightPin, 255 - val);
    bright = val;
}

void LCD4Bit::setContrast(uint8_t val) {
    if (bcControl) analogWrite(contrastPin, val);
    contrast = val;
}

uint8_t LCD4Bit::getBright(void) { return bright; }
uint8_t LCD4Bit::getContrast(void) { return contrast; }

#endif //if (defined OPENTROLLER_LCD && defined LCD_4BIT)

