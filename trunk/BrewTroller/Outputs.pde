/*  
   Copyright (C) 2009 - 2012 Open Source Control Systems, Inc.

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.


BrewTroller - Open Source Brewing Controller
Documentation, Forums and more information available at http://www.brewtroller.com
*/
  
#define OUTPUTBANK_NAME_MAXLEN 20
#define OUTPUTBANKS_MAXBANKS 4

class OutputBank
{
public:
  //OutputBank subclass may optionally (re)define the following
  virtual void init(void) { }
  virtual char* getOutputName(byte index, char* retString) {
    char outputName[10] = "Output ";
    char strIndex[3];
    strlcpy(retString, "Output ", OUTPUTBANK_NAME_MAXLEN);
    strlcat(retString, itoa(index + 1, strIndex, 10), OUTPUTBANK_NAME_MAXLEN);
    return retString;
  }
  
  //OutputBank subclass must define the following
  virtual void set(unsigned long) = 0;
  virtual char* getBankName(char* retSring) = 0;
  virtual byte getCount(void) = 0;
};

#ifdef OUTPUTBANK_GPIO
class OutputBankGPIO : public OutputBank
{
  private:
  pin* outputPins;
 
  public:
  OutputBankGPIO(void) {
    outputPins = (pin *) malloc(OUTPUTBANK_GPIO_COUNT * sizeof(pin));
    byte pinNums[OUTPUTBANK_GPIO_COUNT] = OUTPUTBANK_GPIO_PINS;
    for (byte i = 0; i < OUTPUTBANK_GPIO_COUNT; i++) outputPins[i].setup(pinNums[i], OUTPUT);
  }

  ~OutputBankGPIO() {
    free(outputPins);
  }

  void set(unsigned long outputsState) {
    for (byte i = 0; i < OUTPUTBANK_GPIO_COUNT; i++) {
      outputPins[i].set((outputsState>>i) & 1);
    }
  }
  
  char* getBankName (char* retString) {
    char bankName[] = OUTPUTBANK_GPIO_BANKNAME;
    strlcpy(retString, bankName, OUTPUTBANK_NAME_MAXLEN);
    return retString;
  }
  
  char* getOutputName (byte index, char* retString) {
    if (index < OUTPUTBANK_GPIO_COUNT) {
      char outputNames[] = OUTPUTBANK_GPIO_OUTPUTNAMES;
      char* pos = outputNames;
      for (byte i = 0; i <= index; i++) {
        strlcpy(retString, pos, OUTPUTBANK_NAME_MAXLEN);
        pos += strlen(retString) + 1;
      }
    }
    else retString[0] = '\0';
    return retString;
  }
  
  byte getCount(void) { return OUTPUTBANK_GPIO_COUNT; }
  
};
#endif

#ifdef OUTPUTBANK_MUX
class OutputBankMUX : public OutputBank
{
  private:
  pin muxLatchPin, muxDataPin, muxClockPin, muxEnablePin;
  
  public:
  OutputBankMUX(void) {
    muxLatchPin.setup(OUTPUTBANK_MUX_LATCHPIN, OUTPUT);
    muxDataPin.setup(OUTPUTBANK_MUX_DATAPIN, OUTPUT);
    muxClockPin.setup(OUTPUTBANK_MUX_CLOCKPIN, OUTPUT);
    muxEnablePin.setup(OUTPUTBANK_MUX_ENABLEPIN, OUTPUT);
  }
  
  void init(void) {
    #ifdef OUTPUTBANK_MUX_ENABLELOGIC
      //MUX in Reset State
      muxLatchPin.clear(); //Prepare to copy pin states
      muxEnablePin.clear(); //Force clear of pin registers
      muxLatchPin.set();
      delayMicroseconds(10);
      muxLatchPin.clear();
      muxEnablePin.set(); //Disable clear
    #else
      outputsState = 0;
      update();
      muxEnablePin.clear();
    #endif
  }
  
