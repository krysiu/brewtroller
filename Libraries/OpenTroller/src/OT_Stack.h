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
#ifndef OT_STACK_H
#define OT_STACK_H

#include "OT_HWProfile.h"
#ifdef OPENTROLLER_LCD
	#if defined LCD_4BIT
		#include "OT_LCD4Bit.h"
	#elif defined LCD_I2C
		#include "OT_LCDI2C.h"
	#endif
#endif

#ifdef OPENTROLLER_ONEWIRE
	#if defined ONEWIRE_AVRIO
		#include "OT_1WireAVRIO.h"
	#elif defined ONEWIRE_DS2482
		#include "OT_1WireDS2482.h"
	#endif
#endif

#ifdef OPENTROLLER_OUTPUTS
	#include "OTOutputs.h"
#endif

namespace OpenTroller {

    /**
      * This is the entry point for the OpenTroller framework stack.
      */
    class stack {
      public:
        /**
          * This method needs to be called as early in the application as possible, to initialize
          * the framework for use.  This method will further initialize any hardware defined for
          * use by the framework in OT_HWProfile.h.
          */
        void init();

        /**
          * Insures the framework is updated.  Should be called once per loop.
          */
        void update();

    };

    /**
      * The singleton instance of the framework.
      */
    extern OpenTroller::stack Stack;

	#ifdef OPENTROLLER_LCD
		//Create the appropriate global 'LCD' object depending on configuration in OT_HWProfile.h
		#if defined LCD_4BIT
			class LCD4Bit;
			/**
			  * The global reference to the LCD singleton based on LCD4Bit.
			  */
			extern OpenTroller::LCD4Bit LCD;
		#elif defined LCD_I2C
			class LCDI2C;
			/**
			  * The global reference to the LCD singleton based on LCDI2C.
			  */
			extern OpenTroller::LCDI2C LCD;
		#endif
	#endif
	
	#ifdef OPENTROLLER_ONEWIRE
		//Create the appropriate global 'LCD' object depending on configuration in OT_HWProfile.h
		#if defined ONEWIRE_AVRIO
			class OneWireAVRIO;
			/**
			  * The global reference to the OneWire singleton based on OneWireAVRIO.
			  */
			extern OpenTroller::OneWireAVRIO OneWire;
		#elif defined ONEWIRE_DS2482
			class OneWireDS2482;
			/**
			  * The global reference to the OneWire singleton based on OneWireDS2482.
			  */
			extern OpenTroller::OneWireDS2482 OneWire;
		#endif
	#endif

	#ifdef OPENTROLLER_OUTPUTS
		/**
		  * The global reference to the Outputs singleton.
		  */
		extern OpenTroller::outputs Outputs;
	#endif
}
#endif // OT_STACK_H
