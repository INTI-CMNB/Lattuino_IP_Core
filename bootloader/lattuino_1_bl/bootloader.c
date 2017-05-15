/**[txh]********************************************************************

  Copyright (c) 2016-2017 Salvador E. Tropea <salvador en inti gov ar>
  Copyright (c) 2016-2017 Instituto Nacional de Tecnología Industrial

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 2 of the License.

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 
  Description:
  Lattuino bootloader compatible with STK500 protocol used by Arduino.
  A lot of information comes from the ATmega8 booloader by:
  Jason P. Kyle, DojoCorp - ZGZ - MMX - IVR and David A. Mellis.

  Compiler: avr-gcc (GCC) 4.8.1

***************************************************************************/

#define F_CPU 24000000
#define DEBUG 0

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
#define WB_ADR  _SFR_IO8(0x1F)
#define WB_DAT  _SFR_IO8(0x1E)

/* SPM instruction.
   Not sure why the compiler ignores r1 in the clobbers list */
#define __SPM__(addr, val_l, val_h)   \
(__extension__({                \
    uint16_t __addr16 = (uint16_t)(addr); \
    uint8_t __val_l = (uint8_t)(val_l); \
    uint8_t __val_h = (uint8_t)(val_h); \
    __asm__ __volatile__        \
    (                           \
        "push r1"     "\n\t"    \
        "mov  r0, %0" "\n\t"    \
        "mov  r1, %1" "\n\t"    \
        "spm"         "\n\t"    \
        "pop  r1"     "\n\t"    \
        : \
        : "r" (__val_l), "r" (__val_h), "z" (__addr16)        \
        : "r0", "r1"            \
    );                          \
}))

/* Bootloader time-out */
#define MAX_TIME_COUNT (F_CPU>>4)

/* Onboard LED is connected to pin PB6 */
#define LED_DDR  DDRB
#define LED_PORT PORTB
#define LED_PIN  PINB
#define LED      6

// AVR-GCC compiler compatibility
// avr-gcc compiler v3.1.x and older doesn't support outb() and inb()
//      if necessary, convert outb and inb to outp and inp
#ifndef outb
 #define outb(sfr,val)  (_SFR_BYTE(sfr) = (val))
#endif
#ifndef inb
 #define inb(sfr) _SFR_BYTE(sfr)
#endif

/* defines for future compatibility */
#ifndef cbi
 #define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
 #define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

/* Some values espected by AVR Studio */
#define HW_VER   0x02
#define SW_MAJOR 0x01
#define SW_MINOR 0x12

/* ATmega8 */
/*#define SIG1 0x1E
#define SIG2 0x93
#define SIG3 0x07*/
/* AT90S2343 */
#ifdef __at90s2343__
 #define SIG1 0x1E
 #define SIG2 0x91
 #define SIG3 0x03
#endif
/* ATtiny22 */
#ifdef __attiny22__
 #define SIG1 0x1E
 #define SIG2 0x91
 #define SIG3 0x06
#endif
/* ATtiny26 */
#ifdef __attiny26__
 #define SIG1 0x1E
 #define SIG2 0x91
 #define SIG3 0x09
#endif
/* ATtiny25 */
#ifdef __attiny25__
 #define SIG1 0x1E
 #define SIG2 0x91
 #define SIG3 0x08
#endif
/* ATtiny45 */
#ifdef __attiny45__
 #define SIG1 0x1E
 #define SIG2 0x92
 #define SIG3 0x06
#endif
/* ATtiny85 */
#ifdef __attiny85__
 #define SIG1 0x1E
 #define SIG2 0x93
 #define SIG3 0x0B
#endif

#define Sync_CRC_EOP     ' '
/* Responses */
#define Resp_STK_INSYNC  0x14
#define Resp_STK_OK      0x10
/* Commands */
#define Cmnd_STK_GET_SYNC        '0'
#define Cmnd_STK_GET_SIGN_ON     '1'
#define Cmnd_STK_SET_PARAMETER   '@'
#define Cmnd_STK_GET_PARAMETER   'A'
#define Cmnd_STK_SET_DEVICE      'B'
#define Cmnd_SET_DEVICE_EXT      'E'
#define Cmnd_STK_ENTER_PROGMODE  'P'
#define Cmnd_STK_LEAVE_PROGMODE  'Q'
#define Cmnd_STK_CHIP_ERASE      'R'
#define Cmnd_STK_LOAD_ADDRESS    'U'
#define Cmnd_STK_UNIVERSAL       'V'
#define Cmnd_STK_PROG_PAGE       'd'
#define Cmnd_STK_READ_PAGE       't'
#define Cmnd_STK_READ_SIGN       'u'
#define Cmnd_STK_READ_OSCCAL     'v'

