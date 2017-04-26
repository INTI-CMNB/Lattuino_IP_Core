/*
  Melody

 Plays a melody

 circuit:
 * 8-ohm speaker on digital pin 8

 created 21 Jan 2010
 modified 30 Aug 2011
 by Tom Igoe

This example code is in the public domain.

 http://www.arduino.cc/en/Tutorial/Tone

 */
#include "pitches.h"

// notes in the melody:
int melody[] = {
  NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_E4, NOTE_G4, NOTE_C4, NOTE_D4,
  NOTE_E4,
  NOTE_F4, NOTE_F4, NOTE_F4, NOTE_F4,
  NOTE_F4, NOTE_E4, NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_E4, NOTE_D4, NOTE_D4, NOTE_E4,
  NOTE_D4, NOTE_G4,
  NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_E4, NOTE_G4, NOTE_C4, NOTE_D4,
  NOTE_E4,
  NOTE_F4, NOTE_F4, NOTE_F4, NOTE_F4,
  NOTE_F4, NOTE_E4, NOTE_E4, NOTE_E4, NOTE_E4, 
  NOTE_G4, NOTE_G4, NOTE_F4, NOTE_D4,
  NOTE_C4
};

// note durations: 4 = quarter note, 8 = eighth note, etc.:
char noteDurations[] = {
  2, 2, 4, 
  2, 2, 4,
  2, 2, 3, 1,
  8,
  2, 2, 3, 1,
  2, 2, 2, 1, 1,
  2, 2, 2, 2,
  4, 4,
  2, 2, 4, 
  2, 2, 4,
  2, 2, 3, 1,
  8,
  2, 2, 2, 2,
  2, 2, 2, 1, 1,
  2, 2, 2, 2,
  8
};

void setup() {
  while (1) {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  
  // iterate over the notes of the melody:
  for (int thisNote = 0; thisNote < 51; thisNote++) {

    // to calculate the note duration, take one second
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 125 * noteDurations[thisNote];
    tone(0, melody[thisNote], noteDuration);

    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    int pauseBetweenNotes = noteDuration * 13 / 10;
    delay(pauseBetweenNotes);
    // stop the tone playing:
    noTone(0);
  }

 digitalWrite(LED_BUILTIN, LOW);
 delay(1000);
  }
}

void loop() {
  // no need to repeat the melody.
}
