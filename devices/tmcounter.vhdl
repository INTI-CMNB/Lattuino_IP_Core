------------------------------------------------------------------------------
----                                                                      ----
----  WISHBONE miscellaneous timer                                        ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Implements the micro and milliseconds timers. Also a CPU blocker,   ----
----  used for small time delays.                                         ----
----  This module also implements the 6 PWMs.                             ----
----  Lower 32 bits is a 32 bits microseconds counter                     ----
----  Upper 32 bits is a milliseconds counter                             ----
----                                                                      ----
----  Port    Read    Write                                               ----
----    0    µs B0    PWM0                                                ----
----    1    µs B1    PWM1                                                ----
----    2    µs B2    PWM2                                                ----
----    3    µs B3    PWM3                                                ----
----    4    ms B0    PWM4                                                ----
----    5    ms B1    PWM5                                                ----
----    6    ms B2    PWM Pin Enable                                      ----
----    7    ms B3    Block CPU µs                                        ----
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
---- Design unit:      TMCounter(RTL) (Entity and architecture)           ----
---- File name:        tmcounter.vhdl                                     ----
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

entity TMCounter is
   generic(
      CNT_PRESC : natural:=24;
      ENA_TMR   : boolean:=true);
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
end entity TMCounter;

architecture RTL of TMCounter is
   -- Microseconds counter
   signal cnt_us_r  : unsigned(31 downto 0):=(others => '0');
   -- Microseconds counter for the ms counter
   signal cnt_us2_r : unsigned(9 downto 0):=(others => '0');
   -- Milliseconds counter
   signal cnt_ms_r  : unsigned(31 downto 0):=(others => '0');
   -- Latched value
   signal latched_r : unsigned(31 downto 0):=(others => '0');
   -- Prescaler for the Microseconds counters
   signal ena_cnt   : std_logic;
   signal pre_cnt_r : integer range 0 to CNT_PRESC-1;
   -- Microseconds blocker counter
   signal cnt_blk_r : unsigned(7 downto 0):=(others => '0');
   -- Prescaler for the Microseconds blocker counter
   signal ena_blk_cnt : std_logic;
   signal pre_bk_r    : integer range 0 to CNT_PRESC-1;
   -- Blocker FSM
   type state_t is (idle, delay);
   signal state     : state_t;
   -- Blocker WE
   signal blk_we    : std_logic;
   -- PWM values
   type pwm_val_t is array (0 to 5) of unsigned(7 downto 0);
   signal pwm_val_r : pwm_val_t;
   -- PWM counter
   signal pwm_count : unsigned(7 downto 0);
   -- Auxiliar for config
   signal wb_dat    : std_logic_vector(7 downto 0); -- DataOut Bus
