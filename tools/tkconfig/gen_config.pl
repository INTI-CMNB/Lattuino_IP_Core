#!/usr/bin/perl

# Read all the .config
while (<>)
  {
   $ops{$1}='y' if $_=~/(\S+)\=y/;
  }

# Generate the VHDL config
print
"------------------------------------------------------------------------------
----                                                                      ----
----  Lattuino CPU configuration                                          ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Configuration parameters for the Lattuino CPU.                      ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador en inti.gob.ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2017 Salvador E. Tropea <salvador en inti.gob.ar>      ----
---- Copyright (c) 2017 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      CPUConfig (Package)                                ----
---- File name:        cpuconfig.vhdl                                     ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          avr                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   SPI.Devices                                        ----
---- Target FPGA:      iCE40HX4K-TQ144                                    ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  Lattice iCECube2 2016.02.27810                     ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package CPUConfig is
";
$aux=$ops{CONFIG_SPI} ? 'true' : 'false';
print "   -- SPI support
   constant ENABLE_SPI : boolean:=$aux;
";
$aux=$ops{CONFIG_SPI_PLL} ? 'true' : 'false';
print "   -- Use a PLL to achieve SCK<=F_CLK and not half
   constant ENA_2xSCK  : boolean:=$aux;
";
print "   -- Clock Frequency
   -- IMPORTANT! any change here needs a review of the PLL FILTER_RANGE
   constant F_CLK      : natural:=24e6;
";
$aux=115200 if $ops{CONF_BR_115200};
$aux=57600  if $ops{CONF_BR_57600};
$aux=28800  if $ops{CONF_BR_28800};
$aux=19200  if $ops{CONF_BR_19200};
$aux=14400  if $ops{CONF_BR_14400};
$aux=9600   if $ops{CONF_BR_9600};
print "   -- UART baudrate
   constant BAUD_RATE  : natural:=$aux;
";
if ($ops{CONF_MEM_8K})
  {
   $jmp=3768;
   $ram=9;
   $rom=12;
  }
elsif ($ops{CONF_MEM_4K})
  {
   $jmp=1720;
   $ram=8;
   $rom=11;
  }
else
  {
   $jmp=696;
   $ram=7;
   $rom=10;
  }
print "   -- Starting address for the bootloader (in words)
   constant RESET_JUMP : natural:=$jmp; -- tn25: 696, 45: 1720, 85: 3768
   -- RAM address width
   constant RAM_ADDR_W : positive:=$ram;   -- tn25:  7 45:  8 85:  9 (128 to 512 b)
   -- ROM address width
   constant ROM_ADDR_W : positive:=$rom;  -- tn25: 10 45: 11 85: 12 (2/4/8 kib)
";
$aux=$ops{CONFIG_C1_RESET} ? 'true' : 'false';
print "   -- CapSense button 1 is used as RESET
   constant ENABLE_B1_RESET : boolean:=$aux;
";
print "   -- PWMs support
";
for ($i=0; $i<=5; $i++)
   {
    $aux=$ops{"CONFIG_PWM$i"} ? 'true' : 'false';
print "   constant ENA_PWM0   : boolean:=$aux;
";
   }
$aux=$ops{CONFIG_INT0} ? 'true' : 'false';
$aux2=$ops{CONFIG_INT1} ? 'true' : 'false';
print "   -- Interrupt pins support
   constant ENA_INT0   : boolean:=$aux;
   constant ENA_INT1   : boolean:=$aux2;
";
$aux=$ops{CONFIG_TMR} ? 'true' : 'false';
print "   -- Micro and miliseconds timer
   constant ENA_TIME_CNT : boolean:=$aux;
";
$aux=$ops{CONFIG_TM16} ? 'true' : 'false';
print "   -- 16 bits timer (for Tone generation)
   constant ENA_TMR16    : boolean:=$aux;
";
$aux=$ops{CONFIG_AD} ? 'true' : 'false';
print "   -- A/D converter support
   constant ENABLE_AD    : boolean:=$aux;
";
print "end package CPUConfig;\n"

