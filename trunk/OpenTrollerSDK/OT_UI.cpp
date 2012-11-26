#include "OT_UI.h"

    LiquidCrystal* ScreenGPIO::lcd;
    bool ScreenGPIO::encoderInit = 0;
    ScreenGPIO::ScreenGPIO(byte cols, byte rows, byte rs, byte enable, byte d4, byte d5, byte d6, byte d7, byte encType, byte encA, byte encB, byte encEnter) : Screen(cols, rows) {
      if (!ScreenGPIO::lcd) {
        ScreenGPIO::lcd = new LiquidCrystal(rs, enable, d4, d5, d6, d7);
        ScreenGPIO::lcd->begin(cols, rows);
      }
      if(!ScreenGPIO::encoderInit) {
        Encoder.begin(encType, encEnter, encA, encB);
        #ifdef ENCODER_ACTIVELOW
          Encoder.setActiveLow(1);
        #endif
        Encoder.setWrap(true);
        Encoder.setMin(-10000);
        Encoder.setMax(10000);
        Encoder.setCount(0);
        ScreenGPIO::encoderInit = 1;
      }
    }
    
    void ScreenGPIO::getInputDeltas(int *x, int *y, bool *selected, bool *cancelled) {
      *x = 0;
      *y = Encoder.getDelta();
      *selected = Encoder.ok();
      *cancelled = Encoder.cancel();
      Encoder.setCount(0);
    }
    
  void ScreenGPIO::clear() { ScreenGPIO::lcd->clear(); }  
  void ScreenGPIO::createCustomChar(uint8_t slot, uint8_t *data) { ScreenGPIO::lcd->createChar(slot, data); }

  void ScreenGPIO::draw(uint8_t x, uint8_t y, const char *text) {
    ScreenGPIO::lcd->setCursor(x, y);
    ScreenGPIO::lcd->print(text);
  }
  
  void ScreenGPIO::draw(uint8_t x, uint8_t y, uint8_t customChar) {
    ScreenGPIO::lcd->setCursor(x, y);
    ScreenGPIO::lcd->write(customChar);
  }

  void ScreenGPIO::setCursorVisible(bool visible) { visible ? ScreenGPIO::lcd->cursor() : ScreenGPIO::lcd->noCursor(); }
  void ScreenGPIO::moveCursor(uint8_t x, uint8_t y) { ScreenGPIO::lcd->setCursor(x, y); }
  void ScreenGPIO::setBlink(bool blink) { blink ? ScreenGPIO::lcd->blink() : ScreenGPIO::lcd->noBlink(); }


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
    #ifdef ENCODER_ACTIVELOW
      Encoder.setActiveLow(1);
    #endif
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
  void screenUI::wait(void) { (*waitFunc)(); }


