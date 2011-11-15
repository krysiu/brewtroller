/*
 * Temp.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef TEMP_H_
#define TEMP_H_

#include "wiring.h"

void tempInit();
void updateTemps();
void getDSAddr(byte addrRet[8]);

#endif /* TEMP_H_ */
