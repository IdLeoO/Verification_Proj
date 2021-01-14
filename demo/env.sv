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
    mailbox #(Transaction) gen2driver[3],driver2ref[3];
    mailbox #(Transaction_scb) ref2scb,mon2scb;
    Mon mon;
    Scb scb;
    Ref_model ref_model;
    virtual Mcdt_if mcdt_if;
    extern function  new(virtual Mcdt_if mcdt_if);
    extern function gen_cfg();
    extern function build();
    extern task run();
    extern task rst();
endclass



//new all mailbox 
function Env::new(virtual Mcdt_if mcdt_if);
    this.mcdt_if = mcdt_if;
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
    assert(cfg.randomize);
endfunction

//new all class
function Env::build();

    gen[0]=new("gen0",0,gen2driver[0]);
    gen[1]=new("gen1",1,gen2driver[1]);
    gen[2]=new("gen2",2,gen2driver[2]);
    
    driver[0]=new("driver0",0,gen2driver[0],driver2ref[0],mcdt_if,cfg.port_en[0]);
    driver[1]=new("driver1",1,gen2driver[1],driver2ref[1],mcdt_if,cfg.port_en[1]);
    driver[2]=new("driver2",2,gen2driver[2],driver2ref[2],mcdt_if,cfg.port_en[2]);
    mon = new("monitor",mon2scb,mcdt_if);
    scb = new("scoreboard",mon2scb,ref2scb);
    ref_model=new("reference model",driver2ref,ref2scb,mcdt_if,cfg);
    
endfunction

task Env::run();
    fork
        begin //thread 1 
            for(int r=0;r<`RUN_TIME;r++)
            begin
                $display("*********************run time %d****************************************\n",r);
                
                fork
                    begin
                        gen[0].run();
                        driver[0].run();
                    end
                            
                    begin
                        gen[1].run();
                        driver[1].run();     
                    end

                    begin
                        gen[2].run();
                        driver[2].run();     
                    end
                    begin
                        ref_model.run();
                    end
                   

                    begin 
                        mon.run();
                    end

                    begin
                        scb.run();
                    end
                join
                $display("run time %d done ",r,$time);

            end
        end


        begin  //thread 2
            #1000000000;
        end
    join_any
    
    
    
    
    repeat(5) begin
        @( mcdt_if.cb);
    end  
    $display("*********************result:******************************\n");
    $display("pass_count=   %d ,error_count     =%d \n",scb.pass,scb.error);
endtask

task Env::rst();
    /*
    //your code
    */
    
endtask