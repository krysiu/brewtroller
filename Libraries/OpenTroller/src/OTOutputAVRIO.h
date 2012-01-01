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
#ifndef OT_OUTPUT_AVRIO_H
#define OT_OUTPUT_AVRIO_H

#include "OT_HWProfile.h"
#if defined OUTPUTBANK_AVRIO

#include <stdint.h>
#include "OpenTroller.h"
#include "OTOutput.h"
#include "OT_AVRIO.h"

namespace OpenTroller{

class OutputBankAVRIO;

/**
  * An output provided by an AVR microcontroller GPIO (general purpose input/output) pin.
  */
class OutputAVRIO: public Output {
    private:
        AVRIO outputPin;
        uint8_t err;

    public:
        OutputAVRIO(void);
        void setup(OutputBankAVRIO* outputBank, uint8_t anIndex, uint8_t digitalPinNum);
        virtual void setState(State newState);
        virtual State getState(void);
};

} //namespace OpenTroller
#endif // #if defined OUTPUTBANK_AVRIO
#endif //ifndef OT_OUTPUT_AVRIO_H
