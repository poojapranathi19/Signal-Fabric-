module tb_slice_top();

    reg clk;
    reg rst;
    reg [2:0] cmd;
    reg start;
    reg signed [24:0] data_a;
    reg signed [18:0] data_b;
    reg signed [47:0] data_c;
    reg signed [24:0] data_d;

    wire signed [47:0] data_p;
    wire busy;
    wire result_valid;

    localparam CMD_SINGLE = 3'b000;
    localparam CMD_CHAIN  = 3'b101;

    dsp_slice_top uut (
        .clk(clk),
        .rst(rst),
        .cmd(cmd),
        .start(start),
        .data_a(data_a),
        .data_b(data_b),
        .data_c(data_c),
        .data_d(data_d),
        .data_p(data_p),
        .busy(busy),
        .result_valid(result_valid)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rst = 1;
        cmd = CMD_SINGLE;
        start = 0;
        data_a = 0; data_b = 0; data_c = 0; data_d = 0;
        #20;
        rst = 0;
        #10;

        
        // Section 8.1 single-MACC scenario: P = 0 + A*B (via pre-adder
        // bypassed to A+D, since inmode is hardcoded to "add" in the
        // FSM). Use D=0 so the pre-adder just passes A through:
        //   ad_reg = A + D = 3 + 0 = 3
        //   m_reg  = ad_reg * B = 3 * 5 = 15
        //   p_reg  = 0 (old) + m_reg + 0 = 15   (opmode_r1=000001 -> Z=0)
        
        data_a = 25'sd3;
        data_d = 25'sd0;
        data_b = 18'sd5;
        cmd = CMD_SINGLE;
        start = 1;
        #10;
        start = 0;

        // Wait for result_valid: IDLE->LOAD->MULT->ALU_OP->OUTPUT = 4 cycles
        wait (result_valid == 1);
        #1;
        if (data_p === 48'sd15)
            $display("PASS [single_macc]: data_p = %0d (expected 15)", data_p);
        else
            $display("FAIL [single_macc]: data_p = %0d (expected 15)", data_p);

        // Let the FSM settle back to IDLE
        #20;

                // Chained MACC: two operations back to back, accumulating.
        // Starting from a clean reset, p_reg = 0 going in.
        //   Op1: A=3,D=0,B=5 -> ad=3, m=15, p = 0  + 15 = 15
        //   Op2: A=2,D=0,B=5 -> ad=2, m=10, p = 15 + 10 = 25
        
        rst = 1; #10; rst = 0; #10;

        data_a = 25'sd3;
        data_d = 25'sd0;
        data_b = 18'sd5;
        cmd = CMD_CHAIN;
        start = 1;
        #10;
        start = 0;

        wait (result_valid == 1);
        #1;
        if (data_p === 48'sd15)
            $display("PASS [chain_1]: data_p = %0d (expected 15)", data_p);
        else
            $display("FAIL [chain_1]: data_p = %0d (expected 15)", data_p);

        
        // wait, or the next wait() can catch this same still-high pulse
        // instead of the next one.
        wait (result_valid == 0);

        // Because cmd==CHAIN, the FSM jumped straight back to LOAD
        // instead of IDLE, so the next operand set is already being
        // captured this cycle.
        data_a = 25'sd2;
        data_d = 25'sd0;
        data_b = 18'sd5;
        // cmd still = CMD_CHAIN

        wait (result_valid == 1);
        #1;
        if (data_p === 48'sd25)
            $display("PASS [chain_2]: data_p = %0d (expected 25)", data_p);
        else
            $display("FAIL [chain_2]: data_p = %0d (expected 25)", data_p);

        #30;
        $finish;
    end
endmodule
