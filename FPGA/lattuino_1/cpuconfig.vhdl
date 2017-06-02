------------------------------------------------------------------------------
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
---- Library:          lattuino                                           ----
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
   -- SPI support
   constant ENABLE_SPI : std_logic:='1';
   -- Use a PLL to achieve SCK<=F_CLK and not half
   constant ENA_2xSCK  : boolean:=true;
   -- Clock Frequency
   -- IMPORTANT! any change here needs a review of the PLL FILTER_RANGE
   constant F_CLK      : natural:=24e6;
   -- UART baudrate
   constant BAUD_RATE  : natural:=115200;
   -- Starting address for the bootloader (in words)
   constant RESET_JUMP : natural:=3768; -- tn25: 696, 45: 1720, 85: 3768
   -- RAM address width
   constant RAM_ADDR_W : positive:=9;   -- tn25:  7 45:  8 85:  9 (128 to 512 b)
   -- ROM address width
   constant ROM_ADDR_W : positive:=12;  -- tn25: 10 45: 11 85: 12 (2/4/8 kib)
   -- CapSense button 1 is used as RESET
   constant ENABLE_B1_RESET : boolean:=true;
   -- PWMs support
   constant ENA_PWM0   : boolean:=true;
   constant ENA_PWM1   : boolean:=true;
   constant ENA_PWM2   : boolean:=true;
   constant ENA_PWM3   : boolean:=true;
   constant ENA_PWM4   : boolean:=true;
   constant ENA_PWM5   : boolean:=true;
   -- Interrupt pins support
   constant ENA_INT0   : boolean:=true;
   constant ENA_INT1   : boolean:=true;
   -- Micro and miliseconds timer
   constant ENA_TIME_CNT : std_logic:='1';
   -- 16 bits timer (for Tone generation)
   constant ENA_TMR16    : std_logic:='1';
   -- A/D converter support
   constant ENABLE_AD    : std_logic:='1';
end package CPUConfig;
