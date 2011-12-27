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
#ifdef OPENTROLLER_LCDI2C
using namespace OpenTroller;

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
OpenTroller::LCDI2C OpenTroller::LCD(UI_LCD_I2CADDR);
#endif

