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
#include "OTOutputModbus.h"
#include "OTOutputBankModbus.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
using namespace OpenTroller;

OutputMODBUS::OutputMODBUS(void) {
    state = State_LOW;
    bank = NULL;
}

void OutputMODBUS::setup(OutputBankMODBUS* outputBank, uint8_t bankCount) {
    bank = outputBank;
    index = bankCount;
}

void OutputMODBUS::setState(State newState) {
    if (state != newState) {
        state = newState;
        static_cast<OutputBankMODBUS*>(bank)->doUpdate = 1;
    }
}

uint8_t OutputMODBUS::getErr(void) {
    return static_cast<OutputBankMODBUS*>(bank)->err;
}

#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
