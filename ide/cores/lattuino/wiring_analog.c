/*
  wiring_analog.c - analog input and output
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2005-2006 David A. Mellis
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

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA

  Modified 28 September 2010 by Mark Sproul
*/

#include "wiring_private.h"
#include "pins_arduino.h"

void analogReference(uint8_t mode)
{
}

int analogRead(uint8_t pin)
{
 uint8_t low, high;

 /* Set the channel and start a new conversion */
 WB_ADR=AD_BASE+1;
 WB_DAT=pin;
 /* Wait until the conversion ends */
 loop_until_bit_is_clear(WB_DAT,7);
 /* Read the result */
 high=WB_DAT;
 WB_ADR=AD_BASE;
 low=WB_DAT;
 /* Combine both bytes */
 return (high<<8)|low;
}

// Right now, PWM output only works on the pins with
// hardware support.  These are defined in the appropriate
// pins_arduino.h file.  For the rest of the pins, we default
// to digital output.
void analogWrite(uint8_t pin, int val)
{
 // We need to make sure the PWM output is enabled for those pins
 // that support it, as we turn it off when digitally reading or
 // writing with them.  Also, make sure the pin is in output mode
 // for consistenty with Wiring, which doesn't require a pinMode
 // call for the analog output pins.
 pinMode(pin,OUTPUT);
 if (val==0)
    digitalWrite(pin,LOW);
 else if (val==255)
    digitalWrite(pin,HIGH);
 else
   {
    uint8_t pwm_num=digitalPinToTimer(pin);
    if (pwm_num!=NOT_ON_TIMER)
      {
       pwm_num--;
       _turnOnPWM(pwm_num);
       // Set the desired value
       WB_ADR=TMR_BASE+pwm_num;
       WB_DAT=val;
      }
    else
      {
       if (val<128)
          digitalWrite(pin,LOW);
       else
          digitalWrite(pin,HIGH);
      }
   }
}

