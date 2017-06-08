/***********************************************************************

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
 Dependencies:     IEEE.std_logic_1164
                   IEEE.numeric_std
                   SPI.Devices
 Target FPGA:      iCE40HX4K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  Lattice iCECube2 2016.02.27810
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

***********************************************************************/

// SPI support
localparam ENABLE_SPI=1;
// Use a PLL to achieve SCK<=F_CLK and not half
localparam ENA_2xSCK=1;
// Clock Frequency
// IMPORTANT! any change here needs a review of the PLL FILTER_RANGE
localparam F_CLK=24e6;
// UART baudrate
localparam BAUD_RATE=115200;
// Starting address for the bootloader (in words)
localparam RESET_JUMP=3768; // tn25: 696, 45: 1720, 85: 3768
// RAM address width
localparam RAM_ADDR_W=9;   // tn25:  7 45:  8 85:  9 (128 to 512 b)
// ROM address width
localparam ROM_ADDR_W=12;  // tn25: 10 45: 11 85: 12 (2/4/8 kib)
// CapSense button 1 is used as RESET
localparam ENABLE_B1_RESET=1;
// PWMs support
localparam ENA_PWM0=1;
localparam ENA_PWM1=1;
localparam ENA_PWM2=1;
localparam ENA_PWM3=1;
localparam ENA_PWM4=1;
localparam ENA_PWM5=1;
// Interrupt pins support
localparam ENA_INT0=1;
localparam ENA_INT1=1;
// Micro and miliseconds timer
localparam ENA_TIME_CNT=1;
// 16 bits timer (for Tone generation)
localparam ENA_TMR16=1;
// A/D converter support
localparam ENABLE_AD=1;

