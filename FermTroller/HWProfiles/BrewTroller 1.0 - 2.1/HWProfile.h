/*
BrewTroller 1.0 - 2.1 Hardware Configuration
*/

#ifndef BT_HWPROFILE
#define BT_HWPROFILE
  #include "Config.h"

  
  //**********************************************************************************
  // ENCODER TYPE
  //**********************************************************************************
  // You must uncomment one and only one of the following ENCODER_ definitions
  // Use ENCODER_ALPS for ALPS and Panasonic Encoders
  // Use ENCODER_CUI for older CUI encoders
  //
  #define ENCODER_TYPE ALPS
  //#define ENCODER_TYPE CUI
  //**********************************************************************************
  
  #define ENCODER_OLD_CONSTRUCTOR
  #define ENCA_PIN 2
  #define ENCB_PIN 4
  #define ENTER_PIN 11
  #define ENTER_INT 1
  #define ENCA_INT 2

  #define PVOUT_TYPE_GPIO
  #define PVOUT_COUNT 16 //16 Outputs

  #define VALVE1_PIN 6 //Pin 4
  #define VALVE2_PIN 7 //Pin 3
  #define VALVE3_PIN 8 //Pin 6
  #define VALVE4_PIN 9 //Pin 7
  #define VALVE5_PIN 10 //Pin 8
  #define VALVE6_PIN 12 //Pin 7
  #define VALVE7_PIN 13 //Pin 10
  #define VALVE8_PIN 14 //Pin 9
  #define VALVE9_PIN 24 //Pin 12
  #define VALVEA_PIN 18 //Pin 11
  #define VALVEB_PIN 16 //Pin 14
  #define VALVEC_PIN 0  //HLT
  #define VALVED_PIN 1  //Mash
  #define VALVEE_PIN 3  //Kettle
  #define VALVEF_PIN 6  //Steam
  #define VALVEG_PIN 15 //Buuzzer
  
//**********************************************************************************
// OneWire Temperature Sensor Options
//**********************************************************************************
// TS_ONEWIRE: Enables use of OneWire Temperature Sensors (Future logic may
// support alternatives temperature sensor options.)
#define TS_ONEWIRE
#define TS_ONEWIRE_GPIO
#define TEMP_PIN 5

// TS_ONEWIRE_PPWR: Specifies whether parasite power is used for OneWire temperature
// sensors. Parasite power allows sensors to obtain their power from the data line
// but significantly increases the time required to read the temperature (94-750ms
// based on resolution versus 10ms with dedicated power).
#define TS_ONEWIRE_PPWR 1

// TS_ONEWIRE_RES: OneWire Temperature Sensor Resolution (9-bit - 12-bit). Valid
// options are: 9, 10, 11, 12). Unless parasite power is being used the recommended
// setting is 12-bit (for DS18B20 sensors). DS18S20 sensors can only operate at a max
// of 9 bit. When using parasite power decreasing the resolution reduces the 
// temperature conversion time: 
//   12-bit (0.0625C / 0.1125F) = 750ms 
//   11-bit (0.125C  / 0.225F ) = 375ms 
//   10-bit (0.25C   / 0.45F  ) = 188ms 
//    9-bit (0.5C    / 0.9F   ) =  94ms   
#define TS_ONEWIRE_RES 11
//**********************************************************************************

  #define UI_LCD_4BIT
  #define LCD_RS_PIN 17
  #define LCD_ENABLE_PIN 19
  #define LCD_DATA4_PIN 20
  #define LCD_DATA5_PIN 21
  #define LCD_DATA6_PIN 22
  #define LCD_DATA7_PIN 23

#endif
