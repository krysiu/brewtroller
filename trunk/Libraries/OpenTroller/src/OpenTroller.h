/*
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
#ifndef OPENTROLLER_H
#define OPENTROLLER_H

#include <stdlib.h>
#include <stdint.h>

/**
  * An enum used to describe the state of a pin. Uses defines from wiring.h
  */
typedef enum {
    State_LOW = 0, /*!< The state is LOW */
    State_HIGH = 1 /*!< The state is HIGH */
} State;


// Used to determine if the text on the LCD should be padded to the left, right, or center.
#define PAD_RIGHT 0
#define PAD_CENTER 1
#define PAD_LEFT 2

//#ifdef __cplusplus
//extern "C"{
//#endif

void* operator new(size_t size);

void operator delete(void* ptr);

void * operator new[](size_t size);

void operator delete[](void * ptr);

//#ifdef __cplusplus
//} // extern "C"
//#endif

#endif // OPENTROLLER_H