////////////////////////////////////////////////////////////////////////////////
// dlgYesNo
////////////////////////////////////////////////////////////////////////////////

  bool screenUI::dlgYesNo(char *title, char *message) {
    bool returnCode = 0;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);
    
    Button noButton("No");    
    screen->add(&noButton, 0, 1);
    Button yesButton("Yes");
    screen->add(&yesButton, 15, 1);
    while (1) {
      screen->update();
      if (yesButton.pressed()) { returnCode = 1; break; }
      else if (noButton.pressed()) { break; }
      //Call worker process
      wait();
    }
    delete screen;
    return returnCode;
  }

  byte screenUI::dlgSelectOutput(char * title, outputs* Outputs, byte initValue){
    byte returnValue = initValue;
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
      for (byte i = 0; i < btnCount; i++) {
        if (btnInfo[i].btn.pressed()) {
          delete screen;
          return i;
        }
      }
      if (cancelButton.pressed()) {
        delete screen;
        return initValue;
      }
      //Call worker process
      wait();
    }
  }
  
  unsigned long screenUI::dlgCfgOutputProfile(char * title, outputs* Outputs, unsigned long initValue) {
    unsigned long returnValue = initValue;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    Button okButton("OK");
    Button cancelButton("Cancel");
    ScrollContainer scrollContainer(screen, screen->width(), 3);
    
    struct {
      Label lbl;
      char name[OUTPUTBANK_NAME_MAXLEN];
    } bankInfo[OUTPUTBANKS_MAXBANKS];

    struct {
      Checkbox chk;
      char name[OUTPUTBANK_NAME_MAXLEN];
      Label lbl;
    } outInfo[32];
    

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
        returnValue = 0;
        for (byte i = 0; i < chkCount; i++) { 
          if (outInfo[i].chk.checked()) { returnValue |= ((unsigned long)1 << i); }
        }
        break;
      }
      if (cancelButton.pressed()) { break; }
      //Call worker process
      wait();
    }
    delete screen;
    return returnValue;
  }
  

  void screenUI::dlgCfgTSensor(char * title, tSensorCfg_t *cfg){
    tSensorType currentType = cfg->type;
    tSensorType returnType;
    
    while (1) {
      switch (currentType) {
        case tSensorType_1Wire:
          returnType = dlgCfgTSensor_1Wire(title, cfg);
          break;        
        case tSensorType_Modbus:
          returnType = dlgCfgTSensor_Modbus(title, cfg);
          break;        
        default:
          returnType = dlgCfgTSensor_None(title, cfg);
          break;
      }
      if (returnType == currentType) break;
      currentType = returnType;
    } //End Mode Loop
  }
  
  tSensorType screenUI::dlgCfgTSensor_None(char *title, tSensorCfg_t *cfg) {
    tSensorType returnType = tSensorType_None;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    typeList.addItem("1-Wire");
    typeList.addItem("Modbus");
    typeList.setSelectedIndex(0);
    
    screen->add(&typeLabel, 0, 1);
    screen->add(&typeList, 6, 1);
    
    Button okButton("OK");
    Button cancelButton("Cancel");
    screen->add(&cancelButton, 0, 3);
    screen->add(&okButton, 16, 3);
    screen->setFocusHolder(&typeList);
    
    while (1) {
      screen->update();
      if (!typeList.captured() && typeList.selectedIndex() != 0) {
        if (typeList.selectedIndex() == 1) returnType = tSensorType_1Wire;
        else if (typeList.selectedIndex() == 2) returnType = tSensorType_Modbus;
        break;
      }
      if (okButton.pressed()) {
        cfg->type = tSensorType_None;
        break;
      }
      if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
  
  tSensorType screenUI::dlgCfgTSensor_1Wire(char *title, tSensorCfg_t *cfg) {
    tSensorType returnType = tSensorType_1Wire;

    byte newAddr[8] = {0,0,0,0,0,0,0,0};
    if (cfg->type == tSensorType_1Wire) { memcpy(newAddr, cfg->implementation.tSensorCfg_1Wire.addr, 8); }
    tSensor_1Wire* newSensor = NULL;
    bool addrDirty = 1;
    bool addrCaptured = 0;
    
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    ScrollContainer scrollContainer(screen, screen->width(), 3);
    
    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    typeList.addItem("1-Wire");
    typeList.addItem("Modbus");
    typeList.setSelectedIndex(1);
    scrollContainer.add(&typeLabel, 0, 0);
    scrollContainer.add(&typeList, 6, 0);

    char addrTxt[17] = "FFFFFFFFFFFFFFFF";
    Input addrInput(addrTxt);
    addrInput.setCharSet(&hexCharSet);
    scrollContainer.add(&addrInput, 1, 1);
    
    Label tTitleLbl("Temperature:");
    char tempTxt[8] = "-------";
    Label tempLbl(tempTxt);
    scrollContainer.add(&tTitleLbl, 0, 2);
    scrollContainer.add(&tempLbl, 13, 2);

    Checkbox scanNewChk;
    scanNewChk.setChecked(1);
    Label scanNewLbl("Scan Only New");
    scrollContainer.add(&scanNewChk, 1, 3);
    scrollContainer.add(&scanNewLbl, 5, 3);        
 
    Button scanBtn("Scan");
    Button cancelButton("Cancel");
    Button okButton("OK");
    scrollContainer.add(&scanBtn, 0, 4);
    scrollContainer.add(&cancelButton, 7, 4);
    scrollContainer.add(&okButton, 16, 4);
    screen->add(&scrollContainer, 0, 1);

    while (1) {
      if(addrCaptured != addrInput.captured()) {
        if (!addrInput.captured()) {
          //Transition from captured to uncaptured
          for (byte i = 0; i < 8; i++) {
            char hexByte[3];
            strlcpy(hexByte, addrTxt + i * 2, 3);
            newAddr[i] = (byte)strtol(hexByte, NULL, 16);
          }
          addrDirty = 1;
        }
        addrCaptured = addrInput.captured();
      }
      
      if(addrDirty) {
        delete newSensor;
        newSensor = new tSensor_1Wire(newAddr);
        newSensor->init();
        sprintf(addrTxt, "%02X%02X%02X%02X%02X%02X%02X%02X", newAddr[0], newAddr[1], newAddr[2], newAddr[3], newAddr[4], newAddr[5], newAddr[6], newAddr[7]);
        addrDirty = 0;
      }
      
      if (newSensor) {
        newSensor->update();
        long sensorValue = newSensor->getValue();
        if(sensorValue != BAD_TEMP) { sprintf(tempTxt, "%3ld.%02ld%c", sensorValue / 100, sensorValue % 100, tSensor::getUnit() ? 'C' : 'F'); }
        else { strcpy(tempTxt, "N/A"); }
        tempLbl.setText(tempTxt);
      }

      screen->update();
      if (!typeList.captured() && typeList.selectedIndex() != 1) {
        if (dlgYesNo("Change Type?", "All changes will be lost.")) {
          if (typeList.selectedIndex() == 2) returnType = tSensorType_Modbus;
          else returnType = tSensorType_None;
          break;
        }
        else {
          typeList.setSelectedIndex(1);
          screen->clear();
          screen->repaint();
        }
      }
      else if (scanBtn.pressed()) {
        tSensor_1Wire::scanBus(newAddr, 0, scanNewChk.checked());
        addrDirty = 1;
      }   
      else if (okButton.pressed()) {
        cfg->type = tSensorType_1Wire;
        memcpy(cfg->implementation.tSensorCfg_1Wire.addr, newAddr, 8);
        break;
      }
      else if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
  
  tSensorType screenUI::dlgCfgTSensor_Modbus(char *title, tSensorCfg_t *cfg) {
    tSensorType returnType = tSensorType_Modbus;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    ScrollContainer scrollContainer(screen, screen->width(), 5);
    
    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    typeList.addItem("1-Wire");
    typeList.addItem("Modbus");
    typeList.setSelectedIndex(2);
    scrollContainer.add(&typeLabel, 0, 0);
    scrollContainer.add(&typeList, 6, 0);
    
    Button okButton("OK");
    Button cancelButton("Cancel");
    scrollContainer.add(&cancelButton, 0, 4);
    scrollContainer.add(&okButton, 16, 4);
    screen->add(&scrollContainer, 0, 1);
    
    while (1) {
      screen->update();
      if (!typeList.captured() && typeList.selectedIndex() != 2) {
        if (dlgYesNo("Change Type?", "All changes will be lost.")) {
          if (typeList.selectedIndex() == 1) returnType = tSensorType_1Wire;
          else returnType = tSensorType_None;
          break;
        }
        else {
          typeList.setSelectedIndex(2);
          screen->clear();
          screen->repaint();
        }
      }
      else if (okButton.pressed()) {
        cfg->type = tSensorType_Modbus;
        break;
      }
      else if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
  
  void screenUI::dlgCfgAnalogIn(char * title, analogInCfg_t *cfg){
    analogInType currentType = cfg->type;
    analogInType returnType;
    
    while (1) {
      switch (currentType) {
        #ifdef ANALOGINPUTS_GPIO
          case analogInType_GPIO:
            returnType = dlgCfgAnalogIn_GPIO(title, cfg);
            break;
        #endif
        #ifdef ANALOGINPUTS_MODBUS
          case analogInType_Modbus:
            returnType = dlgCfgAnalogIn_Modbus(title, cfg);
            break;
        #endif
        default:
          returnType = dlgCfgAnalogIn_None(title, cfg);
          break;
      }
      if (returnType == currentType) break;
      currentType = returnType;
    } //End Mode Loop
  }
  
  analogInType screenUI::dlgCfgAnalogIn_None(char *title, analogInCfg_t *cfg) {
    analogInType returnType = analogInType_None;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    #ifdef ANALOGINPUTS_GPIO
      typeList.addItem("GPIO");
    #endif
    #ifdef ANALOGINPUTS_MODBUS
      typeList.addItem("Modbus");
    #endif
    typeList.setSelectedIndex(0);
    
    screen->add(&typeLabel, 0, 1);
    screen->add(&typeList, 6, 1);
    
    Button okButton("OK");
    Button cancelButton("Cancel");
    screen->add(&cancelButton, 0, 3);
    screen->add(&okButton, 16, 3);
    screen->setFocusHolder(&typeList);
    
    while (1) {
      screen->update();
      if (!typeList.captured() && strcmp(typeList.selectedItem(), "None")) {
        #ifdef ANALOGINPUTS_GPIO
          if (!strcmp(typeList.selectedItem(), "GPIO")) returnType = analogInType_GPIO;
        #endif
        #ifdef ANALOGINPUTS_MODBUS
          if (!strcmp(typeList.selectedItem(), "Modbus")) returnType = analogInType_Modbus;
        #endif
        break;
      }
      if (okButton.pressed()) {
        cfg->type = analogInType_None;
        break;
      }
      if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
  
#ifdef ANALOGINPUTS_GPIO
  analogInType screenUI::dlgCfgAnalogIn_GPIO(char *title, analogInCfg_t *cfg) {
    analogInType returnType = analogInType_GPIO;

    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    ScrollContainer scrollContainer(screen, screen->width(), 3);
    
    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    #ifdef ANALOGINPUTS_GPIO
      typeList.addItem("GPIO");
    #endif
    #ifdef ANALOGINPUTS_MODBUS
      typeList.addItem("Modbus");
    #endif
    typeList.setSelectedItem("GPIO");
    scrollContainer.add(&typeLabel, 0, 0);
    scrollContainer.add(&typeList, 6, 0);

    Button cancelButton("Cancel");
    Button okButton("OK");
    scrollContainer.add(&cancelButton, 7, 4);
    scrollContainer.add(&okButton, 16, 4);
    screen->add(&scrollContainer, 0, 1);

    while (1) {
      screen->update();
      if (!typeList.captured() && strcmp(typeList.selectedItem(), "GPIO")) {
        if (dlgYesNo("Change Type?", "All changes will be lost.")) {
          if (!strcmp(typeList.selectedItem(), "Modbus")) returnType = analogInType_Modbus;
          else returnType = analogInType_None;
          break;
        }
        else {
          typeList.setSelectedItem("GPIO");
          screen->clear();
          screen->repaint();
        }
      }
      else if (okButton.pressed()) {
        cfg->type = analogInType_GPIO;
        break;
      }
      else if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
#endif

#ifdef ANALOGINPUTS_MODBUS
  analogInType screenUI::dlgCfgAnalogIn_Modbus(char *title, analogInCfg_t *cfg) {
    analogInType returnType = analogInType_Modbus;
    Screen * screen = create(20, 4);
    Label titleLabel(title);
    screen->add(&titleLabel, 0, 0);

    ScrollContainer scrollContainer(screen, screen->width(), 5);
    
    Label typeLabel("Type:");
    List typeList(3);
    typeList.addItem("None");
    #ifdef ANALOGINPUTS_GPIO
      typeList.addItem("GPIO");
    #endif
    #ifdef ANALOGINPUTS_MODBUS
      typeList.addItem("Modbus");
    #endif
    typeList.setSelectedItem("Modbus");
    scrollContainer.add(&typeLabel, 0, 0);
    scrollContainer.add(&typeList, 6, 0);
    
    Button okButton("OK");
    Button cancelButton("Cancel");
    scrollContainer.add(&cancelButton, 0, 4);
    scrollContainer.add(&okButton, 16, 4);
    screen->add(&scrollContainer, 0, 1);
    
    while (1) {
      screen->update();
      if (!typeList.captured() && typeList.selectedIndex() != 2) {
        if (dlgYesNo("Change Type?", "All changes will be lost.")) {
          if (!strcmp(typeList.selectedItem(), "GPIO")) returnType = analogInType_GPIO;
          else returnType = analogInType_None;
          break;
        }
        else {
          typeList.setSelectedItem("Modbus");
          screen->clear();
          screen->repaint();
        }
      }
      else if (okButton.pressed()) {
        cfg->type = analogInType_Modbus;
        break;
      }
      else if (cancelButton.pressed()) {
        break;
      }
      //Call worker process
      wait();
    }
    delete screen;
    return returnType;
  }
#endif
  
