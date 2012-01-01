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
#ifndef OT_OUTPUT_BANK_MUX_H
#define OT_OUTPUT_BANK_MUX_H

#include "OT_HWProfile.h"
#if defined OUTPUTBANK_MUX

#include <stdint.h>
#include "OTOutputBank.h"
#include "OT_Pin.h"


namespace OpenTroller{

class OutputBankMUX: public OutputBank {
private:
    pin muxLatchPin, muxDataPin, muxClockPin, muxEnablePin;
    boolean muxEnableLogic;
    OutputMUX * outputs;
    uint8_t err, doUpdate;

public:
    OutputBankMUX(uint8_t latchPin,
                  uint8_t dataPin,
                  uint8_t clockPin,
                  uint8_t enablePin,
                  uint8_t enableLogic,
                  uint8_t count);
    virtual ~OutputBankMUX(void);
    virtual Output* getOutput(uint8_t index);
    virtual char* getName(void);
    virtual char* getOutputName(uint8_t index);
    virtual OutputBankType getType(void);
    virtual void update(void);
    friend class OutputMUX;
};

} //namespace OpenTroller
#endif // #if defined OUTPUTBANK_MUX
#endif //ifndef OT_OUTPUT_BANK_MUX_H
