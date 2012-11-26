#ifndef OT_UI_h
#define OT_UI_h

#include <ScreenUi.h>
#include <LiquidCrystalFP.h>
#include <pin.h>
#include <encoder.h>
#include <Wire.h>
#include "HWProfile.h"
#include <NewDelete.h>
#include "OT_Outputs.h"
#include "OT_Inputs.h"

#define I2C_SEND_INT(x) { int value = x; Wire.send((uint8_t)(value >> 8));  Wire.send((uint8_t) value); }
#define I2C_RECV_INT(x) { }

class ScreenGPIO : public Screen {
  private:
    static LiquidCrystal* lcd;
    static bool encoderInit;
    
  public:
    ScreenGPIO(byte cols, byte rows, byte rs, byte enable, byte d4, byte d5, byte d6, byte d7, byte encType, byte encA, byte encB, byte encEnter);
    void getInputDeltas(int *x, int *y, bool *selected, bool *cancelled);
    void clear();
    void createCustomChar(uint8_t slot, uint8_t *data);
    void draw(uint8_t x, uint8_t y, const char *text);
    void draw(uint8_t x, uint8_t y, uint8_t customChar);
    void setCursorVisible(bool visible);
    void moveCursor(uint8_t x, uint8_t y);
    void setBlink(bool blink);
};

class ScreenI2Cv2 : public Screen {
  protected:
    byte i2cLCDAddr;
  
  public:
    ScreenI2Cv2(byte cols, byte rows);
    ScreenI2Cv2(byte cols, byte rows, byte addr);
    virtual void getInputDeltas(int *x, int *y, bool *selected, bool *cancelled);
    void clear();
    void createCustomChar(uint8_t slot, uint8_t *data);
    void draw(uint8_t x, uint8_t y, const char *text);
    void draw(uint8_t x, uint8_t y, uint8_t customChar);
    void setCursorVisible(bool visible);
    void moveCursor(uint8_t x, uint8_t y);
    void setBlink(bool blink);
};

class ScreenI2Cv1 : public ScreenI2Cv2 {
  private:
  
  public:
  ScreenI2Cv1(byte cols, byte rows, byte addr, byte encType, byte encA, byte encB, byte encEnter);
  void getInputDeltas(int *x, int *y, bool *selected, bool *cancelled);
};

typedef enum {
  SCREENTYPE_NONE,
  SCREENTYPE_GPIO,
  SCREENTYPE_I2CV1,
  SCREENTYPE_I2CV2,
  SCREENTYPE_MODBUS
} screenType_t;

class screenUI {
  private:
  screenType_t screenType;
  void (* waitFunc)(void);
  
  public: 
  screenUI(void (* wF)(void));
  Screen* create(byte cols, byte rows);
  screenType_t detect();
  boolean detectI2Cv2(byte i2cLCDAddr);
  boolean detectI2Cv1(byte i2cLCDAddr);  
  boolean detectModbus(byte mbAddr);
  void wait(void);
  
  bool dlgYesNo(char *title, char *message);
  byte dlgSelectOutput(char * title, outputs* Outputs, byte initValue);
  unsigned long dlgCfgOutputProfile(char * title, outputs* Outputs, unsigned long initValue);
  void dlgCfgTSensor(char * title, tSensorCfg_t* cfg);
  tSensorType dlgCfgTSensor_None(char*, tSensorCfg_t*);
  tSensorType dlgCfgTSensor_1Wire(char*, tSensorCfg_t*);
  tSensorType dlgCfgTSensor_Modbus(char*, tSensorCfg_t*);
  void dlgCfgAnalogIn(char * title, analogInCfg_t* cfg);
  analogInType dlgCfgAnalogIn_None(char*, analogInCfg_t*);
  analogInType dlgCfgAnalogIn_GPIO(char*, analogInCfg_t*);
  analogInType dlgCfgAnalogIn_Modbus(char*, analogInCfg_t*);  
};
#endif
