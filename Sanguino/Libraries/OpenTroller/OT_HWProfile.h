/*
BrewTroller 4.0 Lite Hardware Configuration
  HERMS: Two Heat Outputs (HLT, Kettle) + 3 Pump/Valve Outputs + Alarm
*/

#ifndef BT_HWPROFILE
#define BT_HWPROFILE
  #include "OT_Encoder.h"

  #define OPENTROLLER_ENCODER_GPIO
  #define ENCODER_TYPE ALPS
  #define ENCA_PIN 3
  #define ENCB_PIN 2
  #define ENTER_PIN 1
  
  #define OPENTROLLER_OUTPUTBANKS
  #define OUTPUTBANK_MAXBANKS 16  
  
  #define OUTPUTBANK_GPIO
  #define OUTPUTBANK_GPIO_BANKNAME "BrewTroller Lite"
  #define OUTPUTBANK_GPIO_COUNT 6 //6 Outputs
  #define OUTPUTBANK_GPIO_PINS { 22, 21, 20, 19, 18, 15 }
  #define OUTPUTBANK_GPIO_PIN1 22
  #define OUTPUTBANK_GPIO_PIN2 21
  #define OUTPUTBANK_GPIO_PIN3 20
  #define OUTPUTBANK_GPIO_PIN4 19
  #define OUTPUTBANK_GPIO_PIN5 18
  #define OUTPUTBANK_GPIO_PIN6 15
  
  #define OUTPUTBANK_MODBUS
  
  #define INPUTBANK_ANALOG
  #define INPUTBANK_ANALOG_COUNT 4
  #define INPUTBANK_ANALOG_PIN1  3
  #define INPUTBANK_ANALOG_PIN2  2
  #define INPUTBANK_ANALOG_PIN3  1
  #define INPUTBANK_ANALOG_PIN4  0
  
  #define OPENTROLLER_STATUSLED
  #define STATUSLED_PIN 0
  #define STATUSLED_INTERVAL 750
  #define STATUSLED_BLINKONTIME 250
  #define STATUSLED_BLINKOFFTIME 1000
  
  #define OPENTROLLER_LCD4BIT
  #define OPENTROLLER_LCD_COLS 20
  #define OPENTROLLER_LCD_ROWS 4
  #define LCD_RS_PIN 4
  #define LCD_ENABLE_PIN 23
  #define LCD_DATA4_PIN 28
  #define LCD_DATA5_PIN 29
  #define LCD_DATA6_PIN 30
  #define LCD_DATA7_PIN 31
  #define UI_DISPLAY_SETUP
  #define LCD_BRIGHT_PIN 13
  #define LCD_CONTRAST_PIN 14
  #define LCD_DEFAULTBRIGHT 250
  #define LCD_DEFAULTCONTRAST 20

  #define RS485_SERIAL_PORT  1
  #define RS485_RTS_PIN	     12
  #define RS485_BAUDRATE    76800
  #define RS485_PARITY  'e' //'e'ven, 'o'dd, 'n'one
 
//**********************************************************************************
// OneWire Temperature Sensor Options
//**********************************************************************************
// TS_ONEWIRE: Enables use of OneWire Temperature Sensors (Future logic may
// support alternatives temperature sensor options.)
#define TS_ONEWIRE
#define TS_ONEWIRE_I2C

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
#define TS_ONEWIRE_RES 11

// TS_ONEWIRE_FASTREAD: Enables faster reads of temperatures by reading only the first
// 2 bytes of temperature data and ignoring CRC check.
#define TS_ONEWIRE_FASTREAD

// DS2482_ADDR: I2C Address of DS2482 OneWire Master (used for TS_OneWire_I2C)
// Should be 0x18, 0x19, 0x1A, 0x1B
#define DS2482_ADDR 0x1B
//**********************************************************************************

#endif
