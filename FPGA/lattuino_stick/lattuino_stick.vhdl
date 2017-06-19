------------------------------------------------------------------------------
----                                                                      ----
----  AVR ATtX5 CPU for Lattuino                                          ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This module implements the CPU for Lattuino (iCE40HX1K Lattice FPGA ----
----  available in the iCE Stick board).                                  ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008-2017 Salvador E. Tropea <salvador inti.gob.ar>    ----
---- Copyright (c) 2008-2017 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      Lattuino_Stick(FPGA) (Entity and architecture)     ----
---- File name:        lattuino_stick.vhdl                                ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   avr.Micros                                         ----
----                   miniuart.UART                                      ----
----                   CapSense.Devices                                   ----
----                   work.WBDevInterconPkg                              ----
----                   work.CPUConfig                                     ----
----                   lattice.components                                 ----
---- Target FPGA:      iCE40HX1K-TQ144                                    ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  Lattice iCECube2 2016.02.27810                     ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library avr;
use avr.Micros.all;
library miniuart;
use miniuart.UART.all;
library CapSense;
use CapSense.Devices.all;
library lattice;
use lattice.components.all;
library lattuino;
use lattuino.PrgMems.all;
library work;
use work.CPUConfig.all;

entity Lattuino_Stick is
   port(
      CLK        : in    std_logic;  -- CPU clock
      -- Buil-in LEDs
      LED1       : out   std_logic;
      LED2       : out   std_logic;
      LED3       : out   std_logic;
      LED4       : out   std_logic;
      LED5       : out   std_logic;
      -- Arduino UNO I/O
      ARDU00     : inout std_logic;
      ARDU01     : inout std_logic;
      ARDU02     : inout std_logic;
      ARDU03     : inout std_logic;
      ARDU04     : inout std_logic;
      ARDU05     : inout std_logic;
      ARDU06     : inout std_logic;
      ARDU07     : inout std_logic;
      ARDU08     : inout std_logic;
      ARDU09     : inout std_logic;
      ARDU10     : inout std_logic; -- SS
      ARDU11     : inout std_logic; -- MOSI
      ARDU12     : inout std_logic; -- MISO
      ARDU13     : inout std_logic; -- SCK
      -- UART
      FTDI_RXD   : out   std_logic;  -- to UART Tx
      FTDI_TXD   : in    std_logic;  -- to UART Rx
      FTDI_DTR   : in    std_logic); -- UART DTR
end entity Lattuino_Stick;

