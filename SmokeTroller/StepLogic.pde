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
#include "Enum.h"

unsigned long lastHop, grainInStart;
unsigned int boilAdds, triggered;

boolean stepIsActive(byte brewStep) {
  if (stepProgram[brewStep] != PROGRAM_IDLE) return true; else return false;
}

boolean zoneIsActive(byte brewZone) {
  if (brewZone == ZONE_MASH) {
    if (stepIsActive(STEP_FILL) 
      || stepIsActive(STEP_DELAY) 
      || stepIsActive(STEP_PREHEAT)
      || stepIsActive(STEP_ADDGRAIN) 
      || stepIsActive(STEP_REFILL)
      || stepIsActive(STEP_DOUGHIN) 
      || stepIsActive(STEP_ACID)
      || stepIsActive(STEP_PROTEIN) 
      || stepIsActive(STEP_SACCH)
      || stepIsActive(STEP_SACCH2) 
      || stepIsActive(STEP_MASHOUT)
      || stepIsActive(STEP_MASHHOLD) 
      || stepIsActive(STEP_SPARGE)
    ) return 1; else return 0;
  } else if (brewZone == ZONE_BOIL) {
    if (stepIsActive(STEP_BOIL) 
      || stepIsActive(STEP_CHILL) 
    ) return 1; else return 0;
  }
}

//Returns 0 if start was successful or 1 if unable to start due to conflict with other step
//Performs any logic required at start of step
//TO DO: Power Loss Recovery Handling
boolean stepInit(byte pgm, byte brewStep) {

  //Nothing more to do if starting 'Idle' program
  if(pgm == PROGRAM_IDLE) return 1;
  
  //Abort Fill/Mash step init if mash Zone is not free
  if (brewStep >= STEP_FILL && brewStep <= STEP_MASHHOLD && zoneIsActive(ZONE_MASH)) return 1;  
  //Abort sparge init if either zone is currently active
  else if (brewStep == STEP_SPARGE && (zoneIsActive(ZONE_MASH) || zoneIsActive(ZONE_BOIL))) return 1;  
  //Allow Boil step init while sparge is still going

  //If we made it without an abort, save the program number for stepCore
  setProgramStep(brewStep, pgm);

  if (brewStep == STEP_FILL) {
  //Step Init: Fill
    //Set Target Volumes
    tgtVol[PIT_1] = calcSpargeVol(pgm);
    tgtVol[PIT_2] = calcStrikeVol(pgm);
    if (getProgMLHeatSrc(pgm) == PIT_1) {
      tgtVol[PIT_1] = min(tgtVol[PIT_1] + tgtVol[PIT_2], getCapacity(PIT_1));
      tgtVol[PIT_2] = 0;
    }
    
  } else if (brewStep == STEP_DELAY) {
  //Step Init: Delay
    //Load delay minutes from EEPROM if timer is not already populated via Power Loss Recovery
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getDelayMins());

  } else if (brewStep == STEP_PREHEAT) {
  //Step Init: Preheat
    if (getProgMLHeatSrc(pgm) == PIT_1) {
      setSetpoint(TS_PIT_1, calcStrikeTemp(pgm));    
      setSetpoint(TS_PIT_2, 0);            
    } else {
      setSetpoint(TS_PIT_1, getProgHLT(pgm));
      setSetpoint(TS_PIT_2, calcStrikeTemp(pgm));
    }
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_1] = 0;
    preheated[PIT_2] = 0;
    //No timer used for preheat
    clearTimer(TIMER_S1);
    
  } else if (brewStep == STEP_ADDGRAIN) {
  //Step Init: Add Grain
    //Disable HLT and Mash heat output during 'Add Grain' to avoid dry running heat elements and burns from HERMS recirc
    resetHeatOutput(PIT_1);
    resetHeatOutput(PIT_2);
    setSetpoint(PIT_3, getSteamTgt());
    setValves(vlvConfig[VLV_ADDGRAIN], 1);
    if(getProgMLHeatSrc(pgm) == PIT_1) {
      unsigned long spargeVol = calcSpargeVol(pgm);
      unsigned long mashVol = calcStrikeVol(pgm);
      tgtVol[PIT_1] = (min(spargeVol, getCapacity(PIT_1)));      
    }
    
  } else if (brewStep == STEP_REFILL) {
  //Step Init: Refill
    if (getProgMLHeatSrc(pgm) == PIT_1) {
      tgtVol[PIT_1] = calcSpargeVol(pgm);
      tgtVol[PIT_2] = 0;
    }

  } else if (brewStep == STEP_DOUGHIN) {
  //Step Init: Dough In
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_DOUGHIN));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_DOUGHIN)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_ACID) {
  //Step Init: Acid Rest
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_ACID));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_ACID)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_PROTEIN) {
  //Step Init: Protein
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_PROTEIN));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_PROTEIN)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_SACCH) {
  //Step Init: Sacch
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_SACCH));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_SACCH)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_SACCH2) {
  //Step Init: Sacch2
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_SACCH2));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_SACCH2)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_MASHOUT) {
  //Step Init: Mash Out
    setSetpoint(TS_PIT_1, getProgHLT(pgm));
    setSetpoint(TS_PIT_2, getProgMashTemp(pgm, MASH_MASHOUT));
    setSetpoint(PIT_3, getSteamTgt());
    preheated[PIT_2] = 0;
    //Set timer only if empty (for purposed of power loss recovery)
    if (!timerValue[TIMER_S1]) setTimer(TIMER_S1, getProgMashMins(pgm, MASH_MASHOUT)); 
    //Leave timer paused until preheated
    timerStatus[TIMER_S1] = 0;
    
  } else if (brewStep == STEP_MASHHOLD) {
    //Set HLT to Sparge Temp
    setSetpoint(TS_PIT_1, getProgSparge(pgm));
    //Cycle through steps and use last non-zero step for mash setpoint
    if (!setpoint[TS_PIT_2]) {
      byte i = MASH_MASHOUT;
      while (setpoint[TS_PIT_2] == 0 && i >= MASH_DOUGHIN && i <= MASH_MASHOUT) setSetpoint(TS_PIT_2, getProgMashTemp(pgm, i--));
    }
    setSetpoint(PIT_3, getSteamTgt());

  } else if (brewStep == STEP_SPARGE) {
    //Step Init: Sparge
    tgtVol[PIT_3] = calcPreboilVol(pgm); 

  } else if (brewStep == STEP_BOIL) {
  //Step Init: Boil
    setSetpoint(PIT_3, getBoilTemp());
    preheated[PIT_3] = 0;
    boilAdds = getProgAdds(pgm);
    
    //Set timer only if empty (for purposes of power loss recovery)
    if (!timerValue[TIMER_S2]) {
      //Clean start of Boil
      setTimer(TIMER_S2, getProgBoil(pgm));
      triggered = 0;
      setBoilAddsTrig(triggered);
    } else {
      //Assuming power loss recovery
      triggered = getBoilAddsTrig();
    }
    //Leave timer paused until preheated
    timerStatus[TIMER_S2] = 0;
    lastHop = 0;
    doAutoBoil = 1;
    
  } else if (brewStep == STEP_CHILL) {
  //Step Init: Chill
    pitchTemp = getProgPitch(pgm);
  }

  //Call event handler
  eventHandler(EVENT_STEPINIT, brewStep);  
  return 0;
}