/* Parameters */
#define Parm_STK_HW_VER             0x80
#define Parm_STK_SW_MAJOR           0x81
#define Parm_STK_SW_MINOR           0x82
#define Param_STK500_TOPCARD_DETECT 0x98

static
union address_union
{
 uint16_t word;
 uint8_t  byte[2];
} address;

static
union length_union
{
 uint16_t word;
 uint8_t  byte[2];
} length;

static uint8_t is_eeprom;

static __attribute__((noreturn)) void (*app_start)(void)=0x0000;

/*
 * Send character c down the UART Tx, wait until tx holding register
 * is empty.
 */
//static
int uart_putchar(char c)
{
 WB_ADR=1; /* Status is reg 1 */
 loop_until_bit_is_set(WB_DAT,0);
 WB_ADR=0; /* Data is reg 0 */
 WB_DAT=c;
 return 0;
}

static
char uart_getchar(void)
{
 uint32_t count=MAX_TIME_COUNT;

 WB_ADR=1; /* Status is reg 1 */
 while (!(WB_DAT & 2))
   {
    if (!(count--))
       app_start();
   }
 WB_ADR=0; /* Data is reg 0 */
 return WB_DAT;
}

static inline
void uart_puteol(void)
{
 uart_putchar('\r');
 uart_putchar('\n');
}

static
void uart_puts(const char *str)
{
 while (*str)
   {
    uart_putchar(*str);
    str++;
   }
 uart_puteol();
}

static
void uart_show(char dat)
{
 uint8_t i;
 for (i=0x80; i; i>>=1)
    {
     if (dat & i)
        uart_putchar('1');
     else
        uart_putchar('0');
    }
 uart_puteol();
}

static
void nothing_response(void)
{
 if (uart_getchar()==Sync_CRC_EOP)
   {
    uart_putchar(Resp_STK_INSYNC);
    uart_putchar(Resp_STK_OK);
   }
}

static
void byte_response(uint8_t val)
{
 if (uart_getchar()==Sync_CRC_EOP)
   {
    uart_putchar(Resp_STK_INSYNC);
    uart_putchar(val);
    uart_putchar(Resp_STK_OK);
   }
}

static
void skip_N_char(uint8_t count)
{
  uint8_t i;
  for (i=0; i<count; i++)
      uart_getchar();
}

