void initLCD(){
  Serial.begin(9600);
}

void printLCD(int iRow, int iCol, char sText[]){
  goTo(iRow * 20 + iCol);
  delay(100);
  Serial.print(sText);
  delay(500);
}

//Sparkfun 20x4 SerialLCD Functions

void goTo(int position) { //position = line 1: 0-19, line 2: 20-39, etc, 79+ defaults back to 0
if (position<20){ Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+128), BYTE);    //position
}else if (position<40){Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+128+64-20), BYTE);    //position 
}else if (position<60){Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+128+20-40), BYTE);    //position
}else if (position<80){Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+128+84-60), BYTE);    //position              
} else { goTo(0); }
}
void clearLCD(){
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(0x01, BYTE);   //clear command.
}
void backlightOn(){  //turns on the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(157, BYTE);    //light level.
}
void backlightOff(){  //turns off the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(128, BYTE);     //light level for off.
}
void backlight50(){  //sets the backlight at 50% brightness
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(143, BYTE);     //light level for off.
}
void serCommand(){   //a general function to call the command flag for issuing all other commands   
  Serial.print(0xFE, BYTE);
}
