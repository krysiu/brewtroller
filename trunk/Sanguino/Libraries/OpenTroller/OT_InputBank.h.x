#ifndef OT_INPUTBANK_H
	#define OT_INPUTBANK_H
	#include "OT_Stack.h"
	#include "OT_HWProfile.h"
	#include "OT_Pin.h"
	#include <ModbusMaster.h>

	namespace OpenTroller{
		class InputBank
		{
			public:
			  virtual void get(uint8_t)=0;
			  virtual uint8_t getCount(void)=0;
			  virtual void getName(char *)=0;
		};

		class InputBankGPIO: public InputBank
		{
			private:
			pin* pins;
			uint8_t _count;

			public:
			InputBankGPIO(uint8_t);
			~InputBankGPIO();
			void setup(uint8_t, uint8_t);
			void get(uint8_t);
			uint8_t getCount();
			void getName(char * retStr);
		};

	  class InputBankMODBUS: public DigitalInputBank
	  {
		private:
		ModbusMaster _slave;
		unsigned int _coilReg;
		uint8_t _coilCount;

		public:
		DigitalInputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount);
		void get(uint8_t);
		uint8_t getCount();
		void getName(char * retStr);
	  };
	  
	  class InputBanks
	  {
		private:
		InputBank * _banks[INPUTBANKS_MAXBANKS];
		uint8_t _count, _max;
		void addBank(DigitalInputBank *);
	  
		public:
		void init();
		void addModbusBank(uint8_t, uint16_t, uint8_t);
		void get(uint8_t, uint8_t);
		uint8_t getBankCount();
		void getBankName(uint8_t, char *);
		uint8_t getInputCount(uint8_t);
	  };
	  
	  extern OpenTroller::InputBanks InputBanks;
	}
	
#endif //ifndef PVOUT_H