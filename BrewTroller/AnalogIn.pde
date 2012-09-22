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


typedef struct calibration_t {
  unsigned int value;
  unsigned long actual;
};

typedef struct analogInCfg_t {
  typedef enum {
    analogInType_None,
    analogInType_GPIO,
    analogInType_Modbus
  } analogInType;
  union {
    struct analogInCfg_GPIO_t {
      byte pin;
    } analogInCfg_GPIO;
    struct analogInCfg_Modbus_t {
      byte slaveAddr;
      unsigned int reg;
    } analogInCfg_Modbus;
  } implementation;
  boolean calibrate;
  calibration_t calibrations[ANALOG_CALIBRATION_COUNT];
  byte averaging;
};

class calibratedValue {
  private:
  calibration_t * calibrationTable;
  byte count;
  
  public:
  calibratedValue(byte c, calibration_t entries[]) {
    count = c;
    calibrationTable = new calibration_t[count];
    memcpy(calibrationTable, entries, sizeof(calibration_t) * count);
  }
  ~calibratedValue() { delete calibrationTable[]; }
  
  unsigned long compute(unsigned int value) {
    unsigned long retValue;
    byte upperCal = 0;
    byte lowerCal = 0;
    byte lowerCal2 = 0;
    for (byte i = 0; i < count; i++) {
      if (value == calibrationTable[i].value) { 
        return calibrationTable[i].actual; //Exact match
        break;
      } else if (value > calibrationTable[i].value) {
          if (value < calibrationTable[lowerCal].value) lowerCal = i;
          else if (calibrationTable[i].value > calibrationTable[lowerCal].value) { 
            if (value < calibrationTable[lowerCal2].value || calibrationTable[lowerCal].value > calibrationTable[lowerCal2].value) lowerCal2 = lowerCal;
            lowerCal = i; 
          } else if (value < calibrationTable[lowerCal2].value || calibrationTable[i].value > calibrationTable[lowerCal2].value) lowerCal2 = i;
      } else if (value < calibrationTable[i].value) {
        if (value > calibrationTable[upperCal].value) upperCal = i;
        else if (calibrationTable[i].value < calibrationTable[upperCal].value) upperCal = i;
      }
    }
    
    //If no calibrations exist return zero
    if (calibrationTable[upperCal].value == 0 && calibrationTable[lowerCal].value == 0) return 0;
  
    //If read value is greater than all calibrations plot value based on two closest lesser values
    else if (value > calibrationTable[upperCal].value && calibrationTable[lowerCal].value > calibrationTable[lowerCal2].value) retValue = round((float) ((float)value - (float)calibrationTable[lowerCal].value) / (float) ((float)calibrationTable[lowerCal].value - (float)calibrationTable[lowerCal2].value) * ((float)calibrationTable[lowerCal].actual - (float)calibrationTable[lowerCal2].actual)) + calibrationTable[lowerCal].actual;
    
    //If read value exceeds all calibrations and only one lower calibration point is available plot value based on zero and closest lesser value
    else if (value > calibrationTable[upperCal].value) retValue = round((float) ((float)value - (float)calibrationTable[lowerCal].value) / (float) ((float)calibrationTable[lowerCal].value) * (float)((float)calibrationTable[lowerCal].actual)) + calibrationTable[lowerCal].actual;
    
    //If read value is less than all calibrations plot value between zero and closest greater value
    else if (value < calibrationTable[lowerCal].value) retValue = round((float) value / (float) calibrationTable[upperCal].value * (float)calibrationTable[upperCal].actual);
    
    //Otherwise plot value between lower and greater calibrations
    else retValue = round((float) ((float)value - (float)calibrationTable[lowerCal].value) / (float) ((float)calibrationTable[upperCal].value - (float)calibrationTable[lowerCal].value) * ((float)calibrationTable[upperCal].actual - (float)calibrationTable[lowerCal].actual)) + calibrationTable[lowerCal].actual;

  }
};

class averagedValue {
  private:
  byte count, index;
  unsigned long * values;
  
  public:
  averagedValue(byte c) {
    count = c;
    values = new unsigned long[count];
  }
  ~averagedValue() { delete values; }
  
   unsigned long compute(unsigned long value) {
     unsigned long retValue = 0;
     values[index++] = value;
     if (index == count) { index = 0; }
     for (byte i = 0; i < count; i++) { retValue += values[i]; }
     return retValue / count;
   }
};

