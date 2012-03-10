/**
 * Board initialization and address assignment:
 * 	When the board is initialized with a cleared EEPROM it will boot into
 *  a holding mode. In this mode no communication protocols are active.
 *  This mode can be visually identified by seeing three blinks on the debug
 *  LED followed by a pause.
 *  When the button on the board is pressed the RS485 and I2C modules are
 *  activated with the default addresses of 247 for RS485 and 0x7F for I2C.
 *  At this point the board can be configured over RS485 or I2C and have either
 *  address set. It should then be rebooted. If an address has been set the
 *  board will boot into normal communication mode for the interface that
 *  has an address assigned and the interface without an address assigned 
 *  will be disabled.
 */
 
 
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <util/delay.h>
#include <mb.h>
#include <mbport.h>
#include <mbutils.h>
#include "board.h"
#include "tlc5947.h"
#include "input.h"
#include "twi.h"

#define ACTIVITY_NONE     0
#define ACTIVITY_PREOFF   1
#define ACTIVITY_ON       2
#define ACTIVITY_POSTOFF  3

#define LEDTIME_BLINK    250
#define LEDTIME_OK    750
#define LEDTIME_ACT   30
#define LEDBLINK_OFFTIME  1000

#define LEDCOUNT_ID    2
#define LEDCOUNT_INIT  3

#define INIT_BUTTON_LOGIC
#define INIT_BUTTON_TIME  		4000 //4s

#define RESTART_DELAY  			100 //100ms delay to allow restart command response

#define MODBUS_BAUDRATE 		38400 //16MHz XTAL doesn't like 115200

#define EEPROM_SLAVEADDR 		0
#define EEPROM_TWI_ADDRESS		1
#define EEPROM_FINGERPRINT 		511
#define FINGERPRINT_VALUE 		42


#define DEFAULT_DEVADDR 		247
#define TWI_ADDRESS_DEFAULT		0x7F

#define SLAVE_ID        		0  // TODO: Assign
#define SLAVEID_EXTLEN  		3

#define REG_DISC_START     		1000
#define REG_DISC_SIZE      		16

#define REG_HOLDING_IDMODE      9001
#define REG_HOLDING_SLAVEADDR   9002
#define REG_HOLDING_RESTART     9003

#define REG_HOLDING_LEDS_START	3000
#define REG_HOLDING_LEDS_SIZE	8

uint8_t ucRegDiscBuf[REG_DISC_SIZE / 8] = { 0, 0 };
uint16_t usRegHoldingBuf[REG_HOLDING_LEDS_SIZE];
const uint8_t ucSlaveID[] = { 0x4F, 0x00, 0x00 }; //'O' for OSCSYS, TODO: Assign others

volatile uint8_t id_mode_enabled;
volatile uint8_t slave_address;
volatile uint8_t restart_requested; 
volatile uint8_t twi_address;

volatile uint32_t timer0_millis;

uint8_t blinkCount = 0;
uint8_t actMode = ACTIVITY_NONE;
uint32_t ledUpdateTime;

uint32_t millis(void);

void button_init(void);
uint8_t button_is_pressed(void);

void debug_led_init(void);
void debug_led_set(uint8_t on);
void debug_led_toggle(void);

void(* softReset) (void) = 0;

void updateLED();
void ledEvent();
void ledBlinkPattern(uint8_t count, int offTime);

void twi_data_received(uint8_t* buf, int length);
void twi_data_requested();

uint8_t crc8(uint8_t inCrc, uint8_t inData );

