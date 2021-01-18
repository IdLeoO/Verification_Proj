`ifndef GEN_SV
`define GEN_SV
import chnl_pkg::*;

class Gen ;
string name;
int num;
int id;
int pkt_len;

mailbox #(chnl_trans) g2d_mb;

extern function new(string name, int id_i, mailbox gen2driver_mb);
extern virtual task run(bit [2:0] pkt_len);

endclass

function Gen::new(string name, int id_i, mailbox gen2driver_mb);
    // this.length = 
    this.name = name;
    this.id = id_i;
    this.num = 0;
    this.g2d_mb = gen2driver_mb;
endfunction
        
task Gen::run(bit [2:0] pkt_len);
    chnl_trans t = new();

    if (pkt_len == 3'b000)
    begin
        this.pkt_len= 4;
    end
    else if (pkt_len == 3'b001)
    begin
        this.pkt_len = 8;
    end
    else if (pkt_len == 3'b010)
    begin
        this.pkt_len = 16;
    end
    else if (pkt_len ==3'b011)
    begin
        this.pkt_len = 32;// change!!!!!!!
    end
    else
    begin
        this.pkt_len = 32;
    end

    t.id = this.id;
    t.pkt_len = this.pkt_len;
    repeat(this.pkt_len) begin
        t.data.push_back('h00C0_0000 + (this.id<<16) + this.num);
        this.num++;
    end
    // $display("@ %t generator [%s] sent data %p to mailbox", $time, this.name, t.data);
    this.g2d_mb.put(t);
endtask

`endif
