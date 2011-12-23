#include "OT_Status.h"

using namespace OpenTroller;

void statusLED::init() {
	_interval = STATUSLED_INTERVAL;
    _hbPin.setup(STATUSLED_PIN, OUTPUT);
}

void statusLED::update() {
	if (_status) {
		if (millis() - _hbStart > STATUSLED_BLINKONTIME) {
			if (_blinks == 0) _hbPin.clear(); //Start with LED Off
			if (_blinks < _status * 2) _hbPin.toggle();
			_hbStart = millis();
			_blinks++;
			if (_blinks > _status * 2 + (STATUSLED_BLINKOFFTIME / STATUSLED_BLINKONTIME)) _blinks = 0;
		}
	}
	else {
		if (millis() - _hbStart > _interval) {
			_hbPin.toggle();
			_hbStart = millis();
		}
	}
}

void statusLED::setStatus(uint8_t value) {
	_status = value;
	update();
}

uint8_t statusLED::getStatus() { return _status; }

OpenTroller::statusLED OpenTroller::StatusLED;