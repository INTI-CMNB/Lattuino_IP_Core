------------------------------------------------------------------------------
----                                                                      ----
----  AVR program memories package                                        ----
----                                                                      ----
----  Description:                                                        ----
----  This is a package with the PMs used for the AVR core.               ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2017 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2017 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      PrgMems (Package)                                  ----
---- File name:        pm_pkg.in.vhdl (template used)                     ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      iCE40HX4K-TQ144                                    ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Lattice iCECube2 2016.02.27810                     ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package PrgMems is
   component lattuino_1_blPM_8 is
      generic(
         WORD_SIZE  : integer:=16;  -- Word Size
         FALL_EDGE  : boolean:=false;-- Ram clock falling edge
         ADDR_W     : integer:=13); -- Address Width
      port(
         clk_i   : in  std_logic;
         addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
         data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
         we_i    : in  std_logic;
         data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
   end component lattuino_1_blPM_8;

   component lattuino_1_blPM_4 is
      generic(
         WORD_SIZE  : integer:=16;  -- Word Size
         FALL_EDGE  : boolean:=false;-- Ram clock falling edge
         ADDR_W     : integer:=13); -- Address Width
      port(
         clk_i   : in  std_logic;
         addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
         data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
         we_i    : in  std_logic;
         data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
   end component lattuino_1_blPM_4;

   component lattuino_1_blPM_2 is
      generic(
         WORD_SIZE  : integer:=16;  -- Word Size
         FALL_EDGE  : boolean:=false;-- Ram clock falling edge
         ADDR_W     : integer:=13); -- Address Width
      port(
         clk_i   : in  std_logic;
         addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
         data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
         we_i    : in  std_logic;
         data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
   end component lattuino_1_blPM_2;
end package PrgMems;

