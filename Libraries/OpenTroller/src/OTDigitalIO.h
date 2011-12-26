#ifndef OT_DIGITALIO_H
#define OT_DIGITALIO_H

#include "OpenTroller.h"

/**
  * An abstract class that provides a common interface for reading the state of digital input and output objects.
  */
  class DigitalIO {
	public:
	virtual State getState(void) = 0;
  };
  
  #endif //ifndef OT_DIGITALIO_H