void stepCore() {
  if (stepIsActive(STEP_FILL)) stepFill(STEP_FILL);

  if (stepIsActive(STEP_PREHEAT)) {
    if ((setpoint[PIT_2] && temp[PIT_2] >= setpoint[PIT_2])
      || (!setpoint[PIT_2] && temp[PIT_1] >= setpoint[PIT_1])
    ) stepAdvance(STEP_PREHEAT);
  }

  if (stepIsActive(STEP_DELAY)) if (timerValue[TIMER_S1] == 0) stepAdvance(STEP_DELAY);

  if (stepIsActive(STEP_ADDGRAIN)) {   
    //Turn off Sparge In AutoValve if tgtVol has been reached
    if (autoValve[AV_SPARGEIN] && volAvg[PIT_1] <= tgtVol[PIT_1]) autoValve[AV_SPARGEIN] = 0;
  }

  if (stepIsActive(STEP_REFILL)) stepFill(STEP_REFILL);

  for (byte brewStep = STEP_DOUGHIN; brewStep <= STEP_MASHOUT; brewStep++) if (stepIsActive(brewStep)) stepMash(brewStep);    
    
  if (stepIsActive(STEP_BOIL)) {
    if (doAutoBoil) {
      if(temp[TS_PIT_3] < setpoint[TS_PIT_3]) PIDOutput[PIT_3] = PIDCycle[PIT_3] * PIDLIMIT_PIT3;
      else PIDOutput[PIT_3] = PIDCycle[PIT_3] * min(boilPwr, PIDLIMIT_PIT3);
    }
    #ifdef FOOD_ALRM_THRSHOLD
    // TODO: If any of the active food temps are within the threshold - sound the alarm
//      if (!(triggered & 32768) && temp[TS_PIT_3] >= FOOD_ALRM_THRSHOLD) {
//        setAlarm(1);
//        triggered |= 32768; 
//        setBoilAddsTrig(triggered);
//      }
    #endif
    if (!preheated[PIT_3] && temp[TS_PIT_3] >= setpoint[PIT_3] && setpoint[PIT_3] > 0) {
      preheated[PIT_3] = 1;
      //Unpause Timer
      if (!timerStatus[TIMER_S2]) pauseTimer(TIMER_S2);
    }    
    if (preheated[PIT_3]) {
      //Boil Addition
      if ((boilAdds ^ triggered) & 1) {
        setValves(vlvConfig[VLV_HOPADD], 1);
        lastHop = millis();
        setAlarm(1); 
        triggered |= 1; 
        setBoilAddsTrig(triggered); 
      }
      //Timed additions (See hoptimes[] array at top of AutoBrew.pde)
      for (byte i = 0; i < 10; i++) {
        if (((boilAdds ^ triggered) & (1<<(i + 1))) && timerValue[TIMER_S2] <= hoptimes[i] * 60000) { 
          setValves(vlvConfig[VLV_HOPADD], 1);
          lastHop = millis();
          setAlarm(1); 
          triggered |= (1<<(i + 1)); 
          setBoilAddsTrig(triggered);
        }
      }     
    }
    //Exit Condition  
    if(preheated[PIT_3] && timerValue[TIMER_S2] == 0) stepAdvance(STEP_BOIL);
  }
  
  
}

