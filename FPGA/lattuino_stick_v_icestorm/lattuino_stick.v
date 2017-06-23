/***********************************************************************

  AVR ATtX5 CPU for Lattuino

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  This module implements the CPU for Lattuino (iCE40HX1K Lattice FPGA
  available in the iCE Stick board).

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2008-2017 Salvador E. Tropea <salvador inti.gob.ar>
 Copyright (c) 2008-2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      Lattuino_Stick
 File name:        lattuino_stick.v
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
 Target FPGA:      iCE40HX1K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  IceStorm
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

***********************************************************************/

module Lattuino_Stick
   (
    input  CLK,      // CPU clock
    input  RESET_P2, // Reset
    // Buil-in LEDs
    output LED1, 
    output LED2, 
    output LED3, 
    output LED4, 
    output LED5,
    // UART
    output FTDI_RXD,  // to UART Tx
    input  FTDI_TXD,  // to UART Rx
    input  FTDI_DTR); // UART DTR

`include "../cpuconfig.v"

localparam integer BRDIVISOR=F_CLK/BAUD_RATE/4.0+0.5;
localparam integer CNT_PRESC=F_CLK/1e6; // Counter prescaler (1 µs)
localparam EXPLICIT_TBUF=1; // Manually instantiate tri-state buffers
localparam DEBUG_SPI=0;

wire [15:0] pc; // PROM address
wire [ROM_ADDR_W-1:0] pcsv; // PROM address
wire [15:0] inst;   // PROM data
wire [15:0] inst_w; // PROM data
wire we;
wire rst;
reg  rst2=0;
wire [4:0] portd_in;
wire [4:0] portd_out;
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
wire       cpu_stbo;
// rs2
wire [7:0] rs2_dato;
wire       rs2_acko;
wire [7:0] rs2_dati;
wire       rs2_wei;
wire [0:0] rs2_adri;
wire       rs2_stbi;

wire inttx;
wire intrx;

reg  dtr_r;
wire dtr_reset;

///////////////////////////////
// RESET logic               //
// Power-On Reset + UART DTR //
///////////////////////////////
assign rst=~rst2 | dtr_reset;

always @(posedge CLK)
begin : do_reset
  if (!rst2)
     rst2 <= 1;
end // do_reset

// The DTR reset is triggered by a falling edge at DTR
always @(posedge CLK)
begin : do_sample_dtr
  dtr_r <= FTDI_DTR;
end // do_sample_dtr
assign dtr_reset=dtr_r && !FTDI_DTR;

// Built-in LEDs
assign LED1=portd_out[0]; // pin IO14
assign LED2=portd_out[1];
assign LED3=portd_out[2];
assign LED4=portd_out[3];
assign LED5=portd_out[4];

// INT0/1 pins (PD2 and PD3)
assign pin_irq[0]=0;
assign pin_irq[1]=0;

// Device interrupts
assign dev_irq[0]=0;   // UART Rx
assign dev_irq[1]=0;   // UART Tx
assign dev_irq[2]=0;   // 16 bits Timer

ATtX5
   #(
     .ENA_WB(1), .ENA_SPM(1), .ENA_PORTB(0), .ENA_PORTC(0),
     .ENA_PORTD(1), .PORTB_SIZE(7), .PORTC_SIZE(6),
     .PORTD_SIZE(5),.RESET_JUMP(RESET_JUMP), .ENA_IRQ_CTRL(0),
     .RAM_ADDR_W(RAM_ADDR_W), .ENA_SPI(ENABLE_SPI))
   micro
   (
    .rst_i(rst), .clk_i(CLK), .clk2x_i(CLK),
    .pc_o(pc), .inst_i(inst), .ena_i(1), .portc_i(),
    .portb_i(), .pgm_we_o(we), .inst_o(inst_w),
    .portd_i(), .pin_irq_i(pin_irq), .dev_irq_i(dev_irq),
    .dev_ack_o(dev_ack), .portb_o(), .portd_o(portd_out),
    .portb_oe_o(), .portd_oe_o(),
    // SPI
    .spi_ena_o(), .sclk_o(), .miso_i(), .mosi_o(),
    // WISHBONE
    .wb_adr_o(cpu_adro), .wb_dat_o(cpu_dato), .wb_dat_i(cpu_dati),
    .wb_stb_o(cpu_stbo), .wb_we_o(cpu_weo),   .wb_ack_i(cpu_acki),
    // Debug
    .dbg_stop_i(0), .dbg_rf_fake_i(0), .dbg_rr_data_i(0),
    .dbg_rd_data_i(0));

assign pcsv=pc[ROM_ADDR_W-1:0];

// Program memory (1/2/4Kx16) (2/4/8 kiB)
generate
if (ROM_ADDR_W==10)
   begin : pm_2k
   lattuino_1_blPM_2S #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst2
      (.clk_i(CLK), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
else if (ROM_ADDR_W==11)
   begin : pm_4k
   lattuino_1_blPM_4 #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst4
      (.clk_i(CLK), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
else if (ROM_ADDR_W==12)
   begin : pm_8k
   lattuino_1_blPM_8 #(.WORD_SIZE(16), .ADDR_W(ROM_ADDR_W)) PM_Inst8
      (.clk_i(CLK), .addr_i(pcsv), .data_o(inst),
       .data_i(inst_w), .we_i(we));
   end
endgenerate

///////////////////
// WISHBONE UART //
///////////////////
UART_C
  #(.BRDIVISOR(BRDIVISOR),
    .WIP_ENABLE(1),
    .AUX_ENABLE(0))
  the_uart
  (// WISHBONE signals
   .wb_clk_i(CLK),  .wb_rst_i(rst),      .wb_adr_i(cpu_adro[0:0]),
   .wb_dat_i(cpu_dato), .wb_dat_o(cpu_dati), .wb_we_i(cpu_weo),
   .wb_stb_i(cpu_stbo), .wb_ack_o(cpu_acki),
   // Process signals
   .inttx_o(inttx),      .intrx_o(intrx),    .br_clk_i(1),
   .txd_pad_o(FTDI_RXD), .rxd_pad_i(FTDI_TXD));

endmodule // Lattuino_Stick

