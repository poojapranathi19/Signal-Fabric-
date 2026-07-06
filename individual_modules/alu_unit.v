module alu_unit (
    input wire [1:0] alu_sel,                   // 2-bit control signal from FSM pipeline
    
    input wire signed [47:0] x_out,             // 48-bit input from Mux X
    input wire signed [47:0] y_out,             // 48-bit input from Mux Y
    input wire signed [47:0] z_out,             // 48-bit input from Mux Z
    
    output reg signed [47:0] alu_result         // Instant combination result out
);

    always @(*) begin
        case (alu_sel)
            2'b00:   alu_result = z_out + (x_out + y_out);
            2'b01:   alu_result = z_out - (x_out + y_out);
            2'b10:   alu_result = x_out + y_out;         
            default: alu_result = 48'sb0;                
        endcase
    end

endmodule
