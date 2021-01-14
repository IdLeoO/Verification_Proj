

module test_top;
  parameter simulation_cycle = 10;

  bit SystemClock = 0;

  Mcdt_if mcdt_if(SystemClock);

  Test t(mcdt_if);

  mcdt dut(
    /*your code*/
  );

  always begin
    #(simulation_cycle/2) SystemClock = ~SystemClock;
  end


endmodule
