// Code your testbench here
// or browse Examples
module tb_slice_ctrl_fsm();

    logic clk, rst;
    logic [2:0] cmd;
    logic start;

    logic ce_a, ce_b, ce_c, ce_d, ce_ad, ce_m, ce_p;
    logic [1:0] inmode;
    logic [5:0] opmode;
    logic [1:0] alu_sel;
    logic busy, result_valid;

    slice_ctrl_fsm uut (
        .clk(clk), .rst(rst), .cmd(cmd), .start(start),
        .ce_a(ce_a), .ce_b(ce_b), .ce_c(ce_c), .ce_d(ce_d), .ce_ad(ce_ad),
        .ce_m(ce_m), .ce_p(ce_p),
        .inmode(inmode), .opmode(opmode), .alu_sel(alu_sel),
        .busy(busy), .result_valid(result_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0; cmd = uut.SINGLE;

        // Reset
        @(posedge clk); #1;
        $display("Reset:  busy=%0d result_valid=%0d", busy, result_valid);
        rst = 0;

        // single-shot MACC operation
        start = 1;
        @(posedge clk); #1; start = 0;
        $display("LOAD:   ce_a=%0d busy=%0d", ce_a, busy);

        @(posedge clk); #1;
        $display("MULT:   ce_m=%0d inmode=%0d", ce_m, inmode);

        @(posedge clk); #1;
        $display("ALU_OP: ce_p=%0d opmode=%0d", ce_p, opmode);

        @(posedge clk); #1;
        $display("OUTPUT: result_valid=%0d busy=%0d", result_valid, busy);

        @(posedge clk); #1;
        $display("IDLE:   busy=%0d", busy);

        #20;
        $finish;
    end
endmodule