class analogIn {
  private:
  unsigned long value;
  calibratedValue * cValue;
  averagedValue * aValue;
  
  public:
  analogIn(void) {  }
  ~analogIn() { 
    if (cValue) delete cValue; 
    if (aValue) delete aValue;
  }
  
  static analogIn* create(analogInCfg_t cfg) {
    analogIn* retObj;
    if (cfg.analogInType ==  analogInType_GPIO) { retObj = new analogIn_GPIO(cfg.implementation.analogInCfg_GPIO.pin); }
    //else if (cfg.analogInType ==  analogInType_Modbus) { retObj = new analogIn_Modbus(cfg.implementation.analogInCfg_Modbus.slaveAddr, cfg.implementation.analogInCfg_Modbus.reg); }
    else { retObj = NULL; }
    
    if (retObj) {
      if (cfg.calibrated) { retObj.setupCalibration(new calibratedValue(ANALOG_CALIBRATION_COUNT, cfg.calibrations)); }
      if (cfg.averages) { retObj.setupAverages(new averagedValue(cfg.averages));
    }
      
    return retObj;
  }
  
  int getValue() { return value; }
  virtual void setupCalibration(calibratedValue * c) { cValue = c; }
  virtual void setupAverages(averagedValue * a) { aValue = a; }
  virtual void init(void) { };
  virtual void update(void) = 0;
};

class analogIn_GPIO : public analogIn {
  private:
  byte pin;
  
  public:
  analogIn_GPIO(byte pinNum) { pin = pinNum; }
  
  void update() {
    unsigned int newValue = analogRead(pin);
    if (cValue) newValue = cValue->compute(newValue);
    if (aValue) newValue = aValue->compute(newValue);
    value = newValue;
  }
  
  //Utility Functions
  static byte getCount() { 
    return ANALOGINPUTS_GPIO_COUNT;
  }
  
  static byte getPin(byte index) {
    if (index < ANALOGINPUTS_GPIO_COUNT) {
      byte pins[] = ANALOGINPUTS_GPIO_PINS;
      return pins[index];
    }
    return 255;
  }

  static char* getName(byte index, char* retString) {
    if (index < ANALOGINPUTS_GPIO_COUNT) {
      char names[] = #define ANALOGINPUTS_GPIO_NAMES;
      char* pos = names;
      for (byte i = 0; i <= index; i++) {
        strlcpy(retString, pos, OUTPUTBANK_NAME_MAXLEN);
        pos += strlen(retString) + 1;
      }
    }
    else retString[0] = '\0';
    return retString;
  }
};




typedef struct flowMeterCfg_t {
  typedef enum {
    flowMeterType_None,
    flowMeterType_Vol,
    flowMeterType_Trig,
    flowMeterType_Modbus
  } flowMeterType;
  union {
    struct flowMeterCfg_Vol_t {
      byte vessel;
    } flowMeterCfg_Vol;
    struct flowMeterCfg_Trig_t {
      byte pin;
      unsigned int pulseUnit;
    } flowMeterCfg_Trig;    
    struct flowMeterCfg_Modbus_t {
      byte slaveAddr;
      unsigned int reg;
      unsigned int pulseUnit;
    } flowMeterCfg_Modbus;
  } implementation;
};


class flowMeter {
  private:
  long flowRate;
  static unsigned int sampleRate;
  
  public:
  long getValue() { return flowRate; }
  void setSampleRate(unsigned int rate) { flowSensor::sampleRate = rate; }
  
  static flowMeter* create(flowMeterCfg_t cfg) {
    if (cfg.flowMeterType == flowMeterType_Vol) return new flowMeter_Vol(&vessel[cfg.implementation.flowMeterCfg_Vol.vessel]);
    else return NULL;
  }
  
  virtual void init() { }
  virtual void update() = 0;
};


#define MS_TO_MIN(x) 60000*(x);

class flowMeter_Vol : public flowMeter {
  private:
  vessel* vs;
  unsigned long lastVol, lastEvalTime;
  
  public:
  flowMeter_Vol(vessel* v) { vs = v; }
  
  void update() {
    unsigned long evalTime = millis();
    
    if (evalTime - lastEvalTime >= sampleRate) {
      flowRate = round(MS_TO_MIN((float)(vs->getVolume() - lastVol) / (float)(evalTime - lastEvalTime));
      lastVol = vs->getVolume();
      lastEvalTime = evalTime;
    }    
  }
};






