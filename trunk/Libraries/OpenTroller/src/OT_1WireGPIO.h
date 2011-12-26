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
#ifndef OT_1WIRE_GPIO_H
#define OT_1WIRE_GPIO_H

#include <inttypes.h>
#include "OT_1Wire.h"

/**
 * You can exclude onewire_search by defining that to 0
 */
#ifndef ONEWIRE_SEARCH
#define ONEWIRE_SEARCH 1
#endif

/**
 * You can exclude CRC checks altogether by defining this to 0
 */
#ifndef ONEWIRE_CRC
#define ONEWIRE_CRC 1
#endif

/**
 * Select the table-lookup method of computing the 8-bit CRC by setting this to 1.  The lookup
 * table no longer consumes limited RAM, but enlarges total code size by about 250 bytes.
 */
#ifndef ONEWIRE_CRC8_TABLE
#define ONEWIRE_CRC8_TABLE 0
#endif

/**
 * You can allow 16-bit CRC checks by defining this to 1 (Note that ONEWIRE_CRC must also be 1.)
 */
#ifndef ONEWIRE_CRC16
#define ONEWIRE_CRC16 0
#endif

class OneWireGPIO : public OneWire_Generic
{
  private:
    uint8_t bitmask;
    volatile uint8_t *baseReg;

#if ONEWIRE_SEARCH
    // global search state
    unsigned char ROM_NO[8];
    uint8_t LastDiscrepancy;
    uint8_t LastFamilyDiscrepancy;
    uint8_t LastDeviceFlag;
#endif

  public:
    OneWireGPIO( uint8_t pin);

    /**
    * Perform a 1-Wire reset cycle. Returns 1 if a device responds with a presence pulse.  Returns
    * 0 if there is no device or the bus is shorted or otherwise held low for more than 250uS
    */
    uint8_t reset(void);

    /**
    * Issue a 1-Wire rom select command, you do the reset first.
    * @param rom
    */
    void select( uint8_t rom[8]);

    /**
    * Issue a 1-Wire rom skip command, to address all on bus.
    */
    void skip(void);

    /**
    * Write a byte. If 'power' is one then the wire is held high at the end for parasitically
    * powered devices. You are responsible for eventually depowering it by calling depower() or
    * doing another read or write.
    * @param v
    * @param power
    */
    void write(uint8_t v, uint8_t power = 0);

    /**
    * Read a byte.
    * @return the byte read.
    */
    uint8_t read(void);

    /**
    * Write a bit. The bus is always left powered at the end, see note in write() about that.
    * @param v the bit to write.
    */
    void write_bit(uint8_t v);

    /**
    * Read a bit.
    * @return the bit read.
    */
    uint8_t read_bit(void);

    /**
    * Stop forcing power onto the bus. You only need to do this if you used the 'power' flag to
    * write() or used a write_bit() call and aren't about to do another read or write. You would
    * rather not leave this powered if you don't have to, just in case someone shorts your bus.
    */
    void depower(void);

#if ONEWIRE_SEARCH
    /**
    * Clear the search state so that if will start from the beginning again.
    */
    void reset_search();

    /**
    * Look for the next device. Returns 1 if a new address has been returned. A zero might mean
    * that the bus is shorted, there are no devices, or you have already retrieved all of them.  It
    * might be a good idea to check the CRC to make sure you didn't get garbage.  The order is
    * deterministic. You will always get the same devices in the same order.
    */
    uint8_t search(uint8_t *newAddr);
#endif

#if ONEWIRE_CRC
    /**
    * Compute a Dallas Semiconductor 8 bit CRC, these are used in the ROM and scratchpad registers.
    */
    uint8_t crc8( uint8_t *addr, uint8_t len);

#if ONEWIRE_CRC16
    /**
    * Compute a Dallas Semiconductor 16 bit CRC. Maybe. I don't have any devices that use this so
    * this might be wrong. I just copied it from their sample code.
    */
    unsigned short crc16(unsigned short *data, unsigned short len);
#endif // ONEWIRE_CRC16
#endif // ONEWIRE_CRC
};

#endif
