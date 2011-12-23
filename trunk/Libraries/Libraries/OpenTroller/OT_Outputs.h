#ifndef OT_OUTPUTS_H
	#define OT_OUTPUTS_H
	#include "OT_HWProfile.h"
	#ifdef OPENTROLLER_OUTPUTS
		#include "OT_Stack.h"
		#include "OT_Pin.h"
		#include <ModbusMaster.h>
		
		#define BIT_TO_BYTE_COUNT(x) (x + 7)>>3

		namespace OpenTroller{

			class Output
			{
				public:
				virtual uint8_t get(void) = 0;
				virtual void set(uint8_t) = 0;
				virtual uint8_t getErr(void) = 0;
				virtual void getName(char *) = 0;
			};

			#ifdef OUTPUTBANK_GPIO
				class OutputBankGPIO;
				class OutputGPIO: public Output
				{
					private:
					pin _pin;
					uint8_t _err, _index;
					OutputBankGPIO * _bank;
					
					public:
					OutputGPIO(void);
					void setup(OutputBankGPIO *, uint8_t, uint8_t);
					void set(uint8_t);
					uint8_t get();
					uint8_t getErr();
					void getName(char *);
				};
			#endif

			#ifdef OUTPUTBANK_MUX
				class OutputBankMUX;
				class OutputMUX: public Output
				{
					private:
					uint8_t _value, _index;
					OutputBankMUX * _bank;
					
					public:
					OutputMUX();
					void setup(OutputBankMUX *, uint8_t);
					void set(uint8_t);
					uint8_t get();
					uint8_t getErr();
					void getName(char *);
				};
			#endif

			#ifdef OUTPUTBANK_MODBUS
				class OutputBankMODBUS;
				class OutputMODBUS: public Output
				{
					private:
					uint8_t _value, _index;
					OutputBankMODBUS * _bank;
					
					public:
					OutputMODBUS();
					void setup(OutputBankMODBUS *, uint8_t);
					void set(uint8_t);
					uint8_t get();
					uint8_t getErr();
					void getName(char *);
				};
			#endif

			#ifdef OUTPUTBANK_GROUPS
				class OutputGroup : public Output
				{
					private:
					Output ** _outputs;
					uint8_t _count, _value, _err;
					char _name[15];
					
					public:
					OutputGroup(void);
					~OutputGroup(void);
					void init(char [], uint8_t);
					void assignOutput(uint8_t, Output *);
					void set(uint8_t);
					uint8_t get();
					uint8_t getErr();
					void getName(char *);
				};
			#endif
		
			typedef enum
			{
				OUTPUTBANK_TYPE_GPIO,
				OUTPUTBANK_TYPE_MUX,
				OUTPUTBANK_TYPE_MODBUS,
				OUTPUTBANK_TYPE_GROUPS
			} OutputBankType;
			
			class OutputBank
			{
				protected:
				uint8_t _count;
				
				public:
				uint8_t getCount(void);
				virtual Output * getOutput(uint8_t) = 0;
				virtual void getName(char *) = 0;
				virtual uint8_t getType() = 0;
				virtual void update() = 0;
			};

			#ifdef OUTPUTBANK_GPIO
				class OutputBankGPIO: public OutputBank
				{
					private:
					OutputGPIO * _outputs;
					void getOutputName(uint8_t, char * retStr);
					
					public:
					OutputBankGPIO(uint8_t pinCount);
					~OutputBankGPIO();
					Output * getOutput(uint8_t);
					void setup(uint8_t, uint8_t);
					void getName(char * retStr);
					uint8_t getType();
					void update() { }
					friend class OutputGPIO;
				};
			#endif

			#ifdef OUTPUTBANK_MUX
				class OutputBankMUX: public OutputBank
				{
					private:
					pin muxLatchPin, muxDataPin, muxClockPin, muxEnablePin;
					boolean muxEnableLogic;
					OutputMUX * _outputs;
					uint8_t _err, _doUpdate;
					void getOutputName(uint8_t, char *);
										
					public:
					OutputBankMUX(uint8_t, uint8_t, uint8_t, uint8_t, uint8_t, uint8_t);
					~OutputBankMUX(void);
					Output * getOutput(uint8_t);
					void getName(char * retStr);
					uint8_t getType();
					void update();
					friend class OutputMUX;
				};
			#endif

			#ifdef OUTPUTBANK_MODBUS
				class OutputBankMODBUS: public OutputBank
				{
					private:
					ModbusMaster _slave;
					uint8_t _slaveAddr, _err, _doUpdate;
					unsigned int _coilReg;
					OutputMODBUS * _outputs;
					void setUpdate();
					void getOutputName(uint8_t, char *);
					
					public:
					OutputBankMODBUS(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount);
					~OutputBankMODBUS(void);
					Output * getOutput(uint8_t);
					void getName(char * retStr);
					uint8_t getType();
					void update();
					friend class OutputMODBUS;
				};
			#endif

			#ifdef OUTPUTBANK_GROUPS
				class OutputBankGroups: public OutputBank
				{
					private:
					OutputGroup * _groups;
					
					public:
					OutputBankGroups(void);
					~OutputBankGroups(void);
					void init(uint8_t);
					Output * getOutput(uint8_t);
					OutputGroup * getGroup(uint8_t);
					void getName(char * retStr);
					uint8_t getType();
					void update();
				};
			#endif

			class outputs
			{
				private:
				OutputBank ** _banks;
				uint8_t _count, _max;
				void addBank(OutputBank *);
				#ifdef OUTPUTBANK_GROUPS
					OutputBankGroups * _groups;
				#endif
				
				public:
				outputs(void);
				~outputs(void);
				void init();
				OutputBank * getBank(uint8_t);
				#ifdef OUTPUTBANK_MODBUS
					void newModbusBank(uint8_t, uint16_t, uint8_t);
				#endif
				#ifdef OUTPUTBANK_GROUPS
					OutputBankGroups * getGroups(void);
				#endif
				uint8_t getBankCount();
				void update();
			};
			
			extern OpenTroller::outputs Outputs;
		} //namespace OpenTroller
	#endif //ifdef OPENTROLLER_OUTPUTS
#endif //ifndef OT_OUTPUTS_H