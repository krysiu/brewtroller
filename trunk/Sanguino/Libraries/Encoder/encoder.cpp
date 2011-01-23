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

#include <pin.h>
#include <PinChangeInt.h>
#include <PinChangeIntConfig.h>

#include "encoder.h"

// encoder object c'tor
//
encoder::encoder(void)
{
	_count = 0;
	_min = 0;
	_max = 0;
	_wrap = 0;
}

// initialize encoder using External Interrupt method
//  encType - ALPS or CUI
//  activeLow - true if enter switched to ground
//  encE, encA, encB - pin numbers for enter, phaseA, and phaseB
//  intE, intA - external interrupt numbers of enter and phaseA
//
//  Note: encE & encA must be on INT pins
//
void encoder::begin(byte encType, bool activeLow,
                    byte encE, byte encA, byte encB,
                    byte intE, byte intA)
{
	_count = 0;

  _type = encType;

	_ePin.setup(encE,INPUT);
  _aPin.setup(encA,INPUT);
  _bPin.setup(encB,INPUT);

  _intE = intE;
  _intA = intA;

  _activeLow = activeLow;
  // if activeLow, enable PullUp resistors
  if (_activeLow)
  {
    _aPin.set();
    _bPin.set();
    _ePin.set();
  }

	// attach External Interrupts
  noInterrupts();
  _intMode = EXTERNAL_INT;
  attachInterrupt(_intE, enterISR, CHANGE);
  if(_type == ALPS)
    attachInterrupt(_intA, alpsISR, CHANGE);
  else if(_type == CUI)
    attachInterrupt(_intA, cuiISR, RISING);
  interrupts();
}


// initialize encoder using PinChange Interrupt method
//  encType - ALPS or CUI
//  activeLow - true if enter switched to ground
//  encE, encA, encB - pin numbers for enter, phaseA, and phaseB
//
//  Note: encE & encA must be on the same Port
//  Note: Uses PinChangeInt library 
//
void encoder::begin(byte encType, bool activeLow, 
                    byte encE, byte encA, byte encB)
{
  _count = 0;

  _type = encType;
 
  _ePin.setup(encE, INPUT);
  _aPin.setup(encA, INPUT);
  _bPin.setup(encB, INPUT);

  _activeLow = activeLow;
  if (_activeLow)
  {
    _aPin.set();
    _bPin.set();
    _ePin.set();
  }

  // attach PinChange Interrupts
  noInterrupts();
  _intMode = PINCHANCE_INT;
  PCattachInterrupt(encE, enterISR, CHANGE);
  if (encType == ALPS)
    PCattachInterrupt(encA, alpsISR, CHANGE);
  else
    PCattachInterrupt(encA, cuiISR, CHANGE);
  interrupts();
}


//Detaches the Encoder ISRs
void encoder::end(void)
{
  noInterrupts();
  if (_intMode = PINCHANCE_INT)
  {
    PCdetachInterrupt(_intA);
    PCdetachInterrupt(_intE);
  }
  else
  {
    detachInterrupt(_intA);
    detachInterrupt(_intE);
  }
  interrupts();
}

// return value of encoder pins
//  bit-0 enter
//  bit-1 phase A
//  bit-2 phase B
//
byte  encoder::getPins()
{
  byte btVal = 0x80;
  if (_ePin.get()) btVal |= 0x01;
  if (_aPin.get()) btVal |= 0x02;
  if (_bPin.get()) btVal |= 0x04;
  return btVal;
}



// encoder::getDelta()
//  - compares the current count to the last count
//  - updates last count to the current count
//  - returns the difference
//
int encoder::getDelta(void)
{
	int delta,
		count;

	count = getCount();

	delta = count - _lastCount;
	_lastCount = count;

	return delta;
}


// encoder::change()
//  If the count has not changed since the last time change was called
//    return -1
//  else 
//    update the last count and return the new count
//
int encoder::change(void)
{
  return (getDelta()==0) ? -1 : _count;
}


// return ok state
//  if enterState == 1, reset enterState and return true
//
bool encoder::ok(void)
{
  bool okActive = (_enterState == 1);
  if (okActive)
    _enterState = 0;
  return okActive;
}


// return cancel state
//  if enterState == 2, reset enterState and return true
//
bool encoder::cancel(void)
{
  // check if cancel has already been detected and reported
  if (_enterState == 3)
    return false;

  noInterrupts();

  bool cancelState = (_enterState == 2);
  if (cancelState)
  {
    // enter ISR has detected cancel condition
    _enterState = 0;
  }
  else if (isEnterPinPressed() && isTimeElapsed(millis(), ENTER_LONG_PUSH))
  {
    // cancel condition detected
    cancelState = true;
    _enterState = 3;  // 3=cancel detected prior to release (used by ISR)
  }
  interrupts();
  return cancelState;
}

// ALPS phaseA change handler
//
void encoder::alpsHandler(void) 
{
  
  if(_aPin.get() == _bPin.get())
		decCount();
	else
		incCount();
} 

// CUI phaseA change handler
//
void encoder::cuiHandler(void) 
{
	volatile long time;

	time = millis();

	//if adequate time has not elapsed, bail
	if (time - _lastUpdate < CUI_DEBOUNCE) 
	{
		interrupts();
		return;
	}

	//Read EncB
	if(_bPin.get() == LOW)
		incCount();
	else
		decCount();

	//update the last Encoder interrupt time stamp;
	_lastUpdate = time;
} 

void encoder::enterHandler(void) 
{
	volatile long time = millis();

  // test state of _ePin conditioned by  _activeLow
  if (isEnterPinPressed())
  {  
    // enter button pushed in, set the time stamp
		_enterStartTime = time;
	}
  else
	{
    if (_enterState == 3)
    {
      _enterState = 0;
    }
    else if (isTimeElapsed(time, ENTER_LONG_PUSH))
		{
      // enter button released, check time since pressed
			// > long push, Cancel
      _enterState = 2;
		}
		else if (isTimeElapsed(time, ENTER_SHORT_PUSH)) 
		{
			// < long push, but > short Push
      _enterState = 1;
		}
  }
}


// The one and only Global Encoder Object
encoder Encoder;


// ALPS Encoder Function Interrupt Service Routine wrapper
void alpsISR(void)
{
	Encoder.alpsHandler();
}

// CUI Encoder Function Interrupt Service Routine wrapper
void cuiISR(void)
{
	Encoder.cuiHandler();
}

// Enter Function Interrupt Service Routine wrapper
void enterISR(void)
{
	Encoder.enterHandler();
}

