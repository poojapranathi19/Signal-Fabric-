module tb_step6_singlechain();
    // Simulated Clock and Reset
    reg clk;
    reg rst;
    // Simulated Control Inputs (Acting as the FSM)
    reg ce_a, ce_b, ce_c, ce_d;
    reg ce_ad;
    reg ce_m;
    reg ce_p;
    reg [1:0] inmode;
    reg [5:0] opmode;
    reg [1:0] alu_sel;
    // Simulated Data Inputs
    reg [24:0] data_a;
    reg [18:0] data_b;   // matches DSP_modules' 19-bit data_b port (module internally slices data_b[17:0])
    reg [47:0] data_c;
    reg [24:0] data_d;

    // Output Monitoring Wire
    wire [47:0] data_p;

    // Instantiate Unit Under Test (UUT)
    step6_designcode uut (
        .clk(clk),
        .rst(rst),
        .ce_a(ce_a),
        .ce_b(ce_b),
        .ce_c(ce_c),
        .ce_d(ce_d),
        .ce_ad(ce_ad),
        .ce_m(ce_m),
        .ce_p(ce_p),
        .inmode(inmode),
        .opmode(opmode),
        .alu_sel(alu_sel),
        .data_a(data_a),
        .data_b(data_b),
        .data_c(data_c),
        .data_d(data_d),
        .data_p(data_p)
    );

    // Continuous 100MHz Clock Generation
    always begin
        #5 clk = ~clk;
    end

    // Test Execution Script
    initial begin
        // Initialize everything to zero, assert reset
        clk = 0;
        rst = 1;
        ce_a = 0; ce_b = 0; ce_c = 0; ce_d = 0;
        ce_ad = 0; ce_m = 0; ce_p = 0;
        inmode = 2'b00; opmode = 6'b000000; alu_sel = 2'b00;
        data_a = 0; data_b = 0; data_c = 0; data_d = 0;

        // Wait 2 clock cycles, then deassert reset
        #20;
        rst = 0;
        #10;

        // CYCLE 1 (LOAD state): drive operands and assert ce_a/ce_b/ce_d/ce_ad
        // together, exactly as slice_ctrl_fsm's LOAD state does. Because
        // pre_adder now reads data_a/data_d directly, ad_reg correctly
        // captures 2+3=5 on THIS edge, not the next one.
        data_a = 25'd2;
        data_d = 25'd3;
        data_b = 18'd4;
        ce_a = 1; ce_b = 1; ce_d = 1;
        inmode = 2'b01; // Pre-adder config: A + D
        ce_ad = 1;
        #10;

        // CYCLE 2 (MULT state): Lock Stage 1, enable Stage 2 Multiplier.
        // ad_reg now holds 5. m_reg <= 5*4 = 20 lands after this edge.
        ce_a = 0; ce_b = 0; ce_d = 0; ce_ad = 0;
        ce_m = 1;
        #10;

        // CYCLE 3 (ALU_OP state): Lock Multiplier, route Muxes, configure ALU.
        // m_reg=20. p_reg <= 0(old) + 20 + 0 = 20 lands after this edge.
        ce_m = 0;
        opmode = 6'b010001; // Z=p_reg, Y=0, X=m_reg
        alu_sel = 2'b00;    // ALU config: Z + (X + Y)
        ce_p = 1;
        #10;

        // CYCLE 4 (OUTPUT state): Lock Output Register, wait for stabilization.
        ce_p = 0;
        #1;

        // Self-Checking verification block
        if (data_p === 48'd20) begin
            $display("SUCCESS: 20");
        end else begin
            $display("FAILURE: %d", data_p);
        end

        #30;
        $finish;
    end
endmodule
