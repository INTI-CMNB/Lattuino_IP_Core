/* Tone.cpp

  A Tone Generator Library

  Written by Brett Hagman

  Adapted for Lattuino:
  Copyright (c) 2017 Salvador E. Tropea
  Copyright (c) 2017 Instituto Nacional de Tecnología Industrial

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

Version Modified By Date     Comments
------- ----------- -------- --------
0001    B Hagman    09/08/02 Initial coding
0002    B Hagman    09/08/18 Multiple pins
0003    B Hagman    09/08/18 Moved initialization from constructor to begin()
0004    B Hagman    09/09/26 Fixed problems with ATmega8
0005    B Hagman    09/11/23 Scanned prescalars for best fit on 8 bit timers
                    09/11/25 Changed pin toggle method to XOR
                    09/11/25 Fixed timer0 from being excluded
0006    D Mellis    09/12/29 Replaced objects with functions
0007    M Sproul    10/08/29 Changed #ifdefs from cpu to register
0008    S Kanemoto  12/06/22 Fixed for Leonardo by @maris_HY
0009    J Reucker   15/04/10 Issue #292 Fixed problems with ATmega8 (thanks to Pete62)
0010    jipp        15/04/13 added additional define check #2923
*************************************************/

#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "Arduino.h"

// timerx_toggle_count:
//  > 0 - duration specified
//  = 0 - stopped
//  < 0 - infinitely (until stop() method called, or new play() called)

volatile long timer_toggle_count;
volatile uint8_t *timer_pin_port;
volatile uint8_t timer_pin_mask;

static uint8_t tone_pin=255;

static int8_t toneBegin(uint8_t _pin)
{
 if (tone_pin==_pin)
    return 0; // Already using it
 if (tone_pin!=255)
    return -1; // Already using it for other pin
 // Ok, setup the values for this PIN
 tone_pin=_pin;
 timer_pin_port=portOutputRegister(digitalPinToPort(_pin));
 timer_pin_mask=digitalPinToBitMask(_pin);
 return 0;
}

// frequency (in hertz) and duration (in milliseconds).
void tone(uint8_t _pin, unsigned int frequency, unsigned long duration)
{
 long toggle_count=0;

 if (toneBegin(_pin))
    return; // Already using the tone generator for other PIN

 // Set the pinMode as OUTPUT
 pinMode(_pin,OUTPUT);

 uint16_t div=1000000UL/frequency/2; // - 1;
 WB_ADR=T16_BASE;
 WB_DAT=div & 0xFF;
 WB_ADR=T16_BASE+1;
 WB_DAT=div>>8;

 // Calculate the toggle count
 if (duration>0)
    toggle_count=2*frequency*duration/1000;
 else
    toggle_count=-1;
 timer_toggle_count=toggle_count;

 // Enable the interrupts
 GIMSK|=(1<<TM16);
}

static
void disableTimer()
{
 // Disable the interrupts
 GIMSK&=~(1<<TM16);
}

void noTone(uint8_t _pin)
{
 if (tone_pin!=_pin)
    return;
 tone_pin=255;
 disableTimer();
 digitalWrite(_pin,0);
}

ISR(TM16_vect)
{
 if (timer_toggle_count!=0)
   {// toggle the pin
    *timer_pin_port^=timer_pin_mask;

    if (timer_toggle_count>0)
       timer_toggle_count--;
   }
 else
   {
    disableTimer();
    *timer_pin_port&=~(timer_pin_mask);  // keep pin low after stop
   }
}

