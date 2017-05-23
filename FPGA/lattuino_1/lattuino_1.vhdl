------------------------------------------------------------------------------
----                                                                      ----
----  AVR ATtX5 CPU for Lattuino                                          ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This module implements the CPU for Lattuino (iCE40HX4K Lattice FPGA ----
----  available in the Kéfir I board).                                    ----
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
---- Design unit:      Lattuino_1(FPGA) (Entity and architecture)         ----
---- File name:        lattuino_1.vhdl                                    ----
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
use work.WBDevInterconPkg.all;
use work.CPUConfig.all;

entity Lattuino_1 is
   port(
      CLK        : in    std_logic;  -- CPU clock
      RESET_P2   : in    std_logic;  -- Reset
      -- Buil-in LEDs
      LED1       : out   std_logic;
      LED2       : out   std_logic;
      LED3       : out   std_logic;
      LED4       : out   std_logic;
      -- CapSense buttons
      BTN1       : inout std_logic;
      BTN2       : inout std_logic;
      BTN3       : inout std_logic;
      BTN4       : inout std_logic;
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
      -- A/D Interface
      AD_CS      : out   std_logic;
      AD_Din     : out   std_logic;
      AD_Dout    : in    std_logic;
      AD_Clk     : out   std_logic;
      -- SPI memory
      SS_B       : out   std_logic;
      SDO        : out   std_logic;
      SDI        : in    std_logic;
      SCK        : out   std_logic;
      -- ISP SPI
      --ISP_RESET  : in    std_logic;
      ISP_SCK    : out   std_logic;
      ISP_MOSI   : out   std_logic;
      ISP_MISO   : in    std_logic;
      -- UART
      Milk_RXD   : out   std_logic;  -- to UART Tx
      Milk_TXD   : in    std_logic;  -- to UART Rx
      Milk_DTR   : in    std_logic); -- UART DTR
end entity Lattuino_1;

