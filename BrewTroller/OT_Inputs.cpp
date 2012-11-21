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

#include "OT_Inputs.h"

calibratedValue::calibratedValue(uint8_t c, calibration_t entries[]) {
  count = c;
  calibrationTable = new calibration_t[count];
  memcpy(calibrationTable, entries, sizeof(calibration_t) * count);
}
calibratedValue::~calibratedValue() { delete calibrationTable; }

long calibratedValue::compute(unsigned int value) {
  long retValue;
  uint8_t upperCal = 0;
  uint8_t lowerCal = 0;
  uint8_t lowerCal2 = 0;
  for (uint8_t i = 0; i < count; i++) {
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
  else if (value > calibrationTable[upperCal].value && calibrationTable[lowerCal].value > calibrationTable[lowerCal2].value) {
    retValue = round((float) (value - calibrationTable[lowerCal].value) / (float)(calibrationTable[lowerCal].value - calibrationTable[lowerCal2].value) * (calibrationTable[lowerCal].actual - calibrationTable[lowerCal2].actual)) + calibrationTable[lowerCal].actual;
  }
  
  //If read value exceeds all calibrations and only one lower calibration point is available plot value based on zero and closest lesser value
  else if (value > calibrationTable[upperCal].value) {
    retValue = round((float) (value - calibrationTable[lowerCal].value) / (float)(calibrationTable[lowerCal].value) * calibrationTable[lowerCal].actual) + calibrationTable[lowerCal].actual;
  }
  
  //If read value is less than all calibrations plot value between zero and closest greater value
  else if (value < calibrationTable[lowerCal].value) {
    retValue = round((float) value / (float) calibrationTable[upperCal].value * calibrationTable[upperCal].actual);
  }
  
  //Otherwise plot value between lower and greater calibrations
  else {
    retValue = round((float) (value - calibrationTable[lowerCal].value) / (float) (calibrationTable[upperCal].value - calibrationTable[lowerCal].value) * (calibrationTable[upperCal].actual - calibrationTable[lowerCal].actual)) + calibrationTable[lowerCal].actual;
  }
}


averagedValue::averagedValue(uint8_t c) {
  count = c;
  values = new long[count];
}
averagedValue::~averagedValue() { delete values; }

 long averagedValue::compute(long value) {
   long retValue = 0;
   values[index++] = value;
   if (index == count) { index = 0; }
   for (uint8_t i = 0; i < count; i++) { retValue += values[i]; }
   return retValue / count;
 }

analogIn::analogIn(void) {
  cValue = NULL;
  aValue = NULL;
}

analogIn::~analogIn() { 
  if (cValue) delete cValue; 
  if (aValue) delete aValue;
}

static analogIn::analogIn* create(analogInCfg_t cfg) {
  analogIn* retObj;
  #ifdef ANALOGINPUTS_GPIO
  if (cfg.type == analogInType_GPIO) { retObj = new analogIn_GPIO(cfg.implementation.analogInCfg_GPIO.pin); }
  #else
  //Temporary placeholder until other objects exist
  //Force to false
  if (0) {}
  #endif
  //else if (cfg.type ==  analogInType_Modbus) { retObj = new analogIn_Modbus(cfg.implementation.analogInCfg_Modbus.slaveAddr, cfg.implementation.analogInCfg_Modbus.reg); }
  else { retObj = NULL; }

  if (retObj) {
    if (cfg.calibrate) { retObj->setupCalibration(new calibratedValue(ANALOG_CALIBRATION_COUNT, cfg.calibrations)); }
    if (cfg.averaging) { retObj->setupAverages(new averagedValue(cfg.averaging)); }
  }
  
  return retObj;
}

long analogIn::getValue() { return value; }
void analogIn::setupCalibration(calibratedValue * c) { cValue = c; }
void analogIn::setupAverages(averagedValue * a) { aValue = a; }
void analogIn::init(void) { }

#ifdef ANALOGINPUTS_GPIO
analogIn_GPIO::analogIn_GPIO(uint8_t pinNum) { pin = pinNum; }

void analogIn_GPIO::update() {
  unsigned int newValue = analogRead(pin);
  if (cValue) newValue = cValue->compute(newValue);
  if (aValue) newValue = aValue->compute(newValue);
  value = newValue;
} 

//Utility Functions
uint8_t analogIn_GPIO::getCount() { return ANALOGINPUTS_GPIO_COUNT; }
uint8_t analogIn_GPIO::getPin(uint8_t index) {
  if (index < ANALOGINPUTS_GPIO_COUNT) {
    uint8_t pins[] = ANALOGINPUTS_GPIO_PINS;
    return pins[index];
  }
  return 255;
}

char* analogIn_GPIO::getName(uint8_t index, char* retString) {
  if (index < ANALOGINPUTS_GPIO_COUNT) {
    char names[] = ANALOGINPUTS_GPIO_NAMES;
    char* pos = names;
    for (uint8_t i = 0; i <= index; i++) {
      strlcpy(retString, pos, ANALOGIN_NAME_MAXLEN);
      pos += strlen(retString) + 1;
    }
  }
  else retString[0] = '\0';
  return retString;
}
#endif

tSensor::tSensor(void) { value = BAD_TEMP; }

tSensor* tSensor::create(tSensorCfg_t cfg) {
  if (cfg.type == tSensorType_1Wire) return new tSensor_1Wire(cfg.implementation.tSensorCfg_1Wire.addr);
  //else if (cfg.type == tSensorType_Modbus) return new tSensor_Modbus(cfg.implementation.tSensorCfg_Modbus.slaveAddr, cfg.implementation.tSensorCfg_Modbus.reg);
  else return NULL;
}

long tSensor::getValue() { return ((tSensor::unitMetric || value == BAD_TEMP) ? value : (value * 9 / 5 + 3200)); }
void tSensor::setUnit(bool unit) { tSensor::unitMetric = unit; }
bool tSensor::unitMetric = 0;

tSensor_1Wire::tSensor_1Wire(byte *tsAddr) {
  sensorNext = NULL;
  memcpy(addr, tsAddr, 8);
  if (tSensor_1Wire::sensorHead) { tSensor_1Wire::sensorHead->attach(this); }
  else { tSensor_1Wire::sensorHead = this; }
}

tSensor_1Wire::~tSensor_1Wire() {
  if (tSensor_1Wire::sensorHead == this) {  tSensor_1Wire::sensorHead = sensorNext; }
  else { tSensor_1Wire::sensorHead->detach(this, sensorNext); }
}
  
void tSensor_1Wire::init() {
  ds->reset();
  ds->select(addr);
  ds->write(0x4E, tSensor_1Wire::parasitePwr); //Write to scratchpad
  ds->write(0x4B, tSensor_1Wire::parasitePwr); //Default value of TH reg (user byte 1)
  ds->write(0x46, tSensor_1Wire::parasitePwr); //Default value of TL reg (user byte 2)
  
  ds->write((tSensor_1Wire::resolution << 5) | B00011111, tSensor_1Wire::parasitePwr); //Config Reg (12-bit)
  ds->reset();
  ds->select(addr);
  ds->write(0x48, tSensor_1Wire::parasitePwr); //Copy scratchpad to EEPROM
}

void tSensor_1Wire::update() {
  if (!tSensor_1Wire::sensorHead) { return; }
  if (tSensor_1Wire::convStart) {
    if (!tSensor_1Wire::isReady()) { return; }
    //Update Sensor Chain
    tSensor_1Wire::sensorHead->readTemp();
  }
  //Initialize Conversion
  ds->reset();
  ds->skip();
  ds->write(0x44, tSensor_1Wire::parasitePwr); //Start conversion
  tSensor_1Wire::convStart = millis();
}

boolean tSensor_1Wire::isReady() {
  if (tSensor_1Wire::parasitePwr == 0) { //Poll if parasite power is disabled
    if (ds->read() == 0xFF) return 1;
  }
  if (millis() - tSensor_1Wire::convStart >= tSensor_1Wire::convDelay) return 1;
  return 0;
}

boolean tSensor_1Wire::validAddr() {
  if (addr[0] != 0x28 && addr[0] != 0x10) return 0; //Verify the family code
  if(ds->crc8(addr, 7) != addr[7]) return 0; //CRC Error
  return 1;
}

//Returns Int representing hundreths of degree
void tSensor_1Wire::readTemp() {
  long tempOut = 0;
  if (!validAddr()) {
    tempOut = BAD_TEMP;
  }
  else {
    byte data[9];
    ds->reset();
    ds->select(addr);
    ds->write(0xBE, tSensor_1Wire::parasitePwr); //Read Scratchpad
    if (tSensor_1Wire::crcCheck) {
      for (byte i = 0; i < 9; i++) data[i] = ds->read();
      if (ds->crc8(data, 8) != data[8]) {
        tempOut = BAD_TEMP;
      }
    }
    else {
      for (byte i = 0; i < 2; i++) data[i] = ds->read();
    }
    if (tempOut != BAD_TEMP) {
      tempOut = (data[1] << 8) + data[0];
      if ( addr[0] == 0x10) tempOut = tempOut * 50; //9-bit DS18S20
      else tempOut = tempOut * 25 / 4; //12-bit DS18B20, etc.
    }
  }
  //Dallas/Maxim takes Brooks law literally, throw out the first reading
  if (value != BAD_TEMP || tempOut != 8500) value = tempOut;
  if (sensorNext) sensorNext->readTemp();
}

void  tSensor_1Wire::scanBus(byte* addrRet, byte limit, bool skipAssigned){
  byte scanAddr[8];
  ds->reset_search();
  byte count = 0;
  //Optional limit in case the One Wire Search loop issue occurs)
  while (count <= limit) {
    if (limit) count++;
    if (!ds->search(scanAddr)) { break; } //No more sensors
    if (scanAddr[0] != 0x28 && scanAddr[0] != 0x10) { continue; } //Skip if not !DS18B20 && !DS18S20
    if (skipAssigned) { if (sensorHead) { if (sensorHead->matchAddr(scanAddr)) { continue; } } } //Skip if already in use
    //Passed all tests
    memcpy(addrRet, scanAddr, 8);
    break;
  }
  ds->reset_search();
}

bool tSensor_1Wire::matchAddr(byte* scanAddr) {
  if (!memcmp(scanAddr, addr, 8)) { return 1; } //Matched me
  else if(sensorNext) { return sensorNext->matchAddr(scanAddr); }
  else { return 0; } //End of the chain, not found
}

void tSensor_1Wire::attach(tSensor_1Wire* tsNew) {
  if (sensorNext) { sensorNext->attach(tsNew); }
  else { sensorNext = tsNew; }
}

void tSensor_1Wire::detach(tSensor_1Wire* tsDel, tSensor_1Wire* tsNext) {
  if (!sensorNext) {  } //Tried to delete a sensor not in the chain
  else if (sensorNext == tsDel) { sensorNext = tsNext; } //Matched next link in chain so replace
  else { sensorNext->detach(tsDel, tsNext); }
}

#if defined TS_ONEWIRE_GPIO
  void tSensor_1Wire::setup(OneWire *bus, bool parasite, bool crc, byte res) {
    tSensor_1Wire::ds = bus;
    tSensor_1Wire::parasitePwr = parasite;
    tSensor_1Wire::crcCheck = crc;
    tSensor_1Wire::resolution = res;
    unsigned int  resDelay[] = DS18B20_DELAY;
    tSensor_1Wire::convDelay = resDelay[tSensor_1Wire::resolution];
  }
  OneWire *tSensor_1Wire::ds = NULL;
#elif defined TS_ONEWIRE_I2C
  void tSensor_1Wire::setup(DS2482 *bus, bool parasite, bool crc, byte res) {
    tSensor_1Wire::ds = bus;
    tSensor_1Wire::parasitePwr = parasite;
    tSensor_1Wire::crcCheck = crc;
    tSensor_1Wire::resolution = res;
    unsigned int  resDelay[] = DS18B20_DELAY;
    tSensor_1Wire::convDelay = resDelay[tSensor_1Wire::resolution];
  }
  DS2482 *tSensor_1Wire::ds = NULL;
#endif

unsigned long tSensor_1Wire::convStart = 0;
unsigned int tSensor_1Wire::convDelay = 0;
byte tSensor_1Wire::resolution = 0;
boolean tSensor_1Wire::parasitePwr = 0;
boolean tSensor_1Wire::crcCheck = 0;
tSensor_1Wire* tSensor_1Wire::sensorHead = NULL;

trigger* trigger::create(triggerCfg_t cfg) {
  if(cfg.type == triggerType_GPIO) return new trigger_GPIO(cfg.implementation.triggerCfg_GPIO.pin, cfg.implementation.triggerCfg_GPIO.mode);
  else return NULL;
}

boolean trigger::getState() {
  boolean retValue = 0;
  switch (mode) {
    case TRANSITION_CHANGE:
      if (lastValue != value) { retValue = 1; }
      break;
    case TRANSITION_FALLING:
      retValue = ~value;
      break;
    case TRANSITION_RISING:
      retValue = value;
      break;
  }
  lastValue = value;
  return retValue;
}

void trigger::init() {}
void trigger::update() {}




trigger_GPIO::trigger_GPIO(byte pinNum, transitionType m) {
  mode = m;
  trigPin.setup(pinNum, INPUT);
}

void trigger_GPIO::update() { value = trigPin.get(); }


trigger_Modbus::trigger_Modbus(byte sAddr, unsigned int dAddr, transitionType m) {
  slave = ModbusMaster(RS485_SERIAL_PORT, sAddr);
  #ifdef RS485_RTS_PIN
    slave.setupRTS(RS485_RTS_PIN);
  #endif
  slave.begin(RS485_BAUDRATE, RS485_PARITY);
  //Modbus Coil Register index starts at 1 but is transmitted with a 0 index
  dataAddr = dAddr - 1;
}

void trigger_Modbus::update() {
  slave.readDiscreteInputs(dataAddr, 1);
  value = (slave.getResponseBuffer(0) & 1);
}
