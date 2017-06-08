/***********************************************************************

  AVR ATtX5 CPU for Lattuino

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  This module implements the CPU for Lattuino (iCE40HX4K Lattice FPGA
  available in the Kéfir I board).

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2008-2017 Salvador E. Tropea <salvador inti.gob.ar>
 Copyright (c) 2008-2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      Lattuino_1
 File name:        lattuino_1.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          work
 Dependencies:     IEEE.std_logic_1164
                   avr.Micros
                   miniuart.UART
                   CapSense.Devices
                   work.WBDevInterconPkg
                   work.CPUConfig
                   lattice.components
 Target FPGA:      iCE40HX4K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  Lattice iCECube2 2016.02.27810
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

***********************************************************************/

module Lattuino_1
   (
    input  CLK,      // CPU clock
    input  RESET_P2, // Reset
    // Buil-in LEDs
    output LED1, 
    output LED2, 
    output LED3, 
    output LED4, 
    // CapSense buttons
    inout  BTN1,
    inout  BTN2,
    inout  BTN3,
    inout  BTN4,
    // Arduino UNO I/O
    inout  ARDU00,
    inout  ARDU01,
    inout  ARDU02,
    inout  ARDU03,
    inout  ARDU04,
    inout  ARDU05,
    inout  ARDU06,
    inout  ARDU07,
    inout  ARDU08,
    inout  ARDU09,
    inout  ARDU10,  // SS
    inout  ARDU11,  // MOSI
    inout  ARDU12,  // MISO
    inout  ARDU13,  // SCK
    // A/D Interface
    output AD_CS, 
    output AD_Din, 
    input  AD_Dout,
    output AD_Clk, 
    // SPI memory
    output SS_B, 
    output SDO, 
    input  SDI,
    output SCK, 
    // ISP SPI
    //input ISP_RESET;
    output ISP_SCK, 
    output ISP_MOSI, 
    input  ISP_MISO,
    // UART
    output Milk_RXD,  // to UART Tx
    input  Milk_TXD,  // to UART Rx
    input  Milk_DTR); // UART DTR

