// Supported LCD Displays (Use only 1)
//
//#define DISPLAY_20x4
#define DISPLAY_16x2

#include <avr/pgmspace.h>

#include "WProgram.h"
void setup();
void loop();
void initLCD();
void printLCD(byte iRow, byte iCol, char sText[]);
void printLCD_P(byte iRow, byte iCol, const char *sText);
void clearLCD();
void printLCDCenter(byte iRow, byte iCol, char sText[], byte fieldWidth);
char printLCDLPad(byte iRow, byte iCol, char sText[], byte length, char pad);
char printLCDRPad(byte iRow, byte iCol, char sText[], byte length, char pad);
void lcdSetCustChar_P(byte slot, const byte *charDef);
void lcdWriteCustChar(byte iRow, byte iCol, byte slot);
void lcdPrintChar(byte iRow, byte iCol, byte charCode);
void initBigFont();
void printLCD_BigFont(byte row, byte col, char sText[]);
byte fontLookUp(char textChar);
byte puncLookUp(char textChar);
void initFont2x2();
void printFont2x2(byte row, byte col, byte digit);
void printPunc2x2(byte row, byte col, byte digit);
void initFont3x4();
void printFont3x4(byte row, byte col, byte digit);
void printPunc3x4(byte row, byte col, byte digit);
void chkMsg();
void clearMsg();
char buf[11];
char msg[25][21];
byte msgField = 0;

void setup() {
  //Mode Jumpers
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  //pinMode(, INPUT);
  Serial.begin(9600);
  initLCD();  
  initBigFont();
}

void loop() {
  clearLCD();
  printLCD_BigFont(0, 0, "12345");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "67890");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "97.2C");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "152.6F");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "24.3L");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "12.4G");
  delay(3000);

  clearLCD();
  printLCD_BigFont(0, 0, "1:25");
  delay(3000);

  chkMsg();
}

#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 18	  (LCD pin 4 ) aka DI
// enable on pin 19 (LCD pin 6)
// d4, d5, d6, d7 on pins 20, 21, 22, 23  (LCD pins 11-14)

LiquidCrystal lcd(17, 19, 20, 21, 22, 23);

void initLCD(){
  lcd.begin(20, 4);
}

