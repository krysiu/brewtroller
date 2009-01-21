#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 7	  (LCD pin 4 ) aka DI
// rw on pin 6	  (LCD pin 5)
// enable on pin 5 (LCD pin 6)
// d4, d5, d6, d7 on pins 9, 10, 11, 12  (LCD pins 11-14)

LiquidCrystal lcd(17, 18, 19, 20, 21, 22, 23);

void initLCD(){

}

void printLCD(int iRow, int iCol, char sText[]){
lcd.setCursor(iCol,iRow); // Set Cursor to Location
lcd.print(sText); // Print Data from Variable
  
}

void clearLCD(){
lcd.clear();
}
