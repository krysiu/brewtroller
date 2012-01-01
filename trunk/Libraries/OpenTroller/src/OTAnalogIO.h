#ifndef OT_ANALOGIO_H
#define OT_ANALOGIO_H

#include "OpenTroller.h"

/**
  * An abstract class that provides a common interface for reading the value of analog input and output objects.
  */
  class AnalogIO {
	public:
	virtual int32_t getValue(void) = 0;
  };
  
  #endif //ifndef OT_ANALOGIO_H