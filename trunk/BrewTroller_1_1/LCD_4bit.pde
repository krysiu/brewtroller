#include <LiquidCrystal.h>

//const byte LCD_DELAY_CURSOR = 60;
//const byte LCD_DELAY_CHAR = 60;

// LiquidCrystal display with:
// rs on pin 17	  (LCD pin 4 ) aka DI
// rw on pin 18	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)

#ifdef BTBOARD_3
LiquidCrystal lcd(18, 6, 19, 20, 21, 22, 23);
#else
LiquidCrystal lcd(17, 27, 19, 20, 21, 22, 23);
#endif

void initLCD(){

}

void printLCD(byte iRow, byte iCol, char sText[]){
 lcd.setCursor(iCol, iRow);
 lcd.print(sText);
} 

//Version of PrintLCD reading from PROGMEM
void printLCD_P(byte iRow, byte iCol, const char *sText){
 lcd.setCursor(iCol, iRow);
 while (pgm_read_byte(sText) != 0) lcd.print(pgm_read_byte(sText++)); 
} 

void clearLCD(){ lcd.clear(); }
//void clearFieldLCD(byte row, byte col, byte num) { for (int i = col; i < col + num; i++) printLCD_P(row, i, SPACE); }

void printLCDCenter(byte iRow, byte iCol, char sText[], byte fieldWidth){
 printLCDRPad(iRow, iCol, "", fieldWidth, ' ');
 if (strlen(sText) < fieldWidth) lcd.setCursor(iCol + ((fieldWidth - strlen(sText)) / 2), iRow);
 else lcd.setCursor(iCol, iRow);
 lcd.print(sText);
} 

char printLCDLPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
 lcd.setCursor(iCol, iRow);
 if (strlen(sText) < length) {
   for (byte i=0; i < length-strlen(sText); i++) lcd.print(pad);
 }
 lcd.print(sText);
}  

char printLCDRPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
 lcd.setCursor(iCol, iRow);
 lcd.print(sText);
 if (strlen(sText) < length) {
   for (byte i=0; i < length-strlen(sText) ; i++) lcd.print(pad);
 }
}  

void lcdSetCustChar_P(byte slot, const byte *charDef) {
  lcd.command(64 | (slot << 3));
  for (byte i = 0; i < 8; i++) lcd.write(pgm_read_byte(charDef++));
  lcd.command(B10000000);
}

void lcdWriteCustChar(byte iRow, byte iCol, byte slot) {
  lcd.setCursor(iCol, iRow);
  lcd.write(slot);
}
