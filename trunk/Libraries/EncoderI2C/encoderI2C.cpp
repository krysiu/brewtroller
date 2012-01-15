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


  Original Author:  Matt Reba & Jason Vreeland (CodeRage)
  Modified By:      Tom Harkaway, Feb, 2011

  Modifications:

  1. Modified existing begin() method. 
    - Change order of parameter
    - Added an boolean "ActiveLow" parameter to specify if the encoder's switches
      are wired active-low (i.e. switch to ground). If it is active-low, the sense
      of the enter switch is reversed.
    - Require that the external interrupt number for both EncE and EncA be specified.

  2. Added a new begin() method that uses PinChange interrupts rather than External 
     interrupts for the EncE and EncA switches. Uses new PCInt functions added
     to FastPin library

  3. Modified Cancel logic so it triggers as soon as the cancel timeout had been reached
     rather than wait for enter to be released.

  4. General reorganization and additional comments.

***********************************************************/

#include "encoderI2C.h"
#include <Wire.h>
  
void encoderI2C::begin(uint8_t i2cAddr) {
	i2CAddress = i2cAddr;
}

void encoderI2C::setMin(int val) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x40);
	Wire.send(val>>8);
	Wire.send(val&255);
	Wire.endTransmission();
}

void encoderI2C::setMax(int val) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x41);
	Wire.send(val>>8);
	Wire.send(val&255);
	Wire.endTransmission();
}

void encoderI2C::setWrap(bool val) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x42);
	Wire.send(val);
	Wire.endTransmission();
}

void encoderI2C::setCount(int val) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x43);
	Wire.send(val>>8);
	Wire.send(val&255);
	Wire.endTransmission();
}

void encoderI2C::clearCount(void) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x44);
	Wire.endTransmission();
}

void encoderI2C::clearEnterState(void) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x45);
	Wire.endTransmission();
}

int  encoderI2C::getCount(void) {
	int retValue = 0;
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x46);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)2);
	while(Wire.available())
	{
		retValue = retValue << 8;
		retValue &= Wire.receive();
	}
	return retValue;
}

int  encoderI2C::change(void) {
	int retValue = 0;
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x47);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)2);
	while(Wire.available())
	{
		retValue = retValue << 8;
		retValue &= Wire.receive();
	}
	return retValue;
}

int  encoderI2C::getDelta(void) {
	int retValue = 0;
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x48);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)2);
	while(Wire.available())
	{
		retValue = retValue << 8;
		retValue &= Wire.receive();
	}
	return retValue;
}

uint8_t encoderI2C::getEnterState(void) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x49);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)1);
	while(Wire.available())
	{
		return; Wire.receive();
	}
}

bool encoderI2C::ok(void) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x4A);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)1);
	while(Wire.available())
	{
		return; Wire.receive();
	}
}

bool encoderI2C::cancel(void) {
	Wire.beginTransmission(i2cAddress);
	Wire.send(0x4B);
	Wire.endTransmission();
	Wire.requestFrom((int)i2cAddress, (int)1);
	while(Wire.available())
	{
		return; Wire.receive();
	}
}

// The one and only Global Encoder Object
encoderI2C Encoder;

