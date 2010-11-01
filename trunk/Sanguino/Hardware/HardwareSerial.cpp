//#define TxD_Interrupt
/*
  HardwareSerial.cpp - Hardware serial library for Wiring
  Copyright (c) 2006 Nicholas Zambetti.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  Modified 23 November 2006 by David A. Mellis
  Modified 31 October 2010 by Tom Harkaway
*/

/////////////////////////////////////////////////////////////////////
//  ToDo:
//	  1. Just get it working with comments  Done  
//	  2. Change int indexes to chars        Done
//	  3. Change % w/size to & w/mask        Done
//    4. Get it working w/all ATmegas       Done
//    5. Get it working w/Arduino           Done
//    6. Test char check to Rx interrupt
//	  7. Add Transmit Buffer w/interrupt
//    8. Check ISR() vs. SIGNAL()
//
/////////////////////////////////////////////////////////////////////
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "wiring.h"
#include "wiring_private.h"

#include "HardwareSerial.h"

// Receive and Transmit buffer sizes
//
#define RX_BUFFER_SIZE 128
#define TX_BUFFER_SIZE 32

// masks used to handle head/tail wraparound
//
#define RX_BUFFER_MASK (RX_BUFFER_SIZE-1)
#define TX_BUFFER_MASK (TX_BUFFER_SIZE-1)

// receive ring buffer
//
struct ring_bufferRx 
{
	unsigned char buffer[RX_BUFFER_SIZE];
	unsigned char head;
	unsigned char tail;
};

// transmit ring buffer
//
struct ring_bufferTx 
{
	unsigned char buffer[TX_BUFFER_SIZE];
	unsigned char head;
	unsigned char tail;
};

// serial 0 ring buffers for all chips
//
ring_bufferRx rx_buffer = { { 0 }, 0, 0 };
ring_bufferTx tx_buffer = { { 0 }, 0, 0 };

// serial 1 ring buffer for ATmega 644, 1284, 1280, or 2560
//
#if defined(__AVR_ATmega644P__) || defined(__AVR_ATmega1284P__) || defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  ring_bufferRx rx_buffer1 = { { 0 }, 0, 0 };
  ring_bufferTx tx_buffer1 = { { 0 }, 0, 0 };
#endif\

// serial 2 & 3 ring buffers for 1280, or 2560
//
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  ring_bufferRx rx_buffer2 = { { 0 }, 0, 0 };
  ring_bufferTx tx_buffer2 = { { 0 }, 0, 0 };
  ring_bufferRx rx_buffer3 = { { 0 }, 0, 0 };
  ring_bufferTx tx_buffer3 = { { 0 }, 0, 0 };
#endif


// receive character macro
//
inline void store_char(unsigned char c, ring_bufferRx *rx_buffer)
{
	char index = (rx_buffer->head + 1) & RX_BUFFER_MASK;
  if (index != rx_buffer->tail) {
    rx_buffer->buffer[rx_buffer->head] = c;
	  rx_buffer->head = index;
	}
}


// USART 0 interrupt handler
//
ISR(USART0_RX_vect)
{
	unsigned char c = UDR0;             // get character from Data Register
	store_char(c, &rx_buffer);          // stuff it in ring buffer
	//volatile uint8_t *ucsra = &UCSR0A;  // get address of Control/Status Register
	//if ((*ucsra) & (1 << RXC0))         // check for 2nd character
	//{
	//	c = UDR0;                         // get 2nd character
	//	store_char(c, &rx_buffer);        // stuff it in ring buffer
	//}
	// one more may have come in while we storing the last one
	//if (((*ucsra) & (1 << RXC0))
	//{
	//	c UDR0;
	//	store_char(c, &rx_buffer);
	//}
}

#if defined TxD_Interrupt
ISR(USART0_UDRE_vect)
{
	if (tx_buffer.head == tx_buffer.tail) 
	{
		// Buffer is empty, disable the interrupt
    volatile uint8_t *ucsrb = &UCSR0B;  // get address of Control/Status Register
		UCSR0B &= ~(1 << UDRIE0);
	} 
	else 
	{
		tx_buffer.tail = (tx_buffer.tail + 1) & TX_BUFFER_MASK;
		UDR0 = tx_buffer.buffer[tx_buffer.tail];
	}
}
#endif // TxD Interrupt

	
#if defined(__AVR_ATmega644P__) || defined(__AVR_ATmega1284P__) || defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  // USART 1 interrupt handler
  //
  ISR(USART1_RX_vect)
  {
	  unsigned char c = UDR1;
	  store_char(c, &rx_buffer1);
  }

  #if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
    // USART 2 interrupt handler
    //
    ISR(USART2_RX_vect)
	  {
		unsigned char c = UDR2;
		store_char(c, &rx_buffer2);
	  }
	
    // USART 3 interrupt handler
    //
    ISR(USART3_RX_vect)
	  {
		  unsigned char c = UDR3;
		  store_char(c, &rx_buffer3);
	  }
  #endif // end of ATmega1280 of ATmega2560

