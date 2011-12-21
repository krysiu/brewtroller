/*  
   Copyright (C) 2009, 2010 Matt Reba, Jeremiah Dillingham

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.


BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com
*/

#ifndef OT_UTIL_H
	#define OT_UTIL_H
	#include <stdint.h>
	#include <string.h>
	#include <stdlib.h>
	#include <math.h>
	
	namespace OpenTroller {
		class utility {
			public:
			void strLPad(char retString[], uint8_t len, char pad);
			void vftoa(unsigned long val, char retStr[], unsigned int divisor, uint8_t decimal);
			void truncFloat(char retStr[], uint8_t len);
			unsigned long pow10(uint8_t power);
		};
		extern utility Utility;
	}
	
#endif