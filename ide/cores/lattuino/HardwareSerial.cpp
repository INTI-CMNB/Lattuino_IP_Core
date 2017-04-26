/*
  HardwareSerial.cpp - Hardware serial library for Wiring
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
  Modified 3 December 2013 by Matthijs Kooijman
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "Arduino.h"

#include "HardwareSerial.h"
#include "HardwareSerial_private.h"

// this next line disables the entire HardwareSerial.cpp, 
// this is so I can support Attiny series and any other chip without a uart
#if defined(HAVE_HWSERIAL0) || defined(HAVE_HWSERIAL1) || defined(HAVE_HWSERIAL2) || defined(HAVE_HWSERIAL3)

// SerialEvent functions are weak, so when the user doesn't define them,
// the linker just sets their address to 0 (which is checked below).
// The Serialx_available is just a wrapper around Serialx.available(),
// but we can refer to it weakly so we don't pull in the entire
// HardwareSerial instance if the user doesn't also refer to it.
#if defined(HAVE_HWSERIAL0)
  void serialEvent() __attribute__((weak));
  bool Serial0_available() __attribute__((weak));
#endif

#if defined(HAVE_HWSERIAL1)
  void serialEvent1() __attribute__((weak));
  bool Serial1_available() __attribute__((weak));
#endif

#if defined(HAVE_HWSERIAL2)
  void serialEvent2() __attribute__((weak));
  bool Serial2_available() __attribute__((weak));
#endif

#if defined(HAVE_HWSERIAL3)
  void serialEvent3() __attribute__((weak));
  bool Serial3_available() __attribute__((weak));
#endif

void serialEventRun(void)
{
#if defined(HAVE_HWSERIAL0)
  if (Serial0_available && serialEvent && Serial0_available()) serialEvent();
#endif
#if defined(HAVE_HWSERIAL1)
  if (Serial1_available && serialEvent1 && Serial1_available()) serialEvent1();
#endif
#if defined(HAVE_HWSERIAL2)
  if (Serial2_available && serialEvent2 && Serial2_available()) serialEvent2();
#endif
#if defined(HAVE_HWSERIAL3)
  if (Serial3_available && serialEvent3 && Serial3_available()) serialEvent3();
#endif
}

// Actual interrupt handlers //////////////////////////////////////////////////////////////

void HardwareSerial::_tx_udr_empty_irq(void)
{
 // If interrupts are enabled, there must be more data in the output
 // buffer. Send the next byte
 unsigned char c=_tx_buffer[_tx_buffer_tail];
 _tx_buffer_tail=(_tx_buffer_tail+1) % SERIAL_TX_BUFFER_SIZE;

 // This function is usually called from an ISR, we must preserve this register
 uint8_t oldAdr=WB_ADR;
 // Transmit the data
 WB_ADR=_base+UART_TX;
 WB_DAT=c;
 WB_ADR=oldAdr;

 if (_tx_buffer_head==_tx_buffer_tail)
    // Buffer empty, so disable interrupts
    GIMSK&=~(_irq_mask_tx);
}

// Public Methods //////////////////////////////////////////////////////////////

void HardwareSerial::begin(unsigned long , byte )
{
 uint8_t aux=GIMSK;
 // Enable Rx interrupts
 aux|=_irq_mask_rx;
 // Disable Tx interrupts, will be enabled when we have data
 aux&=~(_irq_mask_tx);
 GIMSK=aux;
}

void HardwareSerial::end()
{
 // wait for transmission of outgoing data
 flush();

 // Disable Tx and Rx interrupts
 GIMSK&=~(_irq_mask_tx | _irq_mask_rx);

 // clear any received data
 _rx_buffer_head=_rx_buffer_tail;
}

int HardwareSerial::available(void)
{
 return ((unsigned int)(SERIAL_RX_BUFFER_SIZE + _rx_buffer_head - _rx_buffer_tail)) % SERIAL_RX_BUFFER_SIZE;
}

int HardwareSerial::peek(void)
{
 if (_rx_buffer_head==_rx_buffer_tail)
    return -1;
 return _rx_buffer[_rx_buffer_tail];
}

int HardwareSerial::read(void)
{
 // if the head isn't ahead of the tail, we don't have any characters
 if (_rx_buffer_head==_rx_buffer_tail)
    return -1;
 unsigned char c=_rx_buffer[_rx_buffer_tail];
 _rx_buffer_tail=(rx_buffer_index_t)(_rx_buffer_tail + 1) % SERIAL_RX_BUFFER_SIZE;
 return c;
}

int HardwareSerial::availableForWrite(void)
{
#if (SERIAL_TX_BUFFER_SIZE>256)
  uint8_t oldSREG = SREG;
  cli();
#endif
  tx_buffer_index_t head = _tx_buffer_head;
  tx_buffer_index_t tail = _tx_buffer_tail;
#if (SERIAL_TX_BUFFER_SIZE>256)
  SREG = oldSREG;
#endif
  if (head >= tail) return SERIAL_TX_BUFFER_SIZE - 1 - head + tail;
  return tail - head - 1;
}

void HardwareSerial::flush()
{
 WB_ADR=_base+UART_ST;
 while ((GIMSK & _irq_mask_tx) ||  // Tx IRQs enabled (buffer not empty)
        (WB_DAT & (1<<UART_WIP)))  // UART is transmitting
   {
    if (bit_is_clear(SREG,SREG_I) && // IRQs globally disabled
        (GIMSK & _irq_mask_tx))      // Tx IRQs enabled (buffer not empty)
      {
       // Interrupts are globally disabled, but the DR empty
       // interrupt should be enabled, so poll the DR empty flag to
       // prevent deadlock
       if (WB_DAT & (1<<UART_TX_AVAIL)) // UART Tx register is empty
          _tx_udr_empty_irq();
      }
   }
 // If we get here, nothing is queued anymore and
 // the hardware finished tranmission.
}

size_t HardwareSerial::write(uint8_t c)
{
 // If the buffer and the data register is empty, just write the byte
 // to the data register and be done. This shortcut helps
 // significantly improve the effective datarate at high (>
 // 500kbit/s) bitrates, where interrupt overhead becomes a slowdown.
 WB_ADR=_base+UART_ST;
 if (_tx_buffer_head==_tx_buffer_tail && // No data to transmit
     (WB_DAT & (1<<UART_TX_AVAIL)))      // UART Tx register is empty
   {
    WB_ADR=_base+UART_TX;
    WB_DAT=c;
    return 1;
   }
 tx_buffer_index_t i=(_tx_buffer_head + 1) % SERIAL_TX_BUFFER_SIZE;

 // If the output buffer is full, there's nothing for it other than to
 // wait for the interrupt handler to empty it a bit
 while (i==_tx_buffer_tail)
   {
    if (bit_is_clear(SREG,SREG_I))
      {
       // Interrupts are disabled, so we'll have to poll the data
       // register empty flag ourselves. If it is set, pretend an
       // interrupt has happened and call the handler to free up
       // space for us.
       if (WB_DAT & (1<<UART_TX_AVAIL))
          _tx_udr_empty_irq();
      }
    else
      {// nop, the interrupt handler will free up space for us
      }
   }
 // Queue the byte
 _tx_buffer[_tx_buffer_head]=c;
 _tx_buffer_head=i;
 // Enable Tx interrupts
 GIMSK|=_irq_mask_tx;
 
 return 1;
}

#endif // whole file
