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

#ifndef OT_LCD_H
#define OT_LCD_H

#include "OT_HWProfile.h"
#ifdef OPENTROLLER_LCD
#import "OpenTroller.h"

#include <wiring.h>
#include <stdint.h>

namespace OpenTroller {

    class LCD_Generic {
      protected:
        uint8_t * screen;
        uint8_t columns;
        uint8_t rows;
        uint8_t position;
        uint8_t characters[8][8];

      public:
        virtual void init() = 0;
        virtual void update() = 0;
        virtual void setBright(uint8_t) = 0;
        virtual void setContrast(uint8_t) = 0;
        virtual uint8_t getBright() = 0;
        virtual uint8_t getContrast() = 0;

        void begin(uint8_t columnCount, uint8_t rowCount);
        void print(const char *sText);
        void write(uint8_t data);
        void setCursor(uint8_t row, uint8_t col);
        void clear();
        void printPad(const char *sText,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ');
        void printPad(long value,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ',
                      uint8_t base = 10);
        void printPad(unsigned long value,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ',
                      uint8_t base = 10);
        void printPad(uint8_t value,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ',
                      uint8_t base = 10);
        void printPad(int value,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ',
                      uint8_t base = 10);
        void printPad(unsigned int value,
                      uint8_t fieldWidth,
                      uint8_t padMode = PAD_LEFT,
                      char pad = ' ',
                      uint8_t base = 10);
        void print_P(const char *pText);
        void printPad_P(const char *pText,
                        uint8_t fieldWidth,
                        uint8_t padMode = PAD_LEFT,
                        char pad = ' ');
        void printVFloat(unsigned long val, unsigned int divisor, uint8_t fieldWidth);
        void printVFloatPad(unsigned long val,
                            unsigned int divisor,
                            uint8_t fieldWidth,
                            uint8_t padMode = PAD_LEFT,
                            char pad = ' ');
        void setCustChar_P(uint8_t index, const uint8_t *charDef) ;
        void getScreen(uint8_t * retString);
        void getCustChars(uint8_t * retString);
    };
}

#endif //ifdef OPENTROLLER_LCD
#endif //ifndef OT_LCD_H
