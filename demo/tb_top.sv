`include<mcdf_property.sv>

module test_top;
  parameter simulation_cycle = 10;
  bit SystemClock = 0;

  Mcdf_if mcdf_if(SystemClock);

  Test t(mcdf_if);

  mcdf_property assertion(
    .clk_i       (SystemClock        )
    ,.rstn_i      (mcdf_if.rst_n               )
    ,.cmd_i       (mcdf_if.cmd_i         ) 
    ,.cmd_addr_i  (mcdf_if.cmd_addr_i    ) 
    ,.cmd_data_i  (mcdf_if.cmd_data_i)  
    ,.cmd_data_o  (mcdf_if.cmd_data_o)  
    ,.ch0_data_i  (mcdf_if.ch0_data_i  )
    ,.ch0_vld_i   (mcdf_if.ch0_vld_i )
    ,.ch0_ready_o (mcdf_if.ch0_ready_o )
    ,.ch1_data_i  (mcdf_if.ch1_data_i   )
    ,.ch1_vld_i   (mcdf_if.ch1_vld_i  )
    ,.ch1_ready_o (mcdf_if.ch1_ready_o  )
    ,.ch2_data_i  (mcdf_if.ch2_data_i   )
    ,.ch2_vld_i   (mcdf_if.ch2_vld_i  )
    ,.ch2_ready_o (mcdf_if.ch2_ready_o  )
    ,.fmt_grant_i (mcdf_if.fmt_grant_i   ) 
    ,.fmt_chid_o  (mcdf_if.fmt_chid_o    ) 
    ,.fmt_req_o   (mcdf_if.fmt_req_o     ) 
    ,.fmt_length_o(mcdf_if.fmt_length_o  )    
    ,.fmt_data_o  (mcdf_if.fmt_data_o    )  
    ,.fmt_start_o (mcdf_if.fmt_start_o   )  
    ,.fmt_end_o   (mcdf_if.fmt_end_o     )  
  );

  mcdf dut(
     .clk_i       (SystemClock        )
    ,.rstn_i      (mcdf_if.rst_n               )
    ,.cmd_i       (mcdf_if.cmd_i         ) 
    ,.cmd_addr_i  (mcdf_if.cmd_addr_i    ) 
    ,.cmd_data_i  (mcdf_if.cmd_data_i)  
    ,.cmd_data_o  (mcdf_if.cmd_data_o)  
    ,.ch0_data_i  (mcdf_if.ch0_data_i  )
    ,.ch0_vld_i   (mcdf_if.ch0_vld_i )
    ,.ch0_ready_o (mcdf_if.ch0_ready_o )
    ,.ch1_data_i  (mcdf_if.ch1_data_i   )
    ,.ch1_vld_i   (mcdf_if.ch1_vld_i  )
    ,.ch1_ready_o (mcdf_if.ch1_ready_o  )
    ,.ch2_data_i  (mcdf_if.ch2_data_i   )
    ,.ch2_vld_i   (mcdf_if.ch2_vld_i  )
    ,.ch2_ready_o (mcdf_if.ch2_ready_o  )
    ,.fmt_grant_i (mcdf_if.fmt_grant_i   ) 
    ,.fmt_chid_o  (mcdf_if.fmt_chid_o    ) 
    ,.fmt_req_o   (mcdf_if.fmt_req_o     ) 
    ,.fmt_length_o(mcdf_if.fmt_length_o  )    
    ,.fmt_data_o  (mcdf_if.fmt_data_o    )  
    ,.fmt_start_o (mcdf_if.fmt_start_o   )  
    ,.fmt_end_o   (mcdf_if.fmt_end_o     )  
  );

  assign mcdf_if.chnl_en[0] = test_top.dut.ctrl_regs_inst.slv0_en_o;
  assign mcdf_if.chnl_en[1] = test_top.dut.ctrl_regs_inst.slv1_en_o;
  assign mcdf_if.chnl_en[2] = test_top.dut.ctrl_regs_inst.slv2_en_o;

  // arbiter interface monitoring arbiter ports
  assign mcdf_if.slv_prios[0] = test_top.dut.arbiter_inst.slv0_prio_i;
  assign mcdf_if.slv_prios[1] = test_top.dut.arbiter_inst.slv1_prio_i;
  assign mcdf_if.slv_prios[2] = test_top.dut.arbiter_inst.slv2_prio_i;
  assign mcdf_if.slv_reqs[0] = test_top.dut.arbiter_inst.slv0_req_i;
  assign mcdf_if.slv_reqs[1] = test_top.dut.arbiter_inst.slv1_req_i;
  assign mcdf_if.slv_reqs[2] = test_top.dut.arbiter_inst.slv2_req_i;
  assign mcdf_if.a2s_acks[0] = test_top.dut.arbiter_inst.a2s0_ack_o;
  assign mcdf_if.a2s_acks[1] = test_top.dut.arbiter_inst.a2s1_ack_o;
  assign mcdf_if.a2s_acks[2] = test_top.dut.arbiter_inst.a2s2_ack_o;
  assign mcdf_if.f2a_id_req = test_top.dut.arbiter_inst.f2a_id_req_i;

  always begin
    #(simulation_cycle/2) SystemClock = ~SystemClock;
  end


endmodule
