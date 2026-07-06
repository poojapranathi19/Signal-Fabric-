// Code your testbench here
// or browse Examples
module step6_3 chain macc tb();
    
    reg clk;
    reg rst;
   
    reg ce_a, ce_b, ce_c, ce_d;
    reg ce_ad;
    reg ce_m;
    reg ce_p;
    reg [1:0] inmode;
    reg [5:0] opmode;
    reg [1:0] alu_sel;
    
    reg [24:0] data_a;
    reg [17:0] data_b;   
    reg [47:0] data_c;
    reg [24:0] data_d;

    
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

    
    always begin
        #5 clk = ~clk;
    end

 
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_DSP);
        // Initialize everything to zero
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
        //Cycle 1
        data_a = 25'd2;
        data_d = 25'd3;
        data_b = 18'd10;
        ce_a = 1; ce_b = 1; ce_d = 1;
        inmode = 2'b01; // A + D
        ce_ad = 1;
        #10;
      
        //Cycle 2 pushes 50 to Mult and loads next pair

        ce_m = 1; 
        // Inputs: (4 + 5) * 20
        data_a = 25'sd4;
        data_d = 25'sd5; 
        data_b = 18'sd20;
        // Keep Stage 1 enables ON to capture the new inputs
        ce_a = 1; ce_b = 1; ce_d = 1; 
        ce_ad = 1; 
        #10;
        
      
        //Cycle 3- pushes 50 to alu, 180 to mult and new inputs to load  
        opmode = 6'b000001; //X=m_reg Y=0
        alu_sel = 2'b10; //X+Y---0+50   
        ce_p = 1;

        ce_m = 1;
        data_a = 25'sd6; data_d = 25'sd7; data_b = 18'sd30;
        #10;
        
        // CYCLE 4 -add pair 2, and push pair 3 to mult
        ce_a = 0; ce_b = 0; ce_d = 0; ce_ad = 0;   
        opmode = 6'b010111;
        alu_sel = 2'b00;    // Three-operand Add: Z + (X + Y) -> 50 + (0 + 180) = 230
        ce_p = 1;
        ce_m = 1;
        #10;
        
        //last pair is multiplied and ce_m turns off
        ce_m = 0;
        
        opmode = 6'b010111;
        alu_sel = 2'b00;    // 230 + (0 + 390) = 620
        ce_p = 1;
        #10;
        ce_p = 0;   //to prevent overwriting
        #1;
      
   
        if (data_p === 48'd620) begin
          $display("SUCCESS- 3 chain MACC: 620");
        end else begin
          $display("FAILURE: %d");
        end

        #30;
      $finish;
    end
endmodule
