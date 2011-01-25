/*  
   Copyright (C) 2009, 2010 Matt Reba, Jermeiah Dillingham

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.


BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com
*/

#include "Config.h"

boolean stepIsActive(byte flowStep) {
  if (actStep == flowStep) return true; else return false;
}

boolean zoneIsActive() {
  if (actStep != PROGRAM_IDLE) return 1; else return 0;
}

//Returns 0 if start was successful or 1 if unable to start due to conflict with other step
//Performs any logic required at start of step
boolean stepInit(byte pgm, byte flowStep) {

  //Nothing more to do if starting 'Idle' program
  if(pgm == PROGRAM_IDLE) return 1;
  
  //Abort if Zone is not free
  if (zoneIsActive()) return 1;  

  //If we made it without an abort, save the program number for stepCore
  setProgramStep(flowStep, pgm);

  setSetpoint(getProgTemp(pgm, flowStep));
  pid.SetMode(AUTO);
  preheated = 0;
  //Set timer only if empty (for purposed of power loss recovery)
  if (!timerValue) setTimer(getProgMins(pgm, flowStep)); 
  //Leave timer paused until preheated
  timerStatus = 0;
    
  //Call event handler
  eventHandler(EVENT_STEPINIT, flowStep);  
  return 0;
}

void stepCore() {
  if (actStep != PROGRAM_IDLE) {  
    if (!preheated && temp >= setpoint) {
      preheated = 1;
      //Unpause Timer
      if (!timerStatus) pauseTimer();
    }
    //Exit Condition (and skip unused mash steps)
    if (setpoint == 0 || (preheated && timerValue == 0)) stepAdvance(actStep);
  }
}


//Advances program to next brew step
//Returns 0 if successful or 1 if unable to advance due to conflict with another step
boolean stepAdvance(byte flowStep) {
  //Save program for next step/rollback
  byte program = actProgram;
  stepExit(flowStep);
  //Advance step (if applicable)
  if (flowStep + 1 < NUM_FLOW_STEPS) {
    if (stepInit(program, flowStep + 1)) {
      //Init Failed: Rollback
      stepExit(flowStep + 1); //Just to make sure we clean up a partial start
      setProgramStep(program, flowStep); //Show the step we started with as active
      return 1;
    }
    //Init Successful
    return 0;
  }
}

//Performs exit logic specific to each step
//Note: If called directly (as opposed through stepAdvance) acts as a program abort
void stepExit(byte flowStep) {
  //Mark step idle
  setProgramStep(PROGRAM_IDLE, PROGRAM_IDLE);
  
  //Perform step closeout functions
  clearTimer();
  resetOutputs();
  eventHandler(EVENT_STEPEXIT, flowStep);  
}

