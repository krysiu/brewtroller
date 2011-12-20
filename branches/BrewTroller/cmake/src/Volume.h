/*
 * Volume.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef VOLUME_H_
#define VOLUME_H_

#include "Config.h"
#include "Enum.h"

#include <wiring.h>

unsigned long readPressure( byte aPin, unsigned int sens, unsigned int zero);
unsigned long readVolume( byte pin, unsigned long calibrationVols[10], unsigned int calibrationValues[10] );
void updateVols();

#ifdef FLOWRATE_CALCS
void updateFlowRates();
#endif



#endif /* VOLUME_H_ */