int main(void) {
	// Enable the button
	button_init();

	// Enable the LEDs
	debug_led_init();
	
	// Start up the TLC5947 driver
	tlc5947_init();
	
	// Start up the inputs
	input_init();
	
	// Set up the millisecond timer
	// Clock Select, /64 Prescaler
	TCCR0B = _BV(CS01) | _BV(CS00);
	// Interrupt Enable
	TIMSK0 = _BV(TOIE0);
	
	// Start the timer
    sei();
    
	// Check the EEPROM for the fingerprint showing we've been initialized, or
	// load the default settings into the EEPROM.
	if (eeprom_read_byte(EEPROM_FINGERPRINT) != FINGERPRINT_VALUE) {
		eeprom_write_byte(EEPROM_SLAVEADDR, DEFAULT_DEVADDR);
		eeprom_write_byte(EEPROM_TWI_ADDRESS, TWI_ADDRESS_DEFAULT);
		eeprom_write_byte(EEPROM_FINGERPRINT, FINGERPRINT_VALUE);
	}
	
	// Read the twi_address stored in the EEPROM
	twi_address = eeprom_read_byte(EEPROM_TWI_ADDRESS);

	// Read the ModBus address stored in the EEPROM
	slave_address = eeprom_read_byte(EEPROM_SLAVEADDR);

	// If neither interface has an address assigned, go into wait mode
	if (slave_address == DEFAULT_DEVADDR && twi_address == TWI_ADDRESS_DEFAULT) {
    	while(!button_is_pressed()) {
    		ledBlinkPattern(LEDCOUNT_INIT, LEDBLINK_OFFTIME);
    	}
  	}
  	
  	// Now we either need to turn on both interfaces at default addresses
  	// or we need to only enable the interface that has an assigned address.

  	if ((slave_address == DEFAULT_DEVADDR && twi_address == TWI_ADDRESS_DEFAULT) ||
  		(slave_address != DEFAULT_DEVADDR)) {
		eMBInit(MB_RTU, slave_address, 0, MODBUS_BAUDRATE, MB_PAR_EVEN);
	
		eMBSetSlaveID(SLAVE_ID, TRUE, ucSlaveID, SLAVEID_EXTLEN);
		
		/* Enable the Modbus Protocol Stack. */
		eMBEnable();
	}
    
  	if ((slave_address == DEFAULT_DEVADDR && twi_address == TWI_ADDRESS_DEFAULT) ||
  		(twi_address != TWI_ADDRESS_DEFAULT)) {
		// Initialize the twi interface
		twi_setAddress(twi_address);
		twi_attachSlaveRxEvent(twi_data_received);
		twi_attachSlaveTxEvent(twi_data_requested);
		twi_init();
	}

    for(;;) {
	    input_refresh();
	    
	    for (int i = 0; i < 8; i++) {
			xMBUtilSetBits(ucRegDiscBuf, i, 1, input_is_set(i, INPUT_A));
			xMBUtilSetBits(ucRegDiscBuf, i + 8, 1, input_is_set(i, INPUT_M));
		}
		
		eMBPoll();
		
		updateLED();
		
		if (restart_requested) {
			uint32_t restart_time = millis() + RESTART_DELAY;
			while (millis() < restart_time) {
				eMBPoll();
			}
			softReset();
		}
		
		#ifdef INIT_BUTTON_LOGIC
		//Check if init button is clicked
		if (button_is_pressed()) {
			unsigned long click_start = millis();
			debug_led_set(TRUE);
      		while((button_is_pressed()) && (millis() - click_start < INIT_BUTTON_TIME));
      		if (button_is_pressed()) {
        		//Still pressed so do init
        		cli();
        		eeprom_write_byte(EEPROM_SLAVEADDR, DEFAULT_DEVADDR);
				eeprom_write_byte(EEPROM_TWI_ADDRESS, TWI_ADDRESS_DEFAULT);
        		debug_led_set(FALSE);
        		while (button_is_pressed());
				softReset();
    		}
    	}
  		#endif
  		
		tlc5947_update();
    }
}

/**
 * TWI Protocol
 * Commands:
 * 		Set Output Color
 *			0: 		0x01.
 *			1: 		Output Number.
 *			2-3: 	(uint16_t*) 12 bit RGB in LSB.
 *
 *		Restart
 *			0:		0xfd
 *
 *		Enable/Disable ID Mode
 *			0:		0xfe
 *			1:		0 to enable, 1 to disable
 *
 *		Set TWI Address
 *			0:		0xff
 *			1:		TWI Address
 */
