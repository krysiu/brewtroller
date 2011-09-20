/*
 * Modbus RTU 8-Port Relay
 * Copyright (C) 2011 Open Source Control Systems, Inc. <http://www.oscsys.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * File: $Id: MODBUS_Relay8.pde,v 0.1 2011/09/16 15:38:02 wolti Exp $
 */

#include <mb.h>
#include <mbport.h>
#include <mbutils.h>
#include <EEPROM.h>
#include <pin.h>

#define LED_PIN 13  //PB5

#define ACTIVITY_NONE     0
#define ACTIVITY_PREOFF   1
#define ACTIVITY_ON       2
#define ACTIVITY_POSTOFF  3

#define LEDTIME_BLINK    250
#define LEDTIME_OK    750
#define LEDTIME_ACT   30
#define LEDBLINK_OFFTIME  1000

#define LEDCOUNT_ID    2
#define LEDCOUNT_INIT  3

#define INIT_BUTTON_LOGIC
#define BUTTON_PIN 15 //PC1
#define INIT_BUTTON_TIME  4000 //4s
#define BUTTON_INTERNAL_PULLUP

#define REG_COILS_START     1000
#define REG_COILS_SIZE      8

#define REG_HOLD_START      60001
#define REG_HOLD_SIZE       3
#define REG_HOLD_IDMODE      60001
#define REG_HOLD_SLAVEADDR   60002
#define REG_HOLD_RESTART     60003

#define RESTART_DELAY  100 //100ms delay to allow restart command response

#define MODBUS_BAUDRATE 38400

#define EEPROM_SLAVEADDR 0
#define EEPROM_FINGERPRINT 511

#define FINGERPRINT_VALUE 42
#define DEFAULT_DEVADDR 247

#define SLAVE_ID        8  //8: 8-Port Relay
#define SLAVEID_EXTLEN  3
const UCHAR slaveIDExt[] = { 0x4F, 0x08, 0x01 }; //'O' for OSCSYS, 8 for 8-Port, 1 for v1

byte ucRegCoilsBuf[REG_COILS_SIZE / 8];
boolean idMode = 0;
boolean restart = 0;
byte blinkCount = 0;
byte actMode = ACTIVITY_NONE;
unsigned long ledUpdateTime;
pin ledPin, btnPin;

void(* softReset) (void) = 0;

void setup() {
  initRelays(); //Setup relay outputs

  ledPin.setup(LED_PIN, OUTPUT);
  btnPin.setup(BUTTON_PIN, INPUT);

  #ifdef INIT_BUTTON_LOGIC
    #ifdef BUTTON_INTERNAL_PULLUP
      btnPin.set();
    #endif
  #endif

  if (EEPROM.read(EEPROM_FINGERPRINT)!= FINGERPRINT_VALUE) {
    EEPROM.write(EEPROM_SLAVEADDR, DEFAULT_DEVADDR);
    EEPROM.write(EEPROM_FINGERPRINT, FINGERPRINT_VALUE);
  }

  //If default address go into wait mode
  if (EEPROM.read(EEPROM_SLAVEADDR) == DEFAULT_DEVADDR) {
    while(btnPin.get()) ledBlinkPattern(LEDCOUNT_INIT, LEDBLINK_OFFTIME);
  }
  
  eMBErrorCode    eStatus;
  eStatus = eMBInit( MB_RTU, EEPROM.read(EEPROM_SLAVEADDR), 0, MODBUS_BAUDRATE, MB_PAR_EVEN );
  eStatus = eMBSetSlaveID( SLAVE_ID, TRUE, slaveIDExt, SLAVEID_EXTLEN );
  sei();

  /* Enable the Modbus Protocol Stack. */
  eStatus = eMBEnable();
}

void loop() {
  eMBPoll();
  updateLED();
  if (restart) {
    unsigned long restartTime = millis() + RESTART_DELAY;
    while (millis() < restartTime) eMBPoll();
    softReset();
  }
  
  #ifdef INIT_BUTTON_LOGIC
    //Check if init button is clicked
    if (!btnPin.get()) {
      unsigned long clickStart = millis();
      ledPin.set();
      while((!btnPin.get()) && (millis() - clickStart < INIT_BUTTON_TIME));
      if (!btnPin.get()) {
        //Still pressed so do init
        EEPROM.write(EEPROM_SLAVEADDR, DEFAULT_DEVADDR);
        ledPin.clear();
        while (!btnPin.get());
        softReset();
      }
    }
  #endif
}


eMBErrorCode eMBRegInputCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNRegs ) {
  return MB_ENOREG;
}

