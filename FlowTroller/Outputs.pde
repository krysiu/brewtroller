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

void pinInit() {
  heatPin.setup(HEAT_PIN, OUTPUT);
  pinMode(PWMFAN_PIN, OUTPUT);
}

void pidInit() {
  pid.SetOutputLimits(0, PIDCycle * PIDLIMIT);
  pid.SetTunings(getPIDp() / 100.0, getPIDi() / 100.0, getPIDd() / 100.0);
}

void resetOutputs() {
  setSetpoint(0);
  pid.SetMode(MANUAL);
  PIDOutput = 0;
  heatPin.set(LOW);
}

void processHeatOutputs() {
  //Process Heat Outputs
  if (PIDEnabled) {
    if (temp == 9999) {
      PIDOutput = 0;
    } else {
      if (pid.GetMode() == AUTOMATIC) {
        PIDInput = temp;
        pid.Compute();
      }
    }
    if (cycleStart == 0) cycleStart = millis();
    if (millis() - cycleStart > PIDCycle * 100) cycleStart += PIDCycle * 100;
    if (PIDOutput > millis() - cycleStart) heatPin.set(HIGH); else heatPin.set(LOW);
    if (PIDOutput == 0)  heatStatus = 0; else heatStatus = 1;
  } else {
    if (heatStatus) {
      if (temp == 9999 || temp >= setpoint) {
        heatPin.set(LOW);
        heatStatus = 0;
      } else {
        heatPin.set(HIGH);
      }
    } else {
      if (temp != 9999 && ((float)(setpoint - temp) >= (float) (hysteresis / 10.0))) {
        heatPin.set(HIGH);
        heatStatus = 1;
      } else {
        heatPin.set(LOW);
      }
    }
  }
  if (coolStatus) {
    if (temp != 9999 && ((float)(temp <= setpoint))) {
      analogWrite(PWMFAN_PIN, 0);
      coolStatus = 0;
    }
  } else {
    if (temp != 9999 && ((float)(temp - setpoint) >= coolThresh)) {
      analogWrite(PWMFAN_PIN, pwmFanPwr);
      coolStatus = 1;
    }
  }
}


