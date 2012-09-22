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

typedef struct tSensorCfg_t {
  typedef enum {
    tSensorType_None,
    tSensorType_1Wire,
    tSensorType_Modbus
  } tSensorType;
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

class tSensor {
  private:
  int temperature;
  static boolean unitMetric;
  
  public:
  tSensor(void) {
    temperature = BAD_TEMP;
  }
  
  static tSensor* create(tSensorCfg_t cfg) {
    if (cfg.tSensorType == tSensorType_1Wire) return new tSensor_1Wire(cfg.implementation.tSensorCfg_1Wire.addr);
    //else if (cfg.tSensorType == tSensorType_Modbus) return new tSensor_Modbus(cfg.implementation.tSensorCfg_Modbus.slaveAddr, cfg.implementation.tSensorCfg_Modbus.reg);
    else return NULL;
  }
  
  int getValue() {
    if (tSensor::unitMetric) return temperature;
    else return (temperature * 9 / 5 + 32);
  }
  
  void setUnit(boolean unit) { tSensor::unitMetric = unit; }
  
  virtual void init(void) { };
  virtual void update(void) = 0;
};

#ifdef TS_ONEWIRE

  #define DS18B20_DELAY { 94, 188, 375, 750 } //9Bit - 12Bit

  class tSensor_1Wire : public tSensor {
    private:
    byte addr[8];
    static unsigned long convStart;
    static unsigned int convDelay;
    static byte resolution, devCount, readCount;
    static boolean parasitePwr, crcCheck;
    
    public:
    tSensor_1Wire(byte tsAddr[8]) {
      memcpy(addr, tsAddr, 8);
      devCount++;
    }
    
    void setBusCfg(oneWireBusCfg_t busCfg) {
      tSensor_1Wire::parasitePwr = busCfg.parasite;
      tSensor_1Wire::crcCheck = busCfg.crcCheck;
      tSensor_1Wire::resolution = (busCfg.resHigh << 1 | busCfg.resLow);
      unsigned int  resDelay[] = DS18B20_DELAY;
      tSensor_1Wire::convDelay = resDelay[tSensor_1Wire::resolution];
    }
    
    void init() {
      ds.reset();
      ds.select(addr);
      ds.write(0x4E, tSensor_1Wire::parasitePwr); //Write to scratchpad
      ds.write(0x4B, tSensor_1Wire::parasitePwr); //Default value of TH reg (user byte 1)
      ds.write(0x46, tSensor_1Wire::parasitePwr); //Default value of TL reg (user byte 2)
      
      ds.write((tSensor_1Wire::resolution << 5) | B00011111, tSensor_1Wire::parasitePwr); //Config Reg (12-bit)
      ds.reset();
      ds.skip();
      ds.write(0x48, tSensor_1Wire::parasitePwr); //Copy scratchpad to EEPROM
    }
  };
  
  void update() {
    if (tSensor_1Wire::readCount == 0) {
      ds.reset();
      ds.skip();
      ds.write(0x44, tSensor_1Wire::parasitePwr); //Start conversion
      tSensor_1Wire::convStart = millis();
      tSensor_1Wire::readCount = tSensor_1Wire::devCount;
    } else if (isReady()) {
      if (validAddr()) temperature = read_temp(); else temperature = BAD_TEMP;
      tSensor_1Wire::readCount--;
    }
  }

  boolean isReady() {
    if (tSensor_1Wire::parasitePwr == 0) { //Poll if parasite power is disabled
      if (ds.read() == 0xFF) return 1;
    }
    if (millis() - tSensor_1Wire::convStart >= tSensor_1Wire::convDelay) return 1;
    return 0;
  }
  
  boolean validAddr(byte* addr) {
    if (addr[0] != 0x28 && addr[0] != 0x10) return 0; //Verify the family code
    //Could do a CRC check on the Address
    return 1;
  }
  
//Returns Int representing hundreths of degree
  int read_temp() {
    long tempOut;
    byte data[9];
    ds.reset();
    ds.select(addr);   
    ds.write(0xBE, tSensor_1Wire::parasitePwr); //Read Scratchpad
    if (tSensor_1Wire::crcCheck) {
      for (byte i = 0; i < 2; i++) data[i] = ds.read();
    }
    else {
      for (byte i = 0; i < 9; i++) data[i] = ds.read();
      if (ds.crc8( data, 8) != data[8]) return BAD_TEMP;
    }

    tempOut = (data[1] << 8) + data[0];
    
    if ( addr[0] == 0x10) tempOut = tempOut * 50; //9-bit DS18S20
    else tempOut = tempOut * 25 / 4; //12-bit DS18B20, etc.
    return int(tempOut);  
  }
#endif











//TODO scan function update

  void getDSAddr(addrRet[8]){
    byte scanAddr[8];
    ds.reset_search();
    byte limit = 0;
    //Scan at most 20 sensors (In case the One Wire Search loop issue occurs)
    while (limit <= 20) {
      if (!ds.search(scanAddr)) {
        //No Sensor found, Return
        ds.reset_search();
        return;
      }
      if (
          scanAddr[0] == 0x28 ||  //DS18B20
          scanAddr[0] == 0x10     //DS18S20
         ) 
      {
        boolean found = 0;
        for (byte i = 0; i <  NUM_TS; i++) {
          boolean match = 1;
          for (byte j = 0; j < 8; j++) {
            //Try to confirm a match by checking every byte of the scanned address with those of each sensor.
            if (scanAddr[j] != tSensor[i][j]) {
              match = 0;
              break;
            }
          }
          if (match) { 
            found = 1;
            break;
          }
        }
        if (!found) {
          for (byte k = 0; k < 8; k++) addrRet[k] = scanAddr[k];
          return;
        }
      }
      limit++;
    }      
  }

//TO DO implement averaging logic

#if defined MASH_AVG
void mashAvg() {
  byte sensorCount = 1;
  unsigned long avgTemp = temp[TS_MASH];
  #if defined MASH_AVG_AUX1
    if (temp[TS_AUX1] != BAD_TEMP) {
      avgTemp += temp[TS_AUX1];
      sensorCount++;
    }
  #endif
  #if defined MASH_AVG_AUX2
    if (temp[TS_AUX2] != BAD_TEMP) {
      avgTemp += temp[TS_AUX2];
      sensorCount++;
    }
  #endif
  #if defined MASH_AVG_AUX3
    if (temp[TS_RIMS] != BAD_TEMP) {
      avgTemp += temp[TS_RIMS];
      sensorCount++;
    }
  #endif
  temp[TS_MASH] = avgTemp / sensorCount;
}
#endif


