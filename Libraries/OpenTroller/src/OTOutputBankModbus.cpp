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
#include "OTOutputBankModbus.h"
#include "OTOutputModbus.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
#define BIT_TO_BYTE_COUNT(x) (x + 7)>>3

using namespace OpenTroller;

OutputBankMODBUS::OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount) {
    err = 0;
    doUpdate = 0;
    slaveAddr = slaveAddr;
    slave = ModbusMaster(RS485_SERIAL_PORT, slaveAddr);
    #ifdef RS485_RTS_PIN
        slave.setupRTS(RS485_RTS_PIN);
    #endif
    slave.begin(RS485_BAUDRATE, RS485_PARITY);
    //Modbus Coil Register index starts at 1 but is transmitted with a 0 index
    coilReg = coilReg - 1;
    count = coilCount;
    outputs = new OutputMODBUS[count];
    for (uint8_t i = 0; i < count; i++) {
        outputs[i].setup(this, i);
    }
}

OutputBankMODBUS::~OutputBankMODBUS(void){
	
}

Output* OutputBankMODBUS::getOutput(uint8_t index) {
    Output* output = NULL;
    if (index >= 0 && index < count) {
        output = &outputs[index];
    }
    return output;
}

void OutputBankMODBUS::update(void) {
    if (doUpdate) {
        uint8_t offest = 0;
        for (uint8_t bytePos = 0; bytePos < BIT_TO_BYTE_COUNT(count); bytePos++) {
            uint8_t byteData = 0;
            for (uint8_t bitPos = 0; bitPos < 8; bitPos++) {
                offest = bytePos * 8 + bitPos;
                bitWrite(byteData,
                         bitPos,
                         ((offest < count) ? outputs[offest].getState() : 0));
            }
            slave.setTransmitBuffer(bytePos, byteData);
        }
        err = slave.writeMultipleCoils(coilReg, count);
        doUpdate = 0;
    }
}

char* OutputBankMODBUS::getName(void) {
    char* nameCopy = new char[19];
    char sID[4];
    strcpy(nameCopy, "Modbus Relay #");
    itoa(slaveAddr, sID, 10);
    strcat(nameCopy, sID);
    return nameCopy;
}

OutputBankType OutputBankMODBUS::getType(void) {
    return OUTPUTBANK_TYPE_MODBUS;
}

#endif // #if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_MODBUS)
