#ifndef OT_PVOUT_H
	#define OT_PVOUT_H
	#include "OT_Stack.h"
	#include "OT_HWProfile.h"
	#include "OT_Pin.h"
	#include <ModbusMaster.h>

typedef enum
{
    OUTPUTBANK_TYPE_GPIO,
    OUTPUTBANK_TYPE_MUX,
    OUTPUTBANK_TYPE_MODBUS,
	OUTPUTBANK_TYPE_GROUP
} OutputBankType;
	
	namespace OpenTroller{
		class OutputBank
		{
			public:
			  virtual void set(uint8_t, uint8_t) = 0;
			  virtual uint8_t getCount(void) = 0;
			  virtual void getName(char *) = 0;
			  virtual uint8_t getType() = 0;
		};

		class OutputBankGPIO: public OutputBank
		{
			private:
			pin* pins;
			uint8_t _count;

			public:
			OutputBankGPIO(uint8_t pinCount);
			~OutputBankGPIO();
			void setup(uint8_t pinIndex, uint8_t digitalPin);
			void set(uint8_t, uint8_t);
			uint8_t getCount();
			void getName(char * retStr);
			uint8_t getType() { return OUTPUTBANK_TYPE_GPIO; }
		};

	  class OutputBankMUX: public OutputBank
	  {
		private:
		pin muxLatchPin, muxDataPin, muxClockPin, muxEnablePin;
		boolean muxEnableLogic;
		unsigned long bitValues;
		
		public:
		OutputBankMUX(uint8_t latchPin, uint8_t dataPin, uint8_t clockPin, uint8_t enablePin, boolean enableLogic);
		void set(uint8_t, uint8_t);
		uint8_t getCount();
		void getName(char * retStr);
		uint8_t getType() { return OUTPUTBANK_TYPE_MUX; }
	  };

	 
	  class OutputBankMODBUS: public OutputBank
	  {
		private:
		ModbusMaster _slave;
		unsigned int _coilReg;
		uint8_t _coilCount;

		public:
		OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount);
		void set(uint8_t, uint8_t);
		uint8_t getCount();
		void getName(char * retStr);
		uint8_t getType() { return OUTPUTBANK_TYPE_MODBUS; }
	  };
	  
	  class OutputBankGroup: public OutputBank
	  {
		private:
		uint8_t _bankBits; //number of bits in group output definition that identify the bank ID
		uint8_t _bankMask; //mask of bits in group output definition that identify the bank ID
		uint8_t _bankSize;  //Number of groups in bank
		uint8_t _groupSize;   //Number of outputs per group
		uint8_t * _ptrData; //Pointer to the group definitions; 1 byte values specifying the bank and output of each member of the group

		public:
		OutputBankGroup(uint8_t *, uint8_t, uint8_t, uint8_t);
		void set(uint8_t, uint8_t);
		uint8_t getCount();
		void getName(char * retStr);
		uint8_t getType() { return OUTPUTBANK_TYPE_GROUP; }
	  };
	  
	  
	  class outputBanks
	  {
		private:
		OutputBank * _banks[OUTPUTBANK_MAXBANKS];
		uint8_t _count, _max;
		void addBank(OutputBank *);
	  
		public:
		void init();
		void addModbusBank(uint8_t, uint16_t, uint8_t);
		void set(uint8_t, uint8_t, uint8_t);
		uint8_t getBankCount();
		void getBankName(uint8_t, char *);
		uint8_t getOutputCount(uint8_t);
		uint8_t getType(uint8_t);
	  };
	  
	  extern OpenTroller::outputBanks OutputBanks;
	}
	
#endif //ifndef PVOUT_H