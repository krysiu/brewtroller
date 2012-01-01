/*
    Copyright (C) 2011 Matt Reba (mattreba at oscsys dot com)
    Copyright (C) 2011 Timothy Reaves (treaves at silverfieldstech dot com)

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


*/
#ifndef OT_ANALOGINPUTBANK_H
#define OT_ANALOGINPUTBANK_H

#include <stdint.h>

namespace OpenTroller {

class AnalogInput;

/**
  * Types of AnalogInput classes supported by the framework.
  */
typedef enum {
    ANALOGINPUTBANK_TYPE_AVRIO,		//AVR Analog IO
    ANALOGINPUTBANK_TYPE_MODBUS,	//Modbus RTU
    ANALOGINPUTBANK_TYPE_DS18B20,	//1-Wire Temperature Sensor
	ANALOGINPUTBANK_TYPE_DS2760,	//1-Wire Current Sensor
	ANALOGINPUTBANK_TYPE_DS2450,	//1-Wire Quad ADC
	ANALOGINPUTBANK_TYPE_COUNTER,	//Counter with optional period (eg pulses /sec)
	ANALOGINPUTBANK_TYPE_CALIBMAP	//Calibration Map (eg Analog Value to Value)
} AnalogInputBankType;

/**
  * An analog input bank is a collection of one or more analog inputs of a single specific type. The bank allows for 
  * enumeration of analog inputs on a device. The bank also provides an update() method for types that require updates
  * for changes to take effect (eg (Most)). This is done to reduce the time spent communicating with external devices.
  * This class is a pure virtual superclass; subclasses must implement full functionality.
  */
class AnalogInputBank {
    protected:
        uint8_t count; /*<! The number of analog inputs in this bank. */

    public:
		/**
		  * Returns the count of analog inputs in the bank.
		  */
        uint8_t getCount(void);
		
		/**
		  * Get an analog input within the bank.
		  * @param index The index of the analog input within the bank.
		  * @return a pointer to the requested analog input
		  */
        virtual AnalogInput* getAnalogInput(uint8_t index) = 0;
		
		/**
		  * Accessor for the name of this analog input bank.
		  * @return the name of this bank.  The caller owns the returned string.
		  */
        virtual char* getName(void) = 0;
        
		/**
		  * Accessor for the type of this analog input bank.
		  * @return the type of this bank of AnalogInputBankType
		  */
		virtual AnalogInputBankType getType(void) = 0;
        
		/**
		  * Update the bank pulling value(s) from device.
		  */
		virtual void update(void) = 0;
};

} //namespace OpenTroller

#endif //ifndef OT_ANALOGINPUTBANK_H