  void set(unsigned long outputsState) {
    //ground latchPin and hold low for as long as you are transmitting
    muxLatchPin.clear();
    //clear everything out just in case to prepare shift register for bit shifting
    muxDataPin.clear();
    muxClockPin.clear();
  
    for (byte i = OUTPUTBANK_MUX_COUNT; i > 0; i--)  {
      muxClockPin.clear();
      muxDataPin.set(outputsState & ((unsigned long)1<<(i - 1)));
      muxClockPin.set();
      muxDataPin.clear();
    }
  
    //stop shifting
    muxClockPin.clear();
    muxLatchPin.set();
    delayMicroseconds(10);
    muxLatchPin.clear();
  }
  
  char* getBankName (char* retString) {
    char bankName[] = OUTPUTBANK_MUX_BANKNAME;
    strlcpy(retString, bankName, OUTPUTBANK_NAME_MAXLEN);
    return retString;
  }
  
  byte getCount(void) { return OUTPUTBANK_MUX_COUNT; }
};
#endif

#ifdef OUTPUTBANK_MODBUS
class OutputBankMODBUS : public OutputBank
{
  private:
  ModbusMaster slave;
  byte slaveAddr, outputCount;
  unsigned int coilReg;

  public:
  OutputBankMODBUS(uint8_t addr, unsigned int coilStart, uint8_t coilCount) {
    slaveAddr = addr;
    slave = ModbusMaster(RS485_SERIAL_PORT, slaveAddr);
    #ifdef RS485_RTS_PIN
      slave.setupRTS(RS485_RTS_PIN);
    #endif
    slave.begin(RS485_BAUDRATE, RS485_PARITY);
    //Modbus Coil Register index starts at 1 but is transmitted with a 0 index
    coilReg = coilStart - 1;
    outputCount = coilCount;
  }
 
  char* getBankName (char* retString) {
    char bankName[14] = "MODBUS-8 #";
    char strAddr[6];
    strlcpy(retString, bankName, OUTPUTBANK_NAME_MAXLEN);
    strlcat(retString, itoa(slaveAddr, strAddr, 10), OUTPUTBANK_NAME_MAXLEN);
    strlcat(retString, "-", OUTPUTBANK_NAME_MAXLEN);
    strlcat(retString, itoa(coilReg + 1, strAddr, 10), OUTPUTBANK_NAME_MAXLEN);
    return retString;
  }
  
  void set(unsigned long outputsState) {
    byte outputPos = 0;
    byte bytePos = 0;
    while (outputPos < outputCount) {
      byte byteData = 0;
      byte bitPos = 0;
      while (outputPos < outputCount && bitPos < 8) {
        bitWrite(byteData, bitPos++, (outputsState >> outputPos++) & 1);
      }
      slave.setTransmitBuffer(bytePos++, byteData);
    }
    slave.writeMultipleCoils(coilReg, outputCount);
  }
  
  byte getCount(void) { return outputCount; }
};
#endif

struct OutputProfile {
  unsigned long mask;
  boolean state, overrideOn, overrideOff;
};

class Outputs
{
  private:
  OutputBank** banks;
  OutputProfile* profiles;
  byte profileCount;
  byte bankCount;
  unsigned long stateOn, overrideOn, overrideOff, lastStateOn, lastOverrideOn, lastOverrideOff;
  
  void addBank(OutputBank* outputBank) {
    if (bankCount < OUTPUTBANKS_MAXBANKS) {
      banks[bankCount++] = outputBank;
    }
  }
  
  public:
  Outputs(void) {
    banks = new OutputBank* [OUTPUTBANKS_MAXBANKS];
    for (uint8_t i = 0; i < OUTPUTBANKS_MAXBANKS; i++) {
      banks[i] = NULL;
    }
    bankCount = 0;
    #ifdef OUTPUTBANK_GPIO
      addBank(new OutputBankGPIO());
    #endif

    #if defined OUTPUTBANK_MUX
      addBank(new OutputBankMUX());
    #endif
    
    profiles = new OutputProfile[OUTPUTPROFILES_MAXCOUNT];
  }
  
