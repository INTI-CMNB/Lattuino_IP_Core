/***********************************************************************

  WISHBONE miscellaneous timer

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements the micro and milliseconds timers. Also a CPU blocker,
  used for small time delays.
  This module also implements the 6 PWMs.
  Lower 32 bits is a 32 bits microseconds counter
  Upper 32 bits is a milliseconds counter

  Port    Read    Write
    0    µs B0    PWM0
    1    µs B1    PWM1
    2    µs B2    PWM2
    3    µs B3    PWM3
    4    ms B0    PWM4
    5    ms B1    PWM5
    6    ms B2    PWM Pin Enable
    7    ms B3    Block CPU µs

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador en inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2017 Salvador E. Tropea <salvador en inti.gob.ar>
 Copyright (c) 2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      TMCounter(RTL) (Entity and architecture)
 File name:        tmcounter.v
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


module TMCounter
  #(
    parameter CNT_PRESC=24,
    parameter ENA_TMR=1
   )
   (
    // WISHBONE signals
    input        wb_clk_i, // Clock
    input        wb_rst_i, // Reset input
    input  [2:0] wb_adr_i, // Adress bus
    output [7:0] wb_dat_o, // DataOut Bus
    input  [7:0] wb_dat_i, // DataIn Bus
    input        wb_we_i,  // Write Enable
    input        wb_stb_i, // Strobe
    output       wb_ack_o, // Acknowledge
    output [5:0] pwm_o,    // 6 PWMs
    output [5:0] pwm_e_o   // Pin enable for the PWMs
   );

localparam integer CNT_BITS=$clog2(CNT_PRESC);

// Microseconds counter
reg  [31:0] cnt_us_r=0;
// Microseconds counter for the ms counter
reg  [9:0]  cnt_us2_r=0;
wire tc_cnt_us2;
// Milliseconds counter
reg  [31:0] cnt_ms_r=0;
// Latched value
reg  [31:0] latched_r=0;
// Prescaler for the Microseconds counters
wire ena_cnt;
reg  [CNT_BITS-1:0] pre_cnt_r;
// Microseconds blocker counter
reg  [7:0] cnt_blk_r=0;
// Prescaler for the Microseconds blocker counter
wire ena_blk_cnt;
reg  [CNT_BITS-1:0] pre_bk_r;
// Blocker FSM
localparam IDLE=0, DELAY=1; // state_t
reg  state;
// Blocker WE
wire blk_we;
// PWM values
reg  [7:0] pwm_val_r[0:5];
// PWM counter
wire [7:0] pwm_count;
// Auxiliar for config
reg  [7:0] wb_dat; // DataOut Bus
// Pin enable for the PWMs
reg  [5:0] pwm_e_r;

////////////////////////////////////////////////////////////////////////////
// 32 bits Microseconds counter
////////////////////////////////////////////////////////////////////////////
// Microseconds time source for the counters
always @(posedge wb_clk_i)
begin : tmr_prescaler
  if (wb_rst_i)
     pre_cnt_r <= 0;
  else
     begin
     pre_cnt_r <= pre_cnt_r+1;
     if (pre_cnt_r==CNT_PRESC-1)
        pre_cnt_r <= 0;
     end
end //tmr_prescaler
assign ena_cnt=pre_cnt_r==CNT_PRESC-1;

// Microseconds counter, 32 bits
always @(posedge wb_clk_i)
begin : do_cnt_us
  if (wb_rst_i)
     cnt_us_r <= 0;
  else if (ena_cnt)
     cnt_us_r <= cnt_us_r+1;
end // do_cnt_us

////////////////////////////////////////////////////////////////////////////
// 32 bits Milliseconds counter
////////////////////////////////////////////////////////////////////////////
// Microseconds counter, 10 bits (0 to 999)
always @(posedge wb_clk_i)
begin : do_cnt_us2
  if (wb_rst_i || tc_cnt_us2)
     cnt_us2_r <= 0;
  else if (ena_cnt)
     cnt_us2_r <= cnt_us2_r+1;
end // do_cnt_us2
assign tc_cnt_us2=cnt_us2_r==999 && ena_cnt;

// Milliseconds counter, 32 bits
always @(posedge wb_clk_i)
begin : do_cnt_ms
  if (wb_rst_i)
     cnt_ms_r <= 0;
  else if (tc_cnt_us2)
     cnt_ms_r <= cnt_ms_r+1;
end // do_cnt_ms

////////////////////////////////////////////////////////////////////////////
// WISHBONE read
////////////////////////////////////////////////////////////////////////////
// Latched value
always @(posedge wb_clk_i)
begin : do_cnt_usr
  if (wb_rst_i)
     latched_r <= 0;
  else if (wb_stb_i)
     begin
     if (wb_adr_i==3'b0)
        latched_r <= cnt_us_r;
     else if (wb_adr_i==3'b100)
        latched_r <= cnt_ms_r;
     end
end // do_cnt_usr

always @(wb_adr_i or cnt_us_r or latched_r or cnt_ms_r)
begin
  case (wb_adr_i)
    3'b000:  wb_dat= cnt_us_r[ 7: 0];
    3'b001:  wb_dat=latched_r[15: 8];
    3'b010:  wb_dat=latched_r[23:16];
    3'b011:  wb_dat=latched_r[31:24];
    3'b100:  wb_dat= cnt_ms_r[ 7: 0];
    3'b101:  wb_dat=latched_r[15: 8];
    3'b110:  wb_dat=latched_r[23:16];
    3'b111:  wb_dat=latched_r[31:24];
    default: wb_dat=0;
  endcase
end
assign wb_dat_o=ENA_TMR ? wb_dat : 0;

assign blk_we=wb_stb_i && wb_we_i && wb_adr_i==3'b111 && ENA_TMR;

// ACK all reads and writes when the counter is 0
assign wb_ack_o=wb_stb_i && (!blk_we || (state==DELAY && cnt_blk_r==0));

////////////////////////////////////////////////////////////////////////////
// Microseconds CPU blocker
////////////////////////////////////////////////////////////////////////////
// Blocker FSM (idle and delay)
always @(posedge wb_clk_i)
begin : do_fsm
  if (wb_rst_i)
     state <= IDLE;
  else
     if (state==IDLE)
        begin
        if (blk_we)
           state <= DELAY;
        end
     else // state==DELAY
        begin
        if (!cnt_blk_r)
           state <= IDLE;
        end
end // do_fsm

// Blocker counter (down counter)
always @(posedge wb_clk_i)
begin : do_bk_cnt
  if (wb_rst_i)
     cnt_blk_r <= 0;
  else if (state==IDLE && blk_we)
     cnt_blk_r <= wb_dat_i;
  else if (ena_blk_cnt)
     cnt_blk_r <= cnt_blk_r-1;
end // do_bk_cnt

// Microseconds time source for the Blocker counter
always @(posedge wb_clk_i)
begin : tmr_prescaler_bk
  if (wb_rst_i || (state==IDLE && blk_we))
     pre_bk_r <= CNT_PRESC-1;
  else
     begin
     pre_bk_r <= pre_bk_r-1;
     if (!pre_bk_r)
        pre_bk_r <= CNT_PRESC-1;
     end
end // tmr_prescaler_bk
assign ena_blk_cnt=pre_bk_r==0;

////////////////////////////////////////////////////////////////////////////
// 6 PWMs (8 bits, 250 kHz clock, 976.56 Hz carrier)
////////////////////////////////////////////////////////////////////////////
// PWM value write
always @(posedge wb_clk_i)
begin : do_pwm_val_write
  if (!wb_rst_i && wb_stb_i && wb_we_i &&
      wb_adr_i!=3'b111 && wb_adr_i!=3'b110)
     pwm_val_r[wb_adr_i] <= wb_dat_i;
end // do_pwm_val_write

// 8 bits counter (1 MHz/4)
assign pwm_count=cnt_us_r[9:2];

// PWM outputs (comparators)
genvar i;
generate  
for (i=0; i<=5; i=i+1)
  begin: do_pwm_outs
  assign pwm_o[i]=pwm_count<=pwm_val_r[i];
  end  
endgenerate

// PWM Pin Enable (1 the pin should use the PWM output)
always @(posedge wb_clk_i)
begin : do_pwm_ena_write
  if (wb_rst_i)
     pwm_e_r <= 0;
  else
     if (wb_stb_i && wb_we_i && wb_adr_i==3'b110)
        pwm_e_r <= wb_dat_i[5:0];
end // do_pwm_ena_write
assign pwm_e_o=pwm_e_r;

endmodule // TMCounter

