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
#include "OTOutputBankMux.h"

#if defined OUTPUTBANK_MUX
using namespace OpenTroller;

OutputBankMUX::OutputBankMUX(uint8_t latchPin,
                             uint8_t dataPin,
                             uint8_t clockPin,
                             uint8_t enablePin,
                             uint8_t enableLogic,
                             uint8_t outputCount) {
    err = 0;
    doUpdate = 0;
    count = outputCount;
    outputs = new OutputMUX[count];
    for (uint8_t i = 0; i < count; i++) {
        outputs[i].setup(this, i);
    }
    muxLatchPin.setup(latchPin, OUTPUT);
    muxDataPin.setup(dataPin, OUTPUT);
    muxClockPin.setup(clockPin, OUTPUT);
    muxEnablePin.setup(enablePin, OUTPUT);
    muxEnableLogic = enableLogic;

    if (muxEnableLogic) {
        //MUX in Reset State
        muxLatchPin.clear(); //Prepare to copy pin states
        muxEnablePin.clear(); //Force clear of pin registers
        muxLatchPin.set();
        delayMicroseconds(10);
        muxLatchPin.clear();
        muxEnablePin.set(); //Disable clear
    } else {
        set(0);
        muxEnablePin.clear();
    }
}

Output* OutputBankMUX::getOutput(uint8_t index) {
    Output* output = NULL;
    if (index >= 0 && index < count) {
        output = outputs[index];
    }
    return output;
}

void OutputBankMUX::update(void) {
    if(!doUpdate) return;
    //ground latchPin and hold low for as long as you are transmitting
    muxLatchPin.clear();
    //clear everything out just in case to prepare shift register for bit shifting
    muxDataPin.clear();
    muxClockPin.clear();

    //for each bit in the long myDataOut
    for (uint8_t i = 0; i < 32; i++)  {
        muxClockPin.clear();
        //create bitmask to grab the bit associated with our counter i and set data pin accordingly
        // (NOTE: 32 - i causes bits to be sent most significant to least significant)
        if ( output[i]->get() ) {
            muxDataPin.set();
        } else {
            muxDataPin.clear();
        }
        //register shifts bits on upstroke of clock pin
        muxClockPin.set();
        //zero the data pin after shift to prevent bleed through
        muxDataPin.clear();
    }

    //stop shifting
    muxClockPin.clear();
    muxLatchPin.set();
    delayMicroseconds(10);
    muxLatchPin.clear();
    doUpdate = 0;
}

char* OutputBankMUX::getName(void) {
    char* nameCopy = new char[strlen(OUTPUTBANK_MUX_BANKNAME) + 1];
    strcpy(nameCopy, OUTPUTBANK_MUX_BANKNAME);
    return nameCopy;
}

OutputBankType OutputBankMUX::getType(void) {
    return OUTPUTBANK_TYPE_MUX;
}


#endif // #if defined OUTPUTBANK_MUX
