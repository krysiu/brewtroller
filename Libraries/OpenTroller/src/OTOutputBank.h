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
#ifndef OT_OUTPUTBANK_H
#define OT_OUTPUTBANK_H

#include "OT_HWProfile.h"
#ifdef OPENTROLLER_OUTPUTS

#include "OTOutput.h"
#include <stdint.h>

namespace OpenTroller{

class Output;

typedef enum {
    OUTPUTBANK_TYPE_GPIO,
    OUTPUTBANK_TYPE_MUX,
    OUTPUTBANK_TYPE_MODBUS,
    OUTPUTBANK_TYPE_GROUPS
} OutputBankType;

/**
  * An output bank is a type of output that by it's nature is more than a single output; there
  * are a bank of outputs.
  * (more needed)
  * This class is a pure virtual superclass; subclasses must implement full finctionality.
  */
class OutputBank {
    protected:
        uint8_t count; /*<! The number of outputs in this bank. */

    public:
        //OutputBank(void);
        //~OutputBank(void);

        uint8_t getCount(void);
        virtual Output* getOutput(uint8_t index) = 0;
        virtual char* getName(void) = 0;
        virtual OutputBankType getType(void) = 0;
        virtual void update(void) = 0;
};

} //namespace OpenTroller

#endif //ifdef OPENTROLLER_OUTPUTS
#endif //ifndef OT_OUTPUTBANK_H
