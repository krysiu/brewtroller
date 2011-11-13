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

#endif /* STEPLOGIC_H_ */
