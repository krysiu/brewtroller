#include "OT_OutputBank.h"

using namespace OpenTroller;
#ifdef OUTPUTBANK_GPIO
OutputBankGPIO::OutputBankGPIO(uint8_t pinCount) {
	_count = pinCount;
	pins = (pin *) malloc(_count * sizeof(pin));
}

OutputBankGPIO::~OutputBankGPIO() {
	free(pins);
}

void OutputBankGPIO::setup(uint8_t pinIndex, uint8_t digitalPin) {
	pins[pinIndex].setup(digitalPin, OUTPUT);
	pins[pinIndex].clear();
}

void OutputBankGPIO::set(uint8_t outputIndex, uint8_t outputValue) { pins[outputIndex].set(outputValue); }
uint8_t OutputBankGPIO::get(uint8_t outputIndex) { return pins[outputIndex].get(); }
uint8_t OutputBankGPIO::getCount() { return _count; }

void OutputBankGPIO::getName(char * retStr) { 
	strcpy(retStr, OUTPUTBANK_GPIO_BANKNAME); 
}

#endif

#ifdef OUTPUTBANK_MUX
OutputBankMUX::OutputBankMUX(uint8_t latchPin, uint8_t dataPin, uint8_t clockPin, uint8_t enablePin, boolean enableLogic) {
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

void OutputBankMUX::set(uint8_t outputIndex, uint8_t outputValue) {
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
uint8_t OutputBankMUX::get(uint8_t outputIndex); { return bitRead(bitValues, outputIndex); }
uint8_t OutputBankMUX::getCount() { return OUTPUTBANK_MUX_COUNT };
void OutputBankMUX::getName(char * retStr) { strcpy(retStr, OUTPUTBANK_MUX_BANKNAME); }
}
#endif

#ifdef OUTPUTBANK_MODBUS
OutputBankMODBUS::OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount) {
	_slaveAddr = slaveAddr;
	_slave = ModbusMaster (RS485_SERIAL_PORT, _slaveAddr);
	#ifdef RS485_RTS_PIN
		_slave.setupRTS(RS485_RTS_PIN);
	#endif
	_slave.begin(RS485_BAUDRATE, RS485_PARITY);
	_coilReg = coilReg;
	_coilCount = coilCount;
}

void OutputBankMODBUS::set(uint8_t outputIndex, uint8_t outputValue) { 
	//_slave.setTransmitBuffer(0, outputValue);
	//_slave.setTransmitBuffer(1, 0);
	//_slave.writeMultipleCoils(_coilReg + outputIndex - 1, 1); 
	_slave.writeSingleCoil(_coilReg + outputIndex - 1, outputValue); 
}

uint8_t OutputBankMODBUS::get(uint8_t outputIndex) { 
	_slave.readCoils(_coilReg + outputIndex - 1, 1);  
	return _slave.getResponseBuffer(0);
}
uint8_t OutputBankMODBUS::getCount() { return _coilCount; }

void OutputBankMODBUS::getName(char * retStr) { 
	char sID[4];
	strcpy(retStr, "Modbus Relay #");
	itoa(_slaveAddr, sID, 10);
	strcat(retStr, sID);
}
#endif

OutputBankGroup::OutputBankGroup(uint8_t * ptrData, uint8_t bankBits, uint8_t bankSize, uint8_t groupSize) {
	_ptrData = ptrData;
	_bankBits = bankBits;
	_bankSize = bankSize;
	_groupSize = groupSize;
	_bankMask = 0;
	for (uint8_t i = 0; i < _bankBits; i++) bitSet(_bankMask, 7 - i);
}

void OutputBankGroup::set(uint8_t outputIndex, uint8_t outputValue) {
	bitWrite(bitValues, outputIndex, outputValue);
	uint8_t * data = _ptrData + outputIndex * _groupSize;
	if (outputIndex >= _bankSize) return;
	while (&data < &_ptrData + (outputIndex + 1) * _groupSize) {
		if ((*data & _bankMask) != (255 & _bankMask)) OutputBanks.set(*data>>(8 - _bankBits), *data & (~_bankMask), outputValue);
		data++;
	}
}
uint8_t OutputBankGroup::get(uint8_t outputIndex) { return bitRead(bitValues, outputIndex); }
uint8_t OutputBankGroup::getCount() { return _bankSize; }
void OutputBankGroup::getName(char * retStr) { strcpy(retStr, "Output Groups"); }

void OpenTroller::outputBanks::init() {
	//Free any memory already allocated
	if (_count) {
		free(_banks);
		_count = 0;
	}
	_max = OUTPUTBANK_MAXBANKS;
	
	//Create the appropriate output bank objects for the hardware configuration (GPIO, MUX)
	#if defined OUTPUTBANK_GPIO
	  OpenTroller::OutputBankGPIO * ptrBank;
	  ptrBank = new OpenTroller::OutputBankGPIO (OUTPUTBANK_GPIO_COUNT);
	  addBank(ptrBank);
	  uint8_t pinNums[OUTPUTBANK_GPIO_COUNT] = OUTPUTBANK_GPIO_PINS;
	  for (uint8_t i = 0; i < OUTPUTBANK_GPIO_COUNT; i++) ptrBank->setup(i, pinNums[i]);
	#endif

	#if defined OUTPUTBANK_MUX
	  addBank(new OpenTroller::OutputBankMUX ( MUX_LATCH_PIN, MUX_DATA_PIN, MUX_CLOCK_PIN, MUX_ENABLE_PIN, MUX_ENABLE_LOGIC));
	#endif
}

void OpenTroller::outputBanks::addBank(OutputBank * oBank) {
	if (_count < _max) _banks[_count++] = oBank;
}

void OpenTroller::outputBanks::addModbusBank(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount){
	addBank(new OpenTroller::OutputBankMODBUS(slaveAddr, coilReg, coilCount));
}

uint8_t OpenTroller::outputBanks::getBankCount(){ return _count; }
void OpenTroller::outputBanks::set(uint8_t bankID, uint8_t outputID, uint8_t value) { _banks[bankID]->set(outputID, value); }
uint8_t OpenTroller::outputBanks::get(uint8_t bankID, uint8_t outputID) { return _banks[bankID]->get(outputID); }
void OpenTroller::outputBanks::getBankName(uint8_t bankID, char * retStr) { _banks[bankID]->getName(retStr); }
uint8_t OpenTroller::outputBanks::getOutputCount(uint8_t bankID) { return _banks[bankID]->getCount(); }
uint8_t OpenTroller::outputBanks::getType(uint8_t bankID) { return _banks[bankID]->getType(); }

//Create Global OutputBanks Object
OpenTroller::outputBanks OpenTroller::OutputBanks;