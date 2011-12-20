/*
 * Com.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef COM_H_
#define COM_H_

#include "wiring.h"

void comEvent(byte eventID, int eventParam);
void comInit();
void updateCom();


#endif /* COM_H_ */
