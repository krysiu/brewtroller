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
#include "OT_Stack.h"

#include "OT_HWProfile.h"
#include "OT_Encoder.h"

#include "LCD/OT_LCD.h"
#include "outputs/OTOutputs.h"
#include "OT_Status.h"

using namespace OpenTroller;

void stack::init() {
	#ifdef OPENTROLLER_OUTPUTS
        OpenTroller::Outputs.init();
	#endif
	
	#if defined OPENTROLLER_LCD4BIT || defined OPENTROLLER_LCDI2C
		OpenTroller::LCD.begin(OPENTROLLER_LCD_COLS, OPENTROLLER_LCD_ROWS);
	#endif
	
    #ifdef OPENTROLLER_ENCODER_GPIO
		OpenTroller::Encoder.begin(ENCODER_TYPE, ENTER_PIN, ENCA_PIN, ENCB_PIN);
	#endif
	
	#if defined OPENTROLLER_STATUSLED
		OpenTroller::StatusLED.init();
	#endif
}

void stack::update() {
	#if defined OPENTROLLER_LCD4BIT || defined OPENTROLLER_LCDI2C
		OpenTroller::LCD.update();
	#endif

	#if defined OPENTROLLER_STATUSLED
		OpenTroller::StatusLED.update();
	#endif
	#ifdef OPENTROLLER_OUTPUTS
		OpenTroller::Outputs.update();
	#endif
}

OpenTroller::stack OpenTroller::Stack;


