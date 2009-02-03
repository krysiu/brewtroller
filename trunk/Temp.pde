#include <OneWire.h>
OneWire ds(tempPin);

float temp;
int rawtemp;

float get_temp(int unit, byte* addr) //Unit 1 for F and 0 for C
{
  byte present = 0;
  byte i;
  byte data[12];
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
  delay(750);               // we have to wait 750ms for the DS18S20's
  present = ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad
  for ( i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }
  if ( addr[0] != 0x28) {
  rawtemp = (data[1] << 8) + data[0];
  temp = (float)rawtemp * 0.5;
  if (unit == 1) temp= (temp * 1.8) + 32.0;
  return temp;
 } else {
  rawtemp = (data[1] << 8) + data[0]; 
  temp = (float)rawtemp * 0.0625;
  if (unit == 1) temp= (temp * 1.8) + 32.0;
  return temp;
  }
}

void getDSAddr(byte addrRet[8]){
  ds.reset_search();
  ds.search(addrRet);
}

void setDS9bit(void) {
  ds.reset();
  ds.skip();    
  ds.write(0x4E);  
  ds.write(0x4B);    // default value of TH reg (user byte 1)
  ds.write(0x46);    // default value of TL reg (user byte 2)
  //ds.write(0x7F);    // 12-bit
  //ds.write(0x5F);    // 11-bit
  //ds.write(0x3F);    // 10-bit
  ds.write(0x1F);    // 9-bit
}

void convertAll() {
  ds.reset();
  ds.skip();
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
}

float read_temp(int unit, byte* addr) //Unit 1 for F and 0 for C
{
  byte i;
  byte data[12];
  ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad
  for ( i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }
  if ( addr[0] != 0x28) {
  rawtemp = (data[1] << 8) + data[0];
  temp = (float)rawtemp * 0.5;
  if (unit == 1) temp= (temp * 1.8) + 32.0;
  return temp;
 } else {
  rawtemp = (data[1] << 8) + data[0]; 
  temp = (float)rawtemp * 0.0625;
  if (unit == 1) temp= (temp * 1.8) + 32.0;
  return temp;
  }
}
