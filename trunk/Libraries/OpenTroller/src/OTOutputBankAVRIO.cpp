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
#include "OTOutputBankAVRIO.h"
#include "OTOutputAVRIO.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_AVRIO)
using namespace OpenTroller;

OutputBankAVRIO::OutputBankAVRIO(uint8_t pinCount) {
    count = pinCount;
    outputs = new OutputAVRIO[count];
}

OutputBankAVRIO::~OutputBankAVRIO(void) {
    delete [] outputs;
}

Output* OutputBankAVRIO::getOutput(uint8_t index) {
    Output* output = NULL;
    if (index >= 0 && index < count) {
        output =  &outputs[index];
    }
    return output;
}

void OutputBankAVRIO::setup(uint8_t index, uint8_t digPinNum) {
    outputs[index].setup(this, index, digPinNum);
}

char* OutputBankAVRIO::getName(void) {
    char* nameCopy = new char[strlen(OUTPUTBANK_AVRIO_BANKNAME) + 1];
    strcpy(nameCopy, OUTPUTBANK_AVRIO_BANKNAME);
    return nameCopy;
}

OutputBankType OutputBankAVRIO::getType(void) {
    return OUTPUTBANK_TYPE_AVRIO;
}

#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_AVRIO)
