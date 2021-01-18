`include<gen.sv>
`include<driver.sv>
`include<monitor.sv>
`include<scb.sv>
`include<ref_model.sv>
`include<cfg.sv>

import chnl_pkg::*;
`define RUN_TIME 10

class Env;
    Cfg cfg;
    Gen gen[3];
    Driver driver[3];
    mailbox #(chnl_trans) gen2driver[3],driver2ref[3];
    mailbox #(chnl_trans) ref2scb,mon2scb;
    Mon mon;
    Scb scb;
    Ref_model ref_model;
    virtual Mcdf_if mcdf_if;
    extern function  new(virtual Mcdf_if mcdf_if);
    extern function gen_cfg();
    extern function build();
    extern task run(int i);
    // extern task run_read();
    extern task rst();
endclass


//new all mailbox 
function Env::new(virtual Mcdf_if mcdf_if);
    this.mcdf_if = mcdf_if;
    foreach(gen2driver[index])
    begin
        gen2driver[index]=new();
    end
    foreach(driver2ref[index])
    begin
        driver2ref[index]=new();
    end
    ref2scb=new();
    mon2scb=new();

endfunction


function Env::gen_cfg();
    cfg=new();
    assert(cfg.randomize());
    this.cfg = cfg;
endfunction

//new all class
function Env::build();

    gen[0]=new("gen0",0,gen2driver[0]);
    gen[1]=new("gen1",1,gen2driver[1]);
    gen[2]=new("gen2",2,gen2driver[2]);
    
    driver[0]=new("driver0",0,gen2driver[0],driver2ref[0],mcdf_if);
    driver[1]=new("driver1",1,gen2driver[1],driver2ref[1],mcdf_if);
    driver[2]=new("driver2",2,gen2driver[2],driver2ref[2],mcdf_if);
    mon = new("monitor",mon2scb,mcdf_if);
    scb = new("scoreboard",mon2scb,ref2scb, mcdf_if);
    ref_model=new("reference model",driver2ref,ref2scb,mcdf_if,cfg);
    
endfunction

task Env::run(int i);
    fork
        begin //thread 1 
            for(int r=0;r<`RUN_TIME;r++)
            begin
                cfg.randomize();
                cfg.gen_write(this.mcdf_if);
                $display("@ %t Run time %d starts!",$time, i*10+r);
                fork
                    begin
                        cfg.gen_read(this.mcdf_if);
                        cfg.gen_idle(this.mcdf_if);
                    end
                    begin
                        gen[0].run(cfg.pkt_len[0]);
                        driver[0].run();
                    end
                            
                    begin
                        gen[1].run(cfg.pkt_len[1]);
                        driver[1].run();     
                    end

                    begin
                        gen[2].run(cfg.pkt_len[2]);
                        driver[2].run();     
                    end
                join
                // scb.print_scb();
                $display("@ %t Run time %d done!\n",$time, r+i*10);

            end
        end
        begin forever
            mon.run();
        end
        begin forever
            mon.grant_ctrl(cfg.delay_grant);
        end
        begin forever
            ref_model.run();
        end
        begin forever
            scb.run();
        end

        begin  //thread 2
            #1000000000;
        end
    join_any
    
    
    
    
    repeat(5) begin
        @( mcdf_if.cb);
    end  
endtask

task Env::rst();
    // driver[0].reset();
    // driver[1].reset();
    // driver[2].reset();
    // ref_model.reset();
    // mon = new("monitor",mon2scb,mcdf_if);
    // scb = new("scoreboard",mon2scb,ref2scb, mcdf_if);
    disable fork;
    mcdf_if.rst_n = 0;
    #10;
    @(posedge mcdf_if.cb)
    begin
        mcdf_if.rst_n = 1;
    end
endtask

// task Env::run_read();
//     fork
//         begin //thread 1 
//             mon.grant_ctrl();
//             for(int r=0;r<`RUN_TIME;r++)
//             begin
//                 cfg.randomize();
//                 cfg.gen_read(this.mcdf_if);
//                 $display("*********************run time %d****************************************\n",r);
//                 fork
//                     begin
//                         gen[0].run(cfg.pkt_len[0]);
//                         driver[0].run();
//                     end
                            
//                     begin
//                         gen[1].run(cfg.pkt_len[1]);
//                         driver[1].run();     
//                     end

//                     begin
//                         gen[2].run(cfg.pkt_len[2]);
//                         driver[2].run();     
//                     end
//                 join
//                 scb.print_scb();
//                 $display("run time %d done ",r,$time);
//             end
//         end
//         begin forever
//             mon.run();
//         end

//         begin forever
//             ref_model.run();
//         end
//         begin forever
//             scb.run();
//         end

//         begin  //thread 2
//             #1000000000;
//         end
//     join_any
    
    
    
    
//     repeat(5) begin
//         @( mcdf_if.cb);
//     end  
//     $display("*********************result:******************************\n");
//     scb.print_scb();
// endtask