`timescale 1ns / 1ps
// multiplier.v
module multiplier (
    input  wire        clk,
    input  wire        rst,
    input  wire        ce_m,
    input  wire [24:0] ad_reg,
    input  wire [17:0] b_reg,
    output reg  [42:0] m_reg // 25 + 18 = 43 bits to safely avoid overflow
);

    reg signed [42:0] mult_result;

    // Combinational Part (Strictly Signed Multiplication)
    always @(*) begin
        mult_result = $signed(ad_reg) * $signed(b_reg);
    end

    // Registered Part
    always @(posedge clk) begin
        if (rst) begin
            m_reg <= 43'd0;
        end else if (ce_m) begin
            m_reg <= mult_result;
        end
    end

endmodule