/*
 * EEPROM.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef EEPROM_H_
#define EEPROM_H_

#include "Enum.h"
#include "wiring.h"

boolean checkConfig();
void loadSetup();
void initEEPROM();

byte getBoilTemp();
byte getPIDp(byte vessel);
byte getPIDp(byte vessel);
byte getPIDd(byte vessel);
byte getPIDi(byte vessel);
byte getSteamTgt();
void getProgName(byte preset, char *name);
byte getProgMashTemp(byte preset, byte mashStep) ;
byte getProgMashMins(byte preset, byte mashStep);
byte getProgSparge(byte preset);
byte getProgHLT(byte preset);
unsigned long getProgBatchVol(byte preset);
unsigned long getProgGrain(byte preset);
unsigned int getProgBoil(byte preset);
unsigned int getProgRatio(byte preset);
byte getProgPitch(byte preset);
unsigned int getProgAdds(byte preset);
byte getProgMLHeatSrc(byte preset);
unsigned long getCapacity(byte vessel);
unsigned int getVolLoss(byte vessel);
byte getGrainTemp();
unsigned int getDelayMins() ;
unsigned int getBoilAddsTrig() ;


void setBoilTemp(byte boilTemp) ;
void setVolCalib(byte vessel, byte slot, unsigned int value, unsigned long vol) ;
void setEvapRate(byte value);
void setPIDEnabled(byte vessel, boolean setting);
void setPIDCycle(byte vessel, byte value) ;
void setPIDp(byte vessel, byte value);
void setPIDi(byte vessel, byte value);
void setPIDd(byte vessel, byte value);
void setSteamZero(unsigned int value);
void setSteamZero(unsigned int value);
void setSteamPSens(unsigned int value);
void setHysteresis(byte vessel, byte value);
byte getEvapRate();
void setSteamTgt(byte value);
void setProgName(byte preset, char *name);
void setProgMashTemp(byte preset, byte mashStep, byte mashTemp);
void setProgMashMins(byte preset, byte mashStep, byte mashMins);
void setProgSparge(byte preset, byte sparge);
void setProgHLT(byte preset, byte HLT);
void setProgHLT(byte preset, byte HLT);
void setProgGrain(byte preset, unsigned long grain);
void setProgBoil(byte preset, int boilMins);
void setProgRatio(byte preset, unsigned int ratio);
void setProgPitch(byte preset, byte pitch);
void setProgAdds(byte preset, unsigned int adds);
void setProgBatchVol (byte preset, unsigned long vol);
void setProgMLHeatSrc(byte preset, byte vessel);
void setTSAddr(byte sensor, byte addr[8]) ;
void setCapacity(byte vessel, unsigned long value);
void setVolLoss(byte vessel, unsigned int value);
void setValveCfg(byte profile, unsigned long value);
void setSetpoint(byte vessel, int value);
void setTimerStatus(byte timer, boolean value);
void setBoilPwr(byte value) ;
void setDelayMins(unsigned int mins);
void setGrainTemp(byte grainTemp);
void setProgramStep(byte brewStep, byte actPgm);
void setBoilAddsTrig(unsigned int adds);
void setTimerRecovery(byte timer, unsigned int newMins)

#endif /* EEPROM_H_ */
