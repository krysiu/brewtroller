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
#include "OTOutputBank.h"

#ifdef OPENTROLLER_OUTPUTS

#include "OTOutput.h"

using namespace OpenTroller;

//TODO: These keep throwing errors: undefined reference to `__cxa_pure_virtual'
/*
OutputBank::OutputBank() {

}
OutputBank::~OutputBank() {

}
*/

uint8_t OutputBank::getCount(void) {
    return count;
}

#endif //#ifdef OPENTROLLER_OUTPUTS
