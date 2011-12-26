#ifndef OT_DIGITALIO
#define OT_DIGITALIO

/**
  * An abstract class that provides a common interface for reading the state of digital input and output objects.
  */
  class DigitalIO {
	public:
	virtual uint8_t getState(void) = 0;
  };
  
  #endif //ifndef OT_DIGITALIO