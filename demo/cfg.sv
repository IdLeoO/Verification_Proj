`ifndef CFG_SV
`define CFG_SV

class Cfg;
    rand bit[2:0] port_en;//port enable for each channel
    rand bit [1:0] prior[3];//port priority for each channel
    rand bit [2:0] pkt_len[3];//package length for each chaannel 
    rand bit [6:0] test_mode;
        //test_mode[0] --mcdf_reg_write_read_test
        //test_mode[1] -- mcdf_reg_illegal_access_test
        //test_mode[2] -- mcdf_channel_disable_test
        //test_mode[3] -- mcdf_arbiter_priority_test with same priority
        //test_mode[4] -- mcdf_arbiter_priority_test with different priority
        //test_mode[5] -- mcdf_formatter_length_test
        //test_mode[6] -- mcdf_formatter_grant_test
    
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
        test_mode[3]==1'b1 -> (prior[0] && prior[1] && prior[2] ==1'b1);
        test_mode[4]==1'b1 -> (prior[0] && prior[1] && prior[2] ==1'b0);
    }
    /*
        you can add your constraint
    */
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
 