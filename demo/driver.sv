`ifndef DRIVER_SV
`define DRIVER_SV
`include<gen.sv>
`include<interface.sv>
`include<param_def.v>

class Driver;    
    int idle_cycles;
    int pre_idle_cycles;
    int post_idle_cycles;
    int id;
    string name;
    virtual Mcdf_if intf;
    mailbox #(chnl_trans) g2d_mb;
    mailbox #(chnl_trans) d2r_mb;
    
    extern function new(string name, int id, mailbox #(chnl_trans) gen2driver_mb,mailbox #(chnl_trans) driver2ref_mb,virtual Mcdf_if mcdf_if);
    extern task chnl_idle();
    extern task reset();
    extern function void set_pre_idle_cycles(int n);
    extern function void set_post_idle_cycles(int n);
    extern function void set_idle_cycles(int n);
    extern task chnl0_write(input chnl_trans t);
    extern task chnl1_write(input chnl_trans t);
    extern task chnl2_write(input chnl_trans t);  
    extern task run();     
     
endclass

task Driver::reset();
    if (this.id == 0)
    begin
        this.intf.cb.ch0_vld_i <= 0;
        this.intf.cb.ch0_data_i <= 0;
    end
    else if (this.id == 1)
    begin
        this.intf.cb.ch1_vld_i <= 0;
        this.intf.cb.ch1_data_i <= 0;
    end
    else if (this.id == 2)
    begin
        this.intf.cb.ch2_vld_i <= 0;
        this.intf.cb.ch2_data_i <= 0;
    end
    // $display("@ %t Driver resets", $time);
endtask

function void Driver::set_idle_cycles(int n);
    this.idle_cycles = n;
endfunction

function void Driver::set_pre_idle_cycles(int n);
    this.pre_idle_cycles = n;
endfunction

function void Driver::set_post_idle_cycles(int n);
    this.post_idle_cycles = n;
endfunction

function Driver::new(string name, int id, mailbox #(chnl_trans) gen2driver_mb, mailbox #(chnl_trans) driver2ref_mb, virtual Mcdf_if mcdf_if);
    this.name = name;
    this.id = id;
    this.intf = mcdf_if;
    this.g2d_mb = gen2driver_mb;
    this.d2r_mb = driver2ref_mb;
    this.idle_cycles = 0;
    // $display("@ %t Driver %d is created", $time, this.id);
endfunction

task Driver::chnl0_write(input chnl_trans t);
    // $display("@ %t mailbox send transaction of channel %d to reference model", $time, t.id);
    d2r_mb.put(t);
    foreach(t.data[i]) begin
        @(posedge intf.cb);
        this.intf.cb.ch0_vld_i <= 1;
        this.intf.cb.ch0_data_i <= t.data[i];
        repeat(idle_cycles) chnl_idle();
    end
    // $display("Driver finish writing chnl 0 data to intf");
    //   repeat(idle_cycles) chnl_idle();
endtask

task Driver::chnl1_write(input chnl_trans t);
    // $display("@ %t mailbox send transaction of channel %d to reference model", $time, t.id);
    d2r_mb.put(t);
    foreach(t.data[i]) begin
        @(posedge intf.cb);
        this.intf.cb.ch1_vld_i <= 1;
        this.intf.cb.ch1_data_i <= t.data[i];
        repeat(idle_cycles) chnl_idle();
      end
    //   $display("Driver finish writing chnl 1 data to intf");
      repeat(idle_cycles) chnl_idle();
endtask

task Driver::chnl2_write(input chnl_trans t);
    //$display("Success on getting transactions");
    // $display("@ %t mailbox send transaction of channel %d to reference model", $time, t.id);
    d2r_mb.put(t);
    foreach(t.data[i]) begin
        @(posedge intf.cb);
        this.intf.cb.ch2_vld_i <= 1;
        this.intf.cb.ch2_data_i <= t.data[i];
        repeat(idle_cycles) chnl_idle();
      end
    //   $display("Driver finish writing chnl 2 data to intf");
      repeat(idle_cycles) chnl_idle();
endtask


task Driver::chnl_idle();
    @(posedge intf.cb);
    if (this.id == 0)
    begin
        this.intf.cb.ch0_vld_i <= 0;
        this.intf.cb.ch0_data_i <= 0;
    end
    else if (this.id == 1)
    begin
        this.intf.cb.ch1_vld_i <= 0;
        this.intf.cb.ch1_data_i <= 0;
    end
    else if (this.id == 2)
    begin
        this.intf.cb.ch2_vld_i <= 0;
        this.intf.cb.ch2_data_i <= 0;
    end
    // $display("@ %t Driver %d is idle", $time, this.id);
endtask


task Driver::run();
    chnl_trans gen_trans;
    set_idle_cycles(0);
    set_pre_idle_cycles(0);
    set_post_idle_cycles(200);
    // $display("@ %t mailbox g2d contains %d transactions", $time, g2d_mb.num());
    if ( g2d_mb.num() > 0)
    begin
        g2d_mb.get(gen_trans);
        repeat(pre_idle_cycles) chnl_idle();// Set delay at begining.
        if (gen_trans.id == 0 )
        begin
            // $display("@ %t channel Driver [%s] sent data %p", $time, this.name, gen_trans.data);
            this.chnl0_write(gen_trans);
        end
        else if (gen_trans.id == 1)
        begin
            // $display("@ %t channel Driver [%s] sent data %p", $time, this.name, gen_trans.data);
            this.chnl1_write(gen_trans);
        end
        else if (gen_trans.id == 2)
        begin
            // $display("@ %t channel Driver [%s] sent data %p", $time, this.name, gen_trans.data);               
            this.chnl2_write(gen_trans);
        end
        repeat(post_idle_cycles) chnl_idle();
    end
    else
    begin
        this.chnl_idle();
    end

endtask

`endif