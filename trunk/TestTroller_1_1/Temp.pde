#include <OneWire.h>
//One Wire Bus on 
OneWire ds(TEMP_PIN);

void getDSAddr(byte addrRet[8]){
  ds.reset_search();

  if (!ds.search(addrRet)) {
    //No Sensor found, Return
    ds.reset_search();
    return;
  }
  return;
}

void convertAll() {
  ds.reset();
  ds.skip();
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
}

float read_temp(byte* addr) {
  float temp;
  int rawtemp;
  byte data[12];
  ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad
  for (byte i = 0; i < 9; i++) data[i] = ds.read();
  if ( OneWire::crc8( data, 8) != data[8]) return -1;
  
  rawtemp = (data[1] << 8) + data[0];
  if ( addr[0] != 0x28) temp = (float)rawtemp * 0.5; else temp = (float)rawtemp * 0.0625;
  #ifdef USEMETRIC
    return temp;  
  #else
    return (temp * 1.8) + 32.0;
  #endif
}
