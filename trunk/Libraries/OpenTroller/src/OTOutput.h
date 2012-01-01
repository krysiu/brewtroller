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
#ifndef OT_OUTPUT_H
#define OT_OUTPUT_H

#include <stdint.h>
#include "OpenTroller.h"
#include "OTDigitalIO.h"

namespace OpenTroller{

class OutputBank;

/**
  * The base class of all output objects, this class is the inteface to an output source.
  */
class Output : public DigitalIO {
  protected:
    /**
      * The error state of the output.
      */  
    uint8_t err;
	
	/**
      * The output's index in its parent bank.
      */
    uint8_t index;
	
    /**
      * The state of the output.
      */
    State state;
	
	/**
      * The output's parent bank 
      */
    OutputBank* bank;

  public:
	//TODO: These keep throwing errors: undefined reference to `__cxa_pure_virtual'
	/*
    Output();
    ~Output();
	*/
    /**
      * Accessor for the state of this output.
      * @return the state of the output.
      */
    virtual State getState(void);

    /**
      * Set the state of the output.
      * @param newState the new state of the pin.
      */
    virtual void setState(State newState) = 0;
	
    /**
      * Accessor for the error state of this output.
      * @return the error state of the output.
      */
    virtual uint8_t getErr(void);

    /**
      * Accessor for the name of this output.
      * @return the name of this output.  The caller owns the returned string.
      */
    virtual char* getName(void);
};

} //namespace OpenTroller
#endif //ifndef OT_OUTPUT_H