  ~Outputs(void) {
    delete [] banks;
    if (profiles) delete profiles;
  }
  
  void init(void) {
    stateOn = overrideOn = overrideOff = lastStateOn = lastOverrideOn = lastOverrideOff = 0;
    byte bIndex = 0;
    while (bIndex < bankCount) { banks[bIndex++]->init(); }
    update();
  }
  
  #ifdef OUTPUTBANK_MODBUS
  void newModbusBank(uint8_t slaveAddr, unsigned int coilReg, uint8_t coilCount){
    addBank(new OutputBankMODBUS(slaveAddr, coilReg, coilCount));
  }
  #endif
  
  byte getBankCount(void){
    return bankCount;
  }
  
  OutputBank* getBank(uint8_t bankIndex){
    return banks[bankIndex];
  }
  
  void update(void) {
    //Start with outputs explicitly turned on
    unsigned long data = stateOn;
    
    //Apply all active valve profiles
    if (profileCount) {
      for (byte p = 0; p < profileCount; p++) {
        if (profiles[p].state) { data |= profiles[p].mask; }
        if (profiles[p].overrideOn) { overrideOn |= profiles[p].mask; profiles[p].overrideOn = 0; }
        if (profiles[p].overrideOff) { overrideOff |= profiles[p].mask; profiles[p].overrideOff = 0; }
      }
    }
    
    //Save lastState as explicit + profiles
    lastStateOn = data;

    //Apply overrides
    data |= overrideOn;
    data &= ~overrideOff;
    
    byte bIndex = 0;
    byte oIndex = 0;
    while (bIndex < bankCount && oIndex < 32) {
      unsigned long mask = 0;
      for (byte i = 0; i < banks[bIndex]->getCount(); i++) { mask |= (unsigned long) 1 << i; }
      banks[bIndex]->set(data & mask);
      data = data >> banks[bIndex++]->getCount();
    }
    //Copy overrides for get queries
    lastOverrideOn = overrideOn;
    lastOverrideOff = overrideOff;
    
    //Clear overrides for next update cycle
    overrideOn = overrideOff = 0;
  }
 
  void setOutputState(byte index, boolean value) {
    unsigned long mask = ((unsigned long)1 << index);
    if (value) stateOn |= mask;
    else stateOn &= ~mask;
  }
  
  boolean getOutputState(byte index) {
    return ((lastStateOn >> index) & 1);
  }
  
  boolean getOverrideOn(byte index) {
    return ((lastOverrideOn >> index) & 1);
  }

  boolean getOverrideOff(byte index) {
    return ((lastOverrideOff >> index) & 1);
  }
  
  void overrideOutputState(byte index, boolean value) {
    unsigned long mask = (unsigned long) 1 << index;
    if (value) { overrideOn |= mask; } 
    else { overrideOff |= mask; }
  }
  
  OutputProfile* addProfile() {
    if (profileCount < OUTPUTPROFILES_MAXCOUNT) return profiles[profileCount++];
    return NULL;
  }
};

typedef struct analogOutCfg_t {
  typedef enum {
    analogOutType_None,
    analogOutType_SWPWM,
    analogOutType_HWPWM,
    analogOutType_Modbus
  } analogOutType;
  union {
    struct analogOutCfg_SWPWM_t {
      byte index;
      byte period; //Time period in tenths of a second (0.0- 25.5s)
    } analogOutCfg_SWPWM;
    struct analogOutCfg_HWPWM_t {
      byte index; //HWProfile to provide array of Pin/Freq options
    } analogOutCfg_HWPWM;
    struct analogOutCfg_Modbus_t {
      byte slaveAddr;
      unsigned int reg;
      unsigned long limit; //Max value
    } analogOutCfg_Modbus;
  } implementation;
};

class analogOutput {
  private:
  byte value, limit;
  
