unsigned long readVolume( byte pin, unsigned long calibrationVols[10], unsigned int calibrationValues[10], unsigned int zeroValue ) {
  unsigned int aValue = analogRead(pin);
  if (aValue <= zeroValue) return 0; else aValue -= zeroValue;
  
  byte upperCal = 0;
  byte lowerCal = 0;
  for (byte i = 0; i < 10; i++) {
    if (aValue == calibrationValues[i]) return calibrationVols[i];
    else if (aValue > calibrationValues[i] && aValue - calibrationValues[i] < aValue - calibrationValues[lowerCal]) lowerCal = i;
    else if (aValue < calibrationValues[i] && calibrationValues[i] - aValue < calibrationValues[upperCal] - aValue) upperCal = i;
  }
  if (aValue > calibrationValues[upperCal]) return 9999;
  if (aValue < calibrationValues[lowerCal]) return round((float) aValue / (float) calibrationValues[upperCal] * calibrationVols[upperCal]);
  else return round((float) (aValue - calibrationValues[lowerCal]) / (float) (calibrationValues[upperCal] - calibrationValues[lowerCal]) * (calibrationVols[upperCal] - calibrationVols[lowerCal])) + calibrationVols[lowerCal];
}
