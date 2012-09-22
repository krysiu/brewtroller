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


void eventHandler(byte eventID, int eventParam) {
  //Global Event handler
  //EVENT_STEPINIT: Nothing to do here (Pass to UI handler below)
  //EVENT_STEPEXIT: Nothing to do here (Pass to UI handler below)
  if (eventID == EVENT_SETPOINT) {
    //Setpoint Change (Update AutoValve Logic)
    byte avProfile = vesselAV(eventParam);
    byte vlvHeat = vesselVLVHeat(eventParam);
    byte vlvIdle = vesselVLVIdle(eventParam);
    
    if (setpoint[eventParam]) autoValve[avProfile] = 1;
    else { 
      autoValve[avProfile] = 0; 
      if (vlvConfigIsActive(vlvIdle)) bitClear(actProfiles, vlvIdle);
      if (vlvConfigIsActive(vlvHeat)) bitClear(actProfiles, vlvHeat);
    } 
  }
  
  #ifndef NOUI
    //Pass Event Info to UI Event Handler
    uiEvent(eventID, eventParam);
  #endif

  //Pass Event Info to Com Event Handler
  comEvent(eventID, eventParam);

}

typedef enum {
  TRANSITION_CHANGE = CHANGE,
  TRANSITION_FALLING = FALLING,
  TRANSITION_RISING = RISING
} transitionType;

typedef struct triggerCfg_t {
  typedef enum {
    triggerType_None,
    triggerType_GPIO,
    triggerType_Modbus
  } triggerType;
  union {
    struct triggerCfg_GPIO_t {
      byte pin;
      transitionType mode;
    } triggerCfg_GPIO;
    struct triggerCfg_Modbus_t {
      byte slaveAddr;
      unsigned int dataAddr;
      transitionType mode;
    } triggerCfg_Modbus;
  } implementation;
};



class trigger {
  private:
  transitionType mode;
  boolean value, lastValue;
  
  public:
  static trigger* create(triggerCfg_t cfg) {
    if(cfg.triggerType == triggerType_GPIO) return new trigger_GPIO(cfg.implementation.triggerCfg_GPIO.pin, cfg.implementation.triggerCfg_GPIO.mode);
    else return NULL;
  }
  virtual boolean getState() {
    boolean retValue = 0;
    switch (mode) {
      case TRANSITION_CHANGE:
        if (lastValue != value) retValue = 1;
        break;
      case TRANSITION_FALLING:
        retValue = ~value;
        break;
      case TRANSITION_RISING:
        retValue = value;
        break
    }
    lastValue = value;
    return retValue;
  }
  virtual void init() {}
  virtual void update() {}
};



class trigger_GPIO : public trigger {
  private:
  pin trigPin;
  
  public:
  trigger_GPIO(byte pinNum, transitionType m) {
    mode = m;
    trigPin.setup(pinNum, INPUT);
  }
  void update() { value = trigPin.get(); }
};


class trigger_Modbus : public trigger {
  private:
  ModbusMaster slave;
  unsigned int dataAddr;
    
  public:
  trigger_Modbus(byte sAddr, unsigned int dAddr, transitionType m) {
    slave = ModbusMaster(RS485_SERIAL_PORT, sAddr);
    #ifdef RS485_RTS_PIN
      slave.setupRTS(RS485_RTS_PIN);
    #endif
    slave.begin(RS485_BAUDRATE, RS485_PARITY);
    //Modbus Coil Register index starts at 1 but is transmitted with a 0 index
    dataAddr = dAddr - 1;
  }
  void update() {
    slave.readDiscreetInputs(dAddr, 1);
    value = (slave.getResponseBuffer(0) & 1);
  }
};


void eStopISR() {
  //Either clear E-Stop condition if e-Stop trigger goes high
  //or perform E-Stop actions on trigger low
  if (TriggerPin[TRIGGER_ESTOP]->get()) estop = 0;
  else {
    estop = 1;
    setAlarm(1);
    processHeatOutputs();
    #ifdef PVOUT
      updateValves();
    #endif
    updateTimers();
  }
}

void spargeMaxISR() {
  bitClear(actProfiles, VLV_SPARGEIN);
}

void boilAddISR() {
  bitClear(actProfiles, VLV_BOILADD);
}

