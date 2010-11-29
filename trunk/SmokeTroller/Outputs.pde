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
#include "wiring_private.h"

#include "Config.h"
#include "Enum.h"


#define LAST_HEAT_OUTPUT PIT_3

// set what the PID cycle time should be based on how fast the temp sensors will respond
#if TS_ONEWIRE_RES == 12
  #define PID_CYCLE_TIME 750
#elif TS_ONEWIRE_RES == 11
  #define PID_CYCLE_TIME 375
#elif TS_ONEWIRE_RES == 10
  #define PID_CYCLE_TIME 188
#elif TS_ONEWIRE_RES == 9
  #define PID_CYCLE_TIME 94
#else
  // should not be this value, fail the compile
  #ERROR
#endif

void pinInit() {
  alarmPin.setup(ALARM_PIN, OUTPUT);

  #if MUXBOARDS > 0
    muxLatchPin.setup(MUX_LATCH_PIN, OUTPUT);
    muxDataPin.setup(MUX_DATA_PIN, OUTPUT);
    muxClockPin.setup(MUX_CLOCK_PIN, OUTPUT);
    muxOEPin.setup(MUX_OE_PIN, OUTPUT);
    muxOEPin.set();
  #endif
  #ifdef ONBOARDPV
    valvePin[0].setup(VALVE1_PIN, OUTPUT);
    valvePin[1].setup(VALVE2_PIN, OUTPUT);
    valvePin[2].setup(VALVE3_PIN, OUTPUT);
    valvePin[3].setup(VALVE4_PIN, OUTPUT);
    valvePin[4].setup(VALVE5_PIN, OUTPUT);
    valvePin[5].setup(VALVE6_PIN, OUTPUT);
    valvePin[6].setup(VALVE7_PIN, OUTPUT);
    valvePin[7].setup(VALVE8_PIN, OUTPUT);
    valvePin[8].setup(VALVE9_PIN, OUTPUT);
    valvePin[9].setup(VALVEA_PIN, OUTPUT);
    valvePin[10].setup(VALVEB_PIN, OUTPUT);
  #endif
  
  heatPin[PIT_1].setup(PIT1_HEAT_PIN, OUTPUT);
  heatPin[PIT_2].setup(PIT2_HEAT_PIN, OUTPUT);
  heatPin[PIT_3].setup(PIT3_HEAT_PIN, OUTPUT);
  
}

void pidInit() { 
  
  pid[PIT_1].SetInputLimits(0, 25500);
  pid[PIT_1].SetOutputLimits(0, PIDCycle[PIT_1] * PIDLIMIT_PIT1);
  pid[PIT_1].SetTunings(getPIDp(PIT_1), getPIDi(PIT_1), getPIDd(PIT_1));
  pid[PIT_1].SetMode(AUTO);
  pid[PIT_1].SetSampleTime(PID_CYCLE_TIME);

  pid[PIT_2].SetInputLimits(0, 25500);
  pid[PIT_2].SetOutputLimits(0, PIDCycle[PIT_2] * PIDLIMIT_PIT2);
  pid[PIT_2].SetTunings(getPIDp(PIT_2), getPIDi(PIT_2), getPIDd(PIT_2));
  pid[PIT_2].SetMode(AUTO);
  pid[PIT_2].SetSampleTime(PID_CYCLE_TIME);

  pid[PIT_3].SetInputLimits(0, 25500);
  pid[PIT_3].SetOutputLimits(0, PIDCycle[PIT_3] * PIDLIMIT_PIT3);
  pid[PIT_3].SetTunings(getPIDp(PIT_3), getPIDi(PIT_3), getPIDd(PIT_3));
  pid[PIT_3].SetMode(MANUAL);
  pid[PIT_3].SetSampleTime(PID_CYCLE_TIME);  

#ifdef DEBUG_PID_GAIN
  for (byte smokerPit = PIT_1; smokerPit <= PIT_3; smokerPit++) logDebugPIDGain(smokerPit);
#endif
}

void resetOutputs() {
//  for (byte i = STEP_FILL; i <= STEP_CHILL; i++) stepExit(i); //Go through each step's exit functions to quit clean.
}

void resetHeatOutput(byte smokerPit) {  
  setSetpoint(smokerPit, 0);
  PIDOutput[smokerPit] = 0; 
  heatPin[smokerPit].set(LOW);  
}  

//Sets the specified valves On or Off
void setValves (unsigned long vlvBitMask, boolean value) {
  
  //Nothing to do with an empty valve profile
  if(!vlvBitMask) return;
  
  if (value) vlvBits |= vlvBitMask;
  else vlvBits = vlvBits ^ (vlvBits & vlvBitMask);
  
  #if MUXBOARDS > 0
  //MUX Valve Code
    //Disable outputs
    //muxOEPin.set();
    //ground latchPin and hold low for as long as you are transmitting
    muxLatchPin.clear();
    //clear everything out just in case to prepare shift register for bit shifting
    muxDataPin.clear();
    muxClockPin.clear();
  
    //for each bit in the long myDataOut
    for (byte i = 0; i < 32; i++)  {
      muxClockPin.clear();
      //create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
      if ( vlvBits & ((unsigned long)1<<(31 - i)) ) muxDataPin.set(); else muxDataPin.clear();
      //register shifts bits on upstroke of clock pin  
      muxClockPin.set();
      //zero the data pin after shift to prevent bleed through
      muxDataPin.clear();
    }
  
    //stop shifting
    muxClockPin.clear();
    muxLatchPin.set();
    //Enable outputs
    muxOEPin.clear();
  #endif
  #ifdef ONBOARDPV
  //Original 11 Valve Code
  for (byte i = 0; i < 11; i++) { if (vlvBits & (1<<i)) valvePin[i].set(); else valvePin[i].clear(); }
  #endif
}

