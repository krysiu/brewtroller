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
#include "console.h"

#include <WProgram.h>
#include <Wire.h>

#include "OpenTroller.h"
#include "OT_Stack.h"

using namespace OpenTroller;

void console::init() {
    Stack.init();
    //    Wire.begin(); // join i2c bus (address optional for master)
    //    Serial.begin(9600); // start serial for output
}

void console::update() {
    Stack.update();
    //  Wire.requestFrom(2, 6); // request 6 bytes from slave device #2

    //  while(Wire.available()) // slave may send less than requested
    //  {
    //    char c = Wire.receive(); // receive a byte as character
    //    Serial.print(c); // print the character
    //  }

      delay(500);
}

OpenTroller::console OpenTroller::Console;

// The next two methods are needed - at least for the cmake Arduino setup - and are calles
// whenever a pure virtual function is called.  It should contain whatever error hanleing
// is needed.
extern "C" void __cxa_pure_virtual(void);
void __cxa_pure_virtual(void) { while(0); }


// These are the functions that are implemented as per the Arduino source.  They forward
// to the Console instance.
//void init() {
//}

void setup() {
    Console.init();
}

void loop() {
    Console.update();
}

