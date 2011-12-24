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
#ifndef OT_OUTPUT_H
#define OT_OUTPUT_H

#include "OT_HWProfile.h"
#ifdef OPENTROLLER_OUTPUTS

#include "OpenTroller.h"

namespace OpenTroller{

class OutputBank;

/**
  * The base class of all output objects, this class is the inteface to an outout source.
  */
class Output {
  protected:
    uint8_t err;
    uint8_t index;
    /**
      * The state of the output.
      */
    State state;
    OutputBank* bank;

  public:
    Output();
    virtual ~Output();
    virtual uint8_t get(void);

    /**
      * Set the state of the output.
      * @param state the new state of the pin.
      */
    virtual void set(State newState) = 0;
    virtual uint8_t getErr(void);
    virtual char* getName(void);
};

} //namespace OpenTroller
#endif //ifdef OPENTROLLER_OUTPUTS
#endif //ifndef OT_OUTPUT_H
