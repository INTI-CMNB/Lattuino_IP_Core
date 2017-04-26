/*
  wiring.c - Partial implementation of the Wiring API for the Arduino.
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
*/

#include "lattuino.h"
#include "wiring_private.h"

/**[txh]********************************************************************

  Description: Returns the number of milliseconds since we started
  Uses a custom 32 bits hardware counter. Not TMR0 like in original Arduino.
  
  Return: Elapsed milliseconds
  
***************************************************************************/

unsigned long millis()
{
 union32_t v;
 uint8_t i;
 for (i=0; i<4; i++)
    {
     WB_ADR=TMR_BASE+4+i;
     v.byte[i]=WB_DAT;
    }
 return v.w32;
}

/**[txh]********************************************************************

  Description: Returns the number of microseconds since we started
  Uses a custom 32 bits hardware counter. Not TMR0 like in original Arduino.
  
  Return: Elapsed microseconds
  
***************************************************************************/

unsigned long micros()
{
 union32_t v;
 uint8_t i;
 for (i=0; i<4; i++)
    {
     WB_ADR=TMR_BASE+i;
     v.byte[i]=WB_DAT;
    }
 return v.w32;
}

/* Original */
void delay(unsigned long ms)
{
 uint32_t start=micros();

 while (ms>0)
   {
    yield();
    while (ms>0 && (micros()-start)>=1000)
      {
       ms--;
       start+=1000;
      }
   }
}

/**[txh]********************************************************************

  Description: Blocks the CPU for more than 256 µs
  
***************************************************************************/

void delayManyMicroseconds(unsigned int us)
{
 while (us>256)
   {
    delayMicroseconds(255);
    us-=256;
   }
 if (us)
    delayMicroseconds(us & 0xFF);
}

void init()
{
 sei();
}

