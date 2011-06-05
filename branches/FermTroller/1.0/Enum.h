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

//BTBOARD_3 Defaults: MUX, 16 Outputs, 8 Zones, 8 Heat Pins + 8 Cool Pins, 4 PID Heat Outputs
#if defined BTBOARD_3 && !defined USE_MUX
  #define USE_MUX
#endif

#if defined BTBOARD_3 && !defined NUM_OUTS
  #define NUM_OUTS 16
#endif

#if defined BTBOARD_3 && !defined NUM_ZONES
  #define NUM_ZONES 8
#endif

#if defined BTBOARD_3 && !defined COOLPIN_OFFSET
  #define COOLPIN_OFFSET 8
#endif

#if defined USE_MUX && !defined NUM_PID_OUTS
  #define NUM_PID_OUTS 4
#endif

//BTBOARD_2.x Defaults: 12 Outputs, 6 Zones, 6 Heat Pins + 6 Cool Pins, 6 PID Heat Outputs
#if !defined BTBOARD_3 && !defined NUM_OUTS
  #define NUM_OUTS 12
#endif

#if !defined BTBOARD_3 && !defined NUM_ZONES
  #define NUM_ZONES 6
#endif

#if !defined BTBOARD_3 && !defined COOLPIN_OFFSET
  #define COOLPIN_OFFSET 6
#endif

#if !defined BTBOARD_3 && !defined NUM_PID_OUTS
  #define NUM_PID_OUTS 6
#endif

#ifdef USE_MUX
  #define MUX_LATCH_PIN 12
  #define MUX_CLOCK_PIN 13
  #define MUX_DATA_PIN 14
  #define MUX_OE_PIN 10
#endif

//Safety catch if using fewer zones than defined PID outputs
#if NUM_PID_OUTS > NUM_ZONES
  #define NUM_PID_OUTS NUM_ZONES
#endif

#endif
