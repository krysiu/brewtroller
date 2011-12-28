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
#include "OTOutputGroup.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GROUPS)
#include "OpenTroller.h"

using namespace OpenTroller;

OutputGroup::OutputGroup(void) {
    count = 0;
    err = 0;
    state = State_LOW;
}

OutputGroup::~OutputGroup(void) {
    if (count) {
        delete [] outputs;
    }
}

void OutputGroup::init(char* theName, uint8_t groupSize) {
    strlcpy(name, theName, 15);
    count = groupSize;
    if (count > 0) {
        delete [] outputs;
        outputs = new Output * [count];
        for (uint8_t i = 0; i < count; i++) {
            outputs[i] = NULL;
        }
    }
}

void OutputGroup::assignOutput(uint8_t index, Output* output) {
    if (index < count) {
        outputs[index] = output;
    }
}

void OutputGroup::setState(State newState) {
    if (state != newState) {
        state = newState;
        err = 0;
        for (uint8_t i = 0; i < count; i++) {
            outputs[i]->setState(state);
            if (outputs[i]->getErr()) {
                err = 1;
            }
        }
    }
}

char* OutputGroup::getName(void) {
    char* theName = new char[15];
    strcpy(theName, name);
    return theName;
}

//TODO: I should not need these next two methods, but, withoput them, the app will not link.
State OutputGroup::getState(void) {
    return state;
}

uint8_t OutputGroup::getErr(void) {
    return err;
}


#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GROUPS)
