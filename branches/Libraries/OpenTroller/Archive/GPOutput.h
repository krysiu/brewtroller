	  typedef struct {
		OutputBank* bank;
		uint8_t offset;
		uint8_t count;
	  } outputMap;
	  
	  #define OUTPUT_BANKS_MAX  8
	  #define BANK_MAX_OUTPUTS 32
	  
	  class GeneralPurposeOutputs
	  {
		private:
		  outputMap * _outputMaps;
		  uint8_t _mapCount;
		  uint8_t _mapsMax;
		  uint8_t _offset;
		  
		public:
		  GeneralPurposeOutputs(uint8_t mapsMax);
		  ~GeneralPurposeOutputs(void);
		  void addBank(OutputBank * bank);
		  void set(unsigned long outputBits);
		  uint8_t getBankCount();
		  void getBankName(uint8_t bankID, char *retStr);
		  uint8_t getOutputCount(uint8_t bankID);
		  void getOutputName(uint8_t bankID, uint8_t outputNum, char * retStr);
		  uint8_t getOutputOffset(uint8_t bankID, uint8_t outputNum);
	  };