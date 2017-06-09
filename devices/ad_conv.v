/***********************************************************************

  WISHBONE A/D Interface

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements the WISHBONE interface for the A/D (MCP3008).

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador en inti.gob.ar

----------------------------------------------------------------------

 Copyright (c) 2017 Salvador E. Tropea <salvador en inti.gob.ar>
 Copyright (c) 2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

----------------------------------------------------------------------

 Design unit:      AD_Conv(RTL) (Entity and architecture)
 File name:        ad_conv.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          lattuino
 Dependencies:     IEEE.std_logic_1164
                   IEEE.numeric_std
                   SPI.Devices
 Target FPGA:      iCE40HX4K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  Lattice iCECube2 2016.02.27810
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

----------------------------------------------------------------------

 Wishbone Datasheet

  1 Revision level                      B.3
  2 Type of interface                   SLAVE
  3 Defined signal names                RST_I => wb_rst_i
                                        CLK_I => wb_clk_i
                                        ADR_I => wb_adr_i
                                        DAT_I => wb_dat_i
                                        DAT_O => wb_dat_o
                                        WE_I  => wb_we_i
                                        ACK_O => wb_ack_o
                                        STB_I => wb_stb_i
  4 ERR_I                               Unsupported
  5 RTY_I                               Unsupported
  6 TAGs                                None
  7 Port size                           8-bit
  8 Port granularity                    8-bit
  9 Maximum operand size                8-bit
 10 Data transfer ordering              N/A
 11 Data transfer sequencing            Undefined
 12 Constraints on the CLK_I signal     None

************************************************************************/

module AD_Conv
   #(
     parameter DIVIDER=12,
     parameter INTERNAL_CLK=1,
     parameter ENABLE=1)
   (
    // WISHBONE signals
    input        wb_clk_i,   // Clock
    input        wb_rst_i,   // Reset input
    input  [0:0] wb_adr_i,   // Adress bus
    output [7:0] wb_dat_o,   // DataOut Bus
    input  [7:0] wb_dat_i,   // DataIn Bus
    input        wb_we_i,    // Write Enable
    input        wb_stb_i,   // Strobe
    output       wb_ack_o,   // Acknowledge
    // SPI rate (2x)
    // Note: with 2 MHz spi_ena_i we get 1 MHz SPI clock => 55,6 ks/s
    input        spi_ena_i,  // 2xSPI clock
    // A/D interface
    output       ad_ncs_o,   // SPI /CS
    output       ad_clk_o,   // SPI clock
    output       ad_din_o,   // SPI A/D Din (MOSI)
    input        ad_dout_i); // SPI A/D Dout (MISO)

localparam integer CNT_BITS=$clog2(DIVIDER);

reg [CNT_BITS-1:0] cnt_div_spi=0;
wire spi_ena;
reg  start_r;
wire busy_ad;
wire busy;
reg  [2:0] chn_r;
wire [9:0] cur_val;
wire [7:0] wb_dat;
wire ad_ncs;  // SPI /CS
wire ad_clk;  // SPI clock
wire ad_din;  // SPI A/D Din (MOSI)

assign wb_dat=wb_adr_i[0] ? {busy,{5{1'b0}},cur_val[9:8]} : cur_val[7:0];
assign wb_dat_o=ENABLE ? wb_dat : 0;
assign wb_ack_o=wb_stb_i;

// The A/D reads start only when ena_i is 1, so we memorize it
// until the A/D indicates a conversion with busy_ad
always @(posedge wb_clk_i)
begin : do_start
  if (wb_rst_i)
     start_r <= 0;
  else
     if (wb_stb_i && wb_we_i)
        start_r <= 1;
     else
        if (busy_ad)
           start_r <= 0;
end // do_start

// The A/D is busy or we have a pending start
assign busy=busy_ad | start_r;

always @(posedge wb_clk_i)
begin : do_chn_write
  if (wb_stb_i && wb_we_i)
     chn_r <= wb_dat_i[2:0];
end

//////////////////////
// SPI clock enable //
//////////////////////
generate
if (INTERNAL_CLK)
  begin
  always @(posedge wb_clk_i)
  begin : do_spi_div
    if (cnt_div_spi==DIVIDER-1)
       cnt_div_spi <= 0;
    else
       cnt_div_spi <= cnt_div_spi+1;
  end
  assign spi_ena=cnt_div_spi==DIVIDER-1;
  end
else
  begin
  assign spi_ena=spi_ena_i;
  end
endgenerate

///////////////////
// A/D interface //
///////////////////
MCP300x the_AD
  (// System
   .clk_i(wb_clk_i), .rst_i(1'b0),
   // Master interface
   .start_i(start_r), .busy_o(busy_ad), .chn_i(chn_r), .single_i(1'b1),
   .ena_i(spi_ena), .eoc_o(), .data_o(cur_val),
   // A/D interface
   .ad_ncs_o(ad_ncs), .ad_clk_o(ad_clk), .ad_din_o(ad_din),
   .ad_dout_i(ad_dout_i));

assign ad_ncs_o=ENABLE ? ad_ncs : 0;
assign ad_clk_o=ENABLE ? ad_clk : 0;
assign ad_din_o=ENABLE ? ad_din : 0;
endmodule // AD_Conv

