unsigned long readVolume( byte pin, unsigned long calibrationVols[10], unsigned int calibrationValues[10], unsigned int zeroValue ) {
  unsigned int aValue = analogRead(pin);
  unsigned long retValue;
  #ifdef DEBUG
    logStart_P(LOGDEBUG);
    logField_P(PSTR("VOL_READ"));
    logFieldI(pin);
    logFieldI(aValue);
    logFieldI(zeroValue);
  #endif
  if (aValue <= zeroValue) aValue = 0; else aValue -= zeroValue;
  
  byte upperCal = 0;
  byte lowerCal = 0;
  byte lowerCal2 = 0;
  for (byte i = 0; i < 10; i++) {
    if (aValue == calibrationValues[i]) { 
      upperCal = i;
      lowerCal = i;
      lowerCal2 = i;
      break;
    } else if (aValue > calibrationValues[i]) {
        if (aValue < calibrationValues[lowerCal]) lowerCal = i;
        else if (calibrationValues[i] > calibrationValues[lowerCal]) { 
          if (aValue < calibrationValues[lowerCal2] || calibrationValues[lowerCal] > calibrationValues[lowerCal2]) lowerCal2 = lowerCal;
          lowerCal = i; 
        } else if (aValue < calibrationValues[lowerCal2] || calibrationValues[i] > calibrationValues[lowerCal2]) lowerCal2 = i;
    } else if (aValue < calibrationValues[i]) {
      if (aValue > calibrationValues[upperCal]) upperCal = i;
      else if (calibrationValues[i] < calibrationValues[upperCal]) upperCal = i;
    }
  }
  
  #ifdef DEBUG
    logFieldI(aValue);
    logFieldI(upperCal);
    logFieldI(lowerCal);
    logFieldI(lowerCal2);
  #endif
  
  //If no calibrations exist return zero
  if (calibrationValues[upperCal] == 0 && calibrationValues[lowerCal] == 0) retValue = 0;

  //If the value matches a calibration point return that value
  else if (aValue == calibrationValues[lowerCal]) retValue = calibrationVols[lowerCal];
  else if (aValue == calibrationValues[upperCal]) retValue = calibrationVols[upperCal];
  
  //If read value is greater than all calibrations plot value based on two closest lesser values
  else if (aValue > calibrationValues[upperCal] && calibrationValues[lowerCal] > calibrationValues[lowerCal2]) retValue = round((float) (aValue - calibrationValues[lowerCal]) / (float) (calibrationValues[lowerCal] - calibrationValues[lowerCal2]) * (calibrationVols[lowerCal] - calibrationVols[lowerCal2])) + calibrationVols[lowerCal];
  
  //If read value exceeds all calibrations and only one lower calibration point is available plot value based on zero and closest lesser value
  else if (aValue > calibrationValues[upperCal]) retValue = round((float) (aValue - calibrationValues[lowerCal]) / (float) (calibrationValues[lowerCal]) * (calibrationVols[lowerCal])) + calibrationVols[lowerCal];
  
  //If read value is less than all calibrations plot value between zero and closest greater value
  else if (aValue < calibrationValues[lowerCal]) retValue = round((float) aValue / (float) calibrationValues[upperCal] * calibrationVols[upperCal]);
  
  //Otherwise plot value between lower and greater calibrations
  else retValue = round((float) (aValue - calibrationValues[lowerCal]) / (float) (calibrationValues[upperCal] - calibrationValues[lowerCal]) * (calibrationVols[upperCal] - calibrationVols[lowerCal])) + calibrationVols[lowerCal];

  #ifdef DEBUG
    logFieldI(retValue);
    logEnd();
  #endif
}

//Read Analog value of aPin and calculate kPA or psi based on unit and sensitivity (sens in tenths of mv per kpa)
unsigned long readPressure( byte aPin, byte sens, boolean unit ) {
  unsigned long retValue = analogRead(aPin) * .0049 / (sens / 10000.0);
  if (unit) return retValue * .145; 
  else return retValue; 
}