int main(int argc, char *argv[])
{
 /* Destella el LED1 de la placa muy rápido. Por eso 16 veces */
 sbi(LED_DDR,LED);
 uint8_t i;
 for (i=0; i<4; i++)
    {
     outb(LED_PORT,inb(LED_PORT)^_BV(LED));
     _delay_loop_2(0);
    }

 if (DEBUG)
    uart_puts("ATtinyX5 says: hello world!");
 while (1)
   {
    uint8_t ch;

    ch=uart_getchar();
    if (DEBUG)
       uart_show(ch);
    if (ch==Cmnd_STK_GET_SYNC)
      { /* Used to resync */
       nothing_response();
      }
    else if (ch==Cmnd_STK_GET_SIGN_ON)
      { /* Used to verify we are a bootloader */
       if (uart_getchar()==Sync_CRC_EOP)
         {
          uart_putchar(Resp_STK_INSYNC);
          uart_putchar('A');
          uart_putchar('V');
          uart_putchar('R');
          uart_putchar(' ');
          uart_putchar('I');
          uart_putchar('S');
          uart_putchar('P');
          uart_putchar(Resp_STK_OK);
         }
      }
    else if (ch==Cmnd_STK_SET_PARAMETER)
      { /* No parameters available */
       ch=uart_getchar();
       /*if (ch>0x85) Why? 0x83 is R/W */
          uart_getchar();
       nothing_response();
      }
    else if (ch==Cmnd_STK_GET_PARAMETER)
      {
       ch=uart_getchar();
       if (ch==Parm_STK_HW_VER) /* Hardware version */
          byte_response(HW_VER);
       else if (ch==Parm_STK_SW_MAJOR) /* Software major version */
          byte_response(SW_MAJOR);
       else if (ch==Parm_STK_SW_MINOR) /* Software minor version */
          byte_response(SW_MINOR);
       else if (0 && ch==Param_STK500_TOPCARD_DETECT) /* Topcard detect */
          byte_response(0x03); /* No topcard detected avr studio 3.56 */
       else
          byte_response(0x00); /* Covers various unnecessary responses we don't care about */
      }
    else if (ch==Cmnd_STK_SET_DEVICE) /* Fixed CPU, nothing to configure */
      {
       skip_N_char(20); /* 20 parameters ignored */
       nothing_response();
      }
    else if (ch==Cmnd_SET_DEVICE_EXT) /* Fixed CPU, nothing to configure */
      {
       skip_N_char(5); /* 5 extended parameters ignored */
       nothing_response();
      }
    else if (ch==Cmnd_STK_ENTER_PROGMODE) /* Should disable time-out */
      {
       nothing_response();
      }
    else if (ch==Cmnd_STK_LEAVE_PROGMODE) /* Should enable time-out */
      {
       nothing_response();
      }
    else if (ch==Cmnd_STK_CHIP_ERASE) /* Not needed */
      {
       nothing_response();
      }
    else if (ch==Cmnd_STK_LOAD_ADDRESS) /* Starting address (16 bits) */
      {
       address.byte[0]=uart_getchar(); /* Low byte first */
       address.byte[1]=uart_getchar();
       nothing_response();
      }
    else if (ch==Cmnd_STK_UNIVERSAL) /* No universal SPI support */
      {
       skip_N_char(4); /* 32 bits ignored */
       byte_response(0);
      }
    else if (ch==Cmnd_STK_PROG_PAGE) /* Memory Write */
      {
       uint16_t w;
       /* Data length, upto 0x100 bytes */
       length.byte[1]=uart_getchar(); /* high byte first */
       length.byte[0]=uart_getchar();
       /* Memory type (E/F) */
       is_eeprom=0;
       if (uart_getchar()=='E')
          is_eeprom=1;
       else
          address.word<<=1;
       /* Actual data */
       for (w=0; w<length.word; w+=2)
          {
           uint8_t vl=uart_getchar();
           uint8_t vh=uart_getchar();
           if (!is_eeprom) /* No EEPROM */
              __SPM__(address.word,vl,vh);
           address.word+=2;
          }
       /* End of packet */
       nothing_response();
      }
    else if (ch==Cmnd_STK_READ_PAGE) /* Memory Read */
      {
       uint16_t w;
       /* Data length, upto 0x100 bytes */
       length.byte[1]=uart_getchar(); /* high byte first */
       length.byte[0]=uart_getchar();
       /* Memory type (E/F) */
       is_eeprom=0;
       if (uart_getchar()=='E')
          is_eeprom=1;
       else
          address.word<<=1;
       /* End of packet */
       if (uart_getchar()==Sync_CRC_EOP)
         {/* Do the actual work */
          uart_putchar(Resp_STK_INSYNC);
          for (w=0; w<length.word; w++)
             {
              if (is_eeprom)
                 uart_putchar(0); /* Not supported */
              else
                 uart_putchar(pgm_read_byte_near(address.word));
              address.word++;
             }
          uart_putchar(Resp_STK_OK);
         }
      }
    else if (ch==Cmnd_STK_READ_SIGN) /* CPU Signature */
      {
       if (uart_getchar()==Sync_CRC_EOP)
         {
          uart_putchar(Resp_STK_INSYNC);
          uart_putchar(SIG1);
          uart_putchar(SIG2);
          uart_putchar(SIG3);
          uart_putchar(Resp_STK_OK);
         }
      }
    else if (ch==Cmnd_STK_READ_OSCCAL) /* No oscillator cal. */
      {
       byte_response(0);
      }
   }
 return 0;
}