`include "cpuconfig.v"

localparam integer BRDIVISOR=F_CLK/BAUD_RATE/4.0+0.5;
localparam integer CNT_PRESC=F_CLK/1e6; // Counter prescaler (1 µs)
localparam EXPLICIT_TBUF=1; // Manually instantiate tri-state buffers
localparam DEBUG_SPI=0;
localparam DEBUG_INT=0;

wire [15:0] pc; // PROM address
wire [ROM_ADDR_W-1:0] pcsv; // PROM address
wire [15:0] inst;   // PROM data
wire [15:0] inst_w; // PROM data
wire we;
wire rst;
wire rst1;
reg  rst2=0;
wire [6:0] portb_in;
wire [6:0] portb_out;
wire [7:0] portd_in;
wire [7:0] portd_out;
wire [3:0] btns; // Capsense buttons
wire discharge;
wire rst_btn;
wire [1:0] pin_irq; // Pin interrupts INT0/1
wire [2:0] dev_irq; // Device interrupts
wire [2:0] dev_ack; // Device ACK

// WISHBONE signals:
// cpu
wire [7:0] cpu_dati;
wire       cpu_acki;
wire [7:0] cpu_dato;
wire       cpu_weo;
wire [7:0] cpu_adro;
wire       cpu_cyco;
wire       cpu_stbo;
// rs2
wire [7:0] rs2_dato;
wire       rs2_acko;
wire [7:0] rs2_dati;
wire       rs2_wei;
wire [0:0] rs2_adri;
wire       rs2_stbi;
// ad
wire [7:0] ad_dato;
wire       ad_acko;
wire [7:0] ad_dati;
wire       ad_wei;
wire [0:0] ad_adri;
wire       ad_stbi;
// tmr
wire [7:0] tmr_dato;
wire       tmr_acko;
wire [7:0] tmr_dati;
wire       tmr_wei;
wire [2:0] tmr_adri;
wire       tmr_stbi;
// t16
wire [7:0] t16_dato;
wire       t16_acko;
wire [7:0] t16_dati;
wire       t16_wei;
wire [0:0] t16_adri;
wire       t16_stbi;

wire [5:0] pwm;
wire [5:0] pwm_ena;

wire t16_irq;
wire t16_ack;

wire inttx;
wire intrx;

reg  dtr_r;
wire dtr_reset;
// SPI
wire spi_sck;
wire mosi;
wire miso;
wire spi_ena; // The CPU enabled the SPI pins
// PLL
wire clk_spi; // SPI core clock
wire clk_sys; // CPU clock
wire pll_lock;

///////////////////////////////////////////////////////////
// RESET logic                                           --
// Power-On Reset + External pin + CapSense 4 + UART DTR --
///////////////////////////////////////////////////////////
assign rst1=!RESET_P2;
assign rst=rst1 | ~rst2 | rst_btn | dtr_reset;

always @(posedge clk_sys)
begin : do_reset
  if (!rst2 && pll_lock)
     rst2 <= 1;
end // do_reset

// The DTR reset is triggered by a falling edge at DTR
always @(posedge clk_sys)
begin : do_sample_dtr
  dtr_r <= Milk_DTR;
end // do_sample_dtr
assign dtr_reset=dtr_r && !Milk_DTR;

assign rst_btn=ENABLE_B1_RESET ? btns[0] : 0;

// Built-in LEDs
assign LED1=portb_out[6]; // pin IO14
assign LED2=pwm[0];
assign LED3=0; // btns[2];
assign LED4=rst_btn;

// Arduino IOx pins:
assign ARDU00=portd_out[0];
assign ARDU01=portd_out[1];
assign ARDU02=portd_out[2];
assign ARDU03=pwm_ena[0] && ENA_PWM0 ? pwm[0] : portd_out[3];
assign ARDU04=portd_out[4];
assign ARDU05=pwm_ena[1] && ENA_PWM1 ? pwm[1] : portd_out[5];
assign ARDU06=pwm_ena[2] && ENA_PWM2 ? pwm[2] : portd_out[6];
assign ARDU07=portd_out[7];
assign ARDU08=portb_out[0];
assign ARDU09=pwm_ena[3] && ENA_PWM3 ? pwm[3] : portb_out[1];
assign ARDU10=pwm_ena[4] && ENA_PWM4 ? pwm[4] : portb_out[2];
assign ARDU11=pwm_ena[5] && ENA_PWM5 && !spi_ena ? pwm[5] :
             (spi_ena ? mosi    : portb_out[3]);
assign ARDU12=spi_ena ? 1'bZ    : portb_out[4];
assign ARDU13=spi_ena ? spi_sck : portb_out[5];

assign portd_in[0]=ARDU00;
assign portd_in[1]=ARDU01;
assign portd_in[2]=ARDU02;
assign portd_in[3]=ARDU03;
assign portd_in[4]=ARDU04;
assign portd_in[5]=ARDU05;
assign portd_in[6]=ARDU06;
assign portd_in[7]=ARDU07;
assign portb_in[0]=ARDU08;
assign portb_in[1]=ARDU09;
assign portb_in[2]=ARDU10;
assign portb_in[3]=ARDU11;
assign portb_in[4]=ARDU12;
assign portb_in[5]=ARDU13;

assign miso       =ARDU12;

// This is not 100% Arduino, here we fix SPI regardless spi_ena
//ISP_SCK =spi_sck;
//ARDU12  =ISP_MISO;
//ISP_MOSI=mosi;

generate
if (DEBUG_INT)
   begin : do_int_btns
   // Debug connection to CapSense
   assign pin_irq[0]=btns[1];
   assign pin_irq[1]=btns[2];
   end
else
   begin : do_int_pins
   // INT0/1 pins (PD2 and PD3)
   assign pin_irq[0]=ENA_INT0 ? ARDU02 : 0;
   assign pin_irq[1]=ENA_INT1 ? ARDU03 : 0;
   end
endgenerate

// Device interrupts
assign dev_irq[0]=intrx;   // UART Rx
assign dev_irq[1]=inttx;   // UART Tx
assign dev_irq[2]=t16_irq; // 16 bits Timer
assign t16_ack=dev_ack[2];

generate
if (DEBUG_SPI)
   begin : do_debug_spi
   assign SS_B=portb_out[2];
   assign SCK =spi_sck;
   assign miso=SDI;
   assign SDO =mosi;
   end
else
   begin : do_arduino_spi
   assign SS_B=1; // Disable the SPI memory
   assign SCK =0;
   assign SDO =0;
   end
endgenerate

ATtX5
   #(
     .ENA_WB(1), .ENA_SPM(1), .ENA_PORTB(1), .ENA_PORTC(0),
     .ENA_PORTD(1), .PORTB_SIZE(7), .PORTC_SIZE(6),
     .PORTD_SIZE(8),.RESET_JUMP(RESET_JUMP), .ENA_IRQ_CTRL(1),
     .RAM_ADDR_W(RAM_ADDR_W), .ENA_SPI(ENABLE_SPI))
   micro
   (
    .rst_i(rst), .clk_i(clk_sys), .clk2x_i(clk_spi),
    .pc_o(pc), .inst_i(inst), .ena_i(1), .portc_i(),
    .portb_i(portb_in), .pgm_we_o(we), .inst_o(inst_w),
    .portd_i(portd_in), .pin_irq_i(pin_irq), .dev_irq_i(dev_irq),
    .dev_ack_o(dev_ack), .portb_o(portb_out), .portd_o(portd_out),
    // SPI
    .spi_ena_o(spi_ena), .sclk_o(spi_sck), .miso_i(miso), .mosi_o(mosi),
    // WISHBONE
    .wb_adr_o(cpu_adro), .wb_dat_o(cpu_dato), .wb_dat_i(cpu_dati),
    .wb_stb_o(cpu_stbo), .wb_we_o(cpu_weo),   .wb_ack_i(cpu_acki),
    // Debug
    .dbg_stop_i(0), .dbg_rf_fake_i(0), .dbg_rr_data_i(0),
    .dbg_rd_data_i(0));
assign cpu_cyco=0;

assign pcsv=pc[ROM_ADDR_W-1:0];

// Program memory (1/2/4Kx16) (2/4/8 kiB)
generate
if (ROM_ADDR_W==10)
   begin : pm_2k
   lattuino_1_blPM_2 #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst2
      (.clk_i(clk_sys), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
else if (ROM_ADDR_W==11)
   begin : pm_4k
   lattuino_1_blPM_4 #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst4
      (.clk_i(clk_sys), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
else if (ROM_ADDR_W==12)
   begin : pm_8k
   lattuino_1_blPM_8 #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst8
      (.clk_i(clk_sys), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
endgenerate

///////////////////////
// WISHBONE Intercon //
///////////////////////
WBDevIntercon intercon
   (// WISHBONE master port(s)
    // cpu
    .cpu_dat_o(cpu_dati),
    .cpu_ack_o(cpu_acki),
    .cpu_dat_i(cpu_dato),
    .cpu_we_i(cpu_weo),
    .cpu_adr_i(cpu_adro),
    .cpu_cyc_i(cpu_cyco),
    .cpu_stb_i(cpu_stbo),
    // WISHBONE slave port(s)
    // rs2
    .rs2_dat_i(rs2_dato),
    .rs2_ack_i(rs2_acko),
    .rs2_dat_o(rs2_dati),
    .rs2_we_o(rs2_wei),
    .rs2_adr_o(rs2_adri),
    .rs2_stb_o(rs2_stbi),
    // ad
    .ad_dat_i(ad_dato),
    .ad_ack_i(ad_acko),
    .ad_dat_o(ad_dati),
    .ad_we_o(ad_wei),
    .ad_adr_o(ad_adri),
    .ad_stb_o(ad_stbi),
    // tmr
    .tmr_dat_i(tmr_dato),
    .tmr_ack_i(tmr_acko),
    .tmr_dat_o(tmr_dati),
    .tmr_we_o(tmr_wei),
    .tmr_adr_o(tmr_adri),
    .tmr_stb_o(tmr_stbi),
    // t16
    .t16_dat_i(t16_dato),
    .t16_ack_i(t16_acko),
    .t16_dat_o(t16_dati),
    .t16_we_o(t16_wei),
    .t16_adr_o(t16_adri),
    .t16_stb_o(t16_stbi),
    // clock and reset
    .wb_clk_i(clk_sys),
    .wb_rst_i(rst));

///////////////////
// WISHBONE UART //
///////////////////
UART_C
  #(.BRDIVISOR(BRDIVISOR),
    .WIP_ENABLE(1),
    .AUX_ENABLE(0))
  the_uart
  (// WISHBONE signals
   .wb_clk_i(clk_sys),  .wb_rst_i(rst),      .wb_adr_i(rs2_adri),
   .wb_dat_i(rs2_dati), .wb_dat_o(rs2_dato), .wb_we_i(rs2_wei),
   .wb_stb_i(rs2_stbi), .wb_ack_o(rs2_acko),
   // Process signals
   .inttx_o(inttx),      .intrx_o(intrx),    .br_clk_i(1),
   .txd_pad_o(Milk_RXD), .rxd_pad_i(Milk_TXD));

////////////////////////////
// WISHBONE time counters //
////////////////////////////
TMCounter
  #(.CNT_PRESC(CNT_PRESC), .ENA_TMR(ENA_TIME_CNT))
  the_counter
  (// WISHBONE signals
   .wb_clk_i(clk_sys),  .wb_rst_i(rst),      .wb_adr_i(tmr_adri),
   .wb_dat_o(tmr_dato), .wb_stb_i(tmr_stbi), .wb_ack_o(tmr_acko),
   .wb_dat_i(tmr_dati), .wb_we_i(tmr_wei),
   // PWMs
   .pwm_o(pwm), .pwm_e_o(pwm_ena));

//////////////////////////////
// WISHBONE 16 bits counter //
//////////////////////////////
TM16bits
  #(.CNT_PRESC(CNT_PRESC), .ENA_TMR(ENA_TMR16))
  the_tm16bits
  (// Wishbone signals
   .wb_clk_i(clk_sys),  .wb_rst_i(rst),      .wb_adr_i(t16_adri),
   .wb_dat_o(t16_dato), .wb_stb_i(t16_stbi), .wb_ack_o(t16_acko),
   .wb_dat_i(t16_dati), .wb_we_i(t16_wei),
   // IRQ
   .irq_req_o(t16_irq), .irq_ack_i(t16_ack));

//////////////////
// WISHBONE A/D //
//////////////////
AD_Conv
  #(.ENABLE(ENABLE_AD))
  the_ad
  (// WISHBONE signals
   .wb_clk_i(clk_sys), .wb_rst_i(rst),     .wb_adr_i(ad_adri),
   .wb_dat_o(ad_dato), .wb_stb_i(ad_stbi), .wb_ack_o(ad_acko),
   .wb_dat_i(ad_dati), .wb_we_i(ad_wei),
   // A/D
   .ad_ncs_o(AD_CS),   .ad_clk_o(AD_Clk),  .ad_din_o(AD_Din),
   .ad_dout_i(AD_Dout),.spi_ena_i(0));

//////////////////////
// Botones CapSense //
//////////////////////
wire [3:0] capsense_in;
CapSense_Sys
  #(.N(4), .FREQUENCY(CNT_PRESC), .DIRECT(0))
  CS
  (.clk_i(clk_sys),
   .rst_i(0),
   .capsense_i(capsense_in),
   .capsense_o(discharge),
   .buttons_o(btns), .debug_o());

generate
if (EXPLICIT_TBUF)
   begin
   SB_IO
     #(.PIN_TYPE(6'b1010_01),
       .PULLUP(1'b0))
     buts [3:0]
     (.PACKAGE_PIN({BTN4,BTN3,BTN2,BTN1}),
      .OUTPUT_ENABLE(discharge),
      .D_OUT_0(4'b0),
      .D_IN_0(capsense_in));
   end
else
   begin
   assign {BTN4,BTN3,BTN2,BTN1}=discharge ? 4'b0 : 4'bZ;
   assign capsense_in={BTN4,BTN3,BTN2,BTN1};
   end
endgenerate

generate
if (ENA_2xSCK)
   begin : do_2xSPI
   // *************************************************************************
   // PLL: 48 MHz clock from 24 MHz clock
   // *************************************************************************
   SB_PLL40_2F_PAD
      #(// Feedback (all defaults)
        .FEEDBACK_PATH("SIMPLE"),
        .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
        // .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
        .SHIFTREG_DIV_MODE(2'b0),  //  0 --> Divide by 4, 1 --> Divide by 7), 3 --> Divide by 5
        .FDA_FEEDBACK(4'b0),
        // .FDA_RELATIVE(0),
        .PLLOUT_SELECT_PORTA("GENCLK"),
        .PLLOUT_SELECT_PORTB("GENCLK_HALF"),
        // Freq. Multiplier (DIVF+1)/((2**DIVQ)*(DIVR+1))=32/16=2
        .DIVF(7'b0011111), // 31
        .DIVR(4'b0),
        .DIVQ(3'b100), // 4
        .FILTER_RANGE(3'b010), // Not documented!
        // Output clock gates (for low power modes)
        .ENABLE_ICEGATE_PORTA(0),
        .ENABLE_ICEGATE_PORTB(0)
        // Test Mode Parameter
        // .TEST_MODE(0),
        // EXTERNAL_DIVIDE_FACTOR(1) -- Not Used by model, Added for PLL config GUI
        )
      PLL1
      (.PACKAGEPIN(CLK),        // Clock pin from GBx
       .PLLOUTCOREA(),          // Clock A (to logic)
       .PLLOUTGLOBALA(clk_spi), // Clock A (to global lines)
       .PLLOUTCOREB(),          // Clock B (to logic)
       .PLLOUTGLOBALB(clk_sys), // Clock B (to global lines)
       .EXTFEEDBACK(),          // External feedback (not used here)
       .DYNAMICDELAY(),         // Dynamic delay (not used here)
       .LOCK(pll_lock),         // PLL is locked
       .BYPASS(0),              // Bypass enable
       .RESETB(1),              // /Reset
       .LATCHINPUTVALUE(),      // Clock gate enable
       // Test Pins (not documented)
       .SDO(), .SDI(), .SCLK());
   end
else
   begin : do_1xSPI
   assign clk_spi =CLK;
   assign clk_sys =CLK;
   assign pll_lock=1;
   end
endgenerate

endmodule // Lattuino_1

