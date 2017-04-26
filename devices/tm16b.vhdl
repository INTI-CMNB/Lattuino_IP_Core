------------------------------------------------------------------------------
----                                                                      ----
----  16 bits WISHBONE timer                                              ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Implements a 16 bits timer (clock counter) to generate periodic     ----
----  interrupts. Used by Tone.cpp Arduino API.                           ----
----  Port    Write          Read                                         ----
----    0    Low Divider     0                                            ----
----    1    High Divider    0                                            ----
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
---- Design unit:      TM16bits(RTL) (Entity and architecture)            ----
---- File name:        tm16b.vhdl                                         ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          avr                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
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

entity TM16bits is
   generic(
      CNT_PRESC : natural:=24;
      ENA_TMR   : boolean:=true);
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
end entity TM16bits;

architecture RTL of TM16bits is
   -- Timer counter
   signal cnt_r     : unsigned(15 downto 0):=(others => '0');
   -- Divider value
   signal div_r     : unsigned(15 downto 0):=(others => '0');
   signal tc        : std_logic; -- Terminal count
   -- Microseconds source
   signal ena_cnt   : std_logic;
   signal pre_cnt_r : integer range 0 to CNT_PRESC-1;
begin
   -- Microseconds time source
   tmr_source:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            pre_cnt_r <= 0;
         else
            pre_cnt_r <= pre_cnt_r+1;
            if pre_cnt_r=CNT_PRESC-1 then
               pre_cnt_r <= 0;
            end if;
         end if;
      end if;
   end process tmr_source;
   ena_cnt <= '1' when pre_cnt_r=CNT_PRESC-1 else '0';

   -- 16 bits counter
   do_count:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if (wb_rst_i or tc or
             (wb_stb_i and wb_we_i))='1' then
            cnt_r <= (others => '0');
         elsif ena_cnt='1' then
            cnt_r <= cnt_r+1;
         end if;
      end if;
   end process do_count;
   tc <= '1' when cnt_r=div_r-1 and ena_cnt='1' else '0';

   -- Interrupt logic
   do_flag:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            irq_req_o <= '0';
         elsif tc='1' and ENA_TMR then
            irq_req_o <= '1';
         elsif irq_ack_i='1' then
            irq_req_o <= '0';
         end if;
      end if;
   end process do_flag;


   ----------------------------------------------------------------------------
   -- WISHBONE read
   ----------------------------------------------------------------------------
   wb_dat_o <= (others => '0');
   wb_ack_o <= wb_stb_i;

   ----------------------------------------------------------------------------
   -- WISHBONE write
   ----------------------------------------------------------------------------
   do_write_div:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            div_r <= (others => '0');
         elsif (wb_stb_i and wb_we_i)='1' then
            if wb_adr_i="0" then
               div_r(7 downto 0) <= unsigned(wb_dat_i);
            else
               div_r(15 downto 8) <= unsigned(wb_dat_i);
            end if;
         end if;
      end if;
   end process do_write_div;

end architecture RTL; -- Entity: TM16bits

