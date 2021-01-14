
`include<env.sv>
program automatic Test(Mcdt_if mcdt_if);
Env env;
initial begin
    env=new(mcdt_if);
    env.rst();
    env.gen_cfg();
    env.build();
    env.run();
end



endprogram 
