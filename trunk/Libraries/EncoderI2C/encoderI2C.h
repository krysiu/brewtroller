// 
// If wrap is set the encoder value will roll over to 0 if greater than max and 
// roll to max if less than 0. If wrap is cleared the encoder value will be limited
// to operate with in the min max constraints with no roll over.
//

#ifndef _ENCODERI2C_H
#define _ENCODERI2C_H

class encoderI2C
{
private:
	uint8_t i2CAddress;

public:
	void begin(uint8_t i2cAddr);
	void setMin(int min);
	void setMax(int max);
	void setWrap(bool wrap);
	void setCount(int count);
	void clearCount(void);
	int  getCount(void);
	int  change(void);
	int  getDelta(void);
	uint8_t getEnterState(void);
	void clearEnterState(void);
	bool ok(void);
	bool cancel(void);
};

extern encoderI2C Encoder;

#endif