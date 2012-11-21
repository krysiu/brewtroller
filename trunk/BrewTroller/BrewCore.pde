/*  
   Copyright (C) 2009, 2010 Matt Reba, Jeremiah Dillingham

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

typedef struct vesselCfg_t {
  tSensorCfg_t tSensorCfg;
  vSensorCfg_t vSensorCfg;
  byte hysteresis;
  unsigned long heatProfile, idleProfile;
  int PIDp, PIDi, PIDd;
  analogOutCfg_t pwmOutput;
  byte pwmDelay;
  unsigned long capacity;
  unsigned long volLoss;
  unsigned long minHeatVol; //Minimum volume required to enable vessel heat
  triggerCfg_t minVolTrigger;
};

class vessel {
  private:
  tSensor* tempSensor;
  analogIn* volSensor;
  byte hysteresis;
  OutputProfile* heat, idle;
  PID* pidControl;
  analogOut* pwmHeat;
  unsigned long capacity;
  unsigned long volLoss;
  unsigned long minHeatVol; //Minimum volume required to enable vessel heat
  trigger* minVolTrig;
  double* PIDInput, setpoint, heatPower;
  byte pwmDelay;
  unsigned long pwmDelayStart;
  
  public:
  vessel () {
    tempSet = BAD_TEMP;
    volSet = 0;
  }
  
  void init(vesselCfg_t cfg) {
    if (tempSensor) delete tempSensor;
    tempSensor = tSensor::create(cfg.tSensorCfg);
    
    if (volSensor) delete volSensor;
    volSensor = analogIn::create(cfg.vSensorCfg);
    
    hysteresis = cfg.hysteresis;
    
    if (!heat) heat = Outputs.addprofile();
    heat->mask = cfg.heatProfile;
    
    if (!idle) idle = Outputs.addprofile();
    idle->mask = cfg.idleProfile;
    
    if (!PIDInput) PIDInput = new double;
    if (!setpoint) setpoint = new double;
    if (!heatPower) heatPower = new double;

    if (pwmHeat) delete pwmHeat;
    pwmHeat = analogOutput::create(cfg.pidOutput);
    
    if (pwmHeat) {
      pidControl = new PID(PIDInput, heatPower, setpoint, cfg.PIDp / 100.0, cfg.PIDi / 100.0, cfg.PIDd / 100.0, DIRECT);
      pidControl->SetOutputLimits(0, pwmHeat->getLimit());
      pwmDelayStart = 0;
      pwmDelay = cfg.pwmDelay;
    }
    
    capacity = cfg.capacity;
    volLoss = cfg.volLoss;
    minHeatVol = cfg.minHeatVol;
    
    if (minVolTrigger) delete minVolTrigger;
    minVolTrigger = trigger::create(cfg.minVolTrigger, vesselMinISR);
  }
  
  void update() {
    if (tempSensor) tempSensor->update();
    if (volSensor) volSensor->update();
    if (minVolTrigger) minVolTrigger->update();
    
    if (pwmHeat) processPWMHeat();
    else processOnOffHeat();

    if (minVolTrigger) processMinVolTrigger();
    if (volSensor) processMinHeatVol();

    if (pwmHeat) {
      if (pwmDelay) { if (millis() < pwmDelayStart) { pwmHeat->overrideOff(); } }
      pwmHeat->setValue(*heatPower);
      pwmHeat->update();
    }
  }
  
  void processPWMHeat() {
    // PWM Heat Logic
    if (*setpoint) {
      //PID Heat Logic
      *PIDInput = tempSensor->getValue();
      pidControl->Compute();
      if (*heatPower) { 
        heat->state = 1; 
        idle->state = 0; 
      }
      else { 
        heat->state = 0;
        idle->state = 1;
      }
    }
    else { 
      pwmHeat->setValue(0);
      heat->state = 0; 
      idle->state = 0; 
    }
  }
  
  void processOnOffHeat() {
    // On/Off Heat Logic
    if (!*setpoint) {
      heat->state = 0; 
      idle->state = 0;
      *heatPower = 0;
    }
    else if (*heatPower && tempSensor->getValue() >= *setpoint) { 
      heat->state = 0; 
      idle->state = 1; 
      *heatPower = 0; 
    }
    else if (!*heatPower && tempSensor->getValue() <= *setpoint - hystesis) {
      heat->state = 1; 
      idle->state = 0; 
      *heatPower = 1; 
    }
  }
  
  void processMinVolTrigger() {
    if (minVolTrigger->getState()) {
      heat->state = 0; 
      idle->state = 1; 
      *heatPower = 0;      
    }
  }
  
  void processMinHeatVol() {
    if (volSensor->getValue() < minHeatVol) {
      heat->state = 0; 
      idle->state = 1; 
      *heatPower = 0;      
    }
  }
  
  void setSetpoint(unsigned int t) {
    //If transition from no setpoint to setpoint then delay PWM output
    if (!setpoint && t && pwmDelay) {
      pwmDelayStart = millis() + pwmDelay * 1000;
      pwmHeat->overrideOff();
    }
    setpoint = t;
  }
  
  unsigned int getSetpoint(void) { return setpoint; }
  unsigned int getTemp(void) { return tempSensor->getValue(): }
  unsigned long getVol(void) { return volSensor->getValue(): }
  unsigned long getCapacity(void) { return capacity; }
  unsigned long getVolLoss(void) { return volLoss; }
  byte getHeatPct(void) {
    if (pwmHeat) { return round(heatPower * 100 / pwmHeat->getLimit()); }
    else { return (heatPower ? 100 : 0); }
  }
  OutputProfile* getHeatProfile(void) { return heat; }
  OutputProfile* getIdleProfile(void) { return idle; }
};

void brewCore() {
  #ifdef HEARTBEAT
    HeartBeat.update();
  #endif
  
  for (byte i = 0; i < NUMBEROFVESSELS; i++ { vessel[i].update(); )
  
  #ifndef NOUI
    LCD.update();
  #endif
  
  //Timers: Timer.pde
  updateTimers();
  
  //Communications: Com.pde
  updateCom();  

  //Step Logic: StepLogic.pde
  stepCore();

  Outputs.update();
}

class heartBeat {
  private:
  unsigned long lastUpdate;
  pin hb;
  
  public:
  heartBeat(byte pinNum) {
    hb.setup(pinNum, OUTPUT);
  }
  
  void update() {
    unsigned long timeStamp = millis();
    if (timeStamp - lastUpdate > 750) {
      hbPin.toggle();
      lastUpdate = timeStamp;
    }
  }
};


