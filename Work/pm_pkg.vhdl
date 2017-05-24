------------------------------------------------------------------------------
----                                                                      ----
----  Lattuino program memories and peripherals package                   ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This is a package with the PMs used for Lattuino.                   ----
----  It also includes the Lattuino peripherals.                          ----
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
---- Library:          lattuino                                           ----
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
         FALL_EDGE  : std_logic:='0'; -- Ram clock falling edge
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
         FALL_EDGE  : std_logic:='0'; -- Ram clock falling edge
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
         FALL_EDGE  : std_logic:='0'; -- Ram clock falling edge
         ADDR_W     : integer:=13); -- Address Width
      port(
         clk_i   : in  std_logic;
         addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
         data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
         we_i    : in  std_logic;
         data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
   end component lattuino_1_blPM_2;

   component lattuino_1_blPM_2S is
      generic(
         WORD_SIZE  : integer:=16;  -- Word Size
         FALL_EDGE  : std_logic:='0'; -- Ram clock falling edge
         ADDR_W     : integer:=13); -- Address Width
      port(
         clk_i   : in  std_logic;
         addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
         data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
         we_i    : in  std_logic;
         data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
   end component lattuino_1_blPM_2S;

   component TMCounter is
      generic(
         CNT_PRESC : natural:=24;
         ENA_TMR   : std_logic:='1');
      port(
         -- WISHBONE signals
         wb_clk_i : in  std_logic;  -- Clock
         wb_rst_i : in  std_logic;  -- Reset input
         wb_adr_i : in  std_logic_vector(2 downto 0); -- Adress bus
         wb_dat_o : out std_logic_vector(7 downto 0); -- DataOut Bus
         wb_dat_i : in  std_logic_vector(7 downto 0); -- DataIn Bus
         wb_we_i  : in  std_logic;  -- Write Enable
         wb_stb_i : in  std_logic;  -- Strobe
         wb_ack_o : out std_logic;  -- Acknowledge
         pwm_o    : out std_logic_vector(5 downto 0);  -- 6 PWMs
         pwm_e_o  : out std_logic_vector(5 downto 0)); -- Pin enable for the PWMs
   end component TMCounter;

   component TM16bits is
      generic(
         CNT_PRESC : natural:=24;
         ENA_TMR   : std_logic:='1');
      port(
         -- WISHBONE signals
         wb_clk_i  : in  std_logic;  -- Clock
         wb_rst_i  : in  std_logic;  -- Reset input
         wb_adr_i  : in  std_logic_vector(0 downto 0); -- Adress bus
         wb_dat_o  : out std_logic_vector(7 downto 0); -- DataOut Bus
         wb_dat_i  : in  std_logic_vector(7 downto 0); -- DataIn Bus
         wb_we_i   : in  std_logic;  -- Write Enable
         wb_stb_i  : in  std_logic;  -- Strobe
         wb_ack_o  : out std_logic;  -- Acknowledge
         -- Interface
         irq_req_o : out std_logic;
         irq_ack_i : in  std_logic);
   end component TM16bits;

   component AD_Conv is
      generic(
         DIVIDER      : positive:=12;
         INTERNAL_CLK : std_logic:='1';  -- not boolean for Verilog compat
         ENABLE       : std_logic:='1'); -- not boolean for Verilog compat
      port(
         -- WISHBONE signals
         wb_clk_i : in  std_logic;  -- Clock
         wb_rst_i : in  std_logic;  -- Reset input
         wb_adr_i : in  std_logic_vector(0 downto 0); -- Adress bus
         wb_dat_o : out std_logic_vector(7 downto 0); -- DataOut Bus
         wb_dat_i : in  std_logic_vector(7 downto 0); -- DataIn Bus
         wb_we_i  : in  std_logic;  -- Write Enable
         wb_stb_i : in  std_logic;  -- Strobe
         wb_ack_o : out std_logic;  -- Acknowledge
         -- SPI rate (2x)
         -- Note: with 2 MHz spi_ena_i we get 1 MHz SPI clock => 55,6 ks/s
         spi_ena_i: in  std_logic;  -- 2xSPI clock
         -- A/D interface
         ad_ncs_o : out std_logic;  -- SPI /CS
         ad_clk_o : out std_logic;  -- SPI clock
         ad_din_o : out std_logic;  -- SPI A/D Din (MOSI)
         ad_dout_i: in  std_logic); -- SPI A/D Dout (MISO)
   end component AD_Conv;
end package PrgMems;