architecture FPGA of Lattuino_Stick is
   constant BRDIVISOR  : natural:=natural(real(F_CLK)/real(BAUD_RATE)/4.0+0.5);
   constant CNT_PRESC  : natural:=F_CLK/1e6; -- Counter prescaler (1 µs)
   constant DEBUG_SPI  : boolean:=false;

   signal pc           : unsigned(15 downto 0); -- PROM address
   signal pcsv         : std_logic_vector(ROM_ADDR_W-1 downto 0); -- PROM address
   signal inst         : std_logic_vector(15 downto 0); -- PROM data
   signal inst_w       : std_logic_vector(15 downto 0); -- PROM data
   signal we           : std_logic;
   signal rst          : std_logic;
   signal rst2         : std_logic:='0';
   signal portb_in     : std_logic_vector(6 downto 0);
   signal portb_out    : std_logic_vector(6 downto 0);
   signal portb_oe     : std_logic_vector(6 downto 0);
   signal portd_in     : std_logic_vector(7 downto 0);
   signal portd_out    : std_logic_vector(7 downto 0);
   signal portd_oe     : std_logic_vector(7 downto 0);
   signal pin_irq      : std_logic_vector(1 downto 0); -- Pin interrupts INT0/1
   signal dev_irq      : std_logic_vector(2 downto 0); -- Device interrupts
   signal dev_ack      : std_logic_vector(2 downto 0); -- Device ACK

   -- WISHBONE signals:
   -- cpu
   signal cpu_dati  : std_logic_vector(7 downto 0);
   signal cpu_acki  : std_logic;
   signal cpu_dato  : std_logic_vector(7 downto 0);
   signal cpu_weo   : std_logic;
   signal cpu_adro  : std_logic_vector(7 downto 0);
   signal cpu_cyco  : std_logic;
   signal cpu_stbo  : std_logic;
   -- rs2
   signal rs2_dato  : std_logic_vector(7 downto 0);
   signal rs2_acko  : std_logic;
   signal rs2_dati  : std_logic_vector(7 downto 0);
   signal rs2_wei   : std_logic;
   signal rs2_adri  : std_logic_vector(0 downto 0);
   signal rs2_stbi  : std_logic;
   -- tmr
   signal tmr_dato  : std_logic_vector(7 downto 0);
   signal tmr_acko  : std_logic;
   signal tmr_dati  : std_logic_vector(7 downto 0);
   signal tmr_wei   : std_logic;
   signal tmr_adri  : std_logic_vector(2 downto 0);
   signal tmr_stbi  : std_logic;

   signal pwm       : std_logic_vector(5 downto 0);
   signal pwm_ena   : std_logic_vector(5 downto 0);

   signal t16_irq   : std_logic;
   signal t16_ack   : std_logic;

   signal inttx     : std_logic;
   signal intrx     : std_logic;

   signal dtr_r     : std_logic;
   signal dtr_reset : std_logic;
   -- SPI
   signal spi_sck   : std_logic;
   signal mosi      : std_logic;
   signal miso      : std_logic;
   signal spi_ena   : std_logic; -- The CPU enabled the SPI pins
   -- PLL
   signal clk_spi   : std_logic; -- SPI core clock
   signal clk_sys   : std_logic; -- CPU clock
   signal pll_lock  : std_logic;
