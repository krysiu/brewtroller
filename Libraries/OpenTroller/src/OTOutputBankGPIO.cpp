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
#include "OTOutputBankGPIO.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GPIO)
using namespace OpenTroller;

OutputBankGPIO::OutputBankGPIO(uint8_t pinCount) {
    count = pinCount;
    outputs = new OutputGPIO[count];
}

OutputBankGPIO::~OutputBankGPIO(void) {
    delete [] outputs;
}

Output* OutputBankGPIO::getOutput(uint8_t index) {
    Output* output = NULL;
    if (index >= 0 && index < count) {
        output =  &outputs[index];
    }
    return output;
}

void OutputBankGPIO::setup(uint8_t index, uint8_t digPinNum) {
    outputs[index].setup(this, index, digPinNum);
}

char* OutputBankGPIO::getName(void) {
    char* nameCopy = new char[strlen(OUTPUTBANK_GPIO_BANKNAME) + 1];
    strcpy(nameCopy, OUTPUTBANK_GPIO_BANKNAME);
    return nameCopy;
}

OutputBankType OutputBankGPIO::getType(void) {
    return OUTPUTBANK_TYPE_GPIO;
}

#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GPIO)
