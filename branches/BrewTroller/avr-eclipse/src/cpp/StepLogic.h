/*
 * StepLogic.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef STEPLOGIC_H_
#define STEPLOGIC_H_

boolean stepInit(byte pgm, byte brewStep);
void stepCore();
void stepExit(byte brewStep);
boolean stepAdvance(byte brewStep);
byte calcStrikeTemp(byte pgm);
byte getFirstStepTemp(byte pgm);
unsigned long calcGrainVolume(byte pgm) ;
unsigned long calcGrainLoss(byte pgm);
unsigned long calcPreboilVol(byte pgm);
unsigned long calcStrikeVol(byte pgm);
unsigned long calcStrikeVol(byte pgm);
unsigned long calcSpargeVol(byte pgm);

#endif /* STEPLOGIC_H_ */
