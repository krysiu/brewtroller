/*
Opentroller BX1 Hardware Configuration
*/

#ifndef OT_HWPROFILE_H
#define OT_HWPROFILE_H
#include <WProgram.h> 

#define OPENTROLLER_ENCODER
#define ENCODER_AVRIO
#define ENCODER_TYPE ALPS
#define ENCA_PIN 3
#define ENCB_PIN 2
#define ENTER_PIN 1

//Creates OpenTroller::Outputs Container Object and classes for Outputs and OutputBanks
#define OPENTROLLER_OUTPUTS

//Maximum number of banks that can be added to the OpenTroller::Outputs container object
#define OUTPUTS_MAXBANKS 16
  
//Enables AVR GPIO Output Bank
#define OUTPUTBANK_AVRIO

//Name to display for the AVR GPIO Output Bank
#define OUTPUTBANK_AVRIO_BANKNAME "BX1 Outputs"

//Number of outputs in the AVR GPIO Output Bank
#define OUTPUTBANK_AVRIO_COUNT 6

//Arduino-based pin number array in the AVR GPIO Output Bank
#define OUTPUTBANK_AVRIO_PINS { 22, 21, 20, 19, 18, 15 }

//Provides support for adding MODBUS Output Banks
#define OUTPUTBANK_MODBUS

//Provides support for Output Groups, a virtual output that controls multiple other outputs or groups
#define OUTPUTBANK_GROUPS

#define ANALOGINPUTBANK_AVRIO
#define ANALOGINPUTBANK_AVRIO_BANKNAME "BX1 Analogs"
#define ANALOGINPUTBANK_AVRIO_COUNT 4
#define ANALOGINPUTBANK_AVRIO_PINS { 3, 2, 1, 0 }
#define ANALOGINPUTBANK_DS18B20

//  #define OPENTROLLER_INPUTBANKS
//  #define INPUTBANK_MAXBANKS 16

//Need Actual Pin Numbers for Input Expansion
//#define INPUTBANK_AVRIO
//#define INPUTBANK_AVRIO_BANKNAME "BX1 Inputs"
//#define INPUTBANK_AVRIO_COUNT 4
//#define INPUTBANK_AVRIO_PINS { 22, 21, 20, 19 }

//#define INPUTBANK_MODBUS

/**
  * AVRIO Pin Change Interrupt Optimizations
  */
// Uncomment the line below to limit the Pin Change handler to servicing a single interrupt
//#define	DISABLE_PCINT_MULTI_SERVICE

// Define the value MAX_PIN_CHANGE_PINS to limit the number of pins that may be configured for PCINT
#define	MAX_PIN_CHANGE_PINS 8

// Declare PCINT ports without pin change interrupts used
//#define	NO_PCINT0_PINCHANGES 1
//#define	NO_PCINT1_PINCHANGES 1
//#define	NO_PBINC2_PINCHANGES 1
//#define	NO_PCINT3_PINCHANGES 1

#define OPENTROLLER_STATUSLED		//Enables status LED heartbeat and diagnostics
#define STATUSLED_PIN 0				//Pin attached to Status LED
#define STATUSLED_INTERVAL 750		//Normal interval for LED toggle
#define STATUSLED_BLINKONTIME 250	//Blink on/off toggle time for diagnostic blinks
#define STATUSLED_BLINKOFFTIME 1000	//Pause period between blink sequences

#define OPENTROLLER_LCD
#define LCD_4BIT
#define LCD_COLS 20
#define LCD_ROWS 4
#define LCD4BIT_RS_PIN 4
#define LCD4BIT_ENABLE_PIN 23
#define LCD4BIT_DATA4_PIN 28
#define LCD4BIT_DATA5_PIN 29
#define LCD4BIT_DATA6_PIN 30
#define LCD4BIT_DATA7_PIN 31
#define LCD4BIT_BRIGHT_PIN 13
#define LCD4BIT_CONTRAST_PIN 14
#define LCD4BIT_DEFAULTBRIGHT 200
#define LCD4BIT_DEFAULTCONTRAST 100
#define UI_DISPLAY_SETUP 		//Provides support for brightness/contrast menu

//**********************************************************************************
// RS-485 Configuration
//**********************************************************************************
#define RS485_SERIAL_PORT 1 	//0=UART0, 1=UART1, etc.
#define RS485_RTS_PIN 12		//Pin number used for RTS Control (Comment to disable RTS Control)
#define RS485_BAUDRATE 76800	//Baud rate for serial communication
#define RS485_PARITY 'e' 		//UART parity: 'e'ven, 'o'dd, 'n'one

//**********************************************************************************
// 1-Wire Options
//**********************************************************************************
// OPENTROLLER_ONEWIRE: Enables use of 1-Wire Bus
#define OPENTROLLER_ONEWIRE

// 1WIRE_DS2482: 1-Wire Bus using I2C and DS2482
#define ONEWIRE_DS2482

// DS2482_ADDR: I2C Address of DS2482 OneWire Master (used for TS_OneWire_I2C)
// Should be 0x18, 0x19, 0x1A, 0x1B
#define DS2482_ADDR 0x1B

// 1WIRE_PPWR: Specifies whether parasite power is used for 1-Wire devices. Parasite 
// power allows sensors to obtain their power from the data line but increases the
// time required to perform operations.
#define ONEWIRE_PPWR 1

// 1WIRE_FASTREAD: Enables faster reads by ignoring CRC check.
#define ONEWIRE_FASTREAD
//**********************************************************************************

#endif
