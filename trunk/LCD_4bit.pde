#include <LiquidCrystal.h>

const byte LCD_DELAY_CURSOR = 40;
const byte LCD_DELAY_CHAR = 40;

// LiquidCrystal display with:
// rs on pin 17	  (LCD pin 4 ) aka DI
// rw on pin 18	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)
LiquidCrystal lcd(17, -1, 19, 20, 21, 22, 23);

void initLCD(){}

void printLCD(byte iRow, byte iCol, char sText[]){
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

char printLCDPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
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

void lcdSetCustChar(byte slot, byte charDef[8]) {
  lcd.command(64 | (slot << 3));
  for(byte i = 0; i < 8; i++) {
    lcd.write(charDef[i]);
    delayMicroseconds(LCD_DELAY_CHAR);
  }
  lcd.command(B10000000);
}

void lcdWriteCustChar(byte iRow, byte iCol, byte slot) {
  lcd.setCursor(iCol, iRow);
  delayMicroseconds(LCD_DELAY_CURSOR);
  lcd.write(slot);
  delayMicroseconds(LCD_DELAY_CHAR);
}
