/*
 * BrewCore.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef BREWCORE_H_
#define BREWCORE_H_

#include "Config.h"
#include "Enum.h"
#include "HWProfile.h"



void brewCore();

#ifdef HEARTBEAT
  unsigned long hbStart = 0;
  void heartbeat();
#endif


#endif /* BREWCORE_H_ */