void twi_data_received(uint8_t* buf, int length) {
	if (buf[0] == 0x01) {
		uint8_t output = buf[1];
		uint16_t rgb = *(uint16_t*) &buf[2];
		tlc5947_set_rgb(output,
			((rgb >> 8) & 0x0f) * 16,
			((rgb >> 4) & 0x0f) * 16,
			((rgb >> 0) & 0x0f) * 16);
	}
	else if (buf[0] == 0xfd) {
		restart_requested = TRUE;
	}
	else if (buf[0] == 0xfe) {
		id_mode_enabled = buf[1];
	}
	else if (buf[0] == 0xff) {
		eeprom_write_byte(EEPROM_TWI_ADDRESS, buf[1]);
	}
	ledEvent();
}

void twi_data_requested() {
	uint8_t buf[3];
	for (int i = 0; i < 8; i++) {
		buf[0] <<= 1;
		buf[0] |= input_is_set(7 - i, INPUT_M) ? 1 : 0;
	}
	for (int i = 0; i < 8; i++) {
		buf[1] <<= 1;
		buf[1] |= input_is_set(7 - i, INPUT_A) ? 1 : 0;
	}
	
	buf[2] = '*';
	buf[2] = crc8(buf[2], buf[0]);
	buf[2] = crc8(buf[2], buf[1]);
	
	twi_transmit(buf, 3);
	ledEvent();
}

uint8_t crc8(uint8_t inCrc, uint8_t inData ) {
	uint8_t i;
    uint8_t data;

    data = inCrc ^ inData;
  
	for (i = 0; i < 8; i++) {
	    if ((data & 0x80) != 0) {
            data <<= 1;
            data ^= 0x07;
        }
        else {
            data <<= 1;
        }
    }

	return data;
}

eMBErrorCode
eMBRegHoldingCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNRegs, eMBRegisterMode eMode ) {
    eMBErrorCode eStatus = MB_ENOERR;
	if (eMode == MB_REG_READ) {
		/* Pass current register values to the protocol stack. */
		while( usNRegs > 0 ) {
			if (usAddress == REG_HOLDING_IDMODE) {
				*pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
				*pucRegBuffer++ = ( unsigned char ) id_mode_enabled;
			}
			else if (usAddress == REG_HOLDING_SLAVEADDR) {
				*pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
				*pucRegBuffer++ = ( unsigned char ) slave_address;
			}
			else if (usAddress == REG_HOLDING_RESTART) {
				*pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
				*pucRegBuffer++ = ( unsigned char ) restart_requested;
			}
			else if (usAddress >= REG_HOLDING_LEDS_START && usAddress < REG_HOLDING_LEDS_START + REG_HOLDING_LEDS_SIZE) {
				*pucRegBuffer++ = ( UCHAR ) ( usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] >> 8 );
				*pucRegBuffer++ = ( UCHAR ) ( usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] & 0xFF );
			}
		    else {
		        eStatus = MB_ENOREG;
		        break;
		    }
			
			usAddress++;
			usNRegs--;
		}
	}
	else if (eMode == MB_REG_WRITE) {
		/* Update current register values with new values from the
		 * protocol stack. */
		while( usNRegs > 0 ) {
			if (usAddress == REG_HOLDING_IDMODE) {
				pucRegBuffer++;
				id_mode_enabled = !!(*pucRegBuffer++);
			}
			else if (usAddress == REG_HOLDING_SLAVEADDR) {
				pucRegBuffer++;
				slave_address = *pucRegBuffer++;
				eeprom_write_byte(EEPROM_SLAVEADDR, slave_address);
			}
			else if (usAddress == REG_HOLDING_RESTART) {
				pucRegBuffer++;
				restart_requested = !!(*pucRegBuffer++);
			}
			else if (usAddress >= REG_HOLDING_LEDS_START && usAddress < REG_HOLDING_LEDS_START + REG_HOLDING_LEDS_SIZE) {
				usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] = *pucRegBuffer++ << 8;
				usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] |= *pucRegBuffer++;
				
				tlc5947_set_rgb(
					usAddress - REG_HOLDING_LEDS_START,
					((usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] >> 8) & 0x0f) * 16,
					((usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] >> 4) & 0x0f) * 16,
					((usRegHoldingBuf[usAddress - REG_HOLDING_LEDS_START] >> 0) & 0x0f) * 16);
			}
		    else {
		        eStatus = MB_ENOREG;
		        break;
		    }
			usAddress++;
			usNRegs--;
		}
    }
	ledEvent();
    return eStatus;
}

