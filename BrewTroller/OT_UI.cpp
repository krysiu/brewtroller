#include "OT_UI.h"


    ScreenGPIO::ScreenGPIO(byte cols, byte rows, byte rs, byte enable, byte d4, byte d5, byte d6, byte d7, byte encType, byte encA, byte encB, byte encEnter) : Screen(cols, rows) {
      lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
      lcd->begin(cols, rows);
      Encoder.begin(encType, encEnter, encA, encB);
      Encoder.setWrap(true);
      Encoder.setMin(-10000);
      Encoder.setMax(10000);
      Encoder.setCount(0);
    }
    
    void ScreenGPIO::getInputDeltas(int *x, int *y, bool *selected, bool *cancelled) {
      *x = 0;
      *y = Encoder.getDelta();
      *selected = Encoder.ok();
      *cancelled = Encoder.cancel();
      Encoder.setCount(0);
    }
    
  void ScreenGPIO::clear() { lcd->clear(); }  
  void ScreenGPIO::createCustomChar(uint8_t slot, uint8_t *data) { lcd->createChar(slot, data); }

  void ScreenGPIO::draw(uint8_t x, uint8_t y, const char *text) {
    lcd->setCursor(x, y);
    lcd->print(text);
  }
  
  void ScreenGPIO::draw(uint8_t x, uint8_t y, uint8_t customChar) {
    lcd->setCursor(x, y);
    lcd->write(customChar);
  }

  void ScreenGPIO::setCursorVisible(bool visible) { visible ? lcd->cursor() : lcd->noCursor(); }
  void ScreenGPIO::moveCursor(uint8_t x, uint8_t y) { lcd->setCursor(x, y); }
  void ScreenGPIO::setBlink(bool blink) { blink ? lcd->blink() : lcd->noBlink(); }


  ScreenI2Cv2::ScreenI2Cv2(byte cols, byte rows) : Screen(cols, rows) { }
  ScreenI2Cv2::ScreenI2Cv2(byte cols, byte rows, byte addr) : Screen(cols, rows) {
    int value;
    i2cLCDAddr = addr;
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x01); Wire.send(cols); Wire.send(rows); Wire.endTransmission();
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x42); Wire.send(1); Wire.endTransmission(); //setWrap(1)
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x40); I2C_SEND_INT(-10000) Wire.endTransmission(); //setMin(-10000)
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x41); I2C_SEND_INT(10000) Wire.endTransmission(); //setMax(10000)
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x43); I2C_SEND_INT(0) Wire.endTransmission(); //setCount(0)
  }
  
  void ScreenI2Cv2::getInputDeltas(int *x, int *y, bool *selected, bool *cancelled) {
    *x = 0;
    
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x48); //getDelta()
    Wire.endTransmission();
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 2);
    if (Wire.available() == 2) { 
      *y = Wire.receive(); *y |= (((int)(Wire.receive())) << 8); 
      Wire.beginTransmission(i2cLCDAddr); Wire.send(0x43); I2C_SEND_INT(0) Wire.endTransmission(); //setCount(0)
    } else { *y = 0; }

    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x4A); //ok()
    Wire.endTransmission();
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 1);
    if (Wire.available() == 1) { *selected = Wire.receive(); } else { *selected = 0; }

    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x4B); //cancel()
    Wire.endTransmission();
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 1);
    if (Wire.available() == 1) { *cancelled = Wire.receive(); } else { *cancelled = 0; }
  }
    
  void ScreenI2Cv2::clear() {
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x02);
    Wire.endTransmission();
  }  
  
  void ScreenI2Cv2::createCustomChar(uint8_t slot, uint8_t *data) {
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x05);
    Wire.send(slot);
    for (byte i = 0; i < 8; i++) { Wire.send(*data++); }
    Wire.endTransmission();
  }

  void ScreenI2Cv2::draw(uint8_t x, uint8_t y, const char *text) {
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x04);
    Wire.send(x);
    Wire.send(y);
    char *p = (char *)text;
    while (*p) {
      Wire.send(*p++);
    }
    Wire.endTransmission();
  }
  
  void ScreenI2Cv2::draw(uint8_t x, uint8_t y, uint8_t customChar) {
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x06);
    Wire.send(x);
    Wire.send(y);
    Wire.send(customChar);
    Wire.endTransmission();
  }

  void ScreenI2Cv2::setCursorVisible(bool visible) {  }
  
  void ScreenI2Cv2::moveCursor(uint8_t x, uint8_t y) { 
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x03);
    Wire.send(x);
    Wire.send(y);
    Wire.endTransmission();
  }
  
  void ScreenI2Cv2::setBlink(bool blink) {  }

  ScreenI2Cv1::ScreenI2Cv1(byte cols, byte rows, byte addr, byte encType, byte encA, byte encB, byte encEnter) : ScreenI2Cv2(cols, rows) {
    i2cLCDAddr = addr;
    Wire.beginTransmission(i2cLCDAddr);
    Wire.send(0x01);
    Wire.send(cols);
    Wire.send(rows);
    Wire.endTransmission();
    Encoder.begin(encType, encEnter, encA, encB);
    Encoder.setWrap(true);
    Encoder.setMin(-10000);
    Encoder.setMax(10000);
    Encoder.setCount(0);
  }
  
  void ScreenI2Cv1::getInputDeltas(int *x, int *y, bool *selected, bool *cancelled) {
    *x = 0;
    *y = Encoder.getDelta();
    *selected = Encoder.ok();
    *cancelled = Encoder.cancel();
    Encoder.setCount(0);
  }

  screenUI::screenUI(void (* wF)(void)) { waitFunc = wF; }
  
  Screen* screenUI::create(byte cols, byte rows) {
    if (screenType == SCREENTYPE_NONE) { screenType = detect(); }
    
    switch (screenType) {
      #ifdef UI_LCD_4BIT
        case SCREENTYPE_GPIO:
          return new ScreenGPIO(cols, rows, LCD_RS_PIN, LCD_ENABLE_PIN, LCD_DATA4_PIN, LCD_DATA5_PIN, LCD_DATA6_PIN, LCD_DATA7_PIN, ALPS, ENCA_PIN, ENCB_PIN, ENTER_PIN);
      #endif
      #ifdef UI_LCD_I2CADDR
        case SCREENTYPE_I2CV2:
          return new ScreenI2Cv2(cols, rows, UI_LCD_I2CADDR);
          #ifdef ENCA_PIN
          case SCREENTYPE_I2CV1:
            return new ScreenI2Cv1(cols, rows, UI_LCD_I2CADDR, ALPS, ENCA_PIN, ENCB_PIN, ENTER_PIN);
          #endif
      #endif
      #ifdef UI_LCD_MBADDR
        case SCREENTYPE_MODBUS:
          return new ScreenModbus(cols, rows, UI_LCD_MBADDR);
      #endif
        default:
        //Return generic screen
        return new Screen(cols, rows);
    }
  }
  
  screenType_t screenUI::detect() {
    //Check for Modbus Display
    #ifdef UI_LCD_MBADDR    
      if (detectModbus(UI_LCD_MBADDR)) return SCREENTYPE_MODBUS;
    #endif
    
    //Check for I2C Displays
    #if defined UI_LCD_I2CADDR
      if (detectI2Cv2(UI_LCD_I2CADDR)) return SCREENTYPE_I2CV2;
      #if defined ENCA_PIN
        if (detectI2Cv1(UI_LCD_I2CADDR)) return SCREENTYPE_I2CV1;
      #endif
    #endif
    
    //Use 4-Bit GPIO if defined
    #if defined UI_LCD_4BIT
      return SCREENTYPE_GPIO;
    #endif
    
    return SCREENTYPE_NONE;
  }
  
  boolean screenUI::detectI2Cv2(byte i2cLCDAddr) {
    int eFVal;
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x40); I2C_SEND_INT(-10000) Wire.endTransmission(); //setMin()
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x41); I2C_SEND_INT(10000) Wire.endTransmission(); //setMax()
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x43); I2C_SEND_INT(4242) Wire.endTransmission(); //setCount()
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x46); Wire.endTransmission(); //getCount()
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 2); if (Wire.available() == 2) {  eFVal = Wire.receive(); eFVal += (Wire.receive() << 8); }
    return (eFVal == 4242 ? 1 : 0);    
  }
  
  boolean screenUI::detectI2Cv1(byte i2cLCDAddr) {
    byte bSVal, bFVal;
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x09); Wire.endTransmission(); //getBright()
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 1); if (Wire.available() == 1) { bSVal = Wire.receive(); }
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x07); Wire.send(42); Wire.endTransmission(); //setBright(42)
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x09); Wire.endTransmission(); //getBright()
    Wire.requestFrom(i2cLCDAddr, (uint8_t) 1); if (Wire.available() == 1) { bFVal = Wire.receive(); }
    Wire.beginTransmission(i2cLCDAddr); Wire.send(0x07); Wire.send(bSVal); Wire.endTransmission(); //setBright(bSVal)
    return (bFVal == 42 ? 1 : 0);
  }
  
  boolean screenUI::detectModbus(byte mbAddr) { return 0; }

  byte screenUI::dlgSelectOutput(char * title, outputs* Outputs, byte initValue){
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    Button cancelButton("Cancel");
  
    struct {
      Label lbl;
      char name[OUTPUTBANK_NAME_MAXLEN];
    } bankInfo[OUTPUTBANKS_MAXBANKS];

    struct {
      Button btn;
      char lblText[OUTPUTBANK_NAME_MAXLEN];
      Label lbl;
    } btnInfo[32];
    
    ScrollContainer scrollContainer(screen, screen->width(), 3);
    byte rowPos = 0;
    byte btnCount = 0;
    
    if (Outputs->getBankCount()) {
      byte bankCount = Outputs->getBankCount();
      for (byte bankIndex = 0; bankIndex < bankCount; bankIndex++) {
        Outputs->getBank(bankIndex)->getBankName(bankInfo[bankIndex].name);
        bankInfo[bankIndex].lbl = Label(bankInfo[bankIndex].name);
        scrollContainer.add(&bankInfo[bankIndex].lbl, 0, rowPos++);
        
        if (Outputs->getBank(bankIndex)->getCount()) {
          byte outCount = Outputs->getBank(bankIndex)->getCount();
          for (byte outIndex = 0; outIndex < outCount; outIndex++) {
            if (btnCount < 32) {
              btnInfo[btnCount].btn = Button(btnCount == initValue ? "*" : " ");
              scrollContainer.add(&btnInfo[btnCount].btn, 0, rowPos);
              
              Outputs->getBank(bankIndex)->getOutputName(outIndex, btnInfo[btnCount].lblText);
              btnInfo[btnCount].lbl = Label(btnInfo[btnCount].lblText);
              scrollContainer.add(&btnInfo[btnCount++].lbl, 4, rowPos++);
            }
          }
        }
      }
    }
    
    scrollContainer.add(&cancelButton, 0, rowPos);
    screen->add(&titleLabel, 0, 0);
    screen->add(&scrollContainer, 0, 1);
    if (initValue < btnCount) screen->setFocusHolder(&btnInfo[initValue].btn);
    
    while (1) {
      screen->update();
      for (byte i = 0; i < btnCount; i++) { if (btnInfo[i].btn.pressed()) return i; }
      if (cancelButton.pressed()) { return initValue; }
      //Call worker process
      (*waitFunc)();
    }
  }
  
  unsigned long screenUI::dlgCfgOutputProfile(char * title, outputs* Outputs, unsigned long initValue) {
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    Button okButton("OK");
    Button cancelButton("Cancel");
  
    struct {
      Label lbl;
      char name[OUTPUTBANK_NAME_MAXLEN];
    } bankInfo[OUTPUTBANKS_MAXBANKS];

    struct {
      Checkbox chk;
      char name[OUTPUTBANK_NAME_MAXLEN];
      Label lbl;
    } outInfo[32];
    
    ScrollContainer scrollContainer(screen, screen->width(), 3);
    byte rowPos = 0;
    byte chkCount = 0;
    
    if (Outputs->getBankCount()) {
      byte bankCount = Outputs->getBankCount();
      for (byte bankIndex = 0; bankIndex < bankCount; bankIndex++) {
        Outputs->getBank(bankIndex)->getBankName(bankInfo[bankIndex].name);
        bankInfo[bankIndex].lbl = Label(bankInfo[bankIndex].name);
        scrollContainer.add(&bankInfo[bankIndex].lbl, 0, rowPos++);
        
        if (Outputs->getBank(bankIndex)->getCount()) {
          byte outCount = Outputs->getBank(bankIndex)->getCount();
          for (byte outIndex = 0; outIndex < outCount; outIndex++) {
            if (chkCount < 32) {
              if (initValue & ((unsigned long) 1 << chkCount)) { outInfo[chkCount].chk.setChecked(1); }
              Outputs->getBank(bankIndex)->getOutputName(outIndex, outInfo[chkCount].name);
              outInfo[chkCount].lbl = Label(outInfo[chkCount].name);
              scrollContainer.add(&outInfo[chkCount].chk, 0, rowPos);
              scrollContainer.add(&outInfo[chkCount++].lbl, 4, rowPos++);
            }
          }
        }
      }
    }
    
    scrollContainer.add(&cancelButton, 0, rowPos);
    scrollContainer.add(&okButton, 16, rowPos);
    screen->add(&titleLabel, 0, 0);
    screen->add(&scrollContainer, 0, 1);
    
    while (1) {
      screen->update();
      if (okButton.pressed()) {
        unsigned long retValue = 0;
        for (byte i = 0; i < chkCount; i++) { 
          if (outInfo[i].chk.checked()) { retValue |= ((unsigned long)1 << i); }
        }
        return retValue;
      }
      if (cancelButton.pressed()) { return initValue; }
      //Call worker process
      (*waitFunc)();
    }
  }
  


