
interface Mcdt_if(input bit clk);


  clocking cb @(posedge clk);

    
  endclocking: cb

  modport TB(clocking cb, input rst_n);

endinterface
