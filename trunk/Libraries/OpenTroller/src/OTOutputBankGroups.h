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
#ifndef OT_OUTPUT_BANK_GROUP_H
#define OT_OUTPUT_BANK_GROUP_H

#include "OT_HWProfile.h"
#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GROUPS)

#include <stdint.h>
#include "OTOutputBank.h"
#include "OTOutputGroup.h"


namespace OpenTroller{

class Output;

/**
  * A bank of output groups.
  */
class OutputBankGroups: public OutputBank {
    private:
        OutputGroup * groups;

    public:
        OutputBankGroups(void);
        virtual ~OutputBankGroups(void);
        void init(uint8_t groupSize);
        Output* getOutput(uint8_t index);
        OutputGroup* getGroup(uint8_t index);
        char* getName(void);
        virtual char* getOutputName(uint8_t index);
        OutputBankType getType(void);
        void update(void);
};

} //namespace OpenTroller
#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GROUPS)
#endif // #ifndef OT_OUTPUT_BANK_GROUP_H
