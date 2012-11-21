#ifndef BT_CONFIGURATION
  #define BT_CONFIGURATION
  #include "Global.h"
    
  #define VESSELS_MAX 4
  #define TSENSOR_USERDEFINED_COUNT 4
  
  #define ANALOG_CALIBRATION_COUNT 10
  
  #define OUTPUTPROFILES_USERDEFINED_COUNT 4
  #define OUTPUTPROFILES_MAXCOUNT (VESSELS_MAX * 2 + OUTPUTPROFILES_USERDEFINED_COUNT + 13)
  
  #define RECIPES_MAXACTIVE 2
  
  #define RECIPES_NUMSLOTS 15
  #define HOPADDS_MAX 10
  #define HOPADDS_NAMELEN 8
  
  #define MASHSTEPS_COUNT 6
  #define SPARGE_BATCHESMAX 5
  
  #define I2C_SUPPORT
  
  #define BTPD_SUPPORT
  #define BTPD_MAXDEVICES 12
  #define BTPD_ADDRSTART 0x20
  
  #define RGBIO8_SUPPORT
  #define RGBIO8_MAXDEVICES 4
  #define RGBIO8_ADDRSTART 0x30
  
  #define BTNIC_PROTOCOL
  #define COM_SERIAL0  BTNIC
  #define SERIAL0_BAUDRATE 115200
  #define BTNIC_EMBEDDED
  

  
  
  typedef struct cfgHeader_t {
    byte cfgType;             //What firmware is the configuration for?
    unsigned int cfgVersion;  //Version of configuration structure
    unsigned int cfgSize;     //Size of configuration structure
  };
  
  struct btConfig_t {
    cfgHeader_t cfgHeader;
    boolean unitMetric;
    oneWireBusCfg_t TS1WireBusCfg;

    byte vesselCount;
    struct vesselCfg_t vesselCfg[VESSELS_MAX];

    struct vesselRoles_t {
      byte strikeHeat, spargeHeat, mash, boil, hex, lauter;
    };
    
    struct mash_t {
      //Bitmask representing additional AUX sensors to average with Mash sensor to derive averaged Mash Temperature
      byte mashAverageSensors;
      
      //Specific heat of the mash tun in hundreths Cal/gram-deg C. Used only for calculating strike temperature when
      //strike is heated in another vessel and transferred to the mash tun
      byte mashSpecificHeat;
      
      //This offset is used to prevent overshooting the mash temperature by cutting heat power prior to reaching the setpoint
      //This is especially useful for Direct Fired RIMS where a dedicate RIMS 'vessel' provides fine control and the mash heat
      //is used to control a burner for larger steps
      byte mashOffset;
    } mash;
    
    struct hex_t {
      //Increases HEX setpoint by the specified value (tenths) to offset losses in transfer
      byte hexOffset;
      
      //Delay in seconds activation of HEX heat whenever the mash setpoint is enabled
      //This is used for RIMS users to avoid dry-firing the RIMS element
      byte hexDelay;

      //If active, Boosts HEX temperature by difference between mash setpoint and actual mash temperature
      boolean smartHEX;
      byte smartMaxTemp;
    } hex;
    
    struct sparge_t {
      boolean heatStrike; //Heat strike while sparging
      triggerCfg_t maxSpargeVolTrig;
      unsigned int hysteresis; //Fly sparge hysteresis
    } sparge;
    
    struct boilControl_t {
      int boiltemp;
      byte boilPower;
      int preboilTemp; //Temperature to activate proboil alarm
      byte boilRecircMins; //Number of minutes at end of boil to enable boilRecirc profile; 0 = Disabled
    } boilControl;
    
    struct boilAdd_t {
      byte pinIndex;
      byte activeTime; //In tenths of a second
      triggerCfg_t stopTrig;
    } boilAdd;  
    
    struct kettleLid_t {
      byte pinIndex;
      int activeTemp;
    } kettleLid;

    struct chiller_t {
      tSensorCfg_t tSensor_H2OIn, tSensor_H2OOut, tSensor_WortOut;
    } chiller;

    struct userDefined_t {
      tSensorCfg_t tSensorCfg[TSENSOR_USERDEFINED_COUNT];
      unsigned long outputProfile[];
    } userDefined;
    
    struct stepLogic_t {
      boolean autoFill;
      boolean autoRefill;
      boolean autoFillAdv;
      boolean autoStrikeXfer;
      boolean mashHold; //If enabled waits for user to advance from Mash Hold, Otherwise advances when HLT reaches Sparge Temp; 
      boolean autoSparge;
      boolean autoSpargeAdv;
      byte spargeRecircMins;
      byte grainInMins; //0 = Skip step, 255 = User Advance, 1-254 = minutes
    } stepLogic;

    struct recovery_t {
      struct timer_t {
        unsigned int timerMins;
        bool status;
        bool alarm;
      } timer[2];
      struct actRecipes_t {
        byte recipe;
        byte step;
      } activeRecipes[RECIPES_MAXACTIVE];
      unsigned int boilAddsAck;
    } recovery;
   
    struct display_t {
      byte bright;
      byte contrast;
    } display;
    
    struct alarm_t {
      byte pinIndex;
 
      //Modulation on percentage (0-100%): if less than 100 then the alarm when active will be on for the
      //given perctage of the modulateTimer period below
      byte modulateOnPct;
 
      //Modulation cycle time (in tenths of a second) 
      byte modulateTime; 
    } alarm;

    triggerCfg_t estopTrig;

    struct btpd_t {
      byte lineFunc[2];
    } btpd[BTPD_MAXDEVICES];
    byte btpdInterval; //Refresh rate in tenths of a second
    
    struct rgbio8_t {
      byte channelFunc[8];
    } rgbio8;
    
    struct calcFactors_t {
      // grain2Vol: The amount of volume in (hundreths) l/kg or gal/lb that grain occupies in the mash
      // Conservatively 1 lb = 0.15 gal (1.25 l/kg) **BT 2.x Default
      // Aggressively 1 lb = 0.093 gal
      // Beersmith 0.078 gal/lb
      byte grain2Vol;
      
      // GRAIN_VOL_LOSS: The amount of liquid volume lost with spent grain in gal/lb or l/kg.
      // This value can vary by grain types, crush, etc.
      // Ray Daniels suggests .20, Denny Conn suggests .10
      // BT 2.x Default: .2143 gal/lb or 1.7884 l/kg -> pretty conservative (err on more absorbtion)
      // Value multiplier: 0.0001 (ie 2143 = 0.2143)
      unsigned int grainVolLoss;
      
      //Rate at which kettle volume is decreased during boil in (thousandths) gal /hr or l /hr
      unsigned int boilEvapRate;
      
      //Cooling "loss": Volume reduction in percent as a result of reducing temperature from boil used to
      //convert evaporation rates at boil to real volumes
      byte coolShrinkPct;
    } calcFactors;
    
    unsigned int recipeDelay;
    int grainTemp;
    
    struct recipe_t {
      char name[20];
      unsigned long batchVol;
      unsigned long grainWeight;
      unsigned int mashRatio;
      struct mashSched_t {
        int temp;
        byte mins;
      } mashSched[MASHSTEPS_COUNT];
      byte spargeBatches; //0 = Full boil mash/Fly Sparge
      int spargeTemp;
      unsigned int boilMins;
      int pitchTemp;
      struct hopAdd_t {
        byte mins;
        char name[HOPADDS_NAMELEN];
        unsigned int weight;
      } hopAdd[HOPADDS_MAX];
    } recipe[RECIPES_NUMSLOTS];
  };

#endif

