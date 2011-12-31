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
#include "OTOutputs.h"
#ifdef OPENTROLLER_OUTPUTS

#include "OTOutputBankGPIO.h"
#include "OTOutputBankModbus.h"
using namespace OpenTroller;

outputs::outputs(void) {
    count = 0;
    max = OUTPUTS_MAXBANKS;
    banks = new OutputBank * [max];
    for (uint8_t i = 0; i <max; i++) {
        banks[i] = NULL;
    }
	#ifdef OUTPUTBANK_GROUPS
		groups = NULL;
	#endif
}

outputs::~outputs(void) {
    delete [] banks;
}

void outputs::init(void) {
    //Create the appropriate output bank objects for the hardware configuration (GPIO, MUX)
    //If OUTPUTBANK_GROUPS defined, add them first
    #ifdef OUTPUTBANK_GROUPS
        groups = new OutputBankGroups();
        addBank(groups);
    #endif

    #ifdef OUTPUTBANK_GPIO
        OutputBankGPIO * ptrBank = new OutputBankGPIO (OUTPUTBANK_GPIO_COUNT);
        addBank(ptrBank);
        uint8_t pinNums[OUTPUTBANK_GPIO_COUNT] = OUTPUTBANK_GPIO_PINS;
        for (uint8_t i = 0; i < OUTPUTBANK_GPIO_COUNT; i++) {
            ptrBank->setup(i, pinNums[i]);
        }
    #endif

    #if defined OUTPUTBANK_MUX
        addBank(new OutputBankMUX ( MUX_LATCH_PIN, MUX_DATA_PIN, MUX_CLOCK_PIN, MUX_ENABLE_PIN, MUX_ENABLE_LOGIC, OUTPUTBANK_MUX_COUNT));
    #endif
}

void outputs::addBank(OutputBank* outputBank) {
    if (count < max) {
        banks[count] = outputBank;
        count++;
    }
}

#ifdef OUTPUTBANK_MODBUS
void outputs::newModbusBank(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount){
    addBank(new OutputBankMODBUS(slaveAddr, coilReg, coilCount));
}
#endif

#ifdef OUTPUTBANK_GROUPS
OutputBankGroups* outputs::getGroups(void) {
    return groups;
}
#endif

uint8_t outputs::getBankCount(void){
    return count;
}

OutputBank* outputs::getBank(uint8_t bankIndex){
    return banks[bankIndex];
}

void outputs::update(void) {
    uint8_t index = 0;
    while(index < count) {
        banks[index]->update();
        index++;
    }
}

//Create Global Outputs Object
OpenTroller::outputs OpenTroller::Outputs;

#endif //#ifdef OPENTROLLER_OUTPUTS
