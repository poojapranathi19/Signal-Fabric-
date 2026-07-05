// Code your design here
module slice_ctrl_fsm(
  input wire clk,
  input wire rst,
  input wire [2:0] cmd,
  input wire start,
  output reg ce_a, ce_b, ce_c, ce_d, ce_ad,
  output reg ce_m,
  output reg ce_p,
  
  output reg [1:0] inmode,
  output wire [5:0] opmode,
  output wire [1:0] alu_sel,
  
  output reg busy,
  output reg result_valid
);
  
  localparam CHAIN = 3'b001;
  localparam IDLE= 3'b000;
  localparam LOAD= 3'b001;
  localparam MULT= 3'b010;
  localparam ALU_OP= 3'b011;
  localparam OUTPUT =3'b100;
  reg [2:0] state;
  reg [2:0] next_state;
  
  reg[5:0] opmode_r1, opmode_r2;
  reg[1:0] alu_sel_r1,alu_sel_r2;
  
  assign opmode = opmode_r2;
  assign alu_sel= alu_sel_r2;
  
  
  always @(posedge clk) begin
      if (rst) begin
          state<= IDLE;
      end else begin
          state<= next_state;
      end
  end
  
  
  always @(*) begin
    case (state)
      IDLE: next_state= start? LOAD: IDLE;
      LOAD: next_state= MULT;
      MULT: next_state= ALU_OP;
      ALU_OP: next_state= OUTPUT;
      OUTPUT: next_state= (cmd==CHAIN)? LOAD: IDLE;
      default: next_state = IDLE;
    endcase
  end
  
   
   
  always @(*) begin
    ce_a =(state == LOAD);
    ce_b = (state == LOAD);
    ce_c = (state == LOAD);
    ce_d = (state == LOAD);
    ce_ad = (state == LOAD);
    ce_m  = (state == MULT);
    ce_p  = (state == ALU_OP);
    busy  = (state != IDLE);
    result_valid = (state == OUTPUT);
  end

   
  always @(posedge clk) begin
      if (rst) begin
        inmode      <= 2'b00;
        opmode_r1   <= 6'b000000;
        alu_sel_r1  <= 2'b00;
        opmode_r2   <= 6'b000000;
        alu_sel_r2  <= 2'b00;
      end else begin
          if (state == LOAD) begin
            inmode <= 2'b01; 
            
            if (cmd == CHAIN) begin
              opmode_r1  <= 6'b010001; 
              alu_sel_r1 <= 2'b00;     
            end else begin
              opmode_r1  <= 6'b000001; 
              alu_sel_r1 <= 2'b00;     
            end
          end
          
            
            
          if (ce_m) begin
            opmode_r2  <= opmode_r1;
            alu_sel_r2 <= alu_sel_r1;
          end
      end
  end
endmodule