void printLCD(byte iRow, byte iCol, char sText[]){
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  byte i = 0;
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

void lcdPrintChar(byte iRow, byte iCol, byte charCode) { 
  lcd.setCursor(iCol, iRow);
  #ifdef LCD_DELAY_CURSOR
    delayMicroseconds(LCD_DELAY_CURSOR);
  #endif
  lcd.write(charCode);
}

#ifdef DISPLAY_20x4
  #define CHAR_INCREMENT 3
#else
  #define CHAR_INCREMENT 2
#endif

void initBigFont() {
  #ifdef DISPLAY_20x4
    initFont3x4();
  #else
    initFont2x2();
  #endif
}

void printLCD_BigFont(byte row, byte col, char sText[]){
  byte pos = 0;
  byte i = 0;
  while (sText[i] != 0)  {
    byte punc = puncLookUp(sText[i]);
    if (punc > 0 || i > 0) {
      #ifdef DISPLAY_20x4
        printPunc3x4(0, pos, punc);
      #else
        printPunc2x2(0, pos, punc);
      #endif
      pos++;
    }
    if (punc > 0) i++;
    if (sText[i] != 0)  {
      #ifdef DISPLAY_20x4
        printFont3x4(0, pos, fontLookUp(sText[i]));
      #else
        printFont2x2(0, pos, fontLookUp(sText[i]));
      #endif
      pos = pos + CHAR_INCREMENT;
      i++;
    }
  }
}

byte fontLookUp(char textChar) {
  if (textChar == '0') return 0;
  else if (textChar == '1') return 1;
  else if (textChar == '2') return 2;
  else if (textChar == '3') return 3;
  else if (textChar == '4') return 4;
  else if (textChar == '5') return 5;
  else if (textChar == '6') return 6;
  else if (textChar == '7') return 7;
  else if (textChar == '8') return 8;
  else if (textChar == '9') return 9;
  else if (textChar == 'C') return 10;
  else if (textChar == 'F') return 11;
  else if (textChar == 'L') return 12;
  else if (textChar == 'G') return 13;
  else return 14;  //SPACE
}

byte puncLookUp(char textChar) {
  if (textChar == '.') return 1;
  else if (textChar == ':') return 2;
  else return 0;  //SEPARATOR
}

const byte FONT2X2_0[] PROGMEM = {B00000, B00000, B00000, B00000, B00000, B01110, B01110, B01110};
const byte FONT2X2_1[] PROGMEM = {B11111, B11111, B11111, B00000, B00000, B00000, B11111, B11111};
const byte FONT2X2_2[] PROGMEM = {B11110, B11110, B11110, B11110, B11110, B11111, B11111, B11111};
const byte FONT2X2_3[] PROGMEM = {B00000, B00000, B00000, B00000, B00000, B11111, B11111, B11111};
const byte FONT2X2_4[] PROGMEM = {B11111, B11111, B11111, B00000, B00000, B00000, B00000, B00000};
const byte FONT2X2_5[] PROGMEM = {B11111, B11111, B11111, B11110, B11110, B11110, B11111, B11111};
const byte FONT2X2_6[] PROGMEM = {B11111, B11111, B11111, B01111, B01111, B01111, B11111, B11111};
const byte FONT2X2_7[] PROGMEM = {B11111, B11111, B11111, B11110, B11110, B11110, B11110, B11110};

//10-digits 2x2 as Row 1/Col 1, Row 1/Col 2, Row 2/Col 1 and Row 2/Col 2 (0-9, C, F, L, G, SPACE)
byte font2x2Map[15][4] = {
//0
  {7, 255, 
   2, 255},
//1
  {254, 255, 
   254, 255},
//2
  {1, 6, 
   255, 3},
//3
  {1, 6, 
   3, 255},
//4
  {2, 255, 
   254, 255},
//5
  {5, 1, 
   3, 255},
//6
  {5, 1, 
   2, 255},
//7
  {4, 6, 
   254, 255},
//8
  {5, 6, 
   5, 6},
//9
  {5, 6, 
   254, 255},
//C
  {7, 4, 
   2, 3},
//F
  {255, 1, 
   255, 254},
//L
  {255, 254, 
   255, 3},
//G
  {7, 4, 
   2, 6},
//SPACE
  {254, 254, 
   254, 254}
};

byte punc2x2Map[3][2] = {
//SEPERATOR
  {254, 
   254},
//Decimal
  {254, 
   0},
//Colon
  {0, 
   0}
};

void initFont2x2() {
  lcdSetCustChar_P(0, FONT2X2_0);
  lcdSetCustChar_P(1, FONT2X2_1);
  lcdSetCustChar_P(2, FONT2X2_2);
  lcdSetCustChar_P(3, FONT2X2_3);
  lcdSetCustChar_P(4, FONT2X2_4);
  lcdSetCustChar_P(5, FONT2X2_5);
  lcdSetCustChar_P(6, FONT2X2_6);
  lcdSetCustChar_P(7, FONT2X2_7);
}

void printFont2x2(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 2; irow++) {
    for (byte icol = 0; icol < 2; icol++) {
      //0-7: Custom Chars
      if (font2x2Map[digit][irow * 2 + icol] < 8) lcdWriteCustChar(row + irow, col + icol, font2x2Map[digit][irow * 2 + icol]);
      //Otherwise print char by number
      else lcdPrintChar(row + irow, col + icol, font2x2Map[digit][irow * 2 + icol]);
    }
  }
}

void printPunc2x2(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 2; irow++) {
    if (punc2x2Map[digit][irow] < 8) lcdWriteCustChar(row + irow, col, punc2x2Map[digit][irow]);
    //Otherwise print char by number
    else lcdPrintChar(row + irow, col, punc2x2Map[digit][irow]);
  }
}

const byte FONT3X4_0[] PROGMEM = {B00000, B00000, B00000, B00000, B01110, B01110, B01110, B01110};
const byte FONT3X4_1[] PROGMEM = {B11111, B11111, B11111, B11111, B00000, B00000, B00000, B00000};
const byte FONT3X4_2[] PROGMEM = {B00000, B00000, B00000, B00000, B11111, B11111, B11111, B11111};
const byte FONT3X4_3[] PROGMEM = {B00011, B00011, B00011, B00011, B00000, B00000, B00000, B00000};
const byte FONT3X4_4[] PROGMEM = {B00011, B00111, B01111, B11111, B11111, B11111, B11111, B11111};
const byte FONT3X4_5[] PROGMEM = {B11000, B11100, B11110, B11111, B11111, B11111, B11111, B11111};
const byte FONT3X4_6[] PROGMEM = {B11111, B11111, B11111, B11111, B11111, B01111, B00111, B00011};
const byte FONT3X4_7[] PROGMEM = {B11111, B11111, B11111, B11111, B11111, B11110, B11100, B11000};