void processHeatOutputs() {
  //Process Heat Outputs
  unsigned long millistemp;  
  
  for (byte i = PIT_1; i <= LAST_HEAT_OUTPUT; i++) {    
    if (PIDEnabled[i]) {
      if (temp[i] <= 0) {
        PIDOutput[i] = 0;
      } else {
        if (pid[i].GetMode() == AUTO) {
          PIDInput[i] = temp[i];
          pid[i].Compute();
        }
      }
      
      //only 1 call to millis needed here, and if we get hit with an interrupt we still want to calculate based on the first read value of it
      millistemp = millis();
      if (cycleStart[i] == 0) cycleStart[i] = millistemp;
      if (millistemp - cycleStart[i] > PIDCycle[i] * 100) cycleStart[i] += PIDCycle[i] * 100;
      if (PIDOutput[i] >= millistemp - cycleStart[i] && millistemp != cycleStart[i]) heatPin[i].set(HIGH); else heatPin[i].set(LOW);      
      if (PIDOutput[i] == 0) heatStatus[i] = 0; else heatStatus[i] = 1;
      
    } else {
      if (heatStatus[i]) {
        if (temp[i] <= 0 || temp[i] >= setpoint[i]) {
          heatPin[i].set(LOW);
          heatStatus[i] = 0;
        } else {
          heatPin[i].set(HIGH);
        }
      } else {
        if (temp[i] > 0 && (setpoint[i] - temp[i]) >= hysteresis[i] * 10) {
          heatPin[i].set(HIGH);
          heatStatus[i] = 1;
        } else {
          heatPin[i].set(LOW);
        }
      }
    }    
  }
}

boolean vlvConfigIsActive(byte profile) {
  //An empty valve profile cannot be active
  if (!vlvConfig[profile]) return 0;
  if ((vlvBits & vlvConfig[profile]) == vlvConfig[profile]) return 1; else return 0;
}

void processAutoValve() {
  //Do Valves
  if (autoValve[AV_FILL]) {
//    if (volAvg[PIT_1] < tgtVol[PIT_1]) setValves(vlvConfig[VLV_FILLHLT], 1);
//      else setValves(vlvConfig[VLV_FILLHLT], 0);
//      
//    if (volAvg[PIT_2] < tgtVol[PIT_2]) setValves(vlvConfig[VLV_FILLMASH], 1);
//      else setValves(vlvConfig[VLV_FILLMASH], 0);
  } 
  if (autoValve[AV_HLT]) {
    if (heatStatus[PIT_1]) {
      if (!vlvConfigIsActive(VLV_HLTHEAT)) setValves(vlvConfig[VLV_HLTHEAT], 1);
    } else {
      if (vlvConfigIsActive(VLV_HLTHEAT)) setValves(vlvConfig[VLV_HLTHEAT], 0);
    }
  }
  if (autoValve[AV_MASH]) {
    if (heatStatus[PIT_2]) {
      if (vlvConfigIsActive(VLV_MASHIDLE)) setValves(vlvConfig[VLV_MASHIDLE], 0);
      if (!vlvConfigIsActive(VLV_MASHHEAT)) setValves(vlvConfig[VLV_MASHHEAT], 1);
    } else {
      if (vlvConfigIsActive(VLV_MASHHEAT)) setValves(vlvConfig[VLV_MASHHEAT], 0);
      if (!vlvConfigIsActive(VLV_MASHIDLE)) setValves(vlvConfig[VLV_MASHIDLE], 1); 
    }
  } 
  if (autoValve[AV_SPARGEIN]) {
//    if (volAvg[PIT_1] > tgtVol[PIT_1]) setValves(vlvConfig[VLV_SPARGEIN], 1);
//      else setValves(vlvConfig[VLV_SPARGEIN], 0);
  }
  if (autoValve[AV_SPARGEOUT]) {
//    if (volAvg[PIT_3] < tgtVol[PIT_3]) setValves(vlvConfig[VLV_SPARGEOUT], 1);
//    else setValves(vlvConfig[VLV_SPARGEOUT], 0);
  }
  if (autoValve[AV_FLYSPARGE]) {
//    if (volAvg[PIT_3] < tgtVol[PIT_3]) {      
//      setValves(vlvConfig[VLV_SPARGEIN], 1);
//      setValves(vlvConfig[VLV_SPARGEOUT], 1);
//    } else {
//      setValves(vlvConfig[VLV_SPARGEIN], 0);
//      setValves(vlvConfig[VLV_SPARGEOUT], 0);
//    }
  }
  if (autoValve[AV_CHILL]) {
    //Needs work
    /*
    //If Pumping beer
    if (vlvConfigIsActive(VLV_CHILLBEER)) {
      //Cut beer if exceeds pitch + 1
      if (temp[TS_FOOD_3] > pitchTemp + 1.0) setValves(vlvConfig[VLV_CHILLBEER], 0);
    } else {
      //Enable beer if chiller H2O output is below pitch
      //ADD MIN DELAY!
      if (temp[TS_FOOD_2] < pitchTemp - 1.0) setValves(vlvConfig[VLV_CHILLBEER], 1);
    }
    
    //If chiller water is running
    if (vlvConfigIsActive(VLV_CHILLH2O)) {
      //Cut H2O if beer below pitch - 1
      if (temp[TS_FOOD_3] < pitchTemp - 1.0) setValves(vlvConfig[VLV_CHILLH2O], 0);
    } else {
      //Enable H2O if chiller H2O output is at pitch
      //ADD MIN DELAY!
      if (temp[TS_FOOD_2] >= pitchTemp) setValves(vlvConfig[VLV_CHILLH2O], 1);
    }
    */
  }
}
