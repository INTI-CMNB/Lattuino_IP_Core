const int led = 3;           // the PWM pin the LED is attached to

void setup() {
  pinMode(led, OUTPUT);
}

void loop() {
  analogWrite(led, analogRead(A0)>>2);
}
