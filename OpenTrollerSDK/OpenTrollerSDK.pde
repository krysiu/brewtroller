#include <ScreenUi.h>
#include <LiquidCrystalFP.h>
#include <pin.h>
#include <encoder.h>
#include <Wire.h>
#include <ModbusMaster.h>
#include "HWProfile.h"
#include <NewDelete.h>
#include <DS2482.h>
#include <OneWire.h>
#include "OT_UI.h"
#include "OT_Inputs.h"
#include "OT_Outputs.h"

//Define 1-Wire Bus Object
#ifdef TS_ONEWIRE
  #if defined TS_ONEWIRE_GPIO
    #include <OneWire.h>
    OneWire ds(TEMP_PIN);
  #elif defined TS_ONEWIRE_I2C
    #include <DS2482.h>
    DS2482 ds(DS2482_ADDR);
  #endif
#endif

outputs Outputs;

//Declare our worker function
void testCore(void);

//Create UI and pass worker function
screenUI ScreenUI(testCore);

void setup() {
  #ifdef I2C_SUPPORT
    Wire.begin(BT_I2C_ADDR);
    #ifdef TS_ONEWIRE_I2C
      ds.configure(DS2482_CONFIG_APU | DS2482_CONFIG_SPU);
    #endif
  #endif

  //Attach Outputs to SWPWM
  analogOutput_SWPWM::setup(&Outputs);
  
  //Attach 1-Wire bus to tSensor_1Wire
  tSensor_1Wire::setup(&ds, 1, 1, 1);
  
  //Add Modbus bank
  Outputs.newModbusBank(10,1000,8);
  
  delay(1000);
  Wire.begin();
  pinMode(LCD_BRIGHT_PIN, OUTPUT);
  pinMode(LCD_CONTRAST_PIN, OUTPUT);
  TCCR2B = 0x01;
  analogWrite(LCD_BRIGHT_PIN, 255 - LCD_DEFAULT_BRIGHTNESS);
  analogWrite(LCD_CONTRAST_PIN, LCD_DEFAULT_CONTRAST);
  Serial.begin(115200);
}

unsigned long outProfileX = 0;
byte pwmPinX = 0;
tSensorCfg_t sensorXCfg;
analogInCfg_t aInXCfg;

void mainMenu() {
  Screen * screen = ScreenUI.create(20, 4);
  Label titleLabel("ScreenUI Main Menu");
  screen->add(&titleLabel, 0, 0);
  ScrollContainer scrollContainer(screen, screen->width(), 3);
  
  Button pwmPinBtn("Select Output");
  scrollContainer.add(&pwmPinBtn, 0, 1);
  
  Button profileXBtn("Cfg Output Profile");
  scrollContainer.add(&profileXBtn, 0, 2);

  Button tSensorBtn("Cfg Temp Sensor");
  scrollContainer.add(&tSensorBtn, 0, 3);

  Button aInBtn("Cfg AnalogIn");
  scrollContainer.add(&aInBtn, 0, 4);

  
  screen->add(&scrollContainer, 0, 1);
  
  while (1) {
    screen->update();
    if (pwmPinBtn.pressed()) {
      pwmPinX = ScreenUI.dlgSelectOutput("Select Output", &Outputs, pwmPinX);
      screen->clear(); screen->repaint();
    }
    else if (profileXBtn.pressed()) {
      outProfileX = ScreenUI.dlgCfgOutputProfile("Cfg Output Profile", &Outputs, outProfileX);
      screen->clear(); screen->repaint();
    }
    else if (tSensorBtn.pressed()) {
      ScreenUI.dlgCfgTSensor("Cfg Temp Sensor", &sensorXCfg);
      screen->clear(); screen->repaint();
    }
    else if (aInBtn.pressed()) {
      ScreenUI.dlgCfgAnalogIn("Cfg Analog Input", &aInXCfg);
      screen->clear(); screen->repaint();
    }
    //Call worker process
    ScreenUI.wait();
  }  
}

void loop() {
  mainMenu();
}

void testCore (void) {
  Outputs.update();
}

