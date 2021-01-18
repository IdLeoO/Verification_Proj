`ifndef PACKAGE_SV
`define PACKAGE_SV
`include<param_def.v>
package chnl_pkg;

// The transaction contains a queue of data 

class chnl_trans;
    // FIFO transaction
    logic [31:0] data[$];  // Data queue that contains input queue
    logic [1:0] id;    // Channel id
    int pkt_len;

    


endclass: chnl_trans

endpackage
`endif
 