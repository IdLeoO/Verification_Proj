`include "param_def.v"
interface Mcdf_if(input bit clk);
  logic rst_n;
  logic [1:0]  cmd_i;
  logic [`ADDR_WIDTH-1:0] cmd_addr_i;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_i;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_o;

  logic [31:0] ch0_data_i;
  logic  ch0_vld_i;
  logic [31:0] ch1_data_i;
  logic  ch1_vld_i;
  logic [31:0] ch2_data_i;
  logic  ch2_vld_i;
  logic  ch0_ready_o;
  logic  ch1_ready_o;
  logic  ch2_ready_o;

  logic  fmt_grant_i;
  logic [1:0] fmt_chid_o;
  logic fmt_req_o;
  logic [5:0]  fmt_length_o;
  logic [31:0] fmt_data_o;
  logic fmt_start_o;
  logic fmt_end_o;


  logic [1:0] slv_prios[3];
  logic slv_reqs[3];
  logic a2s_acks[3];
  logic f2a_id_req;

  logic chnl_en[3];

  clocking cb @(posedge clk);

    default input #1ns output #1ns;

    output cmd_i;                         
    output cmd_addr_i;
    output cmd_data_i;
    input cmd_data_o;

    output  ch0_data_i;
    output  ch0_vld_i;
    output  ch1_data_i;
    output  ch1_vld_i;
    output  ch2_data_i;
    output  ch2_vld_i;
    input  ch0_ready_o;
    input  ch1_ready_o;
    input  ch2_ready_o;

    output  fmt_grant_i;
    input fmt_chid_o;
    input fmt_req_o;
    input fmt_length_o;
    input fmt_data_o;
    input fmt_start_o;
    input fmt_end_o;

    input slv_prios;
    input slv_reqs;
    input a2s_acks;
    input f2a_id_req;
    input chnl_en;

  
    
  endclocking: cb

  modport TB(clocking cb,input rst_n);

endinterface
