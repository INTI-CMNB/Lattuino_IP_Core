/***********************************************************************

  Single Port RAM that maps to a Xilinx/Lattice BRAM

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  This is a program memory for the AVR. It maps to a Xilinx/Lattice
  BRAM.
  This version can be modified by the CPU (i. e. SPM instruction)

  To Do:
  -

  Author:
    - Salvador E. Tropea, salvador inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2008-2017 Salvador E. Tropea <salvador inti.gob.ar>
 Copyright (c) 2008-2017 Instituto Nacional de Tecnología Industrial

 Distributed under the BSD license

------------------------------------------------------------------------------

 Design unit:      SinglePortPM(Xilinx) (Entity and architecture)
 File name:        pm_s_rw.in.v (template used)
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          work
 Dependencies:     IEEE.std_logic_1164
 Target FPGA:      Spartan 3 (XC3S1500-4-FG456)
                   iCE40 (iCE40HX4K)
 Language:         Verilog
 Wishbone:         No
 Synthesis tools:  Xilinx Release 9.2.03i - xst J.39
                   iCEcube2.2016.02
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

***********************************************************************/

module lattuino_1_blPM_8
  #(
    parameter WORD_SIZE=16,// Word Size
    parameter FALL_EDGE=0, // Ram clock falling edge
    parameter ADDR_W=13    // Address Width
   )
   (
    input  clk_i,
    input  [ADDR_W-1:0] addr_i,
    output [WORD_SIZE-1:0] data_o, 
    input  we_i,
    input  [WORD_SIZE-1:0] data_i
   );

localparam ROM_SIZE=2**ADDR_W;
reg [ADDR_W-1:0]    addr_r;
reg [WORD_SIZE-1:0] rom[0:ROM_SIZE-1];

initial begin
$readmemh("../../Work/lattuino_1_bl_8_v.dat",rom,3768);
end

generate
if (!FALL_EDGE)
   begin : use_rising_edge
   always @(posedge clk_i)
   begin : do_rom
     addr_r <= addr_i;
     if (we_i)
        rom[addr_i] <= data_i;
   end // do_rom
   end // use_rising_edge
else
   begin : use_falling_edge
   always @(negedge clk_i)
   begin : do_rom
     addr_r <= addr_i;
     if (we_i)
        rom[addr_i] <= data_i;
   end // do_rom
   end // use_falling_edge
endgenerate

assign data_o=rom[addr_r];

endmodule // lattuino_1_blPM_8

