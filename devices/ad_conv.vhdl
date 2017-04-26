------------------------------------------------------------------------------
----                                                                      ----
----  WISHBONE A/D Interface                                              ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Implements the WISHBONE interface for the A/D (MCP3008).            ----
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
---- Design unit:      AD_Conv(RTL) (Entity and architecture)             ----
---- File name:        ad_conv.vhdl                                       ----
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
----                                                                      ----
---- Wishbone Datasheet                                                   ----
----                                                                      ----
----  1 Revision level                      B.3                           ----
----  2 Type of interface                   SLAVE                         ----
----  3 Defined signal names                RST_I => wb_rst_i             ----
----                                        CLK_I => wb_clk_i             ----
----                                        ADR_I => wb_adr_i             ----
----                                        DAT_I => wb_dat_i             ----
----                                        DAT_O => wb_dat_o             ----
----                                        WE_I  => wb_we_i              ----
----                                        ACK_O => wb_ack_o             ----
----                                        STB_I => wb_stb_i             ----
----  4 ERR_I                               Unsupported                   ----
----  5 RTY_I                               Unsupported                   ----
----  6 TAGs                                None                          ----
----  7 Port size                           8-bit                         ----
----  8 Port granularity                    8-bit                         ----
----  9 Maximum operand size                8-bit                         ----
---- 10 Data transfer ordering              N/A                           ----
---- 11 Data transfer sequencing            Undefined                     ----
---- 12 Constraints on the CLK_I signal     None                          ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library SPI;
use SPI.Devices.all;

entity AD_Conv is
   generic(
      DIVIDER      : positive:=12;
      INTERNAL_CLK : boolean:=true;
      ENABLE       : boolean:=true);
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
      spi_ena_i: in  std_logic:='0';  -- 2xSPI clock
      -- A/D interface
      ad_ncs_o : out std_logic;  -- SPI /CS
      ad_clk_o : out std_logic;  -- SPI clock
      ad_din_o : out std_logic;  -- SPI A/D Din (MOSI)
      ad_dout_i: in  std_logic); -- SPI A/D Dout (MISO)
end entity AD_Conv;

architecture RTL of AD_Conv is
   signal cnt_div_spi : integer range 0 to DIVIDER-1:=0;
   signal spi_ena     : std_logic;
   signal start_r     : std_logic;
   signal busy_ad     : std_logic;
   signal busy        : std_logic;
   signal chn_r       : std_logic_vector(2 downto 0);
   signal cur_val     : std_logic_vector(9 downto 0);
   signal wb_dat      : std_logic_vector(7 downto 0);
   signal ad_ncs      : std_logic;  -- SPI /CS
   signal ad_clk      : std_logic;  -- SPI clock
   signal ad_din      : std_logic;  -- SPI A/D Din (MOSI)
begin
   wb_dat <= cur_val(7 downto 0) when wb_adr_i(0)='0' else
             busy&"00000"&cur_val(9 downto 8);
   wb_dat_o <= wb_dat when ENABLE else (others => '0');

   wb_ack_o <= wb_stb_i;

   -- The A/D reads start only when ena_i is 1, so we memorize it
   -- until the A/D indicates a conversion with busy_ad
   do_start:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            start_r <= '0';
         else
            if (wb_stb_i and wb_we_i)='1' then
               start_r <= '1';
            elsif busy_ad='1' then
               start_r <= '0';
            end if;
         end if;
      end if;
   end process do_start;
   -- The A/D is busy or we have a pending start
   busy <= busy_ad or start_r;

   do_chn_write:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if (wb_stb_i and wb_we_i)='1' then
            chn_r <= wb_dat_i(2 downto 0);
         end if;
      end if;
   end process do_chn_write;

   ----------------------
   -- SPI clock enable --
   ----------------------
   internal_divider:
   if INTERNAL_CLK generate
      do_spi_div:
      process (wb_clk_i)
      begin
         if rising_edge(wb_clk_i) then
            cnt_div_spi <= cnt_div_spi+1;
            if cnt_div_spi=DIVIDER-1 then
               cnt_div_spi <= 0;
            end if;
         end if;
      end process do_spi_div;
      spi_ena <= '1' when cnt_div_spi=DIVIDER-1 else '0';
   end generate internal_divider;

   external_divider:
   if not(INTERNAL_CLK) generate
      spi_ena <= spi_ena_i;
   end generate external_divider;

   -------------------
   -- A/D interface --
   -------------------
   the_AD : MCP300x
      port map(
         -- System
         clk_i => wb_clk_i, rst_i => '0',
         -- Master interface
         start_i => start_r, busy_o => busy_ad, chn_i => chn_r, single_i => '1',
         ena_i => spi_ena, eoc_o => open, data_o => cur_val,
         -- A/D interface
         ad_ncs_o => ad_ncs, ad_clk_o => ad_clk, ad_din_o => ad_din,
         ad_dout_i => ad_dout_i);

   ad_ncs_o <= ad_ncs when ENABLE else '0';
   ad_clk_o <= ad_clk when ENABLE else '0';
   ad_din_o <= ad_din when ENABLE else '0';
end architecture RTL; -- Entity: AD_Conv

