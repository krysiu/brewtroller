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

#ifndef OT_LCDI2C_H
#define OT_LCDI2C_H

#include "OT_HWProfile.h"
#if (defined OPENTROLLER_LCD && defined LCD_I2C)
#import "OpenTroller.h"
#include "OT_LCD.h"
#include <wiring.h>
#include <stdint.h>

namespace OpenTroller {
    class LCDI2C : public LCD_Generic {
      private:
        uint8_t i2cLCDAddr;

      public:
        LCDI2C(uint8_t addr);
        void init();
        void update();
        void setBright(uint8_t);
        void setContrast(uint8_t);
        void saveConfig(void);
        uint8_t getBright();
        uint8_t getContrast();
    };

}

#endif //if (defined OPENTROLLER_LCD && defined LCD_I2C)
#endif //ifndef OT_LCDI2C_H
