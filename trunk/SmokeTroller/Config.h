#ifndef BT_CONFIGURATION
  #define BT_CONFIGURATION
  
  //*****************************************************************************************************************************
  // USER COMPILE OPTIONS
  //*****************************************************************************************************************************
  
  
  //**********************************************************************************
  // UNIT (Metric/US)
  //**********************************************************************************
  // By default BrewTroller will use US Units
  // Uncomment USEMETRIC below to use metric instead
  //
  //#define USEMETRIC
  //**********************************************************************************
  
  //**********************************************************************************
  // MAXIMUM VALUES 
  //**********************************************************************************
  // List the maximum values that will appear to the user
  //
  #define MAX_FOOD_TEMP 180
  #define MAX_PIT_TEMP 500
  #define MAX_STEP_TIME_HOURS 48
  //**********************************************************************************

  //**********************************************************************************
  // BrewTroller Board Version
  //**********************************************************************************
  // Certain pins have moved from one board version to the next. Uncomment one of the
  // following definitions to to indifty what board you are using.
  // Use BTBOARD_1 for 1.0 - 2.1 boards without the pump/valve 3 & 4 remapping fix
  // Use BTBOARD_22 for 2.2 boards and earlier boards that have the PV 3-4 remapping
  // Use BTBOARD_3 for 3.0 boards
  //
  //#define BTBOARD_1
  //#define BTBOARD_22
  #define BTBOARD_3
  //**********************************************************************************


  //**********************************************************************************
  // MUX Boards
  //**********************************************************************************
  // Uncomment one of the following lines to enable MUX'ing of Pump/Valve Outputs
  // Note: MUX'ing requires 1-4 expansion boards providing 8-32 pump/valve outputs
  // To use the original 11 Pump/valve outputs included in BrewTroller 1.0 - 2.0 leave
  // all lines commented. If you are using BTBOARD_3, MUXBOARDS 2 is used automatically
  // but you can override the default by specifying a value below.
  //
  //#define MUXBOARDS 1
  //#define MUXBOARDS 2
  //#define MUXBOARDS 3
  //#define MUXBOARDS 4
  //**********************************************************************************


  //**********************************************************************************
  // PID Output Power Limit
  //**********************************************************************************
  // These settings can be used to limit the PID output of the the specified heat
  // output. Enter a percentage (0-100)
  //
  #define PIDLIMIT_PIT1 100
  #define PIDLIMIT_PIT2 100
  #define PIDLIMIT_PIT3 100
  //**********************************************************************************


  //**********************************************************************************
  // OneWire Temperature Sensor Options
  //**********************************************************************************
  // TS_ONEWIRE: Enables use of OneWire Temperature Sensors (Future logic may
  // support alternatives temperature sensor options.)
  #define TS_ONEWIRE
  
  // TS_ONEWIRE_PPWR: Specifies whether parasite power is used for OneWire temperature
  // sensors. Parasite power allows sensors to obtain their power from the data line
  // but significantly increases the time required to read the temperature (94-750ms
  // based on resolution versus 10ms with dedicated power).
  #define TS_ONEWIRE_PPWR 0
  
  // TS_ONEWIRE_RES: OneWire Temperature Sensor Resolution (9-bit - 12-bit). Valid
  // options are: 9, 10, 11, 12). Unless parasite power is being used the recommended
  // setting is 12-bit (for DS18B20 sensors). DS18S20 sensors can only operate at a max
  // of 9 bit. When using parasite power decreasing the resolution reduces the 
  // temperature conversion time: 
  //   12-bit (0.0625C / 0.1125F) = 750ms 
  //   11-bit (0.125C  / 0.225F ) = 375ms 
  //   10-bit (0.25C   / 0.45F  ) = 188ms 
  //    9-bit (0.5C    / 0.9F   ) =  94ms   
  #define TS_ONEWIRE_RES 9
  //**********************************************************************************
  
  
  //**********************************************************************************
  // Food Almost Done Alarm Threshold
  //**********************************************************************************
  // FOOD_ALRM_THRSHOLD: Triggers the alarm when the desired food temp minus the  
  // actual food temp is less than this set value
  
  #define FOOD_ALRM_THRSHOLD 10
  //**********************************************************************************
  
  
  //**********************************************************************************
  // Buzzer modulation parameters
  //**********************************************************************************
  // These parameters allow to modulate the sound of the alarm. 
  // The modulation occurs when the BUZZER_CYCLE_TIME value is larger than the BUZZER_ON_TIME
  // When the BUZZER_CYCLE_TIME is zero there is no modulation so the buzzer will buzz  
  // a steady sound
  
  #define BUZZER_CYCLE_TIME 0 //the value is in milliseconds for the ON and OFF buzzer cycle
  #define BUZZER_ON_TIME 500     //the duration in milliseconds where the alarm will stay on
  //**********************************************************************************
  
  
  //**********************************************************************************
  // Serial Logging Options
  //**********************************************************************************
  // COMTYPE:   Specifies the communication type being used. 
  // COMSCHEMA: Specifies the schema for a particular type
  //  0 = ASCII Messages
  //      0 - Original BT 2.0 Messages
  //      1 - BT 2.1 Enhanced ASCII
  //       Steam, Calc. Vol & Temp, BoilPower, Grain Temp, Delay Start, MLT Heat Source
  //  1 = BTnic Messages - Non-Broadcasting, Single Byte Commands
  //      0 - Original implementation
  //      1 - With CRC
  //  2 = Binary Messages
  //      0 = Original implementation
  //**********************************************************************************
  #define COMTYPE   0
  #define COMSCHEMA 1
  
  // BAUD_RATE: The baud rate for the serial connection. Previous to BrewTroller 2.0
  // Build 419 this was hard coded to 9600. Starting with Build 419 the default rate
  // was increased to 115200 but can be manually set using this compile option.
  #define BAUD_RATE 115200
  
  // LOG_INTERVAL: Specifies how often data is logged via serial in milliseconds. If
  // real time display of data is being used a smaller interval is best (1000 ms). A
  // larger interval can be used for logging applications to reduce log file size 
  // (5000 ms).
  #define LOG_INTERVAL 2000
  
  // LOG_INITSTATUS: Sets whether logging is enabled on bootup. Log status can be
  // toggled using the SET_LOGSTATUS command.
  #define LOG_INITSTATUS 0
  //**********************************************************************************
  
  
  //**********************************************************************************
  // UI Support
  //**********************************************************************************
  // NOUI: Disable built-in user interface 
  // UI_NO_SETUP: 'Light UI' removes system setup code to reduce compile size (~8 KB)
  // UI_LCD_I2C: Enables the I2C LCD interface instead of the 4 bit interface
  //
  //#define NOUI
  //#define UI_NO_SETUP
  //#define UI_LCD_I2C
  //**********************************************************************************
  
  
  //**********************************************************************************
  // BrewTroller PID Display (BTPD)
  //**********************************************************************************
  // BTPD is an external LED display developed by BrewTroller forum member vonnieda. 
  // It is a 2 line, 4 digit (8 digits total) LED display with one line red and one
  // line green. The digits are about a half inch high and can easily be seen across
  // the room. The display connects to the BrewTroller via the I2C header and can be
  // daisy chained to use as many as you like, theoretically up to 127 but in practice
  // probably 10 or so.
  
  // BTPD_SUPPORT: Enables use of BrewTroller PID Display devices on I2C bus
  //#define BTPD_SUPPORT
  
  // BTPD_INTERVAL: Specifies how often BTPD devices are updated in milliseconds.
  //#define BTPD_INTERVAL 1000
  
  // BTPD_P1_TEMP: Displays Smoker #1 temp and setpoint on specified channel
  //#define BTPD_P1_TEMP 0x20
  
  // BTPD_P2_TEMP: Displays Smoker #2 temp and setpoint on specified channel
  //#define BTPD_P2_TEMP 0x21
  
  // BTPD_P3_TEMP: Displays Smoker #3 temp and setpoint on specified channel
  //#define BTPD_P3_TEMP 0x22
  
  // BTPD_F1_TEMP: Displays Food #1 temp and setpoint on specified channel
  //#define BTPD_F1_TEMP 0x23
  
  // BTPD_F2_TEMP: Displays Food #2 temp and setpoint on specified channels
  //#define BTPD_F2_TEMP 0x24
  
  // BTPD_F3_TEMP: Displays Food #3 temp and setpoint on specified channels
  //#define BTPD_F3_TEMP 0x25
  
  //**********************************************************************************
  
  
  //**********************************************************************************
  // DEBUG
  //**********************************************************************************
  // DEBUG_TEMP_CONV_T: Enables logging of OneWire temperature sensor ADC time.
  //#define DEBUG_TEMP_CONV_T
  
  // DEBUG_VOL_READ: Enables logging of additional detail used in calculating volume.
  //#define DEBUG_VOL_READ
  
  // DEBUG_PID_GAIN: Enables logging of PID Gain settings as they are set.
  //#define DEBUG_PID_GAIN
  
  // DEBUG_TIMERALARM: Enables logging of Timer and Alarm values
  //#define DEBUG_TIMERALARM
  
  // DEBUG_VOLCALIB: Enables logging of Volume Calibration values
  //#define DEBUG_VOLCALIB
  
  // DEBUG_PROG_CALC_VOLS: Enables logging of PreBoil, Sparge, and Total water calcs 
  // based on the running program
  //#define DEBUG_PROG_CALC_VOLS
  
  // DEBUG_UI: Enables logging of UI debugging info
  #define DEBUG_UI
  
  //**********************************************************************************

#endif

