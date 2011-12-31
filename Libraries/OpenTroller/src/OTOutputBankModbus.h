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
#ifndef OT_OUTPUT_BANK_MODBUS_H
#define OT_OUTPUT_BANK_MODBUS_H

#include "OT_HWProfile.h"
#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)

#include <stdint.h>
#include "OTOutputBank.h"
#include "OTOutputModbus.h"
#include <ModbusMaster.h>

namespace OpenTroller{

class Output;
class OutputMODBUS;

/**
  * A bank of MODBUS outputs.
  */
class OutputBankMODBUS: public OutputBank {
    private:
        ModbusMaster slave;
        uint8_t slaveAddr, err, doUpdate;
        unsigned int coilReg;
        OutputMODBUS* outputs;
        void setUpdate(void);

    public:
        OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount);
        virtual ~OutputBankMODBUS(void);
        virtual Output* getOutput(uint8_t index);
        virtual char* getName(void);
        virtual char* getOutputName(uint8_t index);
        virtual OutputBankType getType(void);
        virtual void update(void);
        friend class OutputMODBUS;
};

} //namespace OpenTroller
#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
#endif //ifndef OT_OUTPUT_BANK_MODBUS_H
