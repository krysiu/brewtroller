#include "OT_InputBank.h"

using namespace OpenTroller;
#ifdef InputBank_GPIO
InputBankGPIO::InputBankGPIO(uint8_t pinCount) {
	_count = pinCount;
	pins = (pin *) malloc(_count * sizeof(pin));
}

InputBankGPIO::~InputBankGPIO() {
	free(pins);
}

void InputBankGPIO::setup(uint8_t pinIndex, uint8_t digitalPin) {
	pins[pinIndex].setup(digitalPin, INPUT);
}

void InputBankGPIO::set(uint8_t outputIndex, uint8_t outputValue) { pins[outputIndex].set(outputValue); }

uint8_t InputBankGPIO::getCount() { return _count; }

void InputBankGPIO::getName(char * retStr) { 
	strcpy_P(retStr, InputBank_GPIO_BANKNAME); 
}

#endif

#ifdef InputBank_MUX
InputBankMUX::InputBankMUX(uint8_t latchPin, uint8_t dataPin, uint8_t clockPin, uint8_t enablePin, boolean enableLogic) {
	muxLatchPin.setup(latchPin, OUTPUT);
	muxDataPin.setup(dataPin, OUTPUT);
	muxClockPin.setup(clockPin, OUTPUT);
	muxEnablePin.setup(enablePin, OUTPUT);
	muxEnableLogic = enableLogic;

	if (muxEnableLogic) {
		//MUX in Reset State
		muxLatchPin.clear(); //Prepare to copy pin states
		muxEnablePin.clear(); //Force clear of pin registers
		muxLatchPin.set();
		delayMicroseconds(10);
		muxLatchPin.clear();
		muxEnablePin.set(); //Disable clear
	} else {
		set(0);
		muxEnablePin.clear();
	}
}

void InputBankMUX::set(uint8_t outputIndex, uint8_t outputValue) {
	bitWrite(bitValues, outputIndex, outputValue);
	//ground latchPin and hold low for as long as you are transmitting
	muxLatchPin.clear();
	//clear everything out just in case to prepare shift register for bit shifting
	muxDataPin.clear();
	muxClockPin.clear();

	//for each bit in the long myDataOut
	for (uint8_t i = 0; i < 32; i++)  {
		muxClockPin.clear();
		//create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
		if ( bitValues & ((unsigned long)1<<(31 - i)) ) muxDataPin.set(); else muxDataPin.clear();
		//register shifts bits on upstroke of clock pin  
		muxClockPin.set();
		//zero the data pin after shift to prevent bleed through
		muxDataPin.clear();
	}

	//stop shifting
	muxClockPin.clear();
	muxLatchPin.set();
	delayMicroseconds(10);
	muxLatchPin.clear();
}

uint8_t InputBankMUX::getCount() { return InputBank_MUX_COUNT };
void InputBankMUX::getName(char * retStr) { strcpy_P(retStr, MUX_BANK_NAME); }
}
#endif

#ifdef InputBank_MODBUS
InputBankMODBUS::InputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount) {
	_slave = ModbusMaster (RS485_SERIAL_PORT, slaveAddr);
	#ifdef RS485_RTS_PIN
		_slave.setupRTS(RS485_RTS_PIN);
	#endif
	_slave.begin(RS485_BAUDRATE, RS485_PARITY);
	_coilReg = coilReg;
	_coilCount = coilCount;
	for (uint8_t i = 0; i < _coilCount; i++) set(i, 0);
}

void InputBankMODBUS::set(uint8_t outputIndex, uint8_t outputValue) { _slave.writeSingleCoil(_coilReg + outputIndex, outputValue); }
uint8_t InputBankMODBUS::getCount() { return _coilCount; }

void InputBankMODBUS::getName(char * retStr) { 
	strcpy_P(retStr, PSTR("Modbus Relay")); 
}
#endif


void OpenTroller::InputBanks::init() {
	//Free any memory already allocated
	if (_count) {
		free(_banks);
		_count = 0;
	}
	_max = InputBank_MAXBANKS;
	
	//Create the appropriate output bank objects for the hardware configuration (GPIO, MUX)
	#if defined InputBank_GPIO
	  addBank(new OpenTroller::InputBankGPIO (InputBank_GPIO_COUNT));
	#endif

	#if defined InputBank_MUX
	  addBank(new OpenTroller::InputBankMUX ( MUX_LATCH_PIN, MUX_DATA_PIN, MUX_CLOCK_PIN, MUX_ENABLE_PIN, MUX_ENABLE_LOGIC));
	#endif
}

void OpenTroller::InputBanks::addBank(InputBank * oBank) {
	if (_count < _max) _banks[_count++] = oBank;
}

void OpenTroller::InputBanks::addModbusBank(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount){
	addBank(new OpenTroller::InputBankMODBUS(slaveAddr, coilReg, coilCount));
}

uint8_t OpenTroller::InputBanks::getBankCount(){ return _count; }
void OpenTroller::InputBanks::get(uint8_t bankID, uint8_t outputID) { _banks[bankID]->set(outputID, value); }
void OpenTroller::InputBanks::getBankName(uint8_t bankID, char * retStr) { _banks[bankID]->getName(retStr); }
uint8_t OpenTroller::InputBanks::getInputCount(uint8_t bankID) { return _banks[bankID]->getCount(); }

//Create Global InputBanks Object
OpenTroller::InputBanks OpenTroller::InputBanks;