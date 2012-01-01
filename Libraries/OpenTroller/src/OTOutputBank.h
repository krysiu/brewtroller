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
#ifndef OT_OUTPUTBANK_H
#define OT_OUTPUTBANK_H

#include <stdint.h>

namespace OpenTroller{

class Output;

/**
  * The types of OutputBank classes supported by the framework.
  */
typedef enum {
    OUTPUTBANK_TYPE_AVRIO,
    OUTPUTBANK_TYPE_MUX,
    OUTPUTBANK_TYPE_MODBUS,
    OUTPUTBANK_TYPE_GROUPS
} OutputBankType;

/**
  * An output bank is a collection of one or more outputs of a single specific type. The purpose of the output bank is to 
  * allow for enumeration of outputs on a device. The output bank also provides an update() method for output types that
  * require updates for changes to take effect (eg Modbus, MUX). This is done to reduce the time spent communicating with
  * external devices.
  * This class is a pure virtual superclass; subclasses must implement full functionality.
  */
class OutputBank {
    protected:
        uint8_t count; /*<! The number of outputs in this bank. */

    public:
		//TODO: These keep throwing errors: undefined reference to `__cxa_pure_virtual'
		/*
        OutputBank(void);
        ~OutputBank(void);
		*/
		
		/**
		  * Returns the count of outputs in the bank.
		  */
        uint8_t getCount(void);
		
		/**
		  * Get an output within the output bank.
		  * @param index The index of the output within the bank.
		  * @return a pointer to the requested output
		  */
        virtual Output* getOutput(uint8_t index) = 0;
		
		/**
		  * Accessor for the name of this output bank.
		  * @return the name of this output bank.  The caller owns the returned string.
		  */
        virtual char* getName(void) = 0;
        
		/**
		  * Accessor for the type of this output bank.
		  * @return the type of this output bank of OutputBankType
		  */
		virtual OutputBankType getType(void) = 0;
        
		/**
		  * Update the output bank pushing the state to the actual output device.
		  */
		virtual void update(void) = 0;
};

} //namespace OpenTroller

#endif //ifndef OT_OUTPUTBANK_H
