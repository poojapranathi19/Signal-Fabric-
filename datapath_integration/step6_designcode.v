module step6_designcode(
    // 1. GLOBAL SYSTEM SIGNALS
    input clk,
    input rst,
    
    // 2. EXPOSED CONTROL PATH SIGNALS (Driven by your testbench)
    input ce_a, ce_b, ce_c, ce_d,   // Stage 1 Register Clock Enables
    input ce_ad,                    // Stage 1 Pre-Adder Register Enable
    input ce_m,                     // Stage 2 Multiplier Register Enable
    input ce_p,                     // Stage 3 Output Register Enable
    input [1:0] inmode,             // Pre-adder configuration
    input [5:0] opmode,             // Multiplexer configuration
    input [1:0] alu_sel,            // ALU math operation configuration
    
    // 3. EXTERNAL DATA PATH INPUTS
    input signed [24:0] data_a,            // 25-bit Operand A
    input signed [18:0] data_b,            // 18-bit Operand B
    input signed [47:0] data_c,            // 48-bit Operand C
    input signed [24:0] data_d,            // 25-bit Operand D
    
    // 4. EXTERNAL DATA PATH OUTPUT
    output signed [47:0] data_p            // 48-bit Final Output
);

    
    // INTERNAL REGISTERS AND WIRES (Connecting the logic blocks together)
    
    // Stage 1 Registers (From Module 1: input_reg_bank)
    reg signed [24:0] a_reg;
    reg signed [17:0] b_reg;
    reg signed [47:0] c_reg;
    reg signed [24:0] d_reg;
    
    // Stage 1 Extended Register (From Module 2: pre_adder)
    reg signed [24:0] ad_reg;
    
    // Stage 2 Register (From Module 3: multiplier)
    reg signed [42:0] m_reg;
    
    // Combinational Mux Outputs (From Module 4: operand_mux)
    reg signed [47:0] x_out;
    reg signed [47:0] y_out;
    reg signed [47:0] z_out;
    
    // Combinational ALU Output (From Module 5: alu_unit)
    reg signed [47:0] alu_result;
    
    // Stage 3 Register (From Module 6: output_reg)
    reg signed [47:0] p_reg;


    
    // LOGIC BLOCK 1: Input Register Bank (Sequential / Stage 1)
    
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 25'sb0;
            b_reg <= 19'sb0;
            c_reg <= 48'sb0;
            d_reg <= 25'sb0;
        end else begin
            if (ce_a) a_reg <= data_a;
            if (ce_b) b_reg <= data_b[17:0]; // Capture lower 18 bits of B
            if (ce_c) c_reg <= data_c;
            if (ce_d) d_reg <= data_d;
        end
    end


    
    // LOGIC BLOCK 2: Pre-Adder (Sequential / Stage 1 Extended)
    
    always @(posedge clk) begin
        if (rst) begin
            ad_reg <= 25'sb0;
        end else begin
            if (ce_ad) begin
                case (inmode)
                    2'b00:   ad_reg <= data_a;             // Bypass pre-adder
                    2'b01:   ad_reg <= data_a + data_d;     // Add A + D
                    2'b10:   ad_reg <= data_a - data_d;     // Subtract A - D
                    default: ad_reg <= data_a;
                endcase
            end
        end
    end


    
    // LOGIC BLOCK 3: Multiplier (Sequential / Stage 2)
    
    always @(posedge clk) begin
        if (rst) begin
            m_reg <= 43'sb0;
        end else begin
            if (ce_m) begin
                m_reg <= $signed(ad_reg) * $signed(b_reg); // Multiply pre-adder result by B register
            end
        end
    end


    
    // LOGIC BLOCK 4: Operand Multiplexers (Combinational)
    
    always @(*) begin
        // Default assignments to avoid unintended hardware latches
        x_out = 48'sb0;
        y_out = 48'sb0;
        z_out = 48'sb0;

        // X Multiplexer Logic (Controlled by opmode[1:0])
        case (opmode[1:0])
            2'b00:   x_out = $signed({a_reg, b_reg});  // Concatenate A and B
            2'b01:   x_out = $signed(m_reg);   // Select Multiplier (padded to 48 bits)
            2'b10:   x_out = p_reg;           // Select P feedback
            default: x_out = 48'sb0;
        endcase

        // Y Multiplexer Logic (Controlled by opmode[3:2])
        case (opmode[3:2])
            2'b00:   y_out = 48'sb0;               // Force Y to zero
            2'b01:   y_out = $signed(m_reg);// Force Y to all ones
            2'b10:   y_out = c_reg;           // Select C register
            default: y_out = 48'sb0;
        endcase

        // Z Multiplexer Logic (Controlled by opmode[5:4])
        case (opmode[5:4])
            2'b00:   z_out = 48'sb0;               // Force Z to zero
            2'b01:   z_out = p_reg;           // Select P feedback (Accumulator lane)
            2'b10:   z_out = c_reg;           // Select C register
            default: z_out = 48'sb0;
        endcase
    end


    // LOGIC BLOCK 5: Arithmetic Logic Unit - ALU (Combinational)
    
    always @(*) begin
        case (alu_sel)
            2'b00:   alu_result = z_out + (x_out + y_out); // Three-operand Add
            2'b01:   alu_result = z_out - (x_out + y_out); // Three-operand Subtract
            2'b10:   alu_result = x_out + y_out;           // Two-operand Add (Ignores Z)
            default: alu_result = 48'sb0;
        endcase
    end


    
    // LOGIC BLOCK 6: Output Register (Sequential / Stage 3)
    
    always @(posedge clk) begin
        if (rst) begin
            p_reg <= 48'sb0;
        end else begin
            if (ce_p) begin
                p_reg <= alu_result; // Capture final calculated ALU answer
            end
        end
    end


    
    // FINAL CHIP OUTPUT HARNESS
    
    assign data_p = p_reg; // Route the internal p_reg directly to the external pin

endmodule
