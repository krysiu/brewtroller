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
#ifndef OT_OUTPUT_MODBUS_H
#define OT_OUTPUT_MODBUS_H
#include "OT_HWProfile.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)

#include "OpenTroller.h"
#include "OTOutput.h"

namespace OpenTroller{

class OutputBankMODBUS;

class OutputMODBUS: public Output {
    public:
        OutputMODBUS(void);
        void setup(OutputBankMODBUS* outputBank, uint8_t bankCount);
        void set(State newState);
        uint8_t get(void);
        uint8_t getErr(void);
        char* getName(void);
};

} //namespace OpenTroller
#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
#endif //ifndef OT_OUTPUT_MODBUS_H
