#pragma once

void tlc5947_init(void);
void tlc5947_clear(void);
void tlc5947_update(void);
void tlc5947_set_rgb(uint8_t output, uint8_t r, uint8_t g, uint8_t b);
void tlc5947_set_hsv(uint8_t output, float h, float s, float v);
void hsv2rgb(float H, float S, float V, uint8_t *r, uint8_t *g, uint8_t *b);

