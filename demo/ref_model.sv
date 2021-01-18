`ifndef REF_MODEL_SV
`define REF_MODEL_SV
`include<cfg.sv>
import chnl_pkg::*;


typedef struct {
    bit [1:0] prio_nd;
    int id;
} prior_node;

class Ref_model;    
    string name;
    mailbox #(chnl_trans) d2r_mb[3];
    mailbox #(chnl_trans) r2s_mb;
    virtual Mcdf_if intf;
    chnl_trans ref_queue_0[$];
    chnl_trans ref_queue_1[$];
    chnl_trans ref_queue_2[$];
    chnl_trans ref_store[$];
    int prior_queue[$];
    Cfg cfg;

    
    extern function new(string name, mailbox #(chnl_trans) driver2ref[3], mailbox #(chnl_trans) ref2scb, virtual Mcdf_if mcdf_if,Cfg cfg);
    extern task run();
    extern function void sort_priority();
    extern task send_trans(chnl_trans ref_trans);
    extern task ordering_trans();
    extern task enqueue_trans();
    extern task instant_ordering();
    extern task reset();

endclass

task Ref_model::instant_ordering();
    int r = 0;
    int tmp;
    // $display("%p at first", this.prior_queue);
    while (intf.cb.slv_reqs[this.prior_queue[0]] == 0)
    begin
        if (r == 3)
        begin
            break;
        end
        tmp = this.prior_queue.pop_front();
        this.prior_queue.push_back(tmp);
        r = r+1;
    end
    // $display("%p at last", this.prior_queue);
endtask

task Ref_model::reset();
    while (d2r_mb[0].num()>0)
    begin
        chnl_trans t;
        d2r_mb[0].get(t);
    end
    while (d2r_mb[1].num()>0)
    begin
        chnl_trans t;
        d2r_mb[1].get(t);
    end
    while (d2r_mb[2].num()>0)
    begin
        chnl_trans t;
        d2r_mb[2].get(t);
    end
    while (r2s_mb.num()>0)
    begin
        chnl_trans t;
        r2s_mb.get(t);
    end
    while (ref_queue_0.size() > 0)
    begin
        ref_queue_0.delete(0);
    end
    while (ref_queue_1.size() > 0)
    begin
        ref_queue_1.delete(0);
    end
    while (ref_queue_2.size() > 0)
    begin
        ref_queue_2.delete(0);
    end
    while (prior_queue.size() > 0)
    begin
        prior_queue.delete(0);
    end
endtask

function Ref_model::new(string name, mailbox #(chnl_trans) driver2ref[3], mailbox #(chnl_trans) ref2scb, virtual Mcdf_if mcdf_if, Cfg cfg);
    this.name = name;
    this.d2r_mb = driver2ref;
    this.r2s_mb = ref2scb;
    this.intf = mcdf_if;
    this.cfg = cfg;
endfunction

task Ref_model::enqueue_trans();
    @(posedge intf.cb)
    begin
        // Modify this part to let enqueue happen 
        fork
            begin
                if (cfg.port_en[0] == 1)
                begin
                    while (d2r_mb[0].num() > 0)
                    begin
                        chnl_trans dri_trans;
                        d2r_mb[0].get(dri_trans);
                        ref_queue_0.push_back(dri_trans);
                        // $display("%p", ref_queue_0[0].data);
                    end
                end
            end

            begin
                if (cfg.port_en[1] == 1)
                begin
                    while (d2r_mb[1].num() > 0)
                    begin
                        chnl_trans dri_trans;
                        d2r_mb[1].get(dri_trans);
                        ref_queue_1.push_back(dri_trans);
                    end
                end
            end
            begin
                if (cfg.port_en[2] == 1)
                begin
                    while (d2r_mb[2].num() > 0)
                    begin
                        chnl_trans dri_trans;
                        d2r_mb[2].get(dri_trans);
                        ref_queue_2.push_back(dri_trans);
                    end
                end
            end
        join
    end
endtask


task Ref_model::ordering_trans();
    // Based on priority and id
    @(negedge intf.f2a_id_req)
    begin
        sort_priority();
        // $display("@ %t ref model start to send to scb", $time);
        instant_ordering();
        // $display("@ %t %d %d %d", $time, ref_queue_0.size(), ref_queue_1.size(), ref_queue_2.size());

        if (intf.cb.slv_reqs[this.prior_queue[0]] == 1)
        begin
            if (this.prior_queue[0] == 0)
            begin
                while (ref_queue_0.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_0.pop_back();
                    send_trans(t);
                    return;
                end
            end
            else if (this.prior_queue[0] == 1 )
            begin
                while (ref_queue_1.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_1.pop_back();
                    send_trans(t);
                    return;
                end
            end
            else if (this.prior_queue[0] == 2 )
            begin
                // $display("%p", ref_queue_2[0]);
                while (ref_queue_2.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_2.pop_back();
                    send_trans(t);
                    return;
                end
            end
        end
        
        if (intf.cb.slv_reqs[this.prior_queue[1]] == 1)
        begin
            if (this.prior_queue[1] == 0 )
            begin
                while (ref_queue_0.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_0.pop_back();
                    send_trans(t);
                    return;
                end
            end
            if (this.prior_queue[1] == 1 )
            begin
                while (ref_queue_1.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_1.pop_back();
                    send_trans(t);
                    return;
                end
            end
            if (this.prior_queue[1] == 2 )
            begin
                while (ref_queue_2.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_2.pop_back();
                    send_trans(t);
                    return;
                end
            end
        end

        if (intf.cb.slv_reqs[this.prior_queue[2]] == 1)
        begin
            if (this.prior_queue[2] == 0 )
            begin
                while (ref_queue_0.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_0.pop_back();
                    send_trans(t);
                    return;
                end
            end
            if (this.prior_queue[2] == 1 )
            begin
                while (ref_queue_1.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_1.pop_back();
                    send_trans(t);
                    return;
                end
            end
            if (this.prior_queue[2] == 2 )
            begin
                while (ref_queue_2.size() > 0)
                begin
                    chnl_trans t;
                    t = ref_queue_2.pop_back();
                    send_trans(t);
                    return;
                end
            end
            // $display("@ %t Reach default channel", $time);
        end
    end
endtask

task Ref_model::send_trans(chnl_trans ref_trans);
    r2s_mb.put(ref_trans);
    // $display("@ %t Reference model send %p of channel %d to scoreboard", $time, ref_trans.data, ref_trans.id);
    while (this.prior_queue.size() > 0)
    begin
        this.prior_queue.delete(0);
    end
endtask


// Determine the priority queue, the most important placed in 0 with id a, second in 1 with id b...
function void Ref_model::sort_priority();
    prior_node chnl0;
    prior_node chnl1;
    prior_node chnl2;
    bit [1:0] prior_tmp[3] = cfg.prior;

    prior_node nd_queue[$];

    // $display("%p", this.cfg.prior);

    chnl0.id = 0;
    chnl0.prio_nd = this.cfg.prior[0];
    nd_queue.push_back(chnl0);

    chnl1.id = 1;
    chnl1.prio_nd = this.cfg.prior[1];
    nd_queue.push_back(chnl1);

    chnl2.id = 2;
    chnl2.prio_nd = this.cfg.prior[2];
    nd_queue.push_back(chnl2);

    
    prior_tmp.sort();
    
    // $display("%p", prior_tmp);
    // $display("%p", nd_queue);

    for (int i = 0; i < 3; i++)
    begin
        for (int j = 0; j <3; j++)
        begin
            if (prior_tmp[i] == nd_queue[j].prio_nd)
            begin
                // $display("%d %d, %d %d", i, prior_tmp[i],j, nd_queue[j].prio_nd);
                this.prior_queue.push_back(nd_queue[j].id);
                nd_queue.delete(j);
                break;
            end
        end
    end
endfunction

task Ref_model::run();
    // Sort the transactions based on the channel id
    // $display("%p", this.prior_queue);
    // Seperate mailbox item into queue according to channel id
    fork
        // thread 1 enqueue the transactions from d2r_mb
        begin forever
            enqueue_trans();
        end

        // thread 2 generate result
        begin forever
            ordering_trans();
        end
    join
    
    // $display("%p", ref_queue_0);
    // $display("%p", ref_queue_1);
    // $display("%p", ref_queue_2);

    
    
endtask



`endif


