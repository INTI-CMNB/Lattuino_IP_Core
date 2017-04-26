/*
  HardwareSerial_private.h - Hardware serial library for Wiring
  Copyright (c) 2006 Nicholas Zambetti.  All right reserved.
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

  Modified 23 November 2006 by David A. Mellis
  Modified 28 September 2010 by Mark Sproul
  Modified 14 August 2012 by Alarus
*/

#include "wiring_private.h"

// this next line disables the entire HardwareSerial.cpp, 
// this is so I can support Attiny series and any other chip without a uart
#if defined(HAVE_HWSERIAL0) || defined(HAVE_HWSERIAL1) || defined(HAVE_HWSERIAL2) || defined(HAVE_HWSERIAL3)

// Constructors ////////////////////////////////////////////////////////////////

HardwareSerial::HardwareSerial(uint8_t base, uint8_t irq_mask_tx, uint8_t irq_mask_rx) :
    _base(base),
    _irq_mask_tx(irq_mask_tx),
    _irq_mask_rx(irq_mask_rx),
    _rx_buffer_head(0), _rx_buffer_tail(0),
    _tx_buffer_head(0), _tx_buffer_tail(0)
{
}

// Actual interrupt handlers //////////////////////////////////////////////////////////////

void HardwareSerial::_rx_complete_irq(void)
{
 // Read byte and store it in the buffer if there is room
 WB_ADR=_base+UART_RX;
 unsigned char c=WB_DAT;
 rx_buffer_index_t i=(unsigned int)(_rx_buffer_head + 1) % SERIAL_RX_BUFFER_SIZE;

 // if we should be storing the received character into the location
 // just before the tail (meaning that the head would advance to the
 // current location of the tail), we're about to overflow the buffer
 // and so we don't write the character or advance the head.
 if (i != _rx_buffer_tail)
   {
    _rx_buffer[_rx_buffer_head]=c;
    _rx_buffer_head=i;
   }
}

#endif // whole file
