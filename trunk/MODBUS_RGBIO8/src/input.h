#pragma once

#define 	INPUT_A 		0
#define 	INPUT_M 		1

void input_init(void);
void input_refresh(void);
int input_is_set(int row, int a_or_m);
