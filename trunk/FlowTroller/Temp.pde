/*  
   Copyright (C) 2009, 2010 Matt Reba, Jermeiah Dillingham

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

#include "Config.h"
 
void tempInit() {
  pinMode(SPI_CLK_PIN, OUTPUT);
  //pinMode(SPI_MOSI_PIN, OUTPUT);
  pinMode(SPI_MISO_PIN, INPUT);
  pinMode(TEMP_PIN, OUTPUT);
  //Disable temp chip by setting SS HIGH
  digitalWrite(TEMP_PIN, HIGH);
}

void updateTemps() {
  #ifdef USEMETRIC
    temp = read_temp(TEMP_PIN, 1, TEMP_ERROR, TEMP_SAMPLES);
  #else
    temp = read_temp(TEMP_PIN, 1, TEMP_ERROR, TEMP_SAMPLES);
  #endif
}


/* Create a function read_temp that returns an unsigned int
   with the temp from the specified pin (if multiple MAX6675).  The
   function will return 9999 if the TC is open.
  
   Usage: read_temp(int pin, int type, int error)
     pin: the CS pin of the MAX6675
     type: 0 for ˚F, 1 for ˚C
     error: error compensation in digital counts
     samples: number of measurement samples (max:10)
*/
float read_temp(int pin, int type, int error, int samples) {
  unsigned int value = 0;
  int error_tc;
  float temp;
  
  for (int i=samples; i>0; i--){
    digitalWrite(pin,LOW); // Enable device

    /* Cycle the clock for dummy bit 15 */
    digitalWrite(SPI_CLK_PIN,HIGH);
    digitalWrite(SPI_CLK_PIN,LOW);

    /* Read bits 14-3 from MAX6675 for the Temp
	 Loop for each bit reading the value and
	 storing the final value in 'temp'
    */
    for (int i=11; i>=0; i--){
	digitalWrite(SPI_CLK_PIN,HIGH);  // Set Clock to HIGH
	value += digitalRead(SPI_MISO_PIN) << i;  // Read data and add it to our variable
	digitalWrite(SPI_CLK_PIN,LOW);  // Set Clock to LOW
    }
  
    /* Read the TC Input inp to check for TC Errors */
    digitalWrite(SPI_CLK_PIN,HIGH); // Set Clock to HIGH
    error_tc = digitalRead(SPI_MISO_PIN); // Read data
    digitalWrite(SPI_CLK_PIN,LOW);  // Set Clock to LOW
  
    digitalWrite(pin, HIGH); //Disable Device
  }
  
  value = value/samples;  // Divide the value by the number of samples to get the average
  
  /*
     Keep in mind that the temp that was just read is on the digital scale
     from 0˚C to 1023.75˚C at a resolution of 2^12.  We now need to convert
     to an actual readable temperature (this drove me nuts until I figured
     this out!).  Now multiply by 0.25.  I tried to avoid float math but
     it is tough to do a good conversion to ˚F.  THe final value is converted
     to an int and returned at x10 power.
    
   */
  
  value = value + error;  // Insert the calibration error value
  temp = (value*0.25);
  
  if(type == 0) {  // Request temp in ˚F
    temp = (temp * (9.0/5.0)) + 32.0;  // Convert value to ˚F (ensure proper floats!)
  }
  
  /* Output 9999 if there is a TC error, otherwise return 'temp' */
  if(error_tc != 0) { return 9999; } else { return temp; }
}

