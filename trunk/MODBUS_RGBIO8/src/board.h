#pragma once

/**
 * For ATmega168 running internal 8MHz oscillator
 *
 * Board Summary: 
 *
 * Pin Config:
 *	 Name	Number	Func	Description
 *   D6		10		LED_R	
 *   D7		11		LED_G	
 *   B1		13		XLAT
 *   B2		14		BLANK
 *   B3		15		MOSI
 *   B4		16		MISO
 *   B5		17		SCK
 *   D0		30		RO
 *   D1		31		DI
 *   D2		32		!RE+DE
 *   D3		1		  Q7
 *   C0		23		SH_CP
 *   C1		24		!PL
 *   C2		25		!MR
 *   C3		26		ST_CP
 *   C4		27		SDA
 *   C5		28		SCL
 */

#define   BUTTON_DDR				DDRB
#define   BUTTON_PIN				PINB
#define   BUTTON		        0

// TODO: Change to PD7 on production hardware
#define		DEBUG_LED_DDR		  DDRD
#define		DEBUG_LED_PORT		PORTD
#define		DEBUG_LED         7

#define		RTS_DDR		        DDRD
#define		RTS_PORT	        PORTD
#define		RTS	              2

// The ModBus port.h requires RTS_DDR, RTS_PORT and RTS_PIN, so
// make sure that's defined if it's not already
#ifndef   RTS_PIN
#define   RTS_PIN           RTS
#endif

#define		Q7_DDR			      DDRD
#define		Q7_PIN			      PIND
#define		Q7			          3

#define		SH_CP_DDR		      DDRC
#define		SH_CP_PORT		    PORTC
#define		SH_CP		          0

#define		_PL__DDR	      	DDRC
#define		_PL__PORT		      PORTC
#define		_PL_			         1

#define		_MR__DDR		      DDRC
#define		_MR__PORT		      PORTC
#define		_MR_			         2

#define		ST_CP_DDR		      DDRC
#define		ST_CP_PORT		    PORTC
#define		ST_CP			         3

#define		BLANK_DDR		      DDRB
#define		BLANK_PORT		    PORTB
#define		BLANK			         2

#define		MOSI_DDR		      DDRB
#define		MOSI_PORT		      PORTB
#define		MOSI			        3

#define		SCK_DDR			      DDRB
#define		SCK_PORT		      PORTB
#define		SCK			    	    5

#define		XLAT_DDR		      DDRB
#define		XLAT_PORT		      PORTB
#define		XLAT    			    1


