module operand_mux (
    input wire [5:0] opmode,                    // 6-bit control signal from FSM pipeline
    
    input wire signed [24:0] a_reg,             // From input bank
    input wire signed [17:0] b_reg,             // From input bank
    input wire signed [43:0] m_reg,             // From multiplier output
    input wire signed [47:0] c_reg,             // From input bank
    input wire signed [47:0] p_reg,             // From ALU output register
    
    output reg signed [47:0] x_out,             // To ALU Port X
    output reg signed [47:0] y_out,             // To ALU Port Y
    output reg signed [47:0] z_out              // To ALU Port Z
);

    // X MUX (opmode[1:0])
    always @(*) begin
        case (opmode[1:0])
            2'd0:    x_out = 48'sb0;
            // Explicitly handle sign extension by replicating the MSB of a_reg
            2'd1:    x_out = { {5{a_reg[24]}}, a_reg, b_reg }; 
            2'd2:    x_out = m_reg;               // Automatic sign extension (44-bit to 48-bit)
            default: x_out = 48'sb0;
        endcase
    end

    // Y MUX (opmode[3:2])
    always @(*) begin
        case (opmode[3:2])
            2'd0:    y_out = 48'sb0;
            2'd1:    y_out = m_reg;               // Automatic sign extension (44-bit to 48-bit)
            2'd2:    y_out = c_reg;               // Already 48 bits wide
            default: y_out = 48'sb0;
        endcase
    end

    // Z MUX (opmode[5:4])
    always @(*) begin
        case (opmode[5:4])
            2'd0:    z_out = 48'sb0;
            2'd1:    z_out = p_reg;               // Feedback accumulator path
            2'd2:    z_out = c_reg;               // Direct C input
            default: z_out = 48'sb0;
        endcase
    end

endmodule
