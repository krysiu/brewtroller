#define ENTER_BOUNCE_DELAY 30
unsigned long enterStart;

// Error hang, flashing the on-board led
void error(byte blinkCode) { 
  while(1) {
    for (byte n = 0; n < blinkCode; n++) {
      digitalWrite(PIN_LEDRED, HIGH);
      delay(250);
      digitalWrite(PIN_LEDRED, LOW);
      delay(250);
    }
    delay(2000);
  }
}

void doEnter() {
  if (digitalRead(PIN_SWITCH) == HIGH) {
    enterStart = millis();
  } else {
    if (millis() - enterStart > 1000) {
      enterStatus = 2;
    } else if (millis() - enterStart > ENTER_BOUNCE_DELAY) {
      enterStatus = 1;
    }
  }
}