//stepCore logic for Fill and Refill
void stepFill(byte brewStep) {
  //Skip unnecessary refills
  if (brewStep == STEP_REFILL) {
    byte pgm = stepProgram[brewStep];
    unsigned long HLTFillVol = calcSpargeVol(pgm);
    if (getProgMLHeatSrc(pgm) == PIT_1) HLTFillVol += calcStrikeVol(pgm);
    if (HLTFillVol <= getCapacity(PIT_1)) stepAdvance(brewStep);
  } 
}

//stepCore Logic for all mash steps
void stepMash(byte brewStep) { 
  if (!preheated[PIT_2] && temp[TS_PIT_2] >= setpoint[PIT_2]) {
    preheated[PIT_2] = 1;
    //Unpause Timer
    if (!timerStatus[TIMER_S1]) pauseTimer(TIMER_S1);
  }
  //Exit Condition (and skip unused mash steps)
  if (setpoint[PIT_2] == 0 || (preheated[PIT_2] && timerValue[TIMER_S1] == 0)) stepAdvance(brewStep);
}

//Advances program to next brew step
//Returns 0 if successful or 1 if unable to advance due to conflict with another step
boolean stepAdvance(byte brewStep) {
  //Save program for next step/rollback
  byte program = stepProgram[brewStep];
  stepExit(brewStep);
  //Advance step (if applicable)
  if (brewStep + 1 < NUM_BREW_STEPS) {
    if (stepInit(program, brewStep + 1)) {
      //Init Failed: Rollback
      stepExit(brewStep + 1); //Just to make sure we clean up a partial start
      setProgramStep(program, brewStep); //Show the step we started with as active
      return 1;
    }
    //Init Successful
    return 0;
  }
}

//Performs exit logic specific to each step
//Note: If called directly (as opposed through stepAdvance) acts as a program abort
void stepExit(byte brewStep) {
  //Mark step idle
  setProgramStep(brewStep, PROGRAM_IDLE);
  
  //Perform step closeout functions
  if (brewStep == STEP_FILL || brewStep == STEP_REFILL) {
  //Step Exit: Fill/Refill
    tgtVol[PIT_1] = 0;
    tgtVol[PIT_2] = 0;
    autoValve[AV_FILL] = 0;
    setValves(vlvConfig[VLV_FILLHLT], 0);
    setValves(vlvConfig[VLV_FILLMASH], 0);

  } else if (brewStep == STEP_DELAY) {
  //Step Exit: Delay
    clearTimer(TIMER_S1);
  
  } else if (brewStep == STEP_ADDGRAIN) {
  //Step Exit: Add Grain
    tgtVol[PIT_1] = 0;
    autoValve[AV_SPARGEIN] = 0;
    setValves(vlvConfig[VLV_ADDGRAIN], 0);
    setValves(vlvConfig[VLV_SPARGEIN], 0);
    setValves(vlvConfig[VLV_MASHHEAT], 0);
    setValves(vlvConfig[VLV_MASHIDLE], 0);
    resetHeatOutput(PIT_1);

  } else if (brewStep == STEP_PREHEAT || (brewStep >= STEP_DOUGHIN && brewStep <= STEP_MASHHOLD)) {
  //Step Exit: Preheat/Mash
    clearTimer(TIMER_S1);
    setValves(vlvConfig[VLV_MASHHEAT], 0);    
    setValves(vlvConfig[VLV_MASHIDLE], 0);   
    resetHeatOutput(PIT_1);
    resetHeatOutput(PIT_2);    

  } else if (brewStep == STEP_SPARGE) {
  //Step Exit: Sparge
    tgtVol[PIT_1] = 0;
    tgtVol[PIT_3] = 0;
    autoValve[AV_SPARGEIN] = 0;
    autoValve[AV_SPARGEOUT] = 0;
    autoValve[AV_FLYSPARGE] = 0;
    setValves(vlvConfig[VLV_MASHHEAT], 0);
    setValves(vlvConfig[VLV_MASHIDLE], 0);
    setValves(vlvConfig[VLV_SPARGEIN], 0);
    setValves(vlvConfig[VLV_SPARGEOUT], 0);    

  } else if (brewStep == STEP_BOIL) {
  //Step Exit: Boil
    //0 Min Addition
    if ((boilAdds ^ triggered) & 2048) { 
      setValves(vlvConfig[VLV_HOPADD], 1);
      setAlarm(1);
      triggered |= 2048;
      setBoilAddsTrig(triggered);
    }
    setValves(vlvConfig[VLV_HOPADD], 0);    
    resetHeatOutput(PIT_3);
    clearTimer(TIMER_S2);
    
  } else if (brewStep == STEP_CHILL) {
  //Step Exit: Chill
    autoValve[AV_CHILL] = 0;
    setValves(vlvConfig[VLV_CHILLBEER], 0);    
    setValves(vlvConfig[VLV_CHILLH2O], 0);  
  }
}
  
