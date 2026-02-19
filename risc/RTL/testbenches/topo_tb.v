module topo_tb ();  

    reg clk, rst;
    initial begin
        clk = 0; rst = 1;
        #3 rst = 0;
        #3000;
        $stop;
    end

    always #5 clk = ~clk;

    topo DUT (
        .clk(clk),
        .rst(rst)
    );
endmodule
