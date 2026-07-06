`timescale 1ns / 1ps
// input_reg_bank.v
module input_reg_bank (
    input  wire        clk,
    input  wire        rst,
    input  wire        ce_a,
    input  wire        ce_b,
    input  wire        ce_c,
    input  wire        ce_d,
    input  wire [24:0] data_a,
    input  wire [17:0] data_b,
    input  wire [47:0] data_c,
    input  wire [24:0] data_d,
    output reg  [24:0] a_reg,
    output reg  [17:0] b_reg,
    output reg  [47:0] c_reg,
    output reg  [24:0] d_reg
);

    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 25'd0;
            b_reg <= 18'd0;
            c_reg <= 48'd0;
            d_reg <= 25'd0;
        end else begin
            if (ce_a) a_reg <= data_a;
            if (ce_b) b_reg <= data_b;
            if (ce_c) c_reg <= data_c;
            if (ce_d) d_reg <= data_d;
        end
    end

endmodule
