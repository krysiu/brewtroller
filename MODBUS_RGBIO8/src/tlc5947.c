#include <avr/io.h>
#include <string.h>
#include "board.h"
#include "tlc5947.h"

uint16_t tlc5947_data[24];

void tlc5947_init(void) {
 	// Enable outputs for TLC5947
 	XLAT_DDR |= _BV(XLAT);
 	BLANK_DDR |= _BV(BLANK);
 	MOSI_DDR |= _BV(MOSI);
 	SCK_DDR |= _BV(SCK);

	BLANK_PORT |= _BV(BLANK);
	tlc5947_clear();
	tlc5947_update();
	BLANK_PORT &= ~(_BV(BLANK));
}

void tlc5947_clear(void) {
	memset(tlc5947_data, 0, 24);
}

void tlc5947_update(void) {
	for (int i = 24; i >= 0; i--) {
		for (int j = 0; j < 12; j++) {
			uint8_t t = ((tlc5947_data[i] >> (11 - j)) & 0x01);
			if (t) {
				MOSI_PORT |= _BV(MOSI);
			}
			else {
				MOSI_PORT &= ~(_BV(MOSI));
			}
			SCK_PORT |= _BV(SCK);
			SCK_PORT &= ~(_BV(SCK));
		}
	}
	
	BLANK_PORT |= _BV(BLANK);
	XLAT_PORT |= _BV(XLAT);
	XLAT_PORT &= ~(_BV(XLAT));
	BLANK_PORT &= ~(_BV(BLANK));
}

void tlc5947_set_rgb(uint8_t output, uint8_t r, uint8_t g, uint8_t b) {
	tlc5947_data[output * 3] = (r * 16);
	tlc5947_data[output * 3 + 1] = (g * 16);
	tlc5947_data[output * 3 + 2] = (b * 16);
}

void tlc5947_set_hsv(uint8_t output, float h, float s, float v) {
	uint8_t r, g, b;
	hsv2rgb(h, s, v, &r, &g, &b);
	tlc5947_set_rgb(output, r, g, b);
}

void hsv2rgb(float H, float S, float V, uint8_t *r, uint8_t *g, uint8_t *b) {
  // http://www.easyrgb.com/index.php?X=MATH&H=21#text21

  int var_i;
  float R, G, B, var_1, var_2, var_3, var_h;

  if (S == 0) {
	R = V;
	G = V;
	B = V;
  }
  else {
	var_h = H * 6;
	if (var_h == 6) var_h = 0;	// H must be < 1
	var_i = (int) var_h;		  // or ... var_i = floor( var_h )
	var_1 = V * (1 - S );
	var_2 = V * (1 - S * (var_h - var_i));
	var_3 = V * (1 - S * (1 - (var_h - var_i)));

	if (var_i == 0) {
	  R = V;
	  G = var_3;
	  B = var_1;
	}
	else if (var_i == 1) {
	  R = var_2;
	  G = V;
	  B = var_1;
	}
	else if (var_i == 2) {
	  R = var_1;
	  G = V;
	  B = var_3;
	}
	else if (var_i == 3) {
	  R = var_1;
	  G = var_2;
	  B = V;
	}
	else if (var_i == 4) {
	  R = var_3;
	  G = var_1;
	  B = V;
	}
	else {
	  R = V;
	  G = var_1;
	  B = var_2;
	}
  }
  *r = (uint8_t) R * 255;
  *g = G * 255;
  *b = B * 255;
}