eMBErrorCode eMBRegHoldingCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNRegs, eMBRegisterMode eMode ) {
  eMBErrorCode    eStatus = MB_ENOERR;
  short iNRegs = ( short )usNRegs;
  if (usAddress >= REG_HOLD_START && usAddress + usNRegs <= REG_HOLD_START + REG_HOLD_SIZE)
  {
    switch ( eMode )
    {
      /* Read current values and pass to protocol stack. */
      case MB_REG_READ:
        while( iNRegs > 0 )
        {
            switch(usAddress + iNRegs - 1) {
              case REG_HOLD_IDMODE:
                *pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
                *pucRegBuffer++ = ( unsigned char ) idMode;
                break;
              case REG_HOLD_SLAVEADDR:
                *pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
                *pucRegBuffer++ = ( unsigned char ) EEPROM.read(EEPROM_SLAVEADDR);
                break;
              case REG_HOLD_RESTART:
                *pucRegBuffer++ = ( unsigned char ) 0;  //Dummy High Byte
                *pucRegBuffer++ = ( unsigned char ) 0;
                break;
            }
            iNRegs--;
        }
        ledEvent();
        break;
  
      /* Update current register values. */
      case MB_REG_WRITE:            
        while( iNRegs > 0 )
        {
          switch(usAddress + iNRegs - 1) {
            case REG_HOLD_IDMODE:
              *pucRegBuffer++;  //Dummy High Byte
              idMode = (boolean) *pucRegBuffer++;
              break;
            case REG_HOLD_SLAVEADDR:
              *pucRegBuffer++;  //Dummy High Byte
              EEPROM.write(EEPROM_SLAVEADDR, *pucRegBuffer++);
              break;
            case REG_HOLD_RESTART:
              *pucRegBuffer++;  //Dummy High Byte
              restart = (boolean) *pucRegBuffer++;
              break;
          }
          iNRegs--;
        }
        ledEvent();
        break;
    }
  }
  else eStatus = MB_ENOREG;
  return eStatus;
}


eMBErrorCode eMBRegCoilsCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNCoils, eMBRegisterMode eMode ) {
    eMBErrorCode    eStatus = MB_ENOERR;
    short           iNCoils = ( short )usNCoils;
    unsigned short  usBitOffset;

    /* Check if we have registers mapped at this block. */
    if( ( usAddress >= REG_COILS_START ) &&
        ( usAddress + usNCoils <= REG_COILS_START + REG_COILS_SIZE ) )
    {
        usBitOffset = ( unsigned short )( usAddress - REG_COILS_START );
        switch ( eMode )
        {
                /* Read current values and pass to protocol stack. */
            case MB_REG_READ:
                while( iNCoils > 0 )
                {
                    *pucRegBuffer++ = xMBUtilGetBits( ucRegCoilsBuf, usBitOffset, ( unsigned char )( iNCoils > 8 ? 8 : iNCoils ) );
                    iNCoils -= 8;
                    usBitOffset += 8;
                }
                ledEvent();
                break;

                /* Update current register values. */
            case MB_REG_WRITE:
                while( iNCoils > 0 )
                {
                    xMBUtilSetBits( ucRegCoilsBuf, usBitOffset, ( unsigned char )( iNCoils > 8 ? 8 : iNCoils ), *pucRegBuffer++ );
                    iNCoils -= 8;
                }
                updateRelays();
                ledEvent();
                break;
        }
        
    }
    else
    {
        eStatus = MB_ENOREG;
    }
    return eStatus;
}

eMBErrorCode eMBRegDiscreteCB( UCHAR * pucRegBuffer, USHORT usAddress, USHORT usNDiscrete ) {
    return MB_ENOREG;
}

void updateLED() {
  if (idMode) ledBlinkPattern(LEDCOUNT_ID, LEDBLINK_OFFTIME);
  else {
    if (millis() - ledUpdateTime > (actMode?LEDTIME_ACT:LEDTIME_OK)) {
      ledPin.toggle();
      ledUpdateTime = millis();
      if (actMode) {
        actMode++;
        if (actMode > ACTIVITY_POSTOFF) {
          actMode = ACTIVITY_NONE;
        }
      }
    }
  }
}

//Used to show activity on the debug LED
void ledEvent() {
  if (!idMode) {
    actMode = ACTIVITY_PREOFF;
    ledPin.clear();
    ledUpdateTime = millis() - LEDTIME_ACT / 2; //Half Off time
  }
}

void ledBlinkPattern(byte count, int offTime) {
  if (millis() - ledUpdateTime > LEDTIME_BLINK) {
    if (blinkCount == 0) ledPin.clear(); //Start with LED Off
    if (blinkCount < count * 2) ledPin.toggle();
    ledUpdateTime = millis();
    blinkCount++;
    if (blinkCount > count * 2 + (offTime / LEDTIME_BLINK)) blinkCount = 0;
  }
}

// For Relays 1-8 respectively: PD3, PD4, PD5, PD6, PD7, PB0, PB1, PB2
void initRelays() {
  DDRD |= B11111000;			//Make PORTD bits 3-7 outputs
  DDRB |= B00000111;			//Make PORTB bits 0-2 outputs
  updateRelays();
}

void updateRelays() {
PORTD &= B00000111; 			//Leave bits 0-2 as is and clear 3-7
PORTD |= (ucRegCoilsBuf[0] << 3); 	//Enable any bits in the 3-7 range by shifting the register buffer variable to the left

PORTB &= B11111000;			//Leave bits 3-7 as is; clear 0-2
PORTB |= (ucRegCoilsBuf[0] >> 5);	////Enable any bits in the 0-2 range by shifting the register buffer variable to the right
}
