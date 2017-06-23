//---------------------------------------------------------------------------------------
// Generated by WISHBONE Builder. Do not edit this file.
//
// For defines see wb_devices.defines
//
// Generated Tue May 30 10:23:57 2017
//
// Wishbone masters:
//   cpu
//
// Wishbone slaves:
//   rs2
//     baseadr 0x00000000 - size 0x40
//   ad
//     baseadr 0x00000040 - size 0x40
//   tmr
//     baseadr 0x00000080 - size 0x40
//   t16
//     baseadr 0x000000C0 - size 0x40
//---------------------------------------------------------------------------------------

module WBDevIntercon
   (
    // WISHBONE master port(s)
    // cpu
    output [7:0] cpu_dat_o,
    output       cpu_ack_o,
    input  [7:0] cpu_dat_i,
    input        cpu_we_i,
    input  [7:0] cpu_adr_i,
    input        cpu_cyc_i,
    input        cpu_stb_i,
    // WISHBONE slave port(s)
    // rs2
    input  [7:0] rs2_dat_i,
    input        rs2_ack_i,
    output [7:0] rs2_dat_o,
    output       rs2_we_o,
    output [0:0] rs2_adr_o,
    output       rs2_stb_o,
    // ad
    input  [7:0] ad_dat_i,
    input        ad_ack_i,
    output [7:0] ad_dat_o,
    output       ad_we_o,
    output [0:0] ad_adr_o,
    output       ad_stb_o,
    // tmr
    input  [7:0] tmr_dat_i,
    input        tmr_ack_i,
    output [7:0] tmr_dat_o,
    output       tmr_we_o,
    output [2:0] tmr_adr_o,
    output       tmr_stb_o,
    // t16
    input  [7:0] t16_dat_i,
    input        t16_ack_i,
    output [7:0] t16_dat_o,
    output       t16_we_o,
    output [0:0] t16_adr_o,
    output       t16_stb_o,
    // Clock and reset
    input        wb_clk_i,
    input        wb_rst_i);

// Slave select
wire rs2_ss;
wire ad_ss;
wire tmr_ss;
wire t16_ss;

wire [7:0] adr;
assign adr=cpu_adr_i;
assign rs2_ss=adr[7:6]==2'b00;
assign ad_ss=adr[7:6]==2'b01;
assign tmr_ss=adr[7:6]==2'b10;
assign t16_ss=adr[7:6]==2'b11;
assign rs2_adr_o=adr[0:0];
assign ad_adr_o=adr[0:0];
assign tmr_adr_o=adr[2:0];
assign t16_adr_o=adr[0:0];

wire stb_m2s;
wire we_m2s;
wire ack_s2m;
wire [7:0] dat_m2s;
wire [7:0] dat_s2m;
// stb Master -> Slave [Selection]
assign stb_m2s=cpu_stb_i;
assign rs2_stb_o=rs2_ss & stb_m2s;
assign ad_stb_o=ad_ss & stb_m2s;
assign tmr_stb_o=tmr_ss & stb_m2s;
assign t16_stb_o=t16_ss & stb_m2s;
// we Master -> Slave
assign we_m2s=cpu_we_i;
assign rs2_we_o=we_m2s;
assign ad_we_o=we_m2s;
assign tmr_we_o=we_m2s;
assign t16_we_o=we_m2s;
// ack Slave -> Master
assign ack_s2m=rs2_ack_i | ad_ack_i | tmr_ack_i | t16_ack_i;
assign cpu_ack_o=ack_s2m;
// dat Master -> Slave
assign dat_m2s=cpu_dat_i;
assign rs2_dat_o=dat_m2s;
assign ad_dat_o=dat_m2s;
assign tmr_dat_o=dat_m2s;
assign t16_dat_o=dat_m2s;
// dat Slave -> Master [and/or]
assign dat_s2m=(rs2_dat_i & {8{rs2_ss}}) | (ad_dat_i & {8{ad_ss}}) | (tmr_dat_i & {8{tmr_ss}}) | (t16_dat_i & {8{t16_ss}});
assign cpu_dat_o=dat_s2m;

endmodule // WBDevIntercon
