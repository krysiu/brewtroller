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
#include "OTOutputBankGroups.h"

#if (defined OPENTROLLER_OUTPUTS && defined OUTPUTBANK_GROUPS)
using namespace OpenTroller;

OutputBankGroups::OutputBankGroups(void) {
    count = 0;
}

OutputBankGroups::~OutputBankGroups(void) {
    init(0);
}

void OutputBankGroups::init(uint8_t groupSize) {
    count = groupSize;
    if (count > 0) {
        delete [] groups;
        groups = new OutputGroup[count];
    }
}

Output* OutputBankGroups::getOutput(uint8_t index) {
    Output* output = NULL;
    if (index >= 0 && index < count) {
        output = &groups[index];
    }
    return output;
}

OutputGroup* OutputBankGroups::getGroup(uint8_t index) {
    OutputGroup* group = NULL;
    if (index >= 0 && index < count) {
        group = &groups[index];
    }
    return group;
}

char* OutputBankGroups::getName(void) {
    char* name = new char[14];
    strcpy(name, "Output Groups");
    return name;
}

OutputBankType OutputBankGroups::getType(void) {
    return OUTPUTBANK_TYPE_GROUPS;
}

void OutputBankGroups::update(void) {
    for (uint8_t i = 0; i < count; i++) {
        if(groups[i].get()) {
            groups[i].set(State_HIGH);
        }
    }
}

#endif //#ifdef OPENTROLLER_OUTPUTS
