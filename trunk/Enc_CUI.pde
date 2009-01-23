void doEncoderA() {
  if (millis() - lastEncUpd < encBounceDelay) return;
  if (digitalRead(encBPin) == LOW) encCount++; else encCount--;
  if (encCount > encMax) { encCount = encMax; } else if (encCount < encMin) { encCount = encMin; }
  lastEncUpd = millis();
} 

void doEnter() {
  if (digitalRead(enterPin) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else {
      enterStatus = 1;
    }
  }
}

void initEnc() {
  encBounceDelay = 50;
}
