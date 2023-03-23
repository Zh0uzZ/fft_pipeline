module fsm #(
    parameter width = 4
) (
    input clk,
    input start,
    input [width:0] a ,b , c,
    output [width+4:0] sum
);


  reg  [2:0] current_state;
  reg  [2:0] next_state;
  localparam IDLE   = 3'b000;
  localparam STAGE1 = 3'b001;
  localparam STAGE2 = 3'b010;
  localparam STAGE3 = 3'b011;
  localparam STAGE4 = 3'b100;  
  localparam STAGE5 = 3'b101;

  wire [7:0] sum1 [0:4];
  reg  [7:0] sum1_reg [0:3];



always@(posedge clk) begin
        sum1_reg[0] <= sum1[0];
        sum1_reg[1] <= sum1[1];
        sum1_reg[2] <= sum1[2];
        sum1_reg[3] <= sum1[3];
        sum1_reg[4] <= sum1[4];
end
//   always @(posedge clk) begin
//       current_state <= next_state;
//   end



//   always @(*)  begin
//     case (current_state)
//         IDLE: begin
//             if(start) begin
//                 next_state = STAGE1;
//             end else begin
//                 next_state = IDLE;
//             end
//         end
//         STAGE1: begin
//             next_state = STAGE2;
//             sum1_reg[0] = sum1[0];
//         end
//         STAGE2: begin
//             next_state = STAGE3;
//             sum1_reg[1] = sum1[1];
//         end
//         STAGE3: begin
//             next_state = STAGE4;
//             sum1_reg[2] = sum1[2];
//         end
//         STAGE4: begin
//             next_state = STAGE5;
//             sum1_reg[3] = sum1[3];
//         end
//         default begin
//             current_state = IDLE;
//         end
//     endcase
//   end
  
assign  sum1[0] = a;
assign  sum1[1] = sum1_reg[0] + sum1_reg[0];
assign  sum1[2] = sum1_reg[1] + sum1_reg[1];
assign  sum1[3] = sum1_reg[2] + sum1_reg[2];
assign  sum1[4] = sum1_reg[3] + sum1_reg[3];
assign sum = sum1[4]; 

  
endmodule