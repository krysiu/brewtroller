#ifndef BT_ENUM
#define BT_ENUM

#include "Config.h"

//Pin and Interrupt Definitions
#define ENCA_PIN 2
#define ENCB_PIN 4
#define TEMP_PIN 5

#define ENTER_PIN 11
#define ALARM_PIN 15
#define ENTER_INT 1
#define ENCA_INT 2

//P/V Ouput Defines
#define MUX_LATCH_PIN 12
#define MUX_CLOCK_PIN 13
#define MUX_DATA_PIN 14
#define MUX_OE_PIN 10

#define VALVE1_PIN 6 //Pin 4
#define VALVE2_PIN 7 //Pin 3

#ifdef BTBOARD_22
  #define VALVE3_PIN 25
  #define VALVE4_PIN 26
#else
  #define VALVE3_PIN 8 //Pin 6
  #define VALVE4_PIN 9 //Pin 7
#endif

#define VALVE5_PIN 10 //Pin 8
#define VALVE6_PIN 12 //Pin 7
#define VALVE7_PIN 13 //Pin 10
#define VALVE8_PIN 14 //Pin 9
#define VALVE9_PIN 24 //Pin 12
#define VALVEA_PIN 18 //Pin 11
#define VALVEB_PIN 16 //Pin 14

#define PIT1_HEAT_PIN 0 // Labeled "HLT" on Board
#define PIT2_HEAT_PIN 1 // Labeled "MLT" on Board
#define PIT3_HEAT_PIN 3 // Labeled "KET" on Board
//#define STEAMHEAT_PIN 6 // Not Used

//Reverse pin swap on 2.x boards
#ifdef BTBOARD_22
  #define HLTVOL_APIN 2
  #define KETTLEVOL_APIN 0
#else
  #define HLTVOL_APIN 0
  #define KETTLEVOL_APIN 2
#endif

#define MASHVOL_APIN 1
#define STEAMPRESS_APIN 3

//TSensor and Output (0-2) Array Element Constants
#define TS_PIT_1 0
#define TS_PIT_2 1
#define TS_PIT_3 2
#define TS_FOOD_1 3
#define TS_FOOD_2 4
#define TS_FOOD_3 5
#define TS_AUX1 6
#define TS_AUX2 7
#define TS_AUX3 8
#define NUM_TS 9

#define PIT_1 0
#define PIT_2 1
#define PIT_3 2
#define FOOD_1 3
#define FOOD_2 4
#define FOOD_3 5

//Auto-Valve Modes
#define AV_FILL 0
#define AV_MASH 1
#define AV_SPARGEIN 2
#define AV_SPARGEOUT 3
#define AV_FLYSPARGE 4
#define AV_CHILL 5
#define AV_HLT 6
#define NUM_AV 7

//Valve Array Element Constants and Variables
#define VLV_ALL 4294967295
#define VLV_FILLHLT 0
#define VLV_FILLMASH 1
#define VLV_ADDGRAIN 2
#define VLV_MASHHEAT 3
#define VLV_MASHIDLE 4
#define VLV_SPARGEIN 5
#define VLV_SPARGEOUT 6
#define VLV_HOPADD 7
#define VLV_KETTLELID 8
#define VLV_CHILLH2O 9
#define VLV_CHILLBEER 10
#define VLV_BOILRECIRC 11
#define VLV_DRAIN 12
#define VLV_HLTHEAT 13
#define NUM_VLVCFGS 14

//Timers
#define TIMER_S1 0
#define TIMER_S2 1
#define TIMER_S3 2

//Smoke Steps
#define NUM_SMOKE_STEPS 4

#define STEP_ONE 0
#define STEP_TWO 1
#define STEP_THREE 2
#define STEP_FOUR 3

#define PIT_STEP_ONE 0
#define PIT_STEP_TWO 1
#define PIT_STEP_THREE 2
#define PIT_STEP_FOUR 3

//Zones
#define ZONE_MASH 0
#define ZONE_BOIL 1

//Events
#define EVENT_STEPINIT 0
#define EVENT_SETPOINT 1

//Log Constants
#define CMD_MSG_FIELDS 25
#define CMD_FIELD_CHARS 21

#endif
