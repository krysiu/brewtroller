/*
    Copyright (C) 2011 Matt Reba (mattreba at oscsys dot com)
    Copyright (C) 2011 Timothy Reaves (treaves at silverfieldstech dot com)

    This file is part of OpenTroller Framework.

    OpenTroller Framework is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenTroller Framework is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenTroller Framework.  If not, see <http://www.gnu.org/licenses/>.


*/

#include "OTAnalogInput.h"
#include "string.h"

using namespace OpenTroller;

int32_t AnalogInput::getValue(void) {
    return value;
}

uint8_t AnalogInput::getErr(void) {
    return err;
}

/**
  * Default naming of outputs based on index. Some output classes will override this to provide detailed names (eg. outputGroup)
  */
char* AnalogInput::getName(void) {
    char theIndex[4];
	char* theName = new char[17];
    strcpy(theName, "Analog Input ");
	strcat(theName, itoa(index + 1, theIndex, 10));
    return theName;
}