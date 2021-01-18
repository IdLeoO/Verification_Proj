`ifndef SCB_SV
`define SCB_SV
import chnl_pkg::*;

class Scb;
    string name;
    mailbox #(chnl_trans) m2s_mb;
    mailbox #(chnl_trans) r2s_mb;
    virtual Mcdf_if intf;    
    int success;
    int failure;
    chnl_trans ref_queue[$];
    chnl_trans mon_queue[$];

    extern function new(string name, mailbox #(chnl_trans) mon2scb, mailbox #(chnl_trans) ref2scb, virtual Mcdf_if mcdf_if);
    extern task run();
    extern task enqueue_ref_trans();
    extern task enqueue_mon_trans();
    extern task check_trans();
    extern task print_scb();
endclass

function Scb::new(string name, mailbox #(chnl_trans) mon2scb, mailbox #(chnl_trans) ref2scb, virtual Mcdf_if mcdf_if);
    this.name = name;
    this.m2s_mb = mon2scb;
    this.r2s_mb = ref2scb;
    this.intf = mcdf_if;
    this.success = 0;
    this.failure = 0;
endfunction

task Scb::print_scb();
    $display("*********************Scoreboard****************************************");
    $display("@ %t Success: ", $time, this.success);
    $display("@ %t Failure: ", $time, this.failure);
    $display("*********************Scoreboard****************************************\n");
endtask

task Scb::check_trans();
    @(negedge intf.cb)
    begin
        if(this.mon_queue.size() > 0)
        begin
            chnl_trans t_mon;
            chnl_trans t_ref;            
            // $display("@ %t Scb mon_queue: %d !", $time,this.mon_queue.size() > 0);
            t_mon = this.mon_queue.pop_back();
            t_ref = this.ref_queue.pop_back();

            // $display("@ %t Scb mon_queue: %d !", $time,t_mon == t_ref);
            // $display("@ %t Scb mon_queue: %d !", $time,t_mon.id == t_ref.id);
            // $display("@ %t Scb mon_queue: %d !", $time,t_mon.pkt_len == t_ref.pkt_len);
            // $display("@ %t Scb mon_queue: %d !", $time,t_mon.data == t_ref.data);
            
            // $display("@ %t Scb mon_queue has %d trans!", $time,this.mon_queue.size());
            
            if ((t_mon.id == t_ref.id) && (t_mon.pkt_len == t_ref.pkt_len) && (t_mon.data == t_ref.data) == 1)
            // if (t_mon == t_ref)
            begin
                this.success++;
                $display("@ %t Scoreboard check succeed!", $time);
            end
            else
            begin
                this.failure++;
                $display("@ %t Scoreboard check failed!", $time);
            end
        end
        // $display("@ %t Scb mon_queue: %d !", $time,this.mon_queue.size() > 0);
    end
endtask

task Scb::enqueue_ref_trans();
    @(posedge intf.cb)
    begin
        while (r2s_mb.num() > 0)
        begin
            chnl_trans ref_trans;
            this.r2s_mb.get(ref_trans);
            this.ref_queue.push_back(ref_trans);
        end
    end
endtask

task Scb::enqueue_mon_trans();
    @(posedge intf.cb)
    begin
        while (m2s_mb.num() > 0)
        begin
            chnl_trans mon_trans;
            this.m2s_mb.get(mon_trans);
            this.mon_queue.push_back(mon_trans);
        end
    end
endtask

task Scb::run();
    fork
        begin forever
            enqueue_ref_trans();
        end
        begin forever
            enqueue_mon_trans();
        end
        begin forever
            check_trans();
        end


    join
    

    // $display("@ %t mailbox m2s contains %d transactions", $time, m2s_mb.num());
    

endtask
`endif