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
#ifndef OT_OUTPUTS_H
#define OT_OUTPUTS_H

#include "OT_HWProfile.h"
#ifdef OPENTROLLER_OUTPUTS

#include "OT_Stack.h"
#include "OT_Pin.h"
#include <ModbusMaster.h>

#define BIT_TO_BYTE_COUNT(x) (x + 7)>>3

namespace OpenTroller{
class OutputBank;
class OutputBankGroups;

class outputs {
    private:
        OutputBank** banks;
        uint8_t count, max;
        void addBank(OutputBank* outputBank);
        #ifdef OUTPUTBANK_GROUPS
            OutputBankGroups* groups;
        #endif

    public:
        outputs(void);
        virtual ~outputs(void);
        void init(void);
        OutputBank* getBank(uint8_t bankIndex);
        #ifdef OUTPUTBANK_MODBUS
            void newModbusBank(uint8_t slaveAddr, uint16_t coilReg, uint8_t coilCount);
        #endif
        #ifdef OUTPUTBANK_GROUPS
            OutputBankGroups* getGroups(void);
        #endif
        uint8_t getBankCount(void);
        void update(void);
};

extern OpenTroller::outputs Outputs;
} //namespace OpenTroller
#endif //ifdef OPENTROLLER_OUTPUTS
#endif //ifndef OT_OUTPUTS_H
