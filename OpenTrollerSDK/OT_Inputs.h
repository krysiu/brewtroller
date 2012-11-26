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
#ifndef OT_Inputs_h
#define OT_Inputs_h

#include <stdint.h>
#include <string.h>
#include <math.h>
#include "Config.h"
#include "HWProfile.h"
#include <WProgram.h>
#include <pin.h>
#include <ModbusMaster.h>
#ifdef TS_ONEWIRE
  #if defined TS_ONEWIRE_GPIO
    #include <OneWire.h>
  #elif defined TS_ONEWIRE_I2C
    #include <DS2482.h>
  #endif
#endif

#define ANALOGIN_NAME_MAXLEN 20

typedef struct calibration_t {
  unsigned int value;
  long actual;
};

typedef enum {
  analogInType_None,
  analogInType_GPIO,
  analogInType_Modbus
} analogInType;

typedef struct analogInCfg_t {
  analogInType type;
  union {
    struct analogInCfg_GPIO_t {
      uint8_t pin;
    } analogInCfg_GPIO;
    struct analogInCfg_Modbus_t {
      uint8_t slaveAddr;
      unsigned int reg;
    } analogInCfg_Modbus;
  } implementation;
  bool calibrate;
  calibration_t calibrations[ANALOG_CALIBRATION_COUNT];
  uint8_t averaging;
};

class calibratedValue {
  private:
  calibration_t * calibrationTable;
  uint8_t count;
  
  public:
  calibratedValue(uint8_t c, calibration_t entries[]);
  ~calibratedValue();
  long compute(unsigned int value);
};

class averagedValue {
  private:
  uint8_t count, index;
  long * values;
  
  public:
  averagedValue(uint8_t c);
  ~averagedValue();
  
  long compute(long value);
};

class analogIn {
  protected:
  long value;
  calibratedValue* cValue;
  averagedValue* aValue;
  
  public:
  analogIn(void);
  ~analogIn();
  static analogIn* create(analogInCfg_t cfg);
  virtual long getValue();
  virtual void setupCalibration(calibratedValue * c);
  virtual void setupAverages(averagedValue * a);
  virtual void init(void);
  virtual void update(void) {}
};

#ifdef ANALOGINPUTS_GPIO
class analogIn_GPIO : public analogIn {
  private:
  uint8_t pin;
  
  public:
  analogIn_GPIO(uint8_t pinNum);
  void update();
  //Utility Functions
  static uint8_t getCount();
  static uint8_t getPin(uint8_t index);
  static char* getName(uint8_t index, char* retString);  
};
#endif

typedef enum {
  tSensorType_None,
  tSensorType_1Wire,
  tSensorType_Modbus
} tSensorType;
  
typedef struct tSensorCfg_t {
  tSensorType type;
  union {
    struct tSensorCfg_1Wire_t {
      byte addr[8];
    } tSensorCfg_1Wire;
    struct tSensorCfg_Modbus_t {
      byte slaveAddr;
      unsigned int reg;
    } tSensorCfg_Modbus;
  } implementation;
};

typedef struct oneWireBusCfg_t {
  boolean parasite;
  boolean crcCheck;
  boolean resLow;
  boolean resHigh;
};

#define BAD_TEMP -2147483648

class tSensor : public analogIn {
  protected:
  static bool unitMetric;
    
  public:
  tSensor(void);
  ~tSensor(void) {}
  static tSensor* create(tSensorCfg_t cfg);
  long getValue();
  static void setUnit(bool unit);
  static bool getUnit() { return unitMetric; }
  virtual void init(void) { };
  virtual void update(void) {}
};

#ifdef TS_ONEWIRE

  #define DS18B20_DELAY { 94, 188, 375, 750 } //9Bit - 12Bit

  class tSensor_1Wire : public tSensor {
    private:
    static unsigned long convStart;
    static unsigned int convDelay;
    static byte resolution;
    static boolean parasitePwr, crcCheck;
    static tSensor_1Wire* sensorHead;
    #if defined TS_ONEWIRE_GPIO
      static OneWire *ds;
    #elif defined TS_ONEWIRE_I2C
      static DS2482 *ds;
    #endif
    byte addr[8];
    tSensor_1Wire* sensorNext;

    void attach(tSensor_1Wire* tsMe);
    void detach(tSensor_1Wire* tsMe, tSensor_1Wire* tsNext);
    boolean validAddr();
    void readTemp();
    static boolean isReady();
    bool matchAddr(byte* scanAddr);
   
    public:
    tSensor_1Wire(byte *tsAddr);
    ~tSensor_1Wire();
    void init();  
    void update();


    
    //Utility (static) functions
    #if defined TS_ONEWIRE_GPIO
      static void setup(OneWire *bus, bool parasite, bool crc, byte res);
    #elif defined TS_ONEWIRE_I2C
      static void setup(DS2482 *bus, bool parasite, bool crc, byte res);
    #endif

    static void scanBus(byte* addrRet, byte limit = 0, bool skipAssigned = true);
  };
#endif

typedef enum {
  TRANSITION_CHANGE = CHANGE,
  TRANSITION_FALLING = FALLING,
  TRANSITION_RISING = RISING
} transitionType;

typedef enum {
  triggerType_None,
  triggerType_GPIO,
  triggerType_Modbus
} triggerType;

typedef struct triggerCfg_t {
  triggerType type;
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
  protected:
  transitionType mode;
  boolean value, lastValue;
  
  public:
  static trigger* create(triggerCfg_t cfg);
  virtual boolean getState();
  virtual void init();
  virtual void update();
};



class trigger_GPIO : public trigger {
  private:
  pin trigPin;
  
  public:
  trigger_GPIO(byte pinNum, transitionType m);
  void update();
};


class trigger_Modbus : public trigger {
  private:
  ModbusMaster slave;
  unsigned int dataAddr;
    
  public:
  trigger_Modbus(byte sAddr, unsigned int dAddr, transitionType m);
  void update();
};

#endif
