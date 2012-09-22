#ifndef GLOBAL_H
  #define GLOBAL_H
  
  #include <stdlib.h>
  #include <stdint.h>
  
  #define BAD_TEMP -32768
  
  typedef enum {
    //Reserve first X slots for Vessel Heat and second X slots for Vessel Idle
    OUTPUTPROFILE_FILLSTRIKE = VESSELS_MAX * 2,
    OUTPUTPROFILE_FILLSPARGE,
    OUTPUTPROFILE_FILLHEX,
    OUTPUTPROFILE_FILLGRAIN,
    OUTPUTPROFILE_STRIKEXFER,
    OUTPUTPROFILE_GRAINXFER,
    OUTPUTPROFILE_SPARGEIN,
    OUTPUTPROFILE_SPARGEOUT,
    OUTPUTPROFILE_VOROLAUF,
    OUTPUTPROFILE_WHIRLPOOL,
    OUTPUTPROFILE_CHILL,
    OUTPUTPROFILE_WORTOUT,
    OUTPUTPROFILE_DRAIN,
    OUTPUTPROFILE_USER1,
    OUTPUTPROFILE_USER2,
    OUTPUTPROFILE_USER3,
    OUTPUTPROFILE_USER4,
    OUTPUTPROFILE_NUMPROFILES
  } OutputProfiles;
  
  //Auto-Valve Modes
  typedef enum {
    AUTOVALVE_FILL = VESSELS_MAX,
    AUTOVALVE_SPARGEIN,
    AUTOVALVE_SPARGEOUT,
    AUTOVALVE_FLYSPARGE,
    AUTOVALVE_CHILL,
    AUTOVALVE_COUNT
  } autoValveLogic;

  //Timers
  typedef enum {
    TIMER_MASH,
    TIMER_BOIL,
    TIMER_NUMTIMERS
  } timers;
  
  //Brew Steps
  typedef enum {
    BREWSTEP_FILL,
    BREWSTEP_DELAY,
    BREWSTEP_PREHEAT,
    BREWSTEP_ADDGRAIN,
    BREWSTEP_REFILL,
    BREWSTEP_DOUGHIN,
    BREWSTEP_ACID,
    BREWSTEP_PROTEIN,
    BREWSTEP_SACCH,
    BREWSTEP_SACCH2,
    BREWSTEP_MASHOUT,
    BREWSTEP_MASHHOLD,
    BREWSTEP_SPARGE,
    //Reserve additional steps for batch sparge logic
    BREWSTEP_BOIL = BREWSTEP_SPARGE + SPARGE_BATCHESMAX * 3 + 1,
    BREWSTEP_CHILL,
    BREWSTEP_STEPCOUNT
  } brewSteps;
  
  //Zones
  typedef enum {
    BREWZONE_MASH,
    BREWZONE_BOIL,
    BREWZONE_COUNT
  } brewZones;

  //Events
  typedef enum {
    EVENT_STEPINIT,
    EVENT_STEPEXIT,
    EVENT_SETPOINT,
    EVENT_ESTOP,
    EVENT_COUNT
  } events;
  
  //Log Constants
  #define CMD_MSG_FIELDS 25
  #define CMD_FIELD_CHARS 21
  
  #define BT_I2C_ADDR 0x10
  #define BTNIC_I2C_ADDR 0x11
  
  #define ASCII 0
  #define BTNIC 1
  #define BINARY 2
  
  typedef enum {
    CONTROLSTATE_OFF,
    CONTROLSTATE_AUTO,
    CONTROLSTATE_ON,
    NUM_CONTROLSTATES
  } ControlState;
  
  
    
  void* operator new(size_t size) {
    return malloc(size);
  }
  
  void operator delete(void* ptr) {
      free(ptr);
  }
  
  void * operator new[](size_t size) {
      return malloc(size);
  }
  
  void operator delete[](void * ptr) {
      if (ptr) {
          free(ptr);
      }
  }
#endif
