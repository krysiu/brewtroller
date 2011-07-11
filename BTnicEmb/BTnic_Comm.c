#include "BTnic_Comm.h"
#include <i2c.h>
#include "TCPIP Stack/Tick.h"

volatile unsigned char BTCommBuffer[BTCOMM_BUFFER_SIZE];
volatile unsigned int BTCommLen, BTCommCur;
volatile unsigned char BTCommState;
volatile unsigned long BTCommTimer;

void BTCommInit(void)
{
	//I2C Pins as Inputs
	I2C_SCL_TRIS = 1;
	I2C_SDA_TRIS = 1;
	
	//Reset BTCommState
	BTCommLen = BTCommCur = 0;
	BTCommState = BT_COMMSTATE_IDLE;

	//Enter Slave Mode
	PIE1bits.SSPIE = 0;           //Turn off I2C/SPI interrupt    
	PIR1bits.SSPIF = 0;           //Clear any pending interrupt    

	SSP1STAT = 0x80;   //Disable SMBus & Slew Rate Control
 	SSP1CON1 = 0x26;  //I2C 7-Bit Slave
	SSP1ADD = I2C_BTNICSLAVE_ADDR;
	PIE1bits.SSPIE = 1; 

	//Enable I2C interrupts    
	INTCONbits.PEIE = 1;          //Turn on peripheral interrupts    
	INTCONbits.GIE = 1;           //Turn on global interrupts
}

int BTCommTX(unsigned char* reqMsg)
{
	unsigned char c;
	if (BTCommState == BT_COMMSTATE_IDLE) {
		BTCommState = BT_COMMSTATE_TX;
		BTCommTimer = TickGet();
	}
	
	PIE1bits.SSPIE = 0;           //Turn off I2C/SPI interrupt    
	PIR1bits.SSPIF = 0;           //Clear any pending interrupt    

	SSP1CON1 = 0x00;
 	SSP1CON1 = 0x28;  //I2C Master
	SSP1ADD = I2C_MASTER_BAUDRATE; //Set I2C Speed
	SSP1CON2 = 0x00;

	PIR2bits.BCL1IF = 0; //Clear any previous collision flag

	IdleI2C1();
	StartI2C1();
    if (PIR2bits.BCL1IF) return ( -1 );	// test for bus collision

    if (WriteI2C1(I2C_BTSLAVE_ADDR)) 
	{
		StopI2C1();
		return ( -3 );	// set error for write collision
	}

	if (SSP1CON2bits.ACKSTAT) 
	{                 
		StopI2C1();                  
		return ( -2 );      // return with Not Ack error condition                      
	}

    while(*reqMsg != '\0') 
	{
		c = *reqMsg++;
		if (c == '&') c = '\t';
		else if (c == '+') c = ' ';
		if (WriteI2C1(c))
		{
			StopI2C1();
			return ( -3 );	// set error for write collision
		}
		if (SSP1CON2bits.ACKSTAT) 
		{                 
			StopI2C1();                  
			return ( -2 );      // return with Not Ack error condition                      
		}
    }

	if (WriteI2C1('\r'))
	{
		StopI2C1();
		return ( -3 );	// set error for write collision
	}
	if (SSP1CON2bits.ACKSTAT) 
	{                 
		StopI2C1();                  
		return ( -2 );      // return with Not Ack error condition                      
	}

	StopI2C1();
	while ( SSP1CON2bits.PEN );      // wait until stop condition is over
    if (PIR2bits.BCL1IF) return ( -1 );	// test for bus collision

	BTCommTimer = TickGet();
	BTCommState = BT_COMMSTATE_WAIT;
	
	//Re-Enter Slave Mode
	SSP1CON1 = 0x00;
 	SSP1CON1 = 0x26;  //I2C 7-Bit Slave
	SSP1ADD = I2C_BTNICSLAVE_ADDR;

	PIR1bits.SSPIF = 0;
	PIE1bits.SSPIE = 1; 
	return 0;
}

