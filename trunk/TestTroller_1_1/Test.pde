#include <EEPROM.h>

void testLCD(byte testNum, byte numTests) {
  clearLCD();
  lcdSetCustChar_P(0, BMP0);
  lcdSetCustChar_P(1, BMP1);
  lcdSetCustChar_P(2, BMP2);
  lcdSetCustChar_P(3, BMP3);
  lcdSetCustChar_P(4, BMP4);
  lcdSetCustChar_P(5, BMP5);
  lcdSetCustChar_P(6, BMP6);
  lcdSetCustChar_P(7, BMP7);

  printLCD_P(3, 0, PSTR("Test   /  : LCD"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');

 for (byte pos = 0; pos < 3; pos++) printLCD_P(pos, 0, PSTR(">"));
 for (byte pos = 0; pos < 3; pos++) printLCD_P(pos, 19, PSTR("<"));
 for (byte pos = 1; pos < 19; pos = pos + 3) {
    lcdWriteCustChar(0, pos + 1, 0);
    lcdWriteCustChar(0, pos + 2, 1);
    lcdWriteCustChar(1, pos, 2); 
    lcdWriteCustChar(1, pos + 1, 3); 
    lcdWriteCustChar(1, pos + 2, 4); 
    lcdWriteCustChar(2, pos, 5); 
    lcdWriteCustChar(2, pos + 1, 6); 
    lcdWriteCustChar(2, pos + 2, 7); 
  }
  while(!enterStatus) delay(100);
  enterStatus = 0;
}

void testEncoder(byte testNum, byte numTests) {
  clearLCD();
  printLCDLPad(0, 1, "", 19, '-');
  printLCD_P(0, 10, PSTR("|"));
  printLCD_P(3, 0, PSTR("Test   /  : Encoder"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  encMin = 1;
  encMax = 19;
  encCount = 10;
  byte lastCount = encCount + 1;
  while(!enterStatus) {
    if (lastCount != encCount) {
      lastCount = encCount;
      printLCDLPad(1, 1, " ", 19, ' ');
      printLCD_P(1, lastCount, PSTR("^"));
    }
    delay(1);
  }
  enterStatus = 0;
}

void testEEPROM(byte testNum, byte numTests) {
  lcdSetCustChar_P(0, CHK);
  clearLCD();
  printLCD_P(3, 0, PSTR("Test   /  : EEPROM"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  
  for (byte block = 0; block < 16; block++) {
    printLCD_P(1, block + 2, PSTR("W"));
    for (byte pos = 0; pos < 128; pos++) EEPROM.write(block * 128 + pos, pos);
    printLCD_P(1, block + 2, PSTR("V"));
    boolean failed = 0;
    for (byte pos = 0; pos < 128; pos++) {
      if (EEPROM.read(block * 128 + pos) != pos){
        failed = 1;
        break;
      }
      EEPROM.write(block * 128 + pos, 0);
    }
    if (failed) printLCD_P(1, block + 2, PSTR("X"));
    else lcdWriteCustChar(1, block + 2, 0);
  }
  while(!enterStatus) delay(100);
  enterStatus = 0;
}

void testOutputs(byte testNum, byte numTests) {
  clearLCD();
  printLCD_P(3, 0, PSTR("Test   /  : Outputs"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  
  printLCDCenter(1, 0, "HLT Heat", 20);
  digitalWrite(HLTHEAT_PIN, HIGH);
  delay(1000);
  digitalWrite(HLTHEAT_PIN, LOW);

  printLCDCenter(1, 0, "Mash Heat", 20);
  digitalWrite(MASHHEAT_PIN, HIGH);
  delay(1000);
  digitalWrite(MASHHEAT_PIN, LOW);

  printLCDCenter(1, 0, "Kettle Heat", 20);
  digitalWrite(KETTLEHEAT_PIN, HIGH);
  delay(1000);
  digitalWrite(KETTLEHEAT_PIN, LOW);

#ifdef USESTEAM
  printLCDCenter(1, 0, "Steam Heat", 20);
  digitalWrite(STEAMHEAT_PIN, HIGH);
  delay(1000);
  digitalWrite(STEAMHEAT_PIN, LOW);
#endif

  printLCDCenter(1, 0, "", 20);
  printLCD_P(1, 6, PSTR("Valve"));
  for(byte valve = 0; valve < 32; valve++) {
    printLCDLPad(1, 12, itoa(valve + 1, buf, 10), 2, '0');
    setValves(1<<valve);
    delay(1000);
  }
  setValves(0);

  printLCDCenter(1, 0, "Alarm", 20);
  digitalWrite(ALARM_PIN, HIGH);
  delay(1000);
  digitalWrite(ALARM_PIN, LOW);
  
}

void testOneWire(byte testNum, byte numTests) {
  clearLCD();
  printLCD_P(3, 0, PSTR("Test   /  : OneWire"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  byte addr[8];
  getDSAddr(addr);
  printLCD_P(0, 0, PSTR("Found Address:"));
  for (byte i=0; i<8; i++) printLCDLPad(1,i*2+2,itoa(addr[i], buf, 16), 2, '0');  

  #ifdef USEMETRIC
    printLCD_P(2, 13, PSTR("C"));
  #else
    printLCD_P(2, 13, PSTR("F"));  
  #endif

  convertAll();
  unsigned long convertTime = millis();
  
  while(!enterStatus) {
    if (millis() - convertTime > 750) {
      float temp = read_temp(addr);
      ftoa(temp, buf, 2);
      printLCDLPad(2, 7, buf, 6, ' ');
      convertAll();
      convertTime = millis();
    }
  }
  enterStatus = 0;

  
}

void testVSensor(byte testNum, byte numTests) {
  clearLCD();
  printLCD_P(3, 0, PSTR("Test   /  : VSensors"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  printLCD_P(0, 0, PSTR("HLT"));
  printLCD_P(1, 0, PSTR("Mash"));
  printLCD_P(0, 9, PSTR("Kettle"));
  printLCD_P(1, 10, PSTR("Steam"));
  unsigned long lastRead;
  while(!enterStatus) {
    if (millis() - lastRead > 500) {
      float v = 5.0 / 1024 * analogRead(HLTVOL_APIN);
      ftoa(v, buf, 1);
      printLCDLPad(0, 4, buf, 3, ' ');
    
      v = 5.0 / 1024 * analogRead(MASHVOL_APIN);
      ftoa(v, buf, 1);
      printLCDLPad(1, 5, buf, 3, ' ');
    
      v = 5.0 / 1024 * analogRead(KETTLEVOL_APIN);
      ftoa(v, buf, 1);
      printLCDLPad(0, 16, buf, 3, ' ');
    
      v = 5.0 / 1024 * analogRead(STEAMPRESS_APIN);
      ftoa(v, buf, 1);
      printLCDLPad(1, 16, buf, 3, ' ');
      lastRead = millis();
    }  
  }
  enterStatus = 0;
}

void testTimer(byte testNum, byte numTests) {
  clearLCD();
  printLCD_P(3, 0, PSTR("Test   /  : Timer"));
  printLCDLPad(3, 5, itoa(testNum, buf, 10), 2, '0');
  printLCDLPad(3, 8, itoa(numTests, buf, 10), 2, '0');
  for(byte count = 11; count > 0; count--) {
    printLCDLPad(1, 9, itoa(count - 1, buf, 10), 2, '0');
    delay(1000);
  }
}

void testComplete() {
  clearLCD();
  printLCD_P(3, 0, PSTR("Tests Complete."));
  while(!enterStatus) delay(100);
  enterStatus = 0;  
}

