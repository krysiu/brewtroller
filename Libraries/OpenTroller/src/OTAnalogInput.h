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
#ifndef OT_ANALOGINPUT_H
#define OT_ANALOGINPUT_H

#include <stdint.h>
#include "OTAnalogIO.h"

namespace OpenTroller {

class AnalogInputBank;

/**
  * The base class of all analog input objects, this class is the inteface to an analog input source.
  */
class AnalogInput : public AnalogIO {
	protected:
	/**
      * The value of the analog input.
      */  	
	int32_t value;
	
	/**
      * The error state of the analog input.
      */  
	  uint8_t err;

	/**
      * The analog input's index in its parent bank.
      */
    uint8_t index;
	
	/**
      * The analog input's parent bank 
      */
    AnalogInputBank* bank;
	
	public:
	/**
      * Accessor for the value of this analog input.
      * @return the value of the analog input.
      */
	virtual int32_t getValue(void);
	
    /**
      * Accessor for the error state of this analog input.
      * @return the error state of the analog input.
      */
	virtual uint8_t getErr(void);
	
    /**
      * Accessor for the name of this analog input.
      * @return the name of this analog input.  The caller owns the returned string.
      */
	virtual char* getName(void);
};

}

#endif //ifndef OT_ANALOGINPUT_H