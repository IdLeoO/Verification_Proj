`define check1;
`include<param_def.v>
module mcdf_property(
    input logic clk_i,
    input logic rstn_i,

    input logic [1:0]  cmd_i,
    input logic [`ADDR_WIDTH-1:0] cmd_addr_i,
    input logic [`CMD_DATA_WIDTH-1:0] cmd_data_i,
    input logic [`CMD_DATA_WIDTH-1:0] cmd_data_o,

    input logic [31:0] ch0_data_i,
    input logic  ch0_vld_i,
    input logic [31:0] ch1_data_i,
    input logic  ch1_vld_i,
    input logic [31:0] ch2_data_i,
    input logic  ch2_vld_i,
    input logic  ch0_ready_o,
    input logic  ch1_ready_o,
    input logic  ch2_ready_o,

    input logic  fmt_grant_i,
    input logic [1:0] fmt_chid_o,
    input logic fmt_req_o,
    input logic [5:0]  fmt_length_o,
    input logic [31:0] fmt_data_o,
    input logic fmt_start_o,
    input logic fmt_end_o );

    //  Add assertion here
`ifdef check1
property check_formater_req;
@(posedge clk_i) disable iff (!rstn_i) (fmt_req_o==1 && fmt_grant_i==1 |-> ##1 fmt_req_o==0)
endproperty
check_formater_reqP: assert property (check_formater_req) else $error("check_formater_req!");
`endif
endmodule