  public:
  static analogOutput* create(analogOutCfg_t cfg) {
    if (cfg.analogOutType == analogOutType_SWPWM) 
      return new analogOuput_SWPWM(cfg.implementation.analogOutCfg_SWPWM.index, cfg.implementation.analogOutCfg_SWPWM.period);

    else if (cfg.analogOutType == analogOutType_SWPWM) {
      return new analogOuput_HWPWM(cfg.implementation.analogOutCfg_HWPWM.index);

    else { return NULL; }
  }
  
  virtual void setValue(byte v) { value = v; }
  byte getLimit( return limit; }
  virtual void init() {}
  virtual void update() = 0;
};

class analogOuput_SWPWM : public analogOutput {
  private:
  byte pinIndex;
  unsigned long sPeriod; //Start of PWM period: millis()
  //limit: (0-255 x 100ms)
  
  public:
  analogOuput_SWPWM(byte index, byte period) {
    pinIndex = index;
    limit = period;
  }
  
  void setValue(byte v) {
    //Transition from inactive to active
    if (!value && v) { sPeriod = millis(); }
    value = v;
    if (!value) Outputs.setOutputState(pinIndex, 0);
  }
  
  void update() {
    if (value) { 
      unsigned long sUpdated = millis();
      Outputs.setOutputState(pinIndex, (sUpdated - sPeriod < value * 100) ? 1 : 0);
      sPeriod = sUpdated;
    }
  }
};


class analogOuput_HWPWM : public analogOutput {
  private:
  byte pin;
  
  public:
  analogOuput_HWPWM(byte p) {
    pin = p;
  }
  
  void setValue(byte v) { analogWrite(pin, v);  }
  void update() {  }
  
  //Utility methods:
  static byte getCount() { 
      return ANALOGOUTPUTS_HWPWM_PINCOUNT;
  }
  
  static byte getPin(byte index) {
    if (index < ANALOGOUTPUTS_HWPWM_PINCOUNT) {
      byte pins[] = ANALOGOUTPUTS_HWPWM_PINS;
      return pins[index];
    }
    return 255;
  }

  static byte getTimer(byte index) { 
    if (index < ANALOGOUTPUTS_HWPWM_PINCOUNT) {
      byte timers[] = ANALOGOUTPUTS_HWPWM_TIMERS;
      return timers[index];
    }
    return 255;
  }

  static char* getName(byte index, char* retString) {
    if (index < ANALOGOUTPUTS_HWPWM_PINCOUNT) {
      char names[] = ANALOGOUTPUTS_HWPWM_NAMES;
      char* pos = names;
      for (byte i = 0; i <= index; i++) {
        strlcpy(retString, pos, OUTPUTBANK_NAME_MAXLEN);
        pos += strlen(retString) + 1;
      }
    }
    else retString[0] = '\0';
    return retString;
  }
  
  static byte getTimerModes(byte timer) { 
    if (timer == 0) return 1;
    else if (timer == 1) return 5;
    else if (timer == 2) return 7;
    else return 0;
  }

  static byte getTimerValue(byte timer, byte index) {
    if (timer == 0) { return 0x03; } //Timer 0 always equals 1KHz
    else if ((timer == 1 && index < 5) || (timer == 2 && index < 7)) { return index; } //Timer 1 values 1-5, Timer 2 values 1-7
    else return 0;
  }
  
  static char * getTimerText(byte timer, byte index, char* retString) {
    unsigned int freqs[3][7] = {
      {977, 0, 0, 0, 0, 0, 0},                //Timer0
      {31250, 3906, 488, 122, 30, 0, 0},      //Timer1
      {31250, 3906, 977, 488, 244, 122, 30}   //Timer2
    }
    unsigned int value = 0;
    if (index < 7) { value = freqs[timer][index]; }
    if (value == 0) strcpy(retString, "Invalid Mode");
    else if (value > 1000) {
      char sFreq[3];
      itoa(round(value/1000), sFreq, 10);
      strcpy(retString, sFreq);
      strcat(retString, " kHz");
    }
    else {
      char sFreq[4];
      itoa(value, sFreq, 10);
      strcpy(retString, sFreq);
      strcat(retString, " Hz");
    }
    return retString;
  }

};