architecture FPGA of Lattuino_1 is
   constant BRDIVISOR  : natural:=natural(real(F_CLK)/real(BAUD_RATE)/4.0+0.5);
   constant CNT_PRESC  : natural:=F_CLK/1e6; -- Counter prescaler (1 µs)
   constant DEBUG_SPI  : boolean:=false;

   component AD_Conv is
      generic(
         DIVIDER      : positive:=12;
         INTERNAL_CLK : std_logic:='1';
         ENABLE       : std_logic:='1');
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

   signal pc           : unsigned(15 downto 0); -- PROM address
   signal pcsv         : std_logic_vector(ROM_ADDR_W-1 downto 0); -- PROM address
   signal inst         : std_logic_vector(15 downto 0); -- PROM data
   signal inst_w       : std_logic_vector(15 downto 0); -- PROM data
   signal we           : std_logic;
   signal rst          : std_logic;
   signal rst1         : std_logic;
   signal rst2         : std_logic:='0';
   signal portb_in     : std_logic_vector(6 downto 0);
   signal portb_out    : std_logic_vector(6 downto 0);
   signal portd_in     : std_logic_vector(7 downto 0);
   signal portd_out    : std_logic_vector(7 downto 0);
   signal btns         : std_logic_vector(3 downto 0); -- Capsense buttons
   signal rst_btn      : std_logic;
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
   -- ad
   signal ad_dato   : std_logic_vector(7 downto 0);
   signal ad_acko   : std_logic;
   signal ad_dati   : std_logic_vector(7 downto 0);
   signal ad_wei    : std_logic;
   signal ad_adri   : std_logic_vector(0 downto 0);
   signal ad_stbi   : std_logic;
   -- tmr
   signal tmr_dato  : std_logic_vector(7 downto 0);
   signal tmr_acko  : std_logic;
   signal tmr_dati  : std_logic_vector(7 downto 0);
   signal tmr_wei   : std_logic;
   signal tmr_adri  : std_logic_vector(2 downto 0);
   signal tmr_stbi  : std_logic;
   -- t16
   signal t16_dato  : std_logic_vector(7 downto 0);
   signal t16_acko  : std_logic;
   signal t16_dati  : std_logic_vector(7 downto 0);
   signal t16_wei   : std_logic;
   signal t16_adri  : std_logic_vector(0 downto 0);
   signal t16_stbi  : std_logic;

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
   -----------------------------------------------------------
   -- RESET logic                                           --
   -- Power-On Reset + External pin + CapSense 4 + UART DTR --
   -----------------------------------------------------------
   rst1 <= not(RESET_P2);
   rst <= rst1 or not(rst2) or rst_btn or dtr_reset;

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
         dtr_r <= Milk_DTR;
      end if;
   end process do_sample_dtr;
   dtr_reset <= '1' when dtr_r='1' and Milk_DTR='0' else '0';

   rst_btn <= btns(0) when ENABLE_B1_RESET else '0';

   -- Built-in LEDs
   LED1 <= portb_out(6); -- pin IO14
   --LED2 <= '0'; -- pwm(0);
   LED2 <= pwm(0);
   LED3 <= '0'; -- btns(2);
   LED4 <= rst_btn;

   -- Arduino IOx pins:
   ARDU00 <= portd_out(0);
   ARDU01 <= portd_out(1);
   ARDU02 <= portd_out(2);
   ARDU03 <= portd_out(3) when  pwm_ena(0)='0' or not(ENA_PWM0) else pwm(0);
   ARDU04 <= portd_out(4);
   ARDU05 <= portd_out(5) when  pwm_ena(1)='0' or not(ENA_PWM1) else pwm(1);
   ARDU06 <= portd_out(6) when  pwm_ena(2)='0' or not(ENA_PWM2) else pwm(2);
   ARDU07 <= portd_out(7);
   ARDU08 <= portb_out(0);
   ARDU09 <= portb_out(1) when  pwm_ena(3)='0' or not(ENA_PWM3) else pwm(3);
   ARDU10 <= portb_out(2) when  pwm_ena(4)='0' or not(ENA_PWM4) else pwm(4);
   ARDU11 <= portb_out(3) when (pwm_ena(5)='0' or not(ENA_PWM5)) and spi_ena='0' else
             mosi         when spi_ena='1' else
             pwm(5);
   ARDU12 <= portb_out(4) when spi_ena='0' else 'Z';
   ARDU13 <= portb_out(5) when spi_ena='0' else spi_sck;

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

   -- This is not 100% Arduino, here we fix SPI regardless spi_ena
   --ISP_SCK  <= spi_sck;
   --ARDU12   <= ISP_MISO;
   --ISP_MOSI <= mosi;

   -- INT0/1 pins (PD2 and PD3)
   pin_irq(0) <= ARDU02 when ENA_INT0 else '0';
   pin_irq(1) <= ARDU03 when ENA_INT1 else '0';
   -- Debug connection to CapSense
   --pin_irq(0) <= btns(1);
   --pin_irq(1) <= btns(2);

   -- Device interrupts
   dev_irq(0) <= intrx;   -- UART Rx
   dev_irq(1) <= inttx;   -- UART Tx
   dev_irq(2) <= t16_irq; -- 16 bits Timer
   t16_ack <= dev_ack(2);

   do_debug_spi:
   if DEBUG_SPI generate
      SS_B <= portb_out(2);
      SCK  <= spi_sck;
      miso <= SDI;
      SDO  <= mosi;
   end generate do_debug_spi;

   do_arduino_spi:
   if not(DEBUG_SPI) generate
      SS_B <= '1'; -- Disable the SPI memory
      SCK  <= '0';
      SDO  <= '0';
   end generate do_arduino_spi;

   micro : entity avr.ATtX5
      generic map(
         ENA_TC0 => false,   ENA_WB    => true,
         ENA_SPM   => true,  ENA_PORTB => true,  ENA_PORTC => false,
         ENA_PORTD => true,  PORTB_SIZE => 7,    PORTC_SIZE => 6,
         PORTD_SIZE => 8,    RESET_JUMP => RESET_JUMP, ENA_IRQ_CTRL => true,
         RAM_ADDR_W => RAM_ADDR_W, ENA_SPI => ENABLE_SPI)
      port map(
         rst_i => rst, clk_i => clk_sys, clk2x_i => clk_spi,
         pc_o => pc, inst_i => inst,
         portb_i => portb_in, pgm_we_o => we, inst_o => inst_w,
         portd_i => portd_in, pin_irq_i => pin_irq, dev_irq_i => dev_irq,
         dev_ack_o => dev_ack, portb_o => portb_out, portd_o => portd_out,
         -- SPI
          -- Connected to the SPI memory just for test
         spi_ena_o => spi_ena, sclk_o => spi_sck, miso_i => miso, mosi_o => mosi,
         -- WISHBONE
         wb_adr_o => cpu_adro, wb_dat_o => cpu_dato, wb_dat_i => cpu_dati,
         wb_stb_o => cpu_stbo, wb_we_o  => cpu_weo,  wb_ack_i => cpu_acki);
   cpu_cyco <= '0';

   pcsv <= std_logic_vector(pc(ROM_ADDR_W-1 downto 0));
   -- Program memory (1/2/4Kx16) (2/4/8 kiB)
   pm_2k:
   if ROM_ADDR_W=10 generate
      PM_Inst2 : lattuino_1_blPM_2
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

   -----------------------
   -- WISHBONE Intercon --
   -----------------------
   intercon: WBDevIntercon
      port map(
         -- wishbone master port(s)
         -- cpu
         cpu_dat_o => cpu_dati,
         cpu_ack_o => cpu_acki,
         cpu_dat_i => cpu_dato,
         cpu_we_i  => cpu_weo,
         cpu_adr_i => cpu_adro,
         cpu_cyc_i => cpu_cyco,
         cpu_stb_i => cpu_stbo,
         -- wishbone slave port(s)
         -- rs2
         rs2_dat_i => rs2_dato,
         rs2_ack_i => rs2_acko,
         rs2_dat_o => rs2_dati,
         rs2_we_o  => rs2_wei,
         rs2_adr_o => rs2_adri,
         rs2_stb_o => rs2_stbi,
         -- ad
         ad_dat_i => ad_dato,
         ad_ack_i => ad_acko,
         ad_dat_o => ad_dati,
         ad_we_o  => ad_wei,
         ad_adr_o => ad_adri,
         ad_stb_o => ad_stbi,
         -- tmr
         tmr_dat_i => tmr_dato,
         tmr_ack_i => tmr_acko,
         tmr_dat_o => tmr_dati,
         tmr_we_o  => tmr_wei,
         tmr_adr_o => tmr_adri,
         tmr_stb_o => tmr_stbi,
         -- t16
         t16_dat_i => t16_dato,
         t16_ack_i => t16_acko,
         t16_dat_o => t16_dati,
         t16_we_o  => t16_wei,
         t16_adr_o => t16_adri,
         t16_stb_o => t16_stbi,
         -- clock and reset
         wb_clk_i => clk_sys,
         wb_rst_i => rst);

   -------------------
   -- WISHBONE UART --
   -------------------
   the_uart : UART_C
     generic map(
        BRDIVISOR => BRDIVISOR,
        WIP_ENABLE => true,
        AUX_ENABLE => false)
     port map(
        -- Wishbone signals
        wb_clk_i => clk_sys,      wb_rst_i => rst,  wb_adr_i => rs2_adri,
        wb_dat_i => rs2_dati, wb_dat_o => rs2_dato, wb_we_i  => rs2_wei,
        wb_stb_i => rs2_stbi, wb_ack_o => rs2_acko,
        -- Process signals
        inttx_o  => inttx,    intrx_o => intrx,     br_clk_i => '1',
        txd_pad_o => Milk_RXD, rxd_pad_i => Milk_TXD);

   ----------------------------
   -- WISHBONE time counters --
   ----------------------------
   the_counter : TMCounter
     generic map(
        CNT_PRESC => CNT_PRESC, ENA_TMR => ENA_TIME_CNT)
     port map(
        pwm_o => pwm, pwm_e_o => pwm_ena,
        -- Wishbone signals
        wb_clk_i => clk_sys,   wb_rst_i => rst,     wb_adr_i => tmr_adri,
        wb_dat_o => tmr_dato, wb_stb_i => tmr_stbi, wb_ack_o => tmr_acko,
        wb_dat_i => tmr_dati, wb_we_i  => tmr_wei);

   ------------------------------
   -- WISHBONE 16 bits counter --
   ------------------------------
   the_tm16bits : TM16bits
     generic map(CNT_PRESC => CNT_PRESC, ENA_TMR => ENA_TMR16)
     port map(
        irq_req_o => t16_irq, irq_ack_i => t16_ack,
        -- Wishbone signals
        wb_clk_i => clk_sys,   wb_rst_i => rst,     wb_adr_i => t16_adri,
        wb_dat_o => t16_dato, wb_stb_i => t16_stbi, wb_ack_o => t16_acko,
        wb_dat_i => t16_dati, wb_we_i  => t16_wei);

   ------------------
   -- WISHBONE A/D --
   ------------------
   the_ad : AD_Conv
     generic map(ENABLE => ENABLE_AD)
     port map(
        ad_ncs_o => AD_CS,   ad_clk_o => AD_Clk,  ad_din_o => AD_Din,
        ad_dout_i => AD_Dout, spi_ena_i => '0',
        -- Wishbone signals
        wb_clk_i => clk_sys,  wb_rst_i => rst,     wb_adr_i => ad_adri,
        wb_dat_o => ad_dato, wb_stb_i => ad_stbi, wb_ack_o => ad_acko,
        wb_dat_i => ad_dati, wb_we_i  => ad_wei);

   ----------------------
   -- Botones CapSense --
   ----------------------
   CS : entity CapSense.CapSense_Sys
       generic map (N => 4, FREQUENCY => CNT_PRESC, DIRECT => false)
       port map(
          clk_i => clk_sys,
          rst_i => '0',
          capsense_io(0) => BTN1,
          capsense_io(1) => BTN2,
          capsense_io(2) => BTN3,
          capsense_io(3) => BTN4,
          buttons_o => btns, debug_o => open);

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

end architecture FPGA; -- Entity: Lattuino_1

