`ifndef CFG_SV
`define CFG_SV
`include<interface.sv>

class Cfg;
    rand bit[2:0] port_en;//port enable for each channel
    rand bit [1:0] prior[3];//port priority for each channel
    rand bit [2:0] pkt_len[3];//package length for each chaannel 
    rand bit [6:0] test_mode;
    rand bit [1:0] delay_grant;
        //test_mode[0] -- mcdf_reg_write_read_test
        //test_mode[1] -- mcdf_reg_illegal_access_test
        //test_mode[2] -- mcdf_channel_disable_test
        //test_mode[3] -- mcdf_arbiter_priority_test with same priority
        //test_mode[4] -- mcdf_arbiter_priority_test with different priority
        //test_mode[5] -- mcdf_formatter_length_test
        //test_mode[6] -- mcdf_formatter_grant_test
    
    constraint numbers {
        port_en dist {[3'b000: 3'b111]:/1};
        prior[0] dist {[2'b00: 2'b11]:/1};
        prior[1] dist {[2'b00: 2'b11]:/1};
        prior[2] dist {[2'b00: 2'b11]:/1};
        pkt_len[0] dist {[3'b000: 3'b111]:/1};
        pkt_len[1] dist {[3'b000: 3'b111]:/1};
        pkt_len[2] dist {[3'b000: 3'b111]:/1};
        delay_grant dist {[2'b00: 2'b11]:/1};
    }

    constraint basic_c{
        $countones(test_mode)==1;//only one test mode enabled at one time (not necessary)
    }

    constraint channel_disable_c{
        solve test_mode before port_en;
        test_mode[2]==1'b1 -> port_en==3'b0; //when channel_disable_test mode ,all port disabled
    }

    constraint arbiter_priority_test_c{
        solve test_mode before prior[0];
        solve test_mode before prior[1];
        solve test_mode before prior[2];
        test_mode[3]==1'b1 -> ((prior[0]== 2'b01) && (prior[1]== 2'b01) && (prior[2] == 2'b01)) == 1;
        test_mode[4]==1'b1 -> (prior[0] && prior[1] && prior[2] ==2'b00);
    }
    /*
        you can add your constraint
    */
    // constraint try{
    //     test_mode[1]==1'b1;
    // }

    task gen_write(virtual Mcdf_if intf);
        // $display("Begining of cfg generation");
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=8'hC;
            intf.cb.cmd_i <=`WRITE;
            intf.cb.cmd_data_i <={1, this.pkt_len[0], this.prior[0],this.port_en[0]};
            // $display("Command data for chnl 0 is len: %d, prior: %d,enable: %d",this.pkt_len[0],this.prior[0],this.port_en[0]);
        end

        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV0_RW_ADDR;
            intf.cb.cmd_i <=`WRITE;
            intf.cb.cmd_data_i <={32'hffff_ffff};
            // $display("Command data for chnl 0 is len: %d, prior: %d,enable: %d",this.pkt_len[0],this.prior[0],this.port_en[0]);
        end

        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV0_R_ADDR;
            intf.cb.cmd_i <=`WRITE;
            intf.cb.cmd_data_i <={32'hffff_ffff};
            // $display("Command data for chnl 0 is len: %d, prior: %d,enable: %d",this.pkt_len[0],this.prior[0],this.port_en[0]);
        end

        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV0_RW_ADDR;
            intf.cb.cmd_i <=`WRITE;
            intf.cb.cmd_data_i <={this.pkt_len[0], this.prior[0],this.port_en[0]};
            // $display("Command data for chnl 0 is len: %d, prior: %d,enable: %d",this.pkt_len[0],this.prior[0],this.port_en[0]);
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV1_RW_ADDR;
            intf.cb.cmd_i <=`WRITE;
            intf.cmd_data_i<={this.pkt_len[1], this.prior[1],this.port_en[1]};
            // $display("Command data for chnl 1 is len: %d, prior: %d,enable: %d",this.pkt_len[1],this.prior[1],this.port_en[1]);
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i<=`SLV2_RW_ADDR;
            intf.cb.cmd_i<=`WRITE;
            intf.cb.cmd_data_i<={this.pkt_len[2], this.prior[2],this.port_en[2]};
            // $display("Command data for chnl 2 is len: %d, prior: %d,enable: %d",this.pkt_len[2],this.prior[2],this.port_en[2]);
        end
        // $display("End of cfg generation");
    endtask

    
    task gen_read(virtual Mcdf_if intf);
        // $display("Begining of cfg generation");
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=8'hC;
            intf.cb.cmd_i <=`READ;
            intf.cb.cmd_data_i <={32'hffff_ffff};
            // $display("Command data for chnl 0 is len: %d, prior: %d,enable: %d",this.pkt_len[0],this.prior[0],this.port_en[0]);
        end

        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV0_R_ADDR;
            intf.cb.cmd_i <=`READ;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV1_R_ADDR;
            intf.cb.cmd_i <=`READ;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i<=`SLV2_R_ADDR;
            intf.cb.cmd_i<=`READ;
        end

        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV0_RW_ADDR;
            intf.cb.cmd_i <=`READ;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i <=`SLV1_RW_ADDR;
            intf.cb.cmd_i <=`READ;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_addr_i<=`SLV2_RW_ADDR;
            intf.cb.cmd_i<=`READ;
        end
        // $display("End of cfg generation");
    endtask

    task gen_idle(virtual Mcdf_if intf);
        // $display("Begining of cfg generation");
        @(posedge intf.cb);
        begin
            intf.cb.cmd_i <=`IDLE;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_i <=`IDLE;
        end
        
        @(posedge intf.cb);
        begin
            intf.cb.cmd_i<=`IDLE;
        end
        // $display("End of cfg generation");
    endtask

endclass

/*
    class driver;
        ...
        extern function new(..., Cfg cfg);
        extern task run();
    endclass

    task Driver::run();
        ...
        //config channel 1 register
        mcdf_if.cmd_addr=8'b0;
        mcdf_if.cmd=write;
        mcdf_if.cmd_data_in={cfg.pkt_len[0],cfg.prior[0],cfg.port_en[0]};
        //
        ...
        if(cfg.test_mode[1])//mcdf_reg_illegal_access_test
            task_reg_illegal_access_test();
        else if(cfg.test_mode[6])//mcdf_formatter_grant_test
            task_mcdf_formatter_grant_test();

    endtask

*/
`endif
 