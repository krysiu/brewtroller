byte encBounceDelay;
byte enterBounceDelay;
volatile unsigned long lastEncUpd = millis();
unsigned long enterStart;

void initEncoder() {
  switch(encMode) {
    case CUI:
      enterBounceDelay = 50;
      encBounceDelay = 50;
      attachInterrupt(ENCA_INT, doEncoderCUI, RISING);
      break;
    case ALPS:
      enterBounceDelay = 30;
      encBounceDelay = 60;
      attachInterrupt(ENCA_INT, doEncoderALPS, CHANGE);
      break;
  }
  attachInterrupt(ENTER_INT, doEnter, CHANGE);
}

void doEncoderCUI() {
  if (millis() - lastEncUpd < encBounceDelay) return;
  if (digitalRead(ENCB_PIN) == LOW) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 

void doEncoderALPS() {
  //if (millis() - lastEncUpd < encBounceDelay) return;
  if (digitalRead(ENCA_PIN) != digitalRead(ENCB_PIN)) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 

void doEnter() {
  if (digitalRead(ENTER_PIN) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else if (millis() - enterStart > enterBounceDelay) {
      enterStatus = 1;
    }
  }
}

