/*
 * Outputs.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef OUTPUTS_H_
#define OUTPUTS_H_

void pidInit();
void pinInit();
void processHeatOutputs();
byte vesselAV(byte vessel);
byte vesselVLVHeat(byte vessel);
byte vesselVLVIdle(byte vessel);
boolean vlvConfigIsActive(byte profile);
unsigned long computeValveBits() ;
void resetOutputs();
void resetHeatOutput(byte vessel);

#ifdef PVOUT
void processAutoValve();
void updateValves();
#endif

#endif /* OUTPUTS_H_ */
