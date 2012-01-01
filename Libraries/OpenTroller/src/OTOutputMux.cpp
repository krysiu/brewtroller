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
#include "OTOutputMux.h"

#if defined OUTPUTBANK_MUX
using namespace OpenTroller;

OutputMUX::OutputMUX(void) {
    err = value = 0;
    bank = NULL;
}

void OutputMUX::setup(OutputBankMUX* outputBank, uint8_t theIndex) {
    bank = outputBank;
    index = theIndex;
}

void OutputMUX::setState(State newState) {
    if (state != newState) {
        state = newState;
        static_cast<OutputBankMux*>(bank)->doUpdate = 1;
    }

}

uint8_t OutputMUX::getErr(void) {
    return bank->err;
}


#endif // #if defined OUTPUTBANK_MUX
