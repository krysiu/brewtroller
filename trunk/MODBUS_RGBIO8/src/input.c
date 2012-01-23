#include <avr/io.h>
#include <avr/interrupt.h>
#include "board.h"
#include "input.h"

static uint16_t inputs;

/**
FUNCTION TABLE
Notes
1. H = HIGH voltage level
L = LOW voltage level
X = don’t care
↑ = LOW-to-HIGH CP transition
STCP SHCP PL MR FUNCTION
↑ X X X data loaded to input latches
↑ X L H data loaded from inputs to shift register
no clock edge X L H data transferred from input ﬂip-ﬂops to shift register
X X L L invalid logic, state of shift register indeterminate when signals removed
X X H L shift register cleared
X ↑ H H shift register clocked Qn = Qn−1, Q0 = DS
*/

void input_init(void) {
	// Enable shift register outputs
	ST_CP_DDR |= _BV(ST_CP);
	SH_CP_DDR |= _BV(SH_CP);
	_PL__DDR |= _BV(_PL_);
	_MR__DDR |= _BV(_MR_);
}

void input_refresh(void) {
	ST_CP_PORT &= ~(_BV(ST_CP));
	_PL__PORT &= ~(_BV(_PL_));
	_MR__PORT |= ~(_BV(_MR_));
	ST_CP_PORT |= _BV(ST_CP);
	ST_CP_PORT &= ~(_BV(ST_CP));

	uint16_t temp_inputs = 0;

	SH_CP_PORT &= ~(_BV(SH_CP));
	_PL__PORT |= _BV(_PL_);
	_MR__PORT |= _BV(_MR_);

	temp_inputs |= (Q7_PIN & _BV(Q7)) ? 0 : 1;

	for (int i = 0; i < 15; i++) {
		temp_inputs <<= 1;
		SH_CP_PORT |= _BV(SH_CP);
		SH_CP_PORT &= ~(_BV(SH_CP));
		temp_inputs |= (Q7_PIN & _BV(Q7)) ? 0 : 1;
	}
	
	cli();
	inputs = temp_inputs;
	sei();
}

int input_is_set(int row, int a_or_m) {
	// 0M, 0A, 1M, 1A, ... 7M, 7A
	int bit = ((7 - row) * 2) + a_or_m;
	return !!(inputs & (1 << bit));
}