unsigned long calcStrikeVol(byte pgm) {
  unsigned long retValue = round((getProgGrain(pgm) * getProgRatio(pgm) / 100.0) + getVolLoss(TS_PIT_2));
  //Convert qts to gal for US
  #ifndef USEMETRIC
    retValue = round(retValue / 4.0);
  #endif
  
  #ifdef DEBUG_PROG_CALC_VOLS
    logProgCalcVols("Strike:", retValue);
  #endif
  
  return retValue;
}

unsigned long calcSpargeVol(byte pgm) {
  //Determine Preboil Volume Needed (Batch + Evap + Deadspace + Thermo Shrinkage)
  unsigned long retValue = calcPreboilVol(pgm);

  //Add Water Lost in Spent Grain
  retValue += calcGrainLoss(pgm);
  
  //Add Loss from other smokerPits
  retValue += (getVolLoss(TS_PIT_1) + getVolLoss(TS_PIT_2));

  //Subtract Strike Water Volume
  retValue -= calcStrikeVol(pgm);  
  
  return retValue;
}

unsigned long calcPreboilVol(byte pgm) {
  // Pre-Boil Volume is the total volume needed in the kettle to ensure you can collect your anticipated batch volume
  // It is (((batch volume + kettle loss) / thermo shrinkage factor ) / evap loss factor )
  //unsigned long retValue = (getProgBatchVol(pgm) / (1.0 - getEvapRate() / 100.0 * getProgBoil(pgm) / 60.0)) + getVolLoss(TS_PIT_3); // old logic 
  unsigned long retValue = (((getProgBatchVol(pgm) + getVolLoss(TS_PIT_3)) / .96) / (1.0 - getEvapRate() / 100.0 * getProgBoil(pgm) / 60.0)); 
    
  return round(retValue);
}

unsigned long calcGrainLoss(byte pgm) {
  unsigned long retValue;
  #ifdef USEMETRIC
    retValue = round(getProgGrain(pgm) * 1.7884);
  #else
    retValue = round(getProgGrain(pgm) * .2143); // This is pretty conservative (err on more absorbtion) - Ray Daniels suggests .20 - Denny Conn suggest .10
  #endif 
  
  return retValue;
}

unsigned long calcGrainVolume(byte pgm) {
  //Grain-to-volume factor for mash tun capacity
  //Conservatively 1 lb = 0.15 gal 
  //Aggressively 1 lb = 0.093 gal
  #ifdef USEMETRIC
    #define GRAIN2VOL 1.25
  #else
    #define GRAIN2VOL .15
  #endif
  return round (getProgGrain(pgm) * GRAIN2VOL);
}

byte calcStrikeTemp(byte pgm) {
  byte strikeTemp = getFirstStepTemp(pgm);
  #ifdef USEMETRIC
    return strikeTemp + round(.4 * (strikeTemp - getGrainTemp()) / (getProgRatio(pgm) / 100.0)) + 1.7;
  #else
    return strikeTemp + round(.192 * (strikeTemp - getGrainTemp()) / (getProgRatio(pgm) / 100.0)) + 3;
  #endif
}

byte getFirstStepTemp(byte pgm) {
  byte firstStep = 0;
  byte i = MASH_DOUGHIN;
  while (firstStep == 0 && i <= MASH_MASHOUT) firstStep = getProgMashTemp(pgm, i++);
  return firstStep;
}