//Called by ISR
void BTCommRX(void)
{
	unsigned char dummy;
	if (SSP1CON1bits.SSPOV) {	//Check for overflow
		dummy = ReadI2C1();		//Do a dummy read
		SSP1CON1bits.SSPOV = 0;	//Clear the overflow flag
	}
	else {
		switch (SSP1STAT & I2C_SLAVESTATE_BITMASK)
		{
			case I2C_SLAVESTATE_WRITE_ADDR:
				dummy = ReadI2C1();	//Dummy read of address
				break;
			case I2C_SLAVESTATE_WRITE_DATA:
				if (BTCommState == BT_COMMSTATE_WAIT)
				{
					BTCommState = BT_COMMSTATE_RX;
					BTCommBuffer[BTCommLen++] = '[';
					BTCommBuffer[BTCommLen++] = '"';
				}
				else if (BTCommState == BT_COMMSTATE_ASYNCRX)
				{
					BTCommState = BT_COMMSTATE_ASYNCMSG;
					BTCommBuffer[BTCommLen++] = '[';
					BTCommBuffer[BTCommLen++] = '"';
				}
				if (BTCommState == BT_COMMSTATE_RX || BTCommState == BT_COMMSTATE_ASYNCRX) {
					unsigned char byteIn = ReadI2C1();
					switch (byteIn) {
						case '\t':
							//End Field/Start New
							BTCommBuffer[BTCommLen++] = '"';
							BTCommBuffer[BTCommLen++] = ',';
							BTCommBuffer[BTCommLen++] = '"';
							break;
						case '\r':
							//Ignore Carriage return
							break;
						case '\n':
							//End Field & Message
							BTCommBuffer[BTCommLen++] = '"';
							BTCommBuffer[BTCommLen++] = ']';
							if (BTCommState == BT_COMMSTATE_RX) BTCommState = BT_COMMSTATE_MSG;
							else BTCommState = BT_COMMSTATE_ASYNCMSG;
							break;
						default:
							BTCommBuffer[BTCommLen++] = byteIn;
							break;
					}
				}
				break;
			case I2C_SLAVESTATE_READ_ADDR:
				//Not implemented
				break;
			case I2C_SLAVESTATE_READ_DATA:
				//Not implemented
				break;
			case I2C_SLAVESTATE_NACK:
				// Reset the SSP Unit
				SSP1CON1 = 0x26;  //I2C 7-Bit Slave
				SSP1ADD = I2C_BTNICSLAVE_ADDR;
				break;
		}
	}	
	PIR1bits.SSPIF = 0; //Clear SSPIF Interrupt Flag
}

unsigned char BTCommGetStatus() 
{ 
	//Handle TX Timeout
	if (BTCommState == BT_COMMSTATE_TX && (TickGet() - BTCommTimer > (BT_TIMEOUT_TX * TICK_SECOND))) 
	{
		BTCommState = BT_COMMSTATE_IDLE;
	}

	//Handle Response Wait Timeout
	if (BTCommState == BT_COMMSTATE_WAIT && (TickGet() - BTCommTimer > (BT_TIMEOUT_WAIT * TICK_SECOND))) 
	{
		BTCommState = BT_COMMSTATE_IDLE;
	}

	//TO DO: ASYNCMSG Processing
	if (BTCommState == BT_COMMSTATE_ASYNCRX) BTCommState = BT_COMMSTATE_IDLE;

	return BTCommState; 
}
unsigned int BTCommGetRspLen() { return BTCommLen; }

unsigned char BTCommGetRsp()
{
	if (BTCommState != BT_COMMSTATE_MSG || BTCommState != BT_COMMSTATE_ASYNCMSG) return '\0';
	//Last byte state handling
	if (BTCommCur == BTCommLen - 1u) {
		BTCommLen = BTCommCur = 0u;
		BTCommState = BT_COMMSTATE_IDLE;
		return BTCommBuffer[BTCommLen - 1u];
	}
	return BTCommBuffer[BTCommCur++];
}

