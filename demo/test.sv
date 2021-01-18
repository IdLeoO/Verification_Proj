`include<coverage.sv>
`include<env.sv>
program automatic Test(Mcdf_if mcdf_if);
Env env;
mcdf_coverage cov;
int success;
int failure;
int i;

initial begin
    env=new(mcdf_if);
    cov=new("mcdf_coverage", mcdf_if);
    success = 0;
    failure = 0;
    i=0;
    fork
        begin
            for (i = 0; i<100; i++)
            begin
                env.rst();
                env.gen_cfg();
                env.build();
                env.run(i);
                success = success + env.scb.success;
                failure = failure + env.scb.failure;
            end
        end
        // begin
        //     for (int i = 0; i<5; i++)
        //     begin
        //         env.rst();
        //         env.gen_cfg();
        //         env.build();
        //         env.run_read();
        //     end
        // end
        begin
            cov.run();
        end
    join_any

    $display("**********************************************************");
    $display("*********************Final Scoreboard*********************");
    $display("@ %t Success: %d\n", $time, success);
    $display("@ %t Failure: %d", $time, failure);
    $display("**********************************************************");
    $display("**********************************************************");


    cov.do_report();
end

endprogram 
