/*
  pins_arduino.c - pin definitions for the Arduino board
  Part of Arduino / Wiring Lite

  Copyright (c) 2005 David A. Mellis
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

#ifndef Pins_Arduino_h
#define Pins_Arduino_h

#include <avr/pgmspace.h>

#define NUM_DIGITAL_PINS           15
#define NUM_ANALOG_INPUTS           8
#define LED_BUILTIN                14  /* IO14 */

/***************/
/* Analog Pins */
/***************/
#define PIN_A0               (1)
#define PIN_A1               (3)
#define PIN_A2               (4)
#define PIN_A3               (5)
#define PIN_A4               (6)
#define PIN_A5               (5)
#define PIN_A6               (7)
#define PIN_A7               (0)

static const uint8_t A0=PIN_A0;
static const uint8_t A1=PIN_A1;
static const uint8_t A2=PIN_A2;
static const uint8_t A3=PIN_A3;
static const uint8_t A4=PIN_A4;
static const uint8_t A5=PIN_A5;
static const uint8_t A6=PIN_A6;
static const uint8_t A7=PIN_A7;

/************/
/* SPI Pins */
/************/
#define PIN_SPI_SS    (10)
#define PIN_SPI_MOSI  (11)
#define PIN_SPI_MISO  (12)
#define PIN_SPI_SCK   (13)

static const uint8_t SS  =PIN_SPI_SS;
static const uint8_t MOSI=PIN_SPI_MOSI;
static const uint8_t MISO=PIN_SPI_MISO;
static const uint8_t SCK =PIN_SPI_SCK;

/* NOT IMPLEMENTED */
#define PIN_WIRE_SDA        (18)
#define PIN_WIRE_SCL        (19)

static const uint8_t SDA=PIN_WIRE_SDA;
static const uint8_t SCL=PIN_WIRE_SCL;

#define digitalPinToInterrupt(p)  ((p) == 2 ? 0 : ((p) == 3 ? 1 : NOT_AN_INTERRUPT))

#ifdef ARDUINO_MAIN

void initVariant()
{
}

// these arrays map port names (e.g. port B) to the
// appropriate addresses for various functions (e.g. reading
// and writing)
const uint16_t PROGMEM port_to_mode_PGM[] = {
	NOT_A_PORT,
	NOT_A_PORT,
	(uint16_t) &DDRB,
	NOT_A_PORT,
	(uint16_t) &DDRD
};

const uint16_t PROGMEM port_to_output_PGM[] = {
	NOT_A_PORT,
	NOT_A_PORT,
	(uint16_t) &PORTB,
	NOT_A_PORT,
	(uint16_t) &PORTD
};

const uint16_t PROGMEM port_to_input_PGM[] = {
	NOT_A_PIN,
	NOT_A_PIN,
	(uint16_t) &PINB,
	NOT_A_PIN,
	(uint16_t) &PIND
};

const uint8_t PROGMEM digital_pin_to_port_PGM[] = {
	PD, /* 0 */
	PD,
	PD,
	PD,
	PD,
	PD,
	PD,
	PD, /* 7 */
	PB, /* 0 */
	PB,
	PB,
	PB,
	PB,
	PB,
	PB  /* 6 */
};

const uint8_t PROGMEM digital_pin_to_bit_mask_PGM[] = {
	_BV(0), /* 0, port D */
	_BV(1),
	_BV(2),
	_BV(3),
	_BV(4),
	_BV(5),
	_BV(6),
	_BV(7), /* 7, port D */
	_BV(0), /* 0, port B */
	_BV(1),
	_BV(2),
	_BV(3),
	_BV(4),
	_BV(5),
	_BV(6)  /* 6, port B */
};

const uint8_t PROGMEM digital_pin_to_timer_PGM[] = {
	NOT_ON_TIMER, /* IO0 */
	NOT_ON_TIMER, /* IO1 */
	NOT_ON_TIMER, /* IO2 */
	1,            /* IO3 */
	NOT_ON_TIMER, /* IO4 */
	2,            /* IO5 */
	3,            /* IO6 */
	NOT_ON_TIMER, /* IO7 */
	NOT_ON_TIMER, /* IO8 */
	4,            /* IO9 */
	5,            /* IO10 */
	6,            /* IO11 */
	NOT_ON_TIMER, /* IO12 */
	NOT_ON_TIMER, /* IO13 */
	NOT_ON_TIMER  /* IO14 */
};

#endif

#endif
