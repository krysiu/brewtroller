#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 17/18	  (LCD pin 4 ) aka DI
// rw on pin 27	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)

#ifdef BTBOARD_3
  LiquidCrystal lcd(18, 19, 20, 21, 22, 23);
#else
  LiquidCrystal lcd(17, 19, 20, 21, 22, 23);
#endif 

void initLCD(){
  lcd.begin(20, 4);
}

void printLCD(byte iRow, byte iCol, char sText[]){
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
}  

//Version of PrintLCD reading from PROGMEM
void printLCD_P(byte iRow, byte iCol, const char *sText){
  lcd.setCursor(iCol, iRow);
  while (pgm_read_byte(sText) != 0) {
    lcd.print(pgm_read_byte(sText++)); 
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
} 

void clearLCD(){ lcd.clear(); }

void printLCDCenter(byte iRow, byte iCol, char sText[], byte fieldWidth){
  printLCDRPad(iRow, iCol, "", fieldWidth, ' ');
  if (strlen(sText) < fieldWidth) lcd.setCursor(iCol + ((fieldWidth - strlen(sText)) / 2), iRow);
  else lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif

  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }

} 

char printLCDLPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  if (strlen(sText) < length) {
    for (byte i=0; i < length-strlen(sText); i++) {
      lcd.print(pad);
      #ifdef LCD_DELAY_CHAR
        delayMicroseconds(LCD_DELAY_CHAR);
      #endif
    }
  }
  
  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }

}  

char printLCDRPad(byte iRow, byte iCol, char sText[], byte length, char pad) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif

  int i = 0;
  while (sText[i] != 0)  {
    lcd.print(sText[i++]);
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
  
  if (strlen(sText) < length) {
    for (byte i=0; i < length-strlen(sText) ; i++) {
      lcd.print(pad);
      #ifdef LCD_DELAY_CHAR
        delayMicroseconds(LCD_DELAY_CHAR);
      #endif
    }
  }
}  

void lcdSetCustChar_P(byte slot, const byte *charDef) {
  lcd.command(64 | (slot << 3));
  for (byte i = 0; i < 8; i++) {
    lcd.write(pgm_read_byte(charDef++));
    #ifdef LCD_DELAY_CHAR
      delayMicroseconds(LCD_DELAY_CHAR);
    #endif
  }
  lcd.command(B10000000);
}

void lcdWriteCustChar(byte iRow, byte iCol, byte slot) {
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  lcd.write(slot);
}
