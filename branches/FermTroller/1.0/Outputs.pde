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
  pinMode(ENCA_PIN, INPUT);
  pinMode(ENCB_PIN, INPUT);
  pinMode(ENTER_PIN, INPUT);
  pinMode(ALARM_PIN, OUTPUT);
  for (byte i = 0; i < 12; i++) if (!muxOuts[i]) pinMode(outputPin[i], OUTPUT);
 
  #ifdef USE_MUX
    pinMode(MUX_LATCH_PIN, OUTPUT);
    pinMode(MUX_CLOCK_PIN, OUTPUT);
    pinMode(MUX_DATA_PIN, OUTPUT);
    pinMode(MUX_OE_PIN, OUTPUT);
  #endif
  resetOutputs();
}

void pidInit() {
  for (byte i = 0; i < NUM_PID_OUTS; i++) {
      pid[i].SetInputLimits(0, 255);
      pid[i].SetOutputLimits(0, PIDCycle[i] * 1000);
      pid[i].SetTunings(PIDp[i], PIDi[i], PIDd[i]);
  }
}

void resetOutputs() {
  for (byte i = 0; i < NUM_ZONES; i++) {
    setpoint[i] = 0;
    heatStatus[i] = 0;
    coolStatus[i] = 0;
    if (COOLPIN_OFFSET > i) {
      if (!muxOuts[i]) digitalWrite(outputPin[i], LOW);
    }
    if (NUM_OUTS - COOLPIN_OFFSET > i) {
      if (!muxOuts[i + COOLPIN_OFFSET]) digitalWrite(outputPin[i + COOLPIN_OFFSET], LOW);
    }
    #ifdef USE_MUX
      digitalWrite(MUX_OE_PIN, HIGH);
      //ground latchPin and hold low for as long as you are transmitting
      digitalWrite(MUX_LATCH_PIN, 0);
      //clear everything out just in case to prepare shift register for bit shifting
      digitalWrite(MUX_DATA_PIN, 0);
      digitalWrite(MUX_CLOCK_PIN, 0);

      //for each bit in the long myDataOut
      for (byte i = 32; i > 0; i--)  {
        digitalWrite(MUX_CLOCK_PIN, 0);
        //create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
        digitalWrite(MUX_DATA_PIN, 0);
        //register shifts bits on upstroke of clock pin  
        digitalWrite(MUX_CLOCK_PIN, 1);
        //zero the data pin after shift to prevent bleed through
        digitalWrite(MUX_DATA_PIN, 0);
      }

      //stop shifting
      digitalWrite(MUX_CLOCK_PIN, 0);
      digitalWrite(MUX_LATCH_PIN, 1);
      //Enable outputs
      digitalWrite(MUX_OE_PIN, LOW);
    #endif
  }
}

void updateOutputs() {
  //Set doMUXUpdate to 1 to force MUX update on each cycle.
  boolean doMUXUpdate = 0;

  //Process Outputs
  for (byte i = 0; i < NUM_ZONES; i++) {
    if (COOLPIN_OFFSET > i) {
      //Process PID Heat Outputs
      if (PIDEnabled[i]) {
        if (temp[i] == -32768 || coolStatus[i]) {
          pid[i].SetMode(MANUAL);
          PIDOutput[i] = 0;
        } else {
          pid[i].SetMode(AUTO);
          PIDInput[i] = temp[i];
          pid[i].Compute();
        }
        if (cycleStart[i] == 0) cycleStart[i] = millis();
        if (millis() - cycleStart[i] > PIDCycle[i] * 1000) cycleStart[i] += PIDCycle[i] * 1000;
        if (PIDOutput[i] > millis() - cycleStart[i]) digitalWrite(outputPin[i], HIGH); else digitalWrite(outputPin[i], LOW);
      } 

      //Process On/Off Heat
      if (heatStatus[i]) {
        if (temp[i] == -32768 || temp[i] >= setpoint[i]) {
          if (!PIDEnabled[i]) {
            if (!muxOuts[i]) digitalWrite(outputPin[i], LOW);
              else doMUXUpdate = 1;
          }
          heatStatus[i] = 0;
        }
      } else { 
        if (temp[i] != -32768 && ((float)(setpoint[i] - temp[i]) >= (float) hysteresis[i] / 10.0)) {
          if (!PIDEnabled[i]) {
            if (!muxOuts[i]) digitalWrite(outputPin[i], HIGH);
              else doMUXUpdate = 1;
          }
          heatStatus[i] = 1;
        }
      }
    }
    
    if (NUM_OUTS - COOLPIN_OFFSET > i) {
      //Process On/Off Cool
      if (coolStatus[i]) {
        if (temp[i] == -32768 || temp[i] <= setpoint[i] || setpoint[i] == 0) {
          if (!muxOuts[i + COOLPIN_OFFSET]) digitalWrite(outputPin[i + COOLPIN_OFFSET], LOW);
            else doMUXUpdate = 1;
          coolStatus[i] = 0;
        }
        coolOnTime[i] = millis() + coolDelay[i] * 1000;
      } else {
        if (temp[i] != -32768 && setpoint[i] != 0 && (float)(temp[i] - setpoint[i]) >= (float) hysteresis[i] / 10.0) {
          //Check Cool Off Time Limit
          if (coolOnTime[i] <= millis()) {
            if (!muxOuts[i + COOLPIN_OFFSET]) digitalWrite(outputPin[i + COOLPIN_OFFSET], HIGH);
              else doMUXUpdate = 1;
            coolStatus[i] = 1;
            coolOnTime[i] = millis() + coolDelay[i] * 1000;
          }
        }
      }
    }
  }
  
#ifdef USE_MUX
  if (doMUXUpdate) {
    //Disable outputs
    digitalWrite(MUX_OE_PIN, HIGH);
    //ground latchPin and hold low for as long as you are transmitting
    digitalWrite(MUX_LATCH_PIN, LOW);
    //clear everything out just in case to prepare shift register for bit shifting
    digitalWrite(MUX_DATA_PIN, LOW);
    digitalWrite(MUX_CLOCK_PIN, LOW);

    //for each bit in the long myDataOut
    for (byte i = 32; i > 0; i--)  {
      digitalWrite(MUX_CLOCK_PIN, LOW);
      //create bitmask to grab the bit associated with our counter i and set data pin accordingly (NOTE: 32 - i causes bits to be sent most significant to least significant)
      if (muxOuts[i - 1]) {
        if (i - 1 < COOLPIN_OFFSET) digitalWrite(MUX_DATA_PIN, heatStatus[i - 1]);
        else if (i - 1 < NUM_OUTS) digitalWrite(MUX_DATA_PIN, coolStatus[i - 1 - COOLPIN_OFFSET]);
        else digitalWrite(MUX_DATA_PIN, LOW);
      } else digitalWrite(MUX_DATA_PIN, LOW);
      //register shifts bits on upstroke of clock pin  
      digitalWrite(MUX_CLOCK_PIN, HIGH);
      //zero the data pin after shift to prevent bleed through
      digitalWrite(MUX_DATA_PIN, LOW);
    }

    //stop shifting
    digitalWrite(MUX_CLOCK_PIN, LOW);
    digitalWrite(MUX_LATCH_PIN, HIGH);
    //Enable outputs
    digitalWrite(MUX_OE_PIN, LOW);
  }
#endif
}