begin
   ----------------------------------------------------------------------------
   -- 32 bits Microseconds counter
   ----------------------------------------------------------------------------
   -- Microseconds time source for the counters
   tmr_prescaler:
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
   end process tmr_prescaler;
   ena_cnt <= '1' when pre_cnt_r=CNT_PRESC-1 else '0';

   -- Microseconds counter, 32 bits
   do_cnt_us:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            cnt_us_r <= (others => '0');
         elsif ena_cnt='1' then
            cnt_us_r <= cnt_us_r+1;
         end if;
      end if;
   end process do_cnt_us;

   ----------------------------------------------------------------------------
   -- 32 bits Milliseconds counter
   ----------------------------------------------------------------------------
   -- Microseconds counter, 10 bits (0 to 999)
   do_cnt_us2:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' or cnt_us2_r=999 then
            cnt_us2_r <= (others => '0');
         elsif ena_cnt='1' then
            cnt_us2_r <= cnt_us2_r+1;
         end if;
      end if;
   end process do_cnt_us2;

   -- Milliseconds counter, 32 bits
   do_cnt_ms:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            cnt_ms_r <= (others => '0');
         elsif ena_cnt='1' and cnt_us2_r=999 then
            cnt_ms_r <= cnt_ms_r+1;
         end if;
      end if;
   end process do_cnt_ms;

   ----------------------------------------------------------------------------
   -- WISHBONE read
   ----------------------------------------------------------------------------
   -- Latched value
   do_cnt_usr:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            latched_r <= (others => '0');
         elsif wb_stb_i='1' then
            if wb_adr_i="000" then
               latched_r <= cnt_us_r;
            elsif wb_adr_i="100" then
               latched_r <= cnt_ms_r;
            end if;
         end if;
      end if;
   end process do_cnt_usr;

   with wb_adr_i select wb_dat <=
        std_logic_vector( cnt_us_r( 7 downto  0)) when "000",
        std_logic_vector(latched_r(15 downto  8)) when "001",
        std_logic_vector(latched_r(23 downto 16)) when "010",
        std_logic_vector(latched_r(31 downto 24)) when "011",
        std_logic_vector( cnt_ms_r( 7 downto  0)) when "100",
        std_logic_vector(latched_r(15 downto  8)) when "101",
        std_logic_vector(latched_r(23 downto 16)) when "110",
        std_logic_vector(latched_r(31 downto 24)) when "111",
        (others => '0')                       when others;
   wb_dat_o <= wb_dat when ENA_TMR else (others => '0');

   blk_we <= '1' when (wb_stb_i and wb_we_i)='1' and wb_adr_i="111" and ENA_TMR else '0';

   -- ACK all reads and writes when the counter is 0
   wb_ack_o <= '1' when wb_stb_i='1' and (blk_we='0' or (state=delay and cnt_blk_r=0)) else '0';

   ----------------------------------------------------------------------------
   -- Microseconds CPU blocker
   ----------------------------------------------------------------------------
   -- Blocker FSM (idle and delay)
   do_fsm:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            state <= idle;
         else
            case state is
                 when idle =>
                      if blk_we='1' then
                         state <= delay;
                      end if;
                 when others => -- delay
                      if cnt_blk_r=0 then
                         state <= idle;
                      end if;
            end case;
         end if;
      end if;
   end process do_fsm;

   -- Blocker counter (down counter)
   do_bk_cnt:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            cnt_blk_r <= (others => '0');
         elsif state=idle and blk_we='1' then
            cnt_blk_r <= unsigned(wb_dat_i);
         elsif ena_blk_cnt='1' then
            cnt_blk_r <= cnt_blk_r-1;
         end if;
      end if;
   end process do_bk_cnt;

   -- Microseconds time source for the Blocker counter
   tmr_prescaler_bk:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' or
            (state=idle and blk_we='1') then
            pre_bk_r <= CNT_PRESC-1;
         else
            pre_bk_r <= pre_bk_r-1;
            if pre_bk_r=0 then
               pre_bk_r <= CNT_PRESC-1;
            end if;
         end if;
      end if;
   end process tmr_prescaler_bk;
   ena_blk_cnt <= '1' when pre_bk_r=0 else '0';

   ----------------------------------------------------------------------------
   -- 6 PWMs (8 bits, 250 kHz clock, 976.56 Hz carrier)
   ----------------------------------------------------------------------------
   -- PWM value write
   do_pwm_val_write:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='0' then
            if (wb_stb_i and wb_we_i)='1' and
               wb_adr_i/="111" and
               wb_adr_i/="110" then
               pwm_val_r(to_integer(unsigned(wb_adr_i))) <= unsigned(wb_dat_i);
            end if;
         end if;
      end if;
   end process do_pwm_val_write;

   -- 8 bits counter (1 MHz/4)
   pwm_count <= cnt_us_r(9 downto 2);

   -- PWM outputs (comparators)
   do_pwm_outs:
   for i in 0 to 5 generate
       pwm_o(i) <= '0' when pwm_count>pwm_val_r(i) else '1';
   end generate do_pwm_outs;

   -- PWM Pin Enable (1 the pin should use the PWM output)
   do_pwm_ena_write:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i='1' then
            pwm_e_o <= (others => '0');
         else
            if (wb_stb_i and wb_we_i)='1' and wb_adr_i="110" then
               pwm_e_o <= wb_dat_i(5 downto 0);
            end if;
         end if;
      end if;
   end process do_pwm_ena_write;
end architecture RTL; -- Entity: TMCounter

