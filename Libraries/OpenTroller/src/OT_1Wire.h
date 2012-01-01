#ifndef OT_1WIRE_H
#define OT_1WIRE_H

#include <inttypes.h>

// you can exclude onewire_search by defining that to 0
#ifndef ONEWIRE_SEARCH
#define ONEWIRE_SEARCH 1
#endif

// You can exclude CRC checks altogether by defining this to 0
#ifndef ONEWIRE_CRC
#define ONEWIRE_CRC 1
#endif

// Select the table-lookup method of computing the 8-bit CRC
// by setting this to 1.  The lookup table no longer consumes
// limited RAM, but enlarges total code size by about 250 bytes
#ifndef ONEWIRE_CRC8_TABLE
#define ONEWIRE_CRC8_TABLE 0
#endif

// You can allow 16-bit CRC checks by defining this to 1
// (Note that ONEWIRE_CRC must also be 1.)
#ifndef ONEWIRE_CRC16
#define ONEWIRE_CRC16 0
#endif

#define FALSE 0
#define TRUE  1

namespace OpenTroller {
	/**
	  * Generic 1-Wire Bus Class provides communication for other 1-Wire device objects
	  * This class is a pure virtual superclass; subclasses must implement full functionality.
	  */
	class OneWire_Generic
	{
	  public:
		virtual uint8_t reset(void) = 0;
		virtual void select( uint8_t rom[8]) = 0;
		virtual void skip(void) = 0;
		virtual void write(uint8_t v, uint8_t power = 0) = 0;
		virtual uint8_t read(void) = 0;
		//virtual void write_bit(uint8_t v) = 0;
		virtual uint8_t read_bit(void) = 0;
		//virtual void depower(void) = 0;
		virtual void reset_search() = 0;
		virtual uint8_t search(uint8_t *newAddr) = 0;
		virtual uint8_t crc8( uint8_t *addr, uint8_t len) = 0;
		//virtual static unsigned short crc16(unsigned short *data, unsigned short len) = 0;
	};
}
#endif
