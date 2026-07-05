// Code your testbench here
// or browse Examples
module tb_DSP_negative();
 
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
 
    DSP_modules uut (
        .clk(clk), .rst(rst),
        .ce_a(ce_a), .ce_b(ce_b), .ce_c(ce_c), .ce_d(ce_d),
        .ce_ad(ce_ad), .ce_m(ce_m), .ce_p(ce_p),
        .inmode(inmode), .opmode(opmode), .alu_sel(alu_sel),
        .data_a(data_a), .data_b(data_b), .data_c(data_c), .data_d(data_d),
        .data_p(data_p)
    );
 
    always begin
        #5 clk = ~clk;
    end
 
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0,tb_DSP_negative);
        clk = 0;
        rst = 1;
        ce_a = 0; ce_b = 0; ce_c = 0; ce_d = 0;
        ce_ad = 0; ce_m = 0; ce_p = 0;
        inmode = 2'b00; opmode = 6'b000000; alu_sel = 2'b00;
        data_a = 0; data_b = 0; data_c = 0; data_d = 0;
 
        @(negedge clk);
        @(negedge clk);
        rst = 0;
 
        // Cycle 1: AD=1, product=10
        @(negedge clk);
        data_a = -25'sd2;
        data_d = 25'sd3;
        data_b = 18'sd10;
        ce_a = 1; ce_b = 1; ce_d = 1;
        inmode = 2'b01; // A + D
        ce_ad = 1;
 
        // Cycle 2: AD=-1, product=20
        @(negedge clk);
        ce_m = 1;
        data_a = 25'sd4;
        data_d = -25'sd5;
        data_b = -18'sd20;
        ce_a = 1; ce_b = 1; ce_d = 1;
        ce_ad = 1;
 
        // Cycle 3: AD=-13, product=-390
        @(negedge clk);
        opmode = 6'b000001;  // X = m_reg, Y = 0
        alu_sel = 2'b10;     // 0 + 10 = 10
        ce_p = 1;
        ce_m = 1;
        data_a = -25'sd6; data_d = -25'sd7; data_b = 18'sd30;
 
        // Cycle 4: accumulate pair 2 (10 + 20 = 30)
        @(negedge clk);
        ce_a = 0; ce_b = 0; ce_d = 0; ce_ad = 0;
        opmode = 6'b010111;  // Z=p_reg, Y=m_reg, X=forced zero
        alu_sel = 2'b00;
        ce_p = 1;
        ce_m = 1;
 
        // Cycle 5: accumulate pair 3 (30 + (-390) = -360)
        @(negedge clk);
        ce_m = 0;
        opmode = 6'b010111;
        alu_sel = 2'b00;
        ce_p = 1;
 
        @(negedge clk);
        ce_p = 0;
 
        #1;
      
   
        if (data_p === -48'sd360) begin
          $display("SUCCESS- 3 chain MACC");
        end else begin
          $display("FAILURE");
        end

        #30;
      $finish;
    end
endmodule
