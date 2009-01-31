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
byte i;
clearLCD;
printLCD(0,4,"BrewTroller");
for ( i = 0; i < 20; i++) {
  printLCD(3,i,">");
delay(75);
}
delay(1000);
clearLCD();
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

void printLCDBytes(int iRow, int iCol, byte sByte[], int numBytes){
 lcd.setCursor(iCol, iRow);
 delayMicroseconds(LCD_DELAY_CURSOR);
 for (int i = 0; i < numBytes; i++) {
   if (sByte[i] < 0x10) lcd.print(0, HEX);
   lcd.print(sByte[i], HEX);
   delayMicroseconds(LCD_DELAY_CHAR);
 }
} 

void clearLCD(){
lcd.clear();
}

/* mattreba: the following function is not currently being used. itoa/ftoa is being used instead.
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
} */

char printLCDPad(int iRow, int iCol, char sText[], int length) {
 lcd.setCursor(iCol, iRow);
 delayMicroseconds(LCD_DELAY_CURSOR);
 for (int i=0; i < length-strlen(sText) ; i++) {
   lcd.print(" ");
   delayMicroseconds(LCD_DELAY_CHAR);
 }
 int i = 0;
 while (sText[i] != 0)
 {
   lcd.print(sText[i++]);
   delayMicroseconds(LCD_DELAY_CHAR);
 }
}  
