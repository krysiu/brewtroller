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
#ifndef OT_OUTPUT_GPIO_H
#define OT_OUTPUT_GPIO_H

#include "OT_HWProfile.h"
#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GPIO)

#include <stdint.h>
#include "OpenTroller.h"
#include "OTOutput.h"
#include "OT_Pin.h"

namespace OpenTroller{

class OutputBankGPIO;

/**
  * A GPIO (general purpose input/output) output.
  */
class OutputGPIO: public Output {
    private:
        pin outputPin;
        uint8_t err;

    public:
        OutputGPIO(void);
        void setup(OutputBankGPIO* outputBank, uint8_t anIndex, uint8_t digitalPinNum);
        virtual void setState(State newState);
        virtual State getState(void);
};

} //namespace OpenTroller
#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GPIO)
#endif //ifndef OT_OUTPUT_GPIO_H
