#include <OneWire.h>

OneWire ds(tempPin);

int get_temp(int unit, byte* addr) //Unit 1 for F and 0 for C
{
  byte present = 0;
  byte i;
  byte data[12];
 
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
  delay(750);     // maybe 750ms is enough, maybe not
   present = ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad
  for ( i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }
  int temp;
  temp = data[0];      // load all 8 bits of the LSB
   
  if (data[1] > 0x80){  // sign bit set, temp is negative
    temp = !temp + 1; //two's complement adjustment
    temp = temp * -1; //flip value negative.
  }
   int cpc;
   int cr = data[6];
   cpc = data[7];

   temp = temp >> 1;  // Truncate by dropping bit zero for hi-rez forumua
   temp = temp - (float)0.25 + (cpc - cr)/(float)cpc;
   if(unit == 1) temp= ((temp * 9) / 5.0) + 32; 
return temp;
}

void getDSAddr(byte addrRet[8]){
  ds.reset_search();
  ds.search(addrRet);
}

void setDS9bit(void){
  ds.reset();
  ds.write(0xCC);
  ds.write(0x4E);
  ds.write(00000000);
  ds.write(00000000);
  ds.write(00000000);
}
