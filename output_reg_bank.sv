// Code your design here
module output_reg(
  input wire clk,
  input wire rst,
  input wire ce_p,
  input wire [47:0] alu_result,
  output reg [47:0] p_reg
);
  always @(posedge clk) begin
    if (rst) begin
      p_reg <= 48'b0;
    end else if (ce_p) begin
      p_reg <= alu_result;
    end
  end
endmodule


