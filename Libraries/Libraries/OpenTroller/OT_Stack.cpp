#include "OT_Stack.h"

void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { free(ptr); }
void * operator new[](size_t size) { return malloc(size); }
void operator delete[](void * ptr) { if (ptr) free(ptr); }

using namespace OpenTroller;

void stack::init() {
	#ifdef OPENTROLLER_OUTPUTS
		OpenTroller::Outputs.init();
	#endif
	
	#if defined OPENTROLLER_LCD4BIT || defined OPENTROLLER_LCDI2C
		OpenTroller::LCD.begin(OPENTROLLER_LCD_COLS, OPENTROLLER_LCD_ROWS);
		OpenTroller::LCD.init();
	#endif
	
	#if defined OPENTROLLER_ENCODER_GPIO
		OpenTroller::Encoder.begin(ENCODER_TYPE, ENTER_PIN, ENCA_PIN, ENCB_PIN);
	#endif
	
	#if defined OPENTROLLER_STATUSLED
		OpenTroller::StatusLED.init();
	#endif
}

void stack::update() {
	#if defined OPENTROLLER_LCD4BIT || defined OPENTROLLER_LCDI2C
		OpenTroller::LCD.update();
	#endif

	#if defined OPENTROLLER_STATUSLED
		OpenTroller::StatusLED.update();
	#endif
	#ifdef OPENTROLLER_OUTPUTS
		OpenTroller::Outputs.update();
	#endif
}

OpenTroller::stack OpenTroller::Stack;


