#include <LiquidCrystal.h>

#define LCD_DELAY_CURSOR 40
#define LCD_DELAY_CHAR 40

// LiquidCrystal display with:
// rs on pin 17	  (LCD pin 4 ) aka DI
// rw on pin 18	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)
LiquidCrystal lcd(17, 18, 19, 20, 21, 22, 23);

void initLCD(){
}


void printLCD(int iRow, int iCol, char sText[]){
 lcd.setCursor(iCol, iRow);
 delayMicroseconds(LCD_DELAY_CURSOR);
 int i = 0;
 while (sText[i] != 0)
 {
   lcd.print(sText[i++]);
   delayMicroseconds(LCD_DELAY_CHAR);
 }
} 

void clearLCD(){
lcd.clear();
}

char printLCDPad(int iRow, int iCol, char sText[], int length, char pad) {
 lcd.setCursor(iCol, iRow);
 delayMicroseconds(LCD_DELAY_CURSOR);
 for (int i=0; i < length-strlen(sText) ; i++) {
   lcd.print(pad);
   delayMicroseconds(LCD_DELAY_CHAR);
 }
 int i = 0;
 while (sText[i] != 0)
 {
   lcd.print(sText[i++]);
   delayMicroseconds(LCD_DELAY_CHAR);
 }
}  

void ftoa(float val, char retStr[], int precision) {
  itoa(val, retStr, 10);  
  if(val < 0) val = -val;
  if( precision > 0) {
    strcat(retStr, ".");
    unsigned int mult = 1;
    while(precision--) mult *=10;
    unsigned int frac = (val - int(val)) * mult;
    char buf[6];
    strcat(retStr, itoa(frac, buf, 10));
  }
}
