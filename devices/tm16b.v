/***********************************************************************

  16 bits WISHBONE timer

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements a 16 bits timer (clock counter) to generate periodic
  interrupts. Used by Tone.cpp Arduino API.
  Port    Write          Read
    0    Low Divider     0
    1    High Divider    0

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador en inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2017 Salvador E. Tropea <salvador en inti.gob.ar>
 Copyright (c) 2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      TM16bits(RTL) (Entity and architecture)
 File name:        tm16b.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          lattuino
 Dependencies:     IEEE.std_logic_1164
                   IEEE.numeric_std
 Target FPGA:      iCE40HX4K-TQ144
 Language:         Verilog
 Wishbone:         None
 Synthesis tools:  Lattice iCECube2 2016.02.27810
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

------------------------------------------------------------------------------

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

***********************************************************************/

module TM16bits
  #(
    parameter CNT_PRESC=24,
    parameter ENA_TMR=1
   )
   (
    // WISHBONE signals
    input        wb_clk_i,  // Clock
    input        wb_rst_i,  // Reset input
    input  [0:0] wb_adr_i,  // Adress bus
    output [7:0] wb_dat_o,  // DataOut Bus
    input  [7:0] wb_dat_i,  // DataIn Bus
    input        wb_we_i,   // Write Enable
    input        wb_stb_i,  // Strobe
    output       wb_ack_o,  // Acknowledge
    // Interface
    output reg      irq_req_o,
    input        irq_ack_i
   );

localparam integer CNT_BITS=$clog2(CNT_PRESC);

// Timer counter
reg  [15:0] cnt_r=0;
// Divider value
reg  [15:0] div_r=0;
wire tc; // Terminal count
// Microseconds source
wire ena_cnt;
reg  [CNT_BITS-1:0] pre_cnt_r;

// Microseconds time source
always @(posedge wb_clk_i)
begin : tmr_source
  if (wb_rst_i)
     pre_cnt_r <= 0;
  else
     begin
     pre_cnt_r <= pre_cnt_r+1;
     if (pre_cnt_r==CNT_PRESC-1)
        pre_cnt_r <= 0;
     end
end // tmr_source;
assign ena_cnt=pre_cnt_r==CNT_PRESC-1;

// 16 bits counter
always @(posedge wb_clk_i)
begin : do_count
  if (wb_rst_i || tc || (wb_stb_i && wb_we_i))
     cnt_r <= 0;
  else
     if (ena_cnt)
        cnt_r <= cnt_r+1;
end // do_count
assign tc=cnt_r==div_r-1 && ena_cnt;

// Interrupt logic
always @(posedge wb_clk_i)
begin : do_flag
  if (wb_rst_i)
     irq_req_o <= 0;
  else if (tc && ENA_TMR)
     irq_req_o <= 1;
  else if (irq_ack_i)
     irq_req_o <= 0;
end // do_flag

////////////////////////////////////////////////////////////////////////////
// WISHBONE read
////////////////////////////////////////////////////////////////////////////
assign wb_dat_o=0;
assign wb_ack_o=wb_stb_i;

////////////////////////////////////////////////////////////////////////////
// WISHBONE write
////////////////////////////////////////////////////////////////////////////
always @(posedge wb_clk_i)
begin : do_write_div
  if (wb_rst_i)
     div_r <= 0;
  else if (wb_stb_i && wb_we_i)
     begin
     if (wb_adr_i)
        div_r[15:8] <= wb_dat_i;
     else
        div_r[7:0]  <= wb_dat_i;
     end
end // do_write_div

endmodule // TM16bits

