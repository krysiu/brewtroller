GeneralPurposeOutputs::GeneralPurposeOutputs(uint8_t mapsMax) {
	_mapsMax = mapsMax;
	_outputMaps = (outputMap *) malloc(_mapsMax * sizeof(outputMap));
}

GeneralPurposeOutputs::~GeneralPurposeOutputs(void) {
	free(_outputMaps);
}

void GeneralPurposeOutputs::addBank(OutputBank * bank) {
	_outputMaps[_mapCount].bank = bank;
	_outputMaps[_mapCount].offset = _offset;
	_outputMaps[_mapCount].count = bank->getCount();
	_offset += _outputMaps[_mapCount].count;
	_mapCount++;
}

void GeneralPurposeOutputs::set(unsigned long outputBits) {
	if (!_mapCount) return;
	for (uint8_t i = 0; i < _mapCount; i++) 
		_outputMaps[i].bank->set( (outputBits >> _outputMaps[i].offset) & ((1 << _outputMaps[i].count) - 1) );
}

uint8_t GeneralPurposeOutputs::getBankCount() { return _mapCount; }
void GeneralPurposeOutputs::getBankName(uint8_t bankID, char *retStr) { _outputMaps[bankID].bank->getName(retStr); }
uint8_t GeneralPurposeOutputs::getOutputCount(uint8_t bankID) { return _outputMaps[bankID].bank->getCount(); }
void GeneralPurposeOutputs::getOutputName(uint8_t bankID, uint8_t outputNum, char * retStr) { _outputMaps[bankID].bank->getPinName(outputNum, retStr); }
uint8_t GeneralPurposeOutputs::getOutputOffset(uint8_t bankID, uint8_t outputNum) { return (_outputMaps[bankID].offset + outputNum); }