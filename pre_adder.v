`timescale 1ns / 1ps
// pre_adder.v
`include "dsp_defines.vh"

module pre_adder (
    input  wire        clk,
    input  wire        rst,
    input  wire        ce_ad,
    input  wire [1:0]  inmode,
    input  wire [24:0] a_reg,
    input  wire [24:0] d_reg,
    output reg  [24:0] ad_reg
);

    reg signed [24:0] pre_adder_result;

    // Combinational Part (Signed Arithmetic)
    always @(*) begin
        case (inmode)
            INMODE_BYPASS:   pre_adder_result = $signed(a_reg);
            INMODE_ADD:      pre_adder_result = $signed(a_reg) + $signed(d_reg);
            INMODE_SUBTRACT: pre_adder_result = $signed(a_reg) - $signed(d_reg);
            default:         pre_adder_result = $signed(a_reg);
        endcase
    end

    // Registered Part
    always @(posedge clk) begin
        if (rst) begin
            ad_reg <= 25'd0;
        end else if (ce_ad) begin
            ad_reg <= pre_adder_result;
        end
    end

endmodule
