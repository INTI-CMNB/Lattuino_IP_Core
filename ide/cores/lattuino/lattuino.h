/*
  lattuino.h - Hardware definitions for the Lattuino project
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
*/

#ifndef Lattuino_h
#define Lattuino_h

#define __LATTUINO__

/* WISHBONE layout (from wb_dev_intercon.h) */
#define RS2_BASE  0x00
#define AD_BASE   0x40
#define TMR_BASE  0x80
#define T16_BASE  0xC0
/* Note: Upto four UARTs named:
   RS2_BASE, RSB_BASE, RSC_BASE and RSC_BASE */

/* MiniUART registers (from miniuart.h) */
#define UART_RX   0
#define UART_TX   0
#define UART_ST   1

/* UART_ST bits */
#define UART_TX_AVAIL 0
#define UART_RX_AVAIL 1
#define UART_WIP      2

/* WHISHBONE registers */
#define WB_ADR  _SFR_IO8(0x1F)
#define WB_DAT  _SFR_IO8(0x1E)

typedef union union32
{
 unsigned long w32;
 unsigned char byte[4];
} union32_t;

/* We also implement Port D */
#define DDRD  _SFR_IO8(0x11)
#define PORTD _SFR_IO8(0x12)
#define PIND  _SFR_IO8(0x10)

/*******/
/* SPI */
/*******/
/* SPI Control Register */
#define SPCR  _SFR_IO8(0x0D)
#define SPIE  7
#define SPE   6
#define DORD  5
#define MSTR  4
#define CPOL  3
#define CPHA  2
#define SPR1  1
#define SPR0  0

/* SPI Status Register */
#define SPSR  _SFR_IO8(0x0E)
#define SPIF  7
#define WCOL  6
#define SPI2X 0

/* SPI Data Register */
#define SPDR  _SFR_IO8(0x0F)

/***********************************************************
  INT0/1 definitions for irq_gicr_lat.vhdl
***********************************************************/

/* We have INT1, but INT0 and INT1 are at bits 3/4 not 7/6 */
#undef INTF0
#define INTF0 3
#define INTF1 4
#define RXIF0 5
#define TXIF0 6
#define TM16F 7

#undef INT0
#define INT0 3
#define INT1 4
#define RXI0 5
#define TXI0 6
#define TM16 7

/* We also have the corresponding MCUCR bits for INT1 mode */
#define ISC11   3
#define ISC10   2

/* We implement INT1 using the IRQ Vector 2 */
#define INT1_vect_num    2
#define INT1_vect        _VECTOR(2)
#define SIG_INTERRUPT1   _VECTOR(2)

#define UART_RX_vect_num 3
#define UART_RX_vect     _VECTOR(3)

#define UART_TX_vect_num 4
#define UART_TX_vect     _VECTOR(4)

#define TM16_vect_num    5
#define TM16_vect        _VECTOR(5)
#define SIG_TM16         _VECTOR(5)

/* NOT IMPLEMENTED */
#define TWBR _SFR_MEM8(0xB8)
#define TWBR0 0
#define TWBR1 1
#define TWBR2 2
#define TWBR3 3
#define TWBR4 4
#define TWBR5 5
#define TWBR6 6
#define TWBR7 7

#define TWSR _SFR_MEM8(0xB9)
#define TWPS0 0
#define TWPS1 1
#define TWS3 3
#define TWS4 4
#define TWS5 5
#define TWS6 6
#define TWS7 7

#define TWAR _SFR_MEM8(0xBA)
#define TWGCE 0
#define TWA0 1
#define TWA1 2
#define TWA2 3
#define TWA3 4
#define TWA4 5
#define TWA5 6
#define TWA6 7

#define TWDR _SFR_MEM8(0xBB)
#define TWD0 0
#define TWD1 1
#define TWD2 2
#define TWD3 3
#define TWD4 4
#define TWD5 5
#define TWD6 6
#define TWD7 7

#define TWCR _SFR_MEM8(0xBC)
#define TWIE 0
#define TWEN 2
#define TWWC 3
#define TWSTO 4
#define TWSTA 5
#define TWEA 6
#define TWINT 7

#define TWAMR _SFR_MEM8(0xBD)
#define TWAM0 1
#define TWAM1 2
#define TWAM2 3
#define TWAM3 4
#define TWAM4 5
#define TWAM5 6
#define TWAM6 7

#endif