begin
   -------------------------------
   -- RESET logic               --
   -- Power-On Reset + UART DTR --
   -------------------------------
   rst <= not(rst2) or dtr_reset;

   do_reset:
   process (clk_sys)
   begin
      if rising_edge(clk_sys) then
         if rst2='0' and pll_lock='1' then
            rst2 <= '1';
         end if;
      end if;
   end process do_reset;

   -- The DTR reset is triggered by a falling edge at DTR
   do_sample_dtr:
   process (clk_sys)
   begin
      if rising_edge(clk_sys) then
         dtr_r <= FTDI_DTR;
      end if;
   end process do_sample_dtr;
   dtr_reset <= '1' when dtr_r='1' and FTDI_DTR='0' else '0';

   -- Built-in LEDs
   LED1 <= portb_out(6); -- pin IO14
   LED2 <= portd_out(0);
   LED3 <= portd_out(1);
   LED4 <= portd_out(2);
   LED5 <= portd_out(3);

   -- Arduino IOx pins:
   ARDU00 <= portd_out(0) when portd_oe(0)='1' else 'Z';
   ARDU01 <= portd_out(1) when portd_oe(1)='1' else 'Z';
   ARDU02 <= portd_out(2) when portd_oe(2)='1' else 'Z';
   ARDU03 <= portd_out(3) when portd_oe(3)='1' else 'Z';
   ARDU04 <= portd_out(4) when portd_oe(4)='1' else 'Z';
   ARDU05 <= portd_out(5) when portd_oe(5)='1' else 'Z';
   ARDU06 <= portd_out(6) when portd_oe(6)='1' else 'Z';
   ARDU07 <= portd_out(7) when portd_oe(7)='1' else 'Z';
   ARDU08 <= portb_out(0) when portb_oe(0)='1' else 'Z';
   ARDU09 <= portb_out(1) when portb_oe(1)='1' else 'Z';
   ARDU10 <= portb_out(2) when portb_oe(2)='1' else 'Z';
   ARDU11 <= portb_out(3) when portb_oe(3)='1' else 'Z';
   ARDU12 <= portb_out(4) when portb_oe(4)='1' else 'Z';
   ARDU13 <= portb_out(5) when portb_oe(5)='1' else 'Z';

   portd_in(0) <= ARDU00;
   portd_in(1) <= ARDU01;
   portd_in(2) <= ARDU02;
   portd_in(3) <= ARDU03;
   portd_in(4) <= ARDU04;
   portd_in(5) <= ARDU05;
   portd_in(6) <= ARDU06;
   portd_in(7) <= ARDU07;
   portb_in(0) <= ARDU08;
   portb_in(1) <= ARDU09;
   portb_in(2) <= ARDU10;
   portb_in(3) <= ARDU11;
   portb_in(4) <= ARDU12;
   portb_in(5) <= ARDU13;

   miso        <= ARDU12;

   -- INT0/1 pins (PD2 and PD3)
   pin_irq(0) <= ARDU02 when ENA_INT0 else '0';
   pin_irq(1) <= ARDU03 when ENA_INT1 else '0';

   -- Device interrupts
   dev_irq(0) <= intrx;   -- UART Rx
   dev_irq(1) <= inttx;   -- UART Tx
   dev_irq(2) <= t16_irq; -- 16 bits Timer
   t16_ack <= dev_ack(2);

   micro : entity avr.ATtX5
      generic map(
         ENA_WB    => '1',    ENA_SPM   => '1', ENA_PORTB => '1',
         ENA_PORTC => '0',    ENA_PORTD => '1', PORTB_SIZE => 7,
         PORTC_SIZE => 6,     PORTD_SIZE => 8,  RESET_JUMP => RESET_JUMP,
         ENA_IRQ_CTRL => '1', ENA_AVR25 => '0', RAM_ADDR_W => RAM_ADDR_W,
         ENA_SPI => ENABLE_SPI)
      port map(
         rst_i => rst, clk_i => clk_sys, clk2x_i => clk_spi,
         pc_o => pc, inst_i => inst, ena_i => '1', portc_i => open,
         portb_i => portb_in, pgm_we_o => we, inst_o => inst_w,
         portd_i => portd_in, pin_irq_i => pin_irq, dev_irq_i => dev_irq,
         dev_ack_o => dev_ack, portb_o => portb_out, portd_o => portd_out,
         portb_oe_o => portb_oe, portd_oe_o => portd_oe,
         -- SPI
         spi_ena_o => spi_ena, sclk_o => spi_sck, miso_i => miso, mosi_o => mosi,
         -- WISHBONE
         wb_adr_o => cpu_adro, wb_dat_o => cpu_dato, wb_dat_i => cpu_dati,
         wb_stb_o => cpu_stbo, wb_we_o  => cpu_weo,  wb_ack_i => cpu_acki,
         -- Debug
         dbg_stop_i => '0', dbg_rf_fake_i => '0', dbg_rr_data_i => (others => '0'),
         dbg_rd_data_i => (others => '0'));
   cpu_cyco <= '0';

   pcsv <= std_logic_vector(pc(ROM_ADDR_W-1 downto 0));
   -- Program memory (1/2/4Kx16) (2/4/8 kiB)
   pm_2k:
   if ROM_ADDR_W=10 generate
      PM_Inst2 : lattuino_1_blPM_2S
         generic map(
            WORD_SIZE => 16, ADDR_W => ROM_ADDR_W)
         port map(
            clk_i => clk_sys, addr_i => pcsv, data_o => inst,
            data_i => inst_w, we_i => we);
   end generate pm_2k;

   pm_4k:
   if ROM_ADDR_W=11 generate
      PM_Inst4 : lattuino_1_blPM_4
         generic map(
            WORD_SIZE => 16, ADDR_W => ROM_ADDR_W)
         port map(
            clk_i => clk_sys, addr_i => pcsv, data_o => inst,
            data_i => inst_w, we_i => we);
   end generate pm_4k;

   pm_8k:
   if ROM_ADDR_W=12 generate
      PM_Inst8 : lattuino_1_blPM_8
         generic map(
            WORD_SIZE => 16, ADDR_W => ROM_ADDR_W)
         port map(
            clk_i => clk_sys, addr_i => pcsv, data_o => inst,
            data_i => inst_w, we_i => we);
   end generate pm_8k;

   -------------------
   -- WISHBONE UART --
   -------------------
   the_uart : UART_C
     generic map(
        BRDIVISOR => BRDIVISOR,
        WIP_ENABLE => '1',
        AUX_ENABLE => '0')
     port map(
        -- Wishbone signals
        wb_clk_i => clk_sys,  wb_rst_i => rst,      wb_adr_i => cpu_adro(0 downto 0),
        wb_dat_i => cpu_dato, wb_dat_o => cpu_dati, wb_we_i  => cpu_weo,
        wb_stb_i => cpu_stbo, wb_ack_o => cpu_acki,
        -- Process signals
        inttx_o  => inttx,    intrx_o => intrx,     br_clk_i => '1',
        txd_pad_o => FTDI_RXD, rxd_pad_i => FTDI_TXD);

   ----------------------------
   -- WISHBONE time counters --
   ----------------------------
   pwm <= (others => '0');
   pwm_ena <= (others => '0');

   ------------------------------
   -- WISHBONE 16 bits counter --
   ------------------------------
   -- Not supported
   t16_irq <= '0';

   do_2xSPI:
   if ENA_2xSCK generate
      -- *************************************************************************
      -- PLL: 48 MHz clock from 24 MHz clock
      -- *************************************************************************
      PLL1 : SB_PLL40_2F_PAD
         generic map(
            --- Feedback (all defaults)
            FEEDBACK_PATH => "SIMPLE",
            DELAY_ADJUSTMENT_MODE_FEEDBACK => "FIXED",
            -- DELAY_ADJUSTMENT_MODE_RELATIVE => "FIXED",
            SHIFTREG_DIV_MODE => "00",  --  0 --> Divide by 4, 1 --> Divide by 7, 3 --> Divide by 5
            FDA_FEEDBACK => "0000",
            -- FDA_RELATIVE => "0000",
            PLLOUT_SELECT_PORTA => "GENCLK",
            PLLOUT_SELECT_PORTB => "GENCLK_HALF",
            -- Freq. Multiplier (DIVF+1)/((2**DIVQ)*(DIVR+1))=32/16=2
            DIVF => "0011111", -- 31
            DIVR => "0000",
            DIVQ => "100", -- 4
            FILTER_RANGE => "010", -- Not documented!
            --- Output clock gates (for low power modes)
            ENABLE_ICEGATE_PORTA => '0',
            ENABLE_ICEGATE_PORTB => '0'
            --- Test Mode Parameter
            -- TEST_MODE => '0',
            -- EXTERNAL_DIVIDE_FACTOR => 1 -- Not Used by model, Added for PLL config GUI
            )
         port map(
            PACKAGEPIN    => CLK,        -- Clock pin from GBx
            PLLOUTCOREA   => open,       -- Clock A (to logic)
            PLLOUTGLOBALA => clk_spi,    -- Clock A (to global lines)
            PLLOUTCOREB   => open,       -- Clock B (to logic)
            PLLOUTGLOBALB => clk_sys,    -- Clock B (to global lines)
            EXTFEEDBACK   => open,       -- External feedback (not used here)
            DYNAMICDELAY  => open,       -- Dynamic delay (not used here)
            LOCK          => pll_lock,   -- PLL is locked
            BYPASS        => '0',        -- Bypass enable
            RESETB        => '1',       -- /Reset
            LATCHINPUTVALUE => open,     -- Clock gate enable
            -- Test Pins (not documented)
            SDO => open, SDI => open, SCLK => open);
   end generate do_2xSPI;

   do_1xSPI:
   if not(ENA_2xSCK) generate
      clk_spi  <= CLK;
      clk_sys  <= CLK;
      pll_lock <= '1';
   end generate do_1xSPI;

end architecture FPGA; -- Entity: Lattuino_Stick

