#include <OneWire.h>

OneWire ds(tempPin); // Current pin that DS18's are located at

int get_temp(int unit, byte* addr) //Unit 1 for F and 2 for C
{
  byte present = 0;
  byte i;
  byte data[12];
 
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
  delay(750);     // wait 750ms
   present = ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad
  for ( i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }
  int temp;
  float ftemp;
  float ctemp;
  float rtemp;
  
  temp = data[0];      // load all 8 bits of the LSB
   
  if (data[1] > 0x80){  // sign bit set, temp is negative
    temp = !temp + 1; //two's complement adjustment
    temp = temp * -1; //flip value negative.
  }
   int cpc;
   int cr = data[6];
   cpc = data[7];

   temp = temp >> 1;  // Truncate by dropping bit zero for hi-rez forumua
   ftemp = temp - (float)0.25 + (cpc - cr)/(float)cpc;
   ctemp = ftemp;
   ftemp = ((ftemp * 9) / 5.0) + 32; //C -> F
if (unit == 1) rtemp = ftemp; 
if (unit == 2) rtemp = ctemp; 
return rtemp;
}

void getDSAddr(byte addrRet[8]){  // search for new attached DS18 sensor
byte i;
byte addr[8];

  if ( !ds.search(addr)) {  // Lets check the bus to see if anything new is out there
  ds.reset_search();  // Nothing found lets reset and try again
  for( i = 0; i < 8; i++) 
 addrRet[i] = addr[i]; // Load found sensor ID into the return variable
 }
}
