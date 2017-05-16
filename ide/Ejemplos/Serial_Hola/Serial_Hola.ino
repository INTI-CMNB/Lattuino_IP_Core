/*
  Serial Hola (Hello)
  Tested on:
  - Lattuino 1 Kéfir I
  - Lattuino Stick
 */

void setup() {
  // Initialize serial and wait for port to open:
  Serial.begin(115200); // 115200 is fixed
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
}

void delayTest()
{ // No delay on Stick, low-level delay instead
  unsigned i;
  for (i=16; i; i--)
      _delay_loop_2(0);
}

void loop() {
  Serial.println(F("Hola! Saludos desde el Lattuino!"));
  delayTest();
}
