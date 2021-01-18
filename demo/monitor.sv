`include<interface.sv>
import chnl_pkg::*;
`ifndef MONITOR_SV
`define MONITOR_SV


// Monitor receive output of DUT from the interface, transform it into transaction
// and send to scoreboard
class Mon;
    string name;
    virtual Mcdf_if intf;
    mailbox #(chnl_trans) m2s_mb;
    extern function new(string name, mailbox #(chnl_trans) mon2scb, virtual Mcdf_if mcdf_if);
    extern task run();
    extern task grant_ctrl(bit [1:0] delay);
endclass

function Mon::new(string name, mailbox #(chnl_trans) mon2scb, virtual Mcdf_if mcdf_if);
    this.name = name;
    this.m2s_mb = mon2scb;
    this.intf = mcdf_if;
endfunction

task Mon::run();
    @(negedge this.intf.cb);
    begin
        // $display("@ %t monitor checks fmt start of %d", $time, this.intf.fmt_start_o);
        if (this.intf.cb.fmt_start_o)
        begin
            chnl_trans t = new();
            t.id = this.intf.cb.fmt_chid_o;
            t.pkt_len = this.intf.cb.fmt_length_o;
            t.data.push_back(this.intf.cb.fmt_data_o);
            
            for (int i = 0; i <this.intf.cb.fmt_length_o-1; i++)
            begin
                @(posedge intf.cb)
                begin
                    t.data.push_back(this.intf.cb.fmt_data_o);
                end
            end
            // $display("@ %t monitor captures chid %d of length %d with data %p", $time, t.id, t.pkt_len, t.data);
            m2s_mb.put(t);
        end
    end
    
endtask

task Mon::grant_ctrl(bit [1:0] delay);
    @(posedge this.intf.cb.fmt_req_o)
    begin
        // $display("@ %t delay is:  ", $time, delay);
        if(delay == 0)
        begin
            @(posedge intf.cb)  
            begin
                this.intf.cb.fmt_grant_i <= 1;
            end
        end
        else
        begin
            repeat(delay) @(posedge intf.cb);
            this.intf.cb.fmt_grant_i <= 1;
        end
    end

    @(negedge this.intf.cb.fmt_req_o)
    begin
        this.intf.cb.fmt_grant_i <= 0;
    end
endtask

`endif
