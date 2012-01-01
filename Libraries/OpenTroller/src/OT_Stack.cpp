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

#ifdef OPENTROLLER_ENCODER
	#include "OT_Encoder.h"
#endif

#ifdef OPENTROLLER_LCD
	#include "OT_LCD.h"
#endif

#ifdef OPENTROLLER_ONEWIRE
	#include "OT_1Wire.h"
#endif

#ifdef OPENTROLLER_STATUSLED
	#include "OT_Status.h"
#endif

using namespace OpenTroller;

void stack::init() {
	#ifdef OPENTROLLER_OUTPUTS
        Outputs.init();
	#endif
	
	#if defined OPENTROLLER_LCD
		LCD.begin(LCD_COLS, LCD_ROWS);
	#endif
	
    #ifdef ENCODER_AVRIO
		Encoder.begin(ENCODER_TYPE, ENTER_PIN, ENCA_PIN, ENCB_PIN);
	#endif
	
	#if defined OPENTROLLER_STATUSLED
		StatusLED.init();
	#endif
	
	#if defined OPENTROLLER_ONEWIRE && defined ONEWIRE_DS2482
		OneWire.configure(DS2482_CONFIG_APU | DS2482_CONFIG_SPU);
	#endif
}

void stack::update() {
	#if defined OPENTROLLER_LCD
		LCD.update();
	#endif

	#if defined OPENTROLLER_STATUSLED
		StatusLED.update();
	#endif
	#ifdef OPENTROLLER_OUTPUTS
		Outputs.update();
	#endif
}

OpenTroller::stack OpenTroller::Stack;

#ifdef OPENTROLLER_LCD
	//Create the appropriate 'LCD' object for the hardware configuration (4-Bit AVRIO, I2C)
	#if defined LCD_4BIT
		OpenTroller::LCD4Bit OpenTroller::LCD(
			LCD4BIT_RS_PIN,
			LCD4BIT_ENABLE_PIN,
			LCD4BIT_DATA4_PIN,
			LCD4BIT_DATA5_PIN,
			LCD4BIT_DATA6_PIN,
			LCD4BIT_DATA7_PIN
			#if (defined LCD4BIT_BRIGHT_PIN && defined LCD4BIT_CONTRAST_PIN)
				,
				LCD4BIT_BRIGHT_PIN,
				LCD4BIT_CONTRAST_PIN
			#endif
		);
	#elif defined LCD_I2C
		OpenTroller::LCDI2C OpenTroller::LCD(LCDI2C_ADDR);
	#endif
#endif

#ifdef OPENTROLLER_ONEWIRE
	//Create the appropriate 'OneWire' object for the hardware configuration (AVRIO, DS2482)
	#if defined ONEWIRE_AVRIO
		OpenTroller::OneWireAVRIO OpenTroller::OneWire(ONEWIRE_AVRIO_PIN);
	#elif defined ONEWIRE_DS2482
		OpenTroller::OneWireDS2482 OpenTroller::OneWire(DS2482_ADDR);
	#endif
#endif

#ifdef OPENTROLLER_OUTPUTS
	//Create Global Outputs Object
	OpenTroller::outputs OpenTroller::Outputs;
#endif