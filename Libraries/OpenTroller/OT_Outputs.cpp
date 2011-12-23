#include "OT_Outputs.h"

#ifdef OPENTROLLER_OUTPUTS
	using namespace OpenTroller;
	
		#ifdef OUTPUTBANK_GPIO
		OutputGPIO::OutputGPIO(void) { _bank = NULL; }
		void OutputGPIO::setup(OutputBankGPIO * bank, uint8_t index, uint8_t digitalPinNum) {
			_bank = bank;
			_index = index;
			_pin.setup(digitalPinNum, OUTPUT);
			_pin.clear();
			_err = 0;
		}
		void OutputGPIO::set(uint8_t value) { _pin.set(value); }
		uint8_t OutputGPIO::get() { return _pin.get(); }
		uint8_t OutputGPIO::getErr() {  return _err; }
		void OutputGPIO::getName(char * retString) { _bank->getOutputName(_index, retString); }
	#endif

	#ifdef OUTPUTBANK_MUX
		OutputMUX::OutputMUX(void) {
			_err = _value = 0;
			_bank = NULL;
		}
		void OutputMUX::setup(OutputBankMUX * bank, uint8_t index) {
			_bank = bank;
			_index = index;
		}
		void OutputMUX::set(uint8_t value) {
			if (_value == value) return;
			_bank->_doUpdate = 1;
			_value = value;
		}
		uint8_t OutputMUX::get() { return _value; }
		uint8_t OutputMUX::getErr() { return _bank->_err; }
		void OutputMUX::getName(char * retString) { _bank->getOutputName(_index, retString); }
	#endif

	#ifdef OUTPUTBANK_MODBUS
		OutputMODBUS::OutputMODBUS(void) {
			_value = 0;
			_bank = NULL;
		}
		
		void OutputMODBUS::setup(OutputBankMODBUS * bank, uint8_t index) {
			_bank = bank;
			_index = index;
		}
		
		void OutputMODBUS::set(uint8_t value) {
			if (_value == value) return;
			_bank->_doUpdate = 1;
			_value = value;
		}
		uint8_t OutputMODBUS::get() { return _value; }
		uint8_t OutputMODBUS::getErr() { return _bank->_err; }
		void OutputMODBUS::getName(char * retString) { _bank->getOutputName(_index, retString); }
	#endif
	#ifdef OUTPUTBANK_GROUPS
		OutputGroup::OutputGroup(void) { _count = _err = _value = 0; }
		OutputGroup::~OutputGroup(void) { if (_count) delete [] _outputs; }

		void OutputGroup::init(char name[], uint8_t groupSize) {
			strlcpy(_name, name, 15);
			if (_count) delete [] _outputs;
			_count = groupSize;
			if (_count) {
				_outputs = new Output * [_count];
				for (uint8_t i = 0; i < _count; i++) _outputs[i] = NULL;
			}
		}

		void OutputGroup::assignOutput(uint8_t index, Output * outputPtr) { if (index < _count) _outputs[index] = outputPtr; }

		void OutputGroup::set(uint8_t value) {
			_err = 0;
			_value = value;
			for (uint8_t i = 0; i < _count; i++) {
				_outputs[i]->set(value);
				if (_outputs[i]->getErr()) _err = 1;
			}
		}
		uint8_t OutputGroup::get() { return _value; }
		uint8_t OutputGroup::getErr() { return _err; }
		void OutputGroup::getName(char * retString) { strcpy(retString, _name); }
	#endif
	
	uint8_t OutputBank::getCount(void) { return _count; }

	#ifdef OUTPUTBANK_GPIO
	OutputBankGPIO::OutputBankGPIO(uint8_t pinCount) {
		_count = pinCount;
		_outputs = new OutputGPIO[_count];
	}

	OutputBankGPIO::~OutputBankGPIO() { delete [] _outputs; }

	Output * OutputBankGPIO::getOutput(uint8_t index) { if (index < _count) return (_outputs + index); }
	void OutputBankGPIO::setup(uint8_t index, uint8_t digPinNum) { _outputs[index].setup(this, index, digPinNum); }
	void OutputBankGPIO::getName(char * retStr) { 
		strcpy(retStr, OUTPUTBANK_GPIO_BANKNAME); 
	}
	uint8_t OutputBankGPIO::getType() { return OUTPUTBANK_TYPE_GPIO; }
	void OutputBankGPIO::getOutputName(uint8_t index, char * retString) {
		char buf[4];
		strcpy(retString, "Output ");
		strcat(retString, itoa(index + 1, buf, 10));
	}
	#endif

	#ifdef OUTPUTBANK_MUX
	OutputBankMUX::OutputBankMUX(uint8_t latchPin, uint8_t dataPin, uint8_t clockPin, uint8_t enablePin, uint8_t enableLogic, uint8_t count) {
		_err = _doUpdate = 0;
		_count = count;
		_outputs = new OutputMUX[_count];
		for (uint8_t i = 0; i < _count; i++) _outputs[i].setup(this, i);
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

	Output * OutputBankMUX::getOutput(uint8_t index) { if (index < _count) return _outputs + index; }

	void OutputBankMUX::update() {
		if(!_doUpdate) return;
		//ground latchPin and hold low for as long as you are transmitting
		muxLatchPin.clear();
		//clear everything out just in case to prepare shift register for bit shifting
		muxDataPin.clear();
		muxClockPin.clear();

		//for each bit in the long myDataOut
		for (uint8_t i = 0; i < 32; i++)  {
			muxClockPin.clear();
			//create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
			if ( _output[i]->get() ) muxDataPin.set(); else muxDataPin.clear();
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
		_doUpdate = 0;
	}
	void OutputBankMUX::getName(char * retStr) { strcpy(retStr, OUTPUTBANK_MUX_BANKNAME); }
	uint8_t OutputBankMUX::getType() { return OUTPUTBANK_TYPE_MUX; }
	void OutputBankMUX::getOutputName(uint8_t index, char * retStr) {
		char buf[4];
		strcpy(retString, "Output ");
		strcat(retString, itoa(index + 1, buf, 10));
	}
	#endif

	#ifdef OUTPUTBANK_MODBUS
	OutputBankMODBUS::OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount) {
		_err = _doUpdate = 0;
		_slaveAddr = slaveAddr;
		_slave = ModbusMaster (RS485_SERIAL_PORT, _slaveAddr);
		#ifdef RS485_RTS_PIN
			_slave.setupRTS(RS485_RTS_PIN);
		#endif
		_slave.begin(RS485_BAUDRATE, RS485_PARITY);
		//Modbus Coil Register index starts at 1 but is transmitted with a 0 index
		_coilReg = coilReg - 1;
		_count = coilCount;
		_outputs = new OutputMODBUS[_count];
		for (uint8_t i = 0; i < _count; i++) _outputs[i].setup(this, i);
	}

	Output * OutputBankMODBUS::getOutput(uint8_t index) { if (index < _count) return _outputs + index; }

	void OutputBankMODBUS::update() {
		if (!_doUpdate) return;
		for (uint8_t bytePos = 0; bytePos < BIT_TO_BYTE_COUNT(_count); bytePos++) {
			uint8_t byteData = 0;
			for (uint8_t bitPos = 0; bitPos < 8; bitPos++) bitWrite(byteData, bitPos, ((bytePos * 8 + bitPos < _count) ? _outputs[bytePos * 8 + bitPos].get() : 0));
			_slave.setTransmitBuffer(bytePos, byteData);
		}
		_err = _slave.writeMultipleCoils(_coilReg, _count); 
		_doUpdate = 0;
	}

	void OutputBankMODBUS::getName(char * retStr) { 
		char sID[4];
		strcpy(retStr, "Modbus Relay #");
		itoa(_slaveAddr, sID, 10);
		strcat(retStr, sID);
	}

	uint8_t OutputBankMODBUS::getType() { return OUTPUTBANK_TYPE_MODBUS; }
	
	void OutputBankMODBUS::getOutputName(uint8_t index, char * retStr) { 
		char buf[4];
		strcpy(retStr, "Output ");
		strcat(retStr, itoa(index + 1, buf, 10));
	}
	#endif
	#ifdef OUTPUTBANK_GROUPS
		OutputBankGroups::OutputBankGroups(void) { _count = 0; }
		OutputBankGroups::~OutputBankGroups(void) { init(0); }
		
		void OutputBankGroups::init(uint8_t count) {
			if (_count) delete [] _groups;
			_count = count;
			if(_count) _groups = new OutputGroup[_count];
		}
		
		Output * OutputBankGroups::getOutput(uint8_t index) { if (index < _count) return _groups + index; }
		OutputGroup * OutputBankGroups::getGroup(uint8_t index) { if (index < _count) return _groups + index; }
		void OutputBankGroups::getName(char * retStr) { strcpy(retStr, "Output Groups"); }
		uint8_t OutputBankGroups::getType(void) { return OUTPUTBANK_TYPE_GROUPS; }
		void OutputBankGroups::update(void) {
			for (uint8_t i = 0; i < _count; i++) if(_groups[i].get()) _groups[i].set(1);
		}
		
	#endif
	
	outputs::outputs(void) {
		_count = 0;
		_max = OUTPUTS_MAXBANKS;
		_banks = new OutputBank * [_max];
		for (uint8_t i = 0; i < _max; i++) _banks[i] = NULL;
		_groups = NULL;
	}

	outputs::~outputs(void) { delete [] _banks; }

	void outputs::init() {
		//Create the appropriate output bank objects for the hardware configuration (GPIO, MUX)
		//If OUTPUTBANK_GROUPS defined, add them first
		#ifdef OUTPUTBANK_GROUPS
			addBank(_groups = new OutputBankGroups());
		#endif
		
		#if defined OUTPUTBANK_GPIO
			OutputBankGPIO * ptrBank = new OutputBankGPIO (OUTPUTBANK_GPIO_COUNT);
			addBank(ptrBank);
			uint8_t pinNums[OUTPUTBANK_GPIO_COUNT] = OUTPUTBANK_GPIO_PINS;
			for (uint8_t i = 0; i < OUTPUTBANK_GPIO_COUNT; i++) ptrBank->setup(i, pinNums[i]);
		#endif

		#if defined OUTPUTBANK_MUX
		  addBank(new OutputBankMUX ( MUX_LATCH_PIN, MUX_DATA_PIN, MUX_CLOCK_PIN, MUX_ENABLE_PIN, MUX_ENABLE_LOGIC, OUTPUTBANK_MUX_COUNT));
		#endif
	}

	void outputs::addBank(OutputBank * oBank) { if (_count < _max) _banks[_count++] = oBank; }
	#ifdef OUTPUTBANK_MODBUS
		void outputs::newModbusBank(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount){
			addBank(new OutputBankMODBUS(slaveAddr, coilReg, coilCount));
		}
	#endif
	#ifdef OUTPUTBANK_GROUPS
		OutputBankGroups * outputs::getGroups(void) { return _groups; }
	#endif

	uint8_t outputs::getBankCount(){ return _count; }
	OutputBank * outputs::getBank(uint8_t bankIndex){ return _banks[bankIndex]; }
	void outputs::update() {
		uint8_t count = 0;
		while(count < _count) _banks[count++]->update();
	}

	//Create Global Outputs Object
	OpenTroller::outputs OpenTroller::Outputs;
#endif //#ifdef OPENTROLLER_OUTPUTS