#else // not an ATMega 644, 184, 1280, or 2560

  #if defined(__AVR_ATmega8__)
    SIGNAL(SIG_UART_RECV) 
  #else
    SIGNAL(USART_RX_vect)
  #endif
  
  {
    #if defined(__AVR_ATmega8__)
       unsigned char c = UDR;
    #else
      unsigned char c = UDR0;
    #endif

    store_char(c, &rx_buffer);

  }

#endif // Interrupt Handlers



/**** Constructors  ***************************************************************/

HardwareSerial::HardwareSerial(ring_bufferRx *rx_buffer, ring_bufferTx *tx_buffer,
  volatile uint8_t *ubrrh, volatile uint8_t *ubrrl,
  volatile uint8_t *ucsra, volatile uint8_t *ucsrb, volatile uint8_t *udr, 
  uint8_t rxen, uint8_t txen, uint8_t rxc, uint8_t rxcie, uint8_t udre, uint8_t udrie, uint8_t u2x)
{
	_rx_buffer = rx_buffer;
	_tx_buffer = tx_buffer;

	_ubrrh	= ubrrh;	// USART Baud Rate Register High
	_ubrrl	= ubrrl;	// USART Baud Rate Register Low
	_ucsra	= ucsra;	// USART Ctrl/Sts Register A
	_ucsrb	= ucsrb;	// USART Ctrl/Sts Register B	
	_udr	= udr;		  // USART Data Register

	_rxen	= rxen;		  // RxD Enable
	_txen	= txen;		  // TxD Enable
	_rxc	= rxc;		  // RxD Receive Complete
	_rxcie	= rxcie;	// RxD Receive Complete Interrupt Enable
	_udre	= udre;		  // TxD Data Register Empty
	_udrie	= udrie;	// TxD Data Register Empty Interrupt Enable
	_u2x	= u2x;		  // 2x Clock
}

/****** Public Methods *********************************************************/

//**********************************
//	serial.begin
//
void HardwareSerial::begin(long baud)
{
	uint16_t baud_setting;
	bool use_u2x;

	// U2X mode is needed for baud rates higher than (CPU Hz / 16)
  if (baud > F_CPU / 16) {
    use_u2x = true;
  } else {
		// figure out if U2X mode would allow for a better connection

		// calculate the percent difference between the baud-rate specified and
		// the real baud rate for both U2X and non-U2X mode (0-255 error percent)
		uint8_t nonu2x_baud_error = abs((int)(255-((F_CPU/(16*(((F_CPU/8/baud-1)/2)+1))*255)/baud)));
		uint8_t u2x_baud_error = abs((int)(255-((F_CPU/(8*(((F_CPU/4/baud-1)/2)+1))*255)/baud)));

		// prefer non-U2X mode because it handles clock skew better
		use_u2x = (nonu2x_baud_error > u2x_baud_error);
	}

    if (use_u2x) {
		*_ucsra = 1 << _u2x;
		baud_setting = (F_CPU / 4 / baud - 1) / 2;
    } else {
		*_ucsra = 0;
		baud_setting = (F_CPU / 8 / baud - 1) / 2;
	}

	// assign the baud_setting, a.k.a. ubbr (USART Baud Rate Register)
	*_ubrrh = baud_setting >> 8;
	*_ubrrl = baud_setting;

	sbi(*_ucsrb, _rxen);	// Enable RxD
	sbi(*_ucsrb, _txen);	// Enable TxD
	sbi(*_ucsrb, _rxcie);	// Enable RxD Complete Interrupt
}


//**********************************
//	serial.end
//
void HardwareSerial::end()
{
	cbi(*_ucsrb, _rxen);	// Disable RxD
	cbi(*_ucsrb, _txen);	// Disable TxD
	cbi(*_ucsrb, _rxcie); // Disable RxD Complete Interrupt
}


//**********************************
//	serial.available
//
int HardwareSerial::available(void)
{
	//. ToDo: Think about this, there may been an even better way
	return (RX_BUFFER_SIZE + _rx_buffer->head - _rx_buffer->tail) & RX_BUFFER_MASK;
}


//**********************************
//	Serial.peek
int HardwareSerial::peek(void)
{
  if (_rx_buffer->head == _rx_buffer->tail) {
    return -1;
  } else {
    return _rx_buffer->buffer[_rx_buffer->tail];
  }
}


//**********************************
//	Serial.read
//
int HardwareSerial::read(void)
{
  // if the head isn't ahead of the tail, we don't have any characters
  if (_rx_buffer->head == _rx_buffer->tail) {
    return -1;
  } else {
    unsigned char c = _rx_buffer->buffer[_rx_buffer->tail];
	_rx_buffer->tail = (_rx_buffer->tail + 1) & RX_BUFFER_MASK;
	return c;
  }
}


//**********************************
//	Serial.flush
//
void HardwareSerial::flush()
{
	// don't reverse this or there may be problems if the RX interrupt
	// occurs after reading the value of rx_buffer_head but before writing
	// the value to rx_buffer_tail; the previous value of rx_buffer_head
	// may be written to rx_buffer_tail, making it appear as if the buffer
	// don't reverse this or there may be problems if the RX interrupt
	// occurs after reading the value of rx_buffer_head but before writing
	// the value to rx_buffer_tail; the previous value of rx_buffer_head
	// may be written to rx_buffer_tail, making it appear as if the buffer
	// were full, not empty.
	
	_rx_buffer->head = _rx_buffer->tail;

	//. ToDo: Check this out, it may be better to just disable interrupts
}


//**********************************
//	Serial.write
//
void HardwareSerial::write(uint8_t c)
{
#if defined TxD_Interrupt
	// Interrupt Driven

	// Calculate new head position
	uint8_t tmp_head = (_tx_buffer->head + 1) & TX_BUFFER_MASK;

	// Block until there's room in the buffer
	// XXX: this may block forever if someone externally disabled the transmitter
	//      or the DRE interrupt and there's data in the buffer. Careful!
	while (tmp_head == _tx_buffer->tail)
		;

	// Advance the head, store the data
	_tx_buffer->buffer[tmp_head] = c;
	_tx_buffer->head = tmp_head;

	// Enable Data Register Empty interrupt
	*_ucsrb |= (1 << _udrie); 
#else
	//.4
	//. ToDo: Should we just throw away incoming characters.
	//	The other implementation throws away the oldest data in the buffer
	//. ToDo: should the shift count be a constant?

  while ((*_ucsra & (1 << _udre)) == 0)
    ;

	*_udr = c;                          // send character to DataRegister

#endif

}


/****** Instantiate Objects ************************************************/

#if defined(__AVR_ATmega8__)
  HardwareSerial Serial(&rx_buffer, &tx_buffer, &UBRRH, &UBRRL, &UCSRA, &UCSRB, &UDR, RXEN, TXEN, RXC, RXCIE, UDRE, UDRIE, U2X);
#else
  HardwareSerial Serial(&rx_buffer, &tx_buffer, &UBRR0H, &UBRR0L, &UCSR0A, &UCSR0B, &UDR0, RXEN0, TXEN0, RXC0, RXCIE0, UDRE0, UDRIE0, U2X0);
#endif

#if defined(__AVR_ATmega644P__) || defined(__AVR_ATmega1284P__) || defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  HardwareSerial Serial1(&rx_buffer1, &tx_buffer1, &UBRR1H, &UBRR1L, &UCSR1A, &UCSR1B, &UDR1, RXEN1, TXEN1, RXC1, RXCIE1, UDRE1, UDRIE1, U2X1);
#endif

#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  HardwareSerial Serial2(&rx_buffer2, &tx_buffer2, &UBRR2H, &UBRR2L, &UCSR2A, &UCSR2B, &UDR2, RXEN2, TXEN2, RXC2, RXCIE2, UDRE2, UDRIE2, U2X2);
  HardwareSerial Serial3(&rx_buffer3, &tx_buffer3, &UBRR3H, &UBRR3L, &UCSR3A, &UCSR3B, &UDR3, RXEN3, TXEN3, RXC3, RXCIE3, UDRE3, UDRIE3, U2X3);
#endif

// AVR-ATmega644p/1284p/1280/2560
//										                           0	   1	   2	   3
//	&USDR	  - USART Data Register				        0xC6	0xCE	0xD6	0x136			
//	&UBRRH	- USART Baud Rate Register High		  0xC5	0xCD	0xD5	0x135
//	&UBRRL	- USART Baud Rate Register Low		  0xC4	0xCC	0xD4	0x134
//			    - USART Control/Status Register	C	  0xC2	0xCA	0xD2	0x132
//	&UCSRB	- USART Control/Status Register	B	  0xC1	0xC9	0xD1	0x131
//	&UCSRA	- USART Control/Status Register	A	  0xC0	0xC8	0xD0	0x130
// 
//	RXEN	- bit4	RxD Enable (UCSRB bit 4)
//	TXEN	- bit3	TxD Enable (UCSRB bit 3)
//	RXC		- bit7	RxD Receive Complete (UCSRA bit 7)
//	RXCIE	- bit7	RxD Complete Interrupt Enable (UCSRB bit 7)
//	UDRE	- bit5	Data Register Empty (UCSRA bit 5)
//	UDRIE	- bit5	Data Register Empty Interrupt Enable (UCSRB bit 5)
//	U2X		- bit1	2x Clock (UCSRB bit 1)

