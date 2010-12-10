#ifndef BT_CONFIGURATION
#define BT_CONFIGURATION

//*****************************************************************************************************************************
// USER COMPILE OPTIONS
//*****************************************************************************************************************************

//**********************************************************************************
// UNIT (Metric/US)
//**********************************************************************************
// By default BrewTroller will use US Units
// Uncomment USEMETRIC below to use metric instead
// 
//#define USEMETRIC
//**********************************************************************************

//**********************************************************************************
// BrewTroller Board Version
//**********************************************************************************
// The Brewtroller 3.0 board uses MUX instead of direct on-board outputs.
// 
//#define BTBOARD_22
#define BTBOARD_3
//**********************************************************************************

//**********************************************************************************
// ENCODER TYPE
//**********************************************************************************
// You must uncomment one and only one of the following ENCODER_ definitions
// Use ENCODER_ALPS for ALPS and Panasonic Encoders
// Use ENCODER_CUI for older CUI encoders
// 
#define ENCODER_ALPS
//#define ENCODER_CUI
//**********************************************************************************

//**********************************************************************************
// Number of Zones
//**********************************************************************************
// Theoretical maximum value is 32 zones
//
// Default for BTBOARD_2.x is 6 zones
// Default for BTBOARD_3 is 8 zones
// 
//#define NUM_ZONES 6
//**********************************************************************************

//**********************************************************************************
// Number of Outputs
//**********************************************************************************
// The total number of outputs used
// 12 is the theoretical maximum for non-MUX
// MUX enabled systems could support up to 32 outputs
// 
// Default for BTBOARD_2.x is 12 outputs
// Default for BTBOARD_3 is 16 outputs
//
//#define NUM_OUTS 12
//**********************************************************************************

//**********************************************************************************
// Number of Cool/Heat Outputs
//**********************************************************************************
// The number of output pins dedicated to heat
// Increase to trade cool outputs for heat.
// Decrease to trade heat outputs for cool.
// If there are fewer heat or cool outputs than zones, the outputs will be applied
// starting with Zone 1. Higher zones will lack those outputs.
// 
// Default for BTBOARD_2.x is 6 (6+6)
// Default for BTBOARD_3 is 8 (8+8)
//
// Examples:
//   NUM_ZONES 6, NUM_OUTS 12, COOLPIN_OFFSET 6 gives 6 zones with heat on 1-6 and cool on 1-6 (Default)
//   NUM_ZONES 8, NUM_OUTS 12, COOLPIN_OFFSET 8 gives 8 zones with heat on 1-8 and cool on 1-4
//   NUM_ZONES 8, NUM_OUTS 12, COOLPIN_OFFSET 4 gives 8 zones with heat on 1-4 and cool on 1-8
//   NUM_ZONES 12, NUM_OUTS 12, COOLPIN_OFFSET 0 gives 12 zones with cool on 1-12
//   NUM_ZONES 12, NUM_OUTS 12, COOLPIN_OFFSET 12 gives 12 zones with heat on 1-12
//
//#define COOLPIN_OFFSET 6
//**********************************************************************************

//**********************************************************************************
// Number of PID Outputs
//**********************************************************************************
//WARNING: A value greater than 5 on 3.x boards will conflict with MUX outputs.
//Output pin 5 is not connected on the 3.x board. A value of 0-4 is recommended for 3.x boards.
//Theoretical limit for is 12 on 2.x boards, matching NUM_OUTS. 
//PID is only used on heat so a value > 6 would only be useful if you were using > 6 zones.
// 
// Default for BTBOARD_2.x is 6
// Default for BTBOARD_3 is 4
//
//#define NUM_PID_OUTS 6
//**********************************************************************************

//**********************************************************************************
// Enable MUX
//**********************************************************************************
// 3.x boards use MUX by default. Use this setting to enable MUX on 2.x boards
//
//#define USE_MUX
//**********************************************************************************

//**********************************************************************************
// OneWire Temperature Sensor Options
//**********************************************************************************
// TS_ONEWIRE: Enables use of OneWire Temperature Sensors (Future logic may
// support alternatives temperature sensor options.)
#define TS_ONEWIRE

// TS_ONEWIRE_PPWR: Specifies whether parasite power is used for OneWire temperature
// sensors. Parasite power allows sensors to obtain their power from the data line
// but significantly increases the time required to read the temperature (94-750ms
// based on resolution versus 10ms with dedicated power).
#define TS_ONEWIRE_PPWR 1

// TS_ONEWIRE_RES: OneWire Temperature Sensor Resolution (9-bit - 12-bit). Valid
// options are: 9, 10, 11, 12). Unless parasite power is being used the recommended
// setting is 12-bit (for DS18B20 sensors). DS18S20 sensors can only operate at a max
// of 9 bit. When using parasite power decreasing the resolution reduces the 
// temperature conversion time: 
//   12-bit (0.0625C / 0.1125F) = 750ms 
//   11-bit (0.125C  / 0.225F ) = 375ms 
//   10-bit (0.25C   / 0.45F  ) = 188ms 
//    9-bit (0.5C    / 0.9F   ) =  94ms   
#define TS_ONEWIRE_RES 9
//**********************************************************************************

//**********************************************************************************
// LOG INTERVAL
//**********************************************************************************
// Specifies how often data is logged via serial in milliseconds. If real time
// display of data is being used a smaller interval is best (1000 ms). A larger
// interval can be used for logging applications to reduce log file size (5000 ms).

#define LOG_INTERVAL 2000
//**********************************************************************************

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

//**********************************************************************************
// Cool Cycle Limit
//**********************************************************************************
// When using cool outputs for devices with compressors like refrigerators you may
// need to specify a minimum delay before enabling the output. This is intended to
// eliminate quick cycling of the output On/Off. Specify a limit in seconds for each
// zone in the array below. Maximum value is 65535 seconds or approximately 18 hrs.
//
unsigned int coolDelay[32] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
//**********************************************************************************


//**********************************************************************************
// BrewTroller PID Display (BTPD)
//**********************************************************************************
// BTPD is an external LED display developed by BrewTroller forum member vonnieda. 
// It is a 2 line, 4 digit (8 digits total) LED display with one line red and one
// line green. The digits are about a half inch high and can easily be seen across
// the room. The display connects to the BrewTroller via the I2C header and can be
// daisy chained to use as many as you like, theoretically up to 127 but in practice
// probably 10 or so.

// BTPD_SUPPORT: Enables use of BrewTroller PID Display devices on I2C bus
//#define BTPD_SUPPORT

// BTPD_INTERVAL: Specifies how often BTPD devices are updated in milliseconds.
#define BTPD_INTERVAL 1000

// BTPD_ZONEx: Displays zone temp and setpoint on specified channel
//#define BTPD_ZONE1 0x20
//#define BTPD_ZONE2 0x21
//#define BTPD_ZONE3 0x22
//#define BTPD_ZONE4 0x23
//#define BTPD_ZONE5 0x24
//#define BTPD_ZONE6 0x25
//#define BTPD_ZONE7 0x26
//#define BTPD_ZONE8 0x27

//**********************************************************************************
// DEBUG
//**********************************************************************************
// Enables Serial Out with Additional Debug Data
//
//#define DEBUG
//**********************************************************************************

#endif
