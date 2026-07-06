module dsp_slice_top(
    // Global system signals
    input  wire clk,
    input  wire rst,

    // External command interface (drives the FSM only)
    input  wire [2:0] cmd,
    input  wire       start,

    // External data path inputs (drive the datapath only)
    input  wire signed [24:0] data_a,
    input  wire signed [18:0] data_b,
    input  wire signed [47:0] data_c,
    input  wire signed [24:0] data_d,

    // External data path output
    output wire signed [47:0] data_p,

    // External status outputs (from the FSM)
    output wire busy,
    output wire result_valid
);

    
    wire ce_a, ce_b, ce_c, ce_d, ce_ad;
    wire ce_m;
    wire ce_p;
    wire [1:0] inmode;
    wire [5:0] opmode;
    wire [1:0] alu_sel;

        // Control path: slice_ctrl_fsm.v
    // Decodes cmd/start into the per-cycle control words that drive
    // every other module.
    
    slice_ctrl_fsm ctrl_fsm (
        .clk           (clk),
        .rst           (rst),
        .cmd           (cmd),
        .start         (start),

        .ce_a          (ce_a),
        .ce_b          (ce_b),
        .ce_c          (ce_c),
        .ce_d          (ce_d),
        .ce_ad         (ce_ad),
        .ce_m          (ce_m),
        .ce_p          (ce_p),

        .inmode        (inmode),
        .opmode        (opmode),
        .alu_sel       (alu_sel),

        .busy          (busy),
        .result_valid  (result_valid)
    );

        // Data path: DSP_modules.v
    // The 3-stage pipeline (input regs -> pre-adder -> multiplier ->
    // operand muxes -> ALU -> output reg), entirely driven by the
    // control bus above.
        step6_designcode datapath (
        .clk       (clk),
        .rst       (rst),

        .ce_a      (ce_a),
        .ce_b      (ce_b),
        .ce_c      (ce_c),
        .ce_d      (ce_d),
        .ce_ad     (ce_ad),
        .ce_m      (ce_m),
        .ce_p      (ce_p),

        .inmode    (inmode),
        .opmode    (opmode),
        .alu_sel   (alu_sel),

        .data_a    (data_a),
        .data_b    (data_b),
        .data_c    (data_c),
        .data_d    (data_d),

        .data_p    (data_p)
    );

endmodule
