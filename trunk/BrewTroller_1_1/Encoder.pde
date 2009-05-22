#ifdef ENCODER_CUI
#define ENTER_BOUNCE_DELAY 50
#endif

#ifdef ENCODER_ALPS
#define ENTER_BOUNCE_DELAY 30
#endif

volatile unsigned long lastEncUpd = millis();
unsigned long enterStart;

void doEncoderALPS() {
  if (digitalRead(2) != digitalRead(4)) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 
void doEncoderCUI() {
  if (millis() - lastEncUpd < 50) return;
  //Read EncB
  if (digitalRead(4) == LOW) encCount++; else encCount--;
  if (encCount == -1) encCount = 0; else if (encCount < encMin) { encCount = encMin; } else if (encCount > encMax) { encCount = encMax; }
  lastEncUpd = millis();
} 

void doEnter() {
  if (digitalRead(11) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else if (millis() - enterStart > ENTER_BOUNCE_DELAY) {
      enterStatus = 1;
    }
  }
}

