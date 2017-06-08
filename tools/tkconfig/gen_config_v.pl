#!/usr/bin/perl

# Read all the .config
while (<>)
  {
   $ops{$1}='y' if $_=~/(\S+)\=y/;
  }

# Generate the VHDL config
print
"/***********************************************************************

  Lattuino CPU configuration

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Configuration parameters for the Lattuino CPU.

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador en inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2017 Salvador E. Tropea <salvador en inti.gob.ar>
 Copyright (c) 2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      CPUConfig
 File name:        cpuconfig.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          lattuino
 Dependencies:     None
 Target FPGA:      iCE40HX4K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  Lattice iCECube2 2016.02.27810
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

***********************************************************************/

";
$aux=$ops{CONFIG_SPI} ? '1' : '0';
print "// SPI support
localparam ENABLE_SPI=$aux;
";
$aux=$ops{CONFIG_SPI_PLL} ? '1' : '0';
print "// Use a PLL to achieve SCK<=F_CLK and not half
localparam ENA_2xSCK=$aux;
";
print "// Clock Frequency
// IMPORTANT! any change here needs a review of the PLL FILTER_RANGE
localparam F_CLK=24e6;
";
$aux=115200 if $ops{CONF_BR_115200};
$aux=57600  if $ops{CONF_BR_57600};
$aux=28800  if $ops{CONF_BR_28800};
$aux=19200  if $ops{CONF_BR_19200};
$aux=14400  if $ops{CONF_BR_14400};
$aux=9600   if $ops{CONF_BR_9600};
print "// UART baudrate
localparam BAUD_RATE=$aux;
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
print "// Starting address for the bootloader (in words)
localparam RESET_JUMP=$jmp; // tn25: 696, 45: 1720, 85: 3768
// RAM address width
localparam RAM_ADDR_W=$ram; // tn25:  7 45:  8 85:  9 (128 to 512 b)
// ROM address width
localparam ROM_ADDR_W=$rom; // tn25: 10 45: 11 85: 12 (2/4/8 kib)
";
$aux=$ops{CONFIG_C1_RESET} ? '1' : '0';
print "// CapSense button 1 is used as RESET
localparam ENABLE_B1_RESET=$aux;
";
print "// PWMs support
";
for ($i=0; $i<=5; $i++)
   {
    $aux=$ops{"CONFIG_PWM$i"} ? '1' : '0';
print "localparam ENA_PWM$i=$aux;
";
   }
$aux=$ops{CONFIG_INT0} ? '1' : '0';
$aux2=$ops{CONFIG_INT1} ? '1' : '0';
print "// Interrupt pins support
localparam ENA_INT0=$aux;
localparam ENA_INT1=$aux2;
";
$aux=$ops{CONFIG_TMR} ? '1' : '0';
print "// Micro and miliseconds timer
localparam ENA_TIME_CNT=$aux;
";
$aux=$ops{CONFIG_TM16} ? '1' : '0';
print "// 16 bits timer (for Tone generation)
localparam ENA_TMR16=$aux;
";
$aux=$ops{CONFIG_AD} ? '1' : '0';
print "// A/D converter support
localparam ENABLE_AD=$aux;
";