eMBErrorCode
eMBRegDiscreteCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNDiscrete ) {
    eMBErrorCode    eStatus = MB_ENOERR;
    short           iNDiscrete = ( short )usNDiscrete;
    unsigned short  usBitOffset;

    /* Check if we have registers mapped at this block. */
    if( ( usAddress >= REG_DISC_START ) &&
        ( usAddress + usNDiscrete <= REG_DISC_START + REG_DISC_SIZE ) ) {
        usBitOffset = ( unsigned short )( usAddress - REG_DISC_START );
        while( iNDiscrete > 0 ) {
            *pucRegBuffer++ =
                xMBUtilGetBits( ucRegDiscBuf, usBitOffset,
                                ( unsigned char )( iNDiscrete >
                                                   8 ? 8 : iNDiscrete ) );
            iNDiscrete -= 8;
            usBitOffset += 8;
        }
    }
    else {
        eStatus = MB_ENOREG;
    }
	ledEvent();
    return eStatus;
}

eMBErrorCode
eMBRegCoilsCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNCoils,
               eMBRegisterMode eMode ) {
    return MB_ENOREG;
}

eMBErrorCode
eMBRegInputCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNRegs ) {
    return MB_ENOREG;
}

void updateLED() {
  if (id_mode_enabled) {
  	ledBlinkPattern(LEDCOUNT_ID, LEDBLINK_OFFTIME);
  }
  else {
    if (millis() - ledUpdateTime > (actMode?LEDTIME_ACT:LEDTIME_OK)) {
    	debug_led_toggle();
      ledUpdateTime = millis();
      if (actMode) {
        actMode++;
        if (actMode > ACTIVITY_POSTOFF) {
          actMode = ACTIVITY_NONE;
        }
      }
    }
  }
}

//Used to show activity on the debug LED
void ledEvent() {
  if (!id_mode_enabled) {
    actMode = ACTIVITY_PREOFF;
    debug_led_set(FALSE);
    ledUpdateTime = millis() - LEDTIME_ACT / 2; //Half Off time
  }
}

void ledBlinkPattern(uint8_t count, int offTime) {
  if (millis() - ledUpdateTime > LEDTIME_BLINK) {
    if (blinkCount == 0) {
	    debug_led_set(FALSE);
    }
    if (blinkCount < count * 2) {
    	debug_led_toggle();
    }
    ledUpdateTime = millis();
    blinkCount++;
    if (blinkCount > count * 2 + (offTime / LEDTIME_BLINK)) {
    	blinkCount = 0;
    }
  }
}

void debug_led_init(void) {
	DEBUG_LED_DDR |= _BV(DEBUG_LED);
}

void debug_led_set(uint8_t on) {
	if (on) {
		DEBUG_LED_PORT |= _BV(DEBUG_LED);
	}
	else {
		DEBUG_LED_PORT &= ~(_BV(DEBUG_LED));
	}
}

void debug_led_toggle(void) {
	DEBUG_LED_PORT ^= _BV(DEBUG_LED);
}

void button_init(void) {
	BUTTON_DDR &= ~(_BV(BUTTON));
}

uint8_t button_is_pressed(void) {
	return !(BUTTON_PIN & _BV(BUTTON));
}

uint32_t millis(void) {
	uint8_t old_sreg = SREG;
	cli();
	uint32_t m = timer0_millis;
	SREG = old_sreg;
	return m;
}

ISR(TIMER0_OVF_vect) {
	timer0_millis++;
	TCNT0 = 0xFF - 125;
}