//3x4 as Row 1/Col 1, Row 1/Col 2, Row 1/Col 3, Row 2/Col 1, etc (0-9, C, F, L, G, SPACE)
byte font3x4Map[15][12] = {
//0
  {4,    1,    5,
   255,  254,  255,
   255,  254,  255,
   6,    2,    7},
//1
  {254,  255,  254,
   254,  255,  254,
   254,  255,  254,
   254,  255,  254},
//2
  {4,    1,    5,
   254,  2,    7,
   4,    1,    254,
   255,  2,    2},
//3
  {4,    1,    5,
   254,  2,    7,
   254,  254,  5,
   6,    2,    7},
//4
  {255,  254,  255,
   255,  2,    255,
   254,  254,  255,
   254,  254,  255},
//5
  {255,  1,    1,
   255,  254,  254,
   1,    1,    5,
   2,    2,    7},
//6 
  {4,    1,    5,
   255,  254,  254,
   255,  1,    5,
   6,    2,    7},
//7
  {255,  255,  255,
   254,  254,  255,
   254,  254,  255,
   254,  254,  255},
//8
  {4,    1,    5,
   6,    2,    7,
   4,    1,    5,
   6,    2,    7},
//9
  {4,    1,    5,
   6,    2,    255,
   254,  254,  255,
   254,  254,  255},
//C
  {4,    1,    5,
   255,  254,  254,
   255,  254,  254,
   6,    2,    7},
//F
  {255,  255,  255,
   255,  2,  2,
   255,  254,  254,
   255,  254,  254},
//L
  {255,  254,  254,
   255,  254,  254,
   255,  254,  254,
   255,  255,  255},
//G
  {4,    1,    5,
   255,  254,  254,
   255,  3,    255,
   6,    2,    7},
//SPACE   
  {254,  254,  254,
   254,  254,  254,
   254,  254,  254,
   254,  254,  254}
};

byte punc3x4Map[3][4] = {
//SEPERATOR
  {254,
   254,
   254,
   254},
//Decimal   
  {254,
   254, 
   254, 
   0},
//Colon
  {254, 
   0, 
   0, 
   254}
};

void initFont3x4() {
  lcdSetCustChar_P(0, FONT3X4_0);
  lcdSetCustChar_P(1, FONT3X4_1);
  lcdSetCustChar_P(2, FONT3X4_2);
  lcdSetCustChar_P(3, FONT3X4_3);
  lcdSetCustChar_P(4, FONT3X4_4);
  lcdSetCustChar_P(5, FONT3X4_5);
  lcdSetCustChar_P(6, FONT3X4_6);
  lcdSetCustChar_P(7, FONT3X4_7);
}

void printFont3x4(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 4; irow++) {
    for (byte icol = 0; icol < 3; icol++) {
      //0-7: Custom Chars
      if (font3x4Map[digit][irow * 3 + icol] < 8) lcdWriteCustChar(row + irow, col + icol, font3x4Map[digit][irow * 3 + icol]);
      //Otherwise print char by number
      else lcdPrintChar(row + irow, col + icol, font3x4Map[digit][irow * 3 + icol]);
    }
  }
}

void printPunc3x4(byte row, byte col, byte digit) {
  for (byte irow = 0; irow < 4; irow++) {
    if (punc3x4Map[digit][irow] < 8) lcdWriteCustChar(row + irow, col, punc3x4Map[digit][irow]);
    //Otherwise print char by number
    else lcdPrintChar(row + irow, col, punc3x4Map[digit][irow]);
  }
}

void chkMsg() {
  while (Serial.available()) {
    byte byteIn = Serial.read();
    if (byteIn == '\r' || byteIn == '\n') {
      //Read Jumpers and Set Mode
      
      if (strcasecmp(msg[1], "DATA") == 0 && strcasecmp(msg[2], "PGM") == 0) {

      }
      
      clearMsg();
    } else if (byteIn == '\t') {
      if (msgField < 25) {
        msgField++;
      } else {
        //Message Overflow
        clearMsg();
      }
    } else {
      byte charCount = strlen(msg[msgField]);
      if (charCount < 20) { 
        msg[msgField][charCount] = byteIn; 
        msg[msgField][charCount + 1] = '\0';
      } else {
        //Field Overflow
        clearMsg();
      }
    }
  }
}

void clearMsg() {
  msgField = 0;
  for (byte i = 0; i < 20; i++) msg[i][0] = '\0';
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

