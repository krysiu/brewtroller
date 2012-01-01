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

#ifndef OT_LCD4BIT_H
#define OT_LCD4BIT_H

#include "OT_HWProfile.h"
#if (defined OPENTROLLER_LCD && defined LCD_4BIT)
#import "OpenTroller.h"
#include "OT_LCD.h"
#include "OT_LiquidCrystal.h"
#include <wiring.h>
#include <stdint.h>

namespace OpenTroller {

    //**********************************************************************************
    // LCD Timing Fix
    //**********************************************************************************
    // Some LCDs seem to have issues with displaying garbled characters but introducing
    // a delay seems to help or resolve completely. You may comment out the following
    // lines to remove this delay between a print of each character.
    //
    //#define LCD_DELAY_CURSOR 60
    //#define LCD_DELAY_CHAR 60
    //**********************************************************************************
    class LCD4Bit : public LCD_Generic {
      private:
        LiquidCrystal * _lcd;

        uint8_t brightPin;
        uint8_t contrastPin;
        uint8_t bright;
        uint8_t contrast;
        uint8_t bcControl;

        void saveLCDBright(uint8_t val);
        void saveLCDContrast(uint8_t val);
        uint8_t loadLCDBright();
        uint8_t loadLCDContrast();

      public:
        LCD4Bit(uint8_t rs, uint8_t enable, uint8_t d4, uint8_t d5, uint8_t d6, uint8_t d7);
        LCD4Bit(uint8_t rs,
                uint8_t enable,
                uint8_t d4,
                uint8_t d5,
                uint8_t d6,
                uint8_t d7,
                uint8_t b,
                uint8_t c);

        void init();
        void update();
        void setBright(uint8_t);
        void setContrast(uint8_t);
        void saveConfig(void);
        uint8_t getBright();
        uint8_t getContrast();
    };
}

#endif //if (defined OPENTROLLER_LCD && defined LCD_4BIT)
#endif //ifndef OT_LCD4BIT_H
