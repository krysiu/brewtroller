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
// PID Output Power Limit
//**********************************************************************************
// These settings can be used to limit the PID output of the the heat
// output. Enter a percentage (0-100)
//
#define PIDLIMIT 100
//**********************************************************************************

//**********************************************************************************
// LOG INTERVAL
//**********************************************************************************
// LOG_INTERVAL: Specifies how often data is logged via serial in milliseconds. If
// real time display of data is being used a smaller interval is best (1000 ms). A
// larger interval can be used for logging applications to reduce log file size 
// (5000 ms).
// LOG_INITSTATUS: Sets whether logging is enabled on bootup. Log status can be
// toggled using the SET_LOGSTATUS command.

#define LOG_INTERVAL 2000
#define LOG_INITSTATUS 1
//**********************************************************************************


//**********************************************************************************
// UI Support
//**********************************************************************************
// NOUI: Disable built-in user interface 
// UI_NO_SETUP: 'Light UI' removes system setup code to reduce compile size (~8 KB)
//
//#define NOUI
//#define UI_NO_SETUP
//**********************************************************************************

//**********************************************************************************
// DEBUG
//**********************************************************************************
// Enables Serial Out with Additional Debug Data
//
//#define DEBUG
//**********************************************************************************

//**********************************************************************************
// Enable Serial
//**********************************************************************************
// Comment out to disable use of serial

#define USESERIAL
//**********************************************************************************


//**********************************************************************************
// Temperature Reading Settings
//**********************************************************************************
// TC0_ERROR: Calibration correction in 0.25C units
// TC0_SAMPLES: Number of samples to use in reading (Max: 10)

#define TC0_ERROR 0 // Calibration compensation value in digital counts (.25˚C)
#define TC0_SAMPLES 10
#define TEMP_INTERVAL 250 //Delay between tc reads in ms
//**********************************************************************************
