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

