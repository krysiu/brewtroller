#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 17	  (LCD pin 4 ) aka DI
// rw on pin 18	  (LCD pin 5)
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)

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

void lcdPrintFloat( float val, byte precision, int iRow, int iCol){
  // prints val on a ver 0012 text lcd with number of decimal places determine by precision
  // precision is a number from 0 to 6 indicating the desired decimial places
  // example: lcdPrintFloat( 3.1415, 2); // prints 3.14 (two decimal places)
  lcd.setCursor(iCol,iRow); // Set Cursor to Location
  if(val < 0.0){
    lcd.print('-');
    val = -val;
  }

  lcd.print ((long)val);  //prints the integral part
    if( precision > 0) {
    lcd.print("."); // print the decimal point
    unsigned long frac;
    unsigned long mult = 1;
    byte padding = precision -1;
    while(precision--)
	mult *=10;

    if(val >= 0)
	frac = (val - int(val)) * mult;
    else
	frac = (int(val)- val ) * mult;
    unsigned long frac1 = frac;
    while( frac1 /= 10 )
	padding--;
    while(  padding--)
	lcd.print("0");
    lcd.print(frac,DEC) ;
  }
}
 
