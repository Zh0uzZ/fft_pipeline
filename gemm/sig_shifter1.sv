`define SIGNED_WIDTH (sigWidth+4+low_expand)
module SIG_SHIFTER1 #( //100LUT
  parameter expWidth   = 4,
  parameter sigWidth   = 4,
  parameter low_expand = 2,
  parameter type exp_t = logic [expWidth-1:0],
  parameter type man_t = logic [sigWidth-1:0],
  parameter type add_t = logic [`SIGNED_WIDTH-1:0]
) (
  input exp_t  [3:0] exp_offset_num,
  input man_t  [3:0] significand,
  input logic  [3:0] sign,
  input logic  [3:0] complement_sign1,
  input logic  [3:0] complement_sign2,
  output add_t [3:0] adder_num1,
  output add_t [3:0] adder_num2

);

  logic [`SIGNED_WIDTH-2:0] sig_off [0:3];
  genvar i;
//   generate
//     for (i = 0; i < 4; i = i + 1) begin : ushifter0
//       assign sig_off[i] =
//       {3'b001 , significand[sigWidth*i+:sigWidth] , {low_expand{1'b0}}} >> exp_offset_num[expWidth*i+:expWidth];
//     end
//   endgenerate


  generate
    for (i = 0; i < 4; i = i + 1) begin : ushifter0
    always_comb begin
        case(exp_offset_num[i])
        0: begin sig_off[i] = {3'b001 , significand[i] , {low_expand{1'b0}}}; end
        1: begin sig_off[i] = {4'h1   , significand[i] , {(low_expand-1){1'b0}}}; end
        3: begin sig_off[i] = {5'h01  , significand[i] }; end
        4: begin sig_off[i] = {6'h01  , significand[i][sigWidth-2:0]}; end
        5: begin sig_off[i] = {7'h01  , significand[i][sigWidth-3:0]}; end
        6: begin sig_off[i] = {8'h01  , significand[i][sigWidth-4:0]}; end
        7: begin sig_off[i] = {9'h001 }; end
        default : begin sig_off[i] = 9'h000; end
        endcase
    end
    end
  endgenerate




  wire [3:0] zero;
  wire [7:0] complement_sign;
  wire [`SIGNED_WIDTH*8-1:0] complement_num_buf;
  generate
    for(i = 0;i < 4;i = i + 1) begin
      assign zero[i] = (sig_off[i] == {`SIGNED_WIDTH{1'b0}});
  end
  endgenerate

  assign complement_sign[0] = sign[0] ^ complement_sign1[0]; //number1
  assign complement_sign[1] = sign[1] ^ complement_sign1[1];
  assign complement_sign[2] = sign[2] ^ complement_sign1[2];
  assign complement_sign[3] = sign[3] ^ complement_sign1[3];
  assign complement_sign[4] = sign[0] ^ complement_sign2[0]; //number2
  assign complement_sign[5] = sign[1] ^ complement_sign2[1];
  assign complement_sign[6] = sign[2] ^ complement_sign2[2];
  assign complement_sign[7] = sign[3] ^ complement_sign2[3];
  assign complement_num_buf[`SIGNED_WIDTH*1-2:`SIGNED_WIDTH*0] = complement_sign[0] ? ~sig_off[0] + 1 : sig_off[0];
  assign complement_num_buf[`SIGNED_WIDTH*2-2:`SIGNED_WIDTH*1] = complement_sign[1] ? ~sig_off[1] + 1 : sig_off[1];
  assign complement_num_buf[`SIGNED_WIDTH*3-2:`SIGNED_WIDTH*2] = complement_sign[2] ? ~sig_off[2] + 1 : sig_off[2];
  assign complement_num_buf[`SIGNED_WIDTH*4-2:`SIGNED_WIDTH*3] = complement_sign[3] ? ~sig_off[3] + 1 : sig_off[3];

  assign complement_num_buf[`SIGNED_WIDTH*5-2:`SIGNED_WIDTH*4] = complement_sign[4] ? ~sig_off[0] + 1 : sig_off[0];
  assign complement_num_buf[`SIGNED_WIDTH*6-2:`SIGNED_WIDTH*5] = complement_sign[5] ? ~sig_off[1] + 1 : sig_off[1];
  assign complement_num_buf[`SIGNED_WIDTH*7-2:`SIGNED_WIDTH*6] = complement_sign[6] ? ~sig_off[2] + 1 : sig_off[2];
  assign complement_num_buf[`SIGNED_WIDTH*8-2:`SIGNED_WIDTH*7] = complement_sign[7] ? ~sig_off[3] + 1 : sig_off[3];


  assign complement_num_buf[`SIGNED_WIDTH*1-1] = complement_sign[0];
  assign complement_num_buf[`SIGNED_WIDTH*2-1] = complement_sign[1];
  assign complement_num_buf[`SIGNED_WIDTH*3-1] = complement_sign[2];
  assign complement_num_buf[`SIGNED_WIDTH*4-1] = complement_sign[3];

  assign complement_num_buf[`SIGNED_WIDTH*5-1] = complement_sign[4];
  assign complement_num_buf[`SIGNED_WIDTH*6-1] = complement_sign[5];
  assign complement_num_buf[`SIGNED_WIDTH*7-1] = complement_sign[6];
  assign complement_num_buf[`SIGNED_WIDTH*8-1] = complement_sign[7];

  generate
    for(i = 0;i < 4;i = i + 1) begin
      assign adder_num1[i] = zero[i] ? {`SIGNED_WIDTH{1'b0}} : complement_num_buf[`SIGNED_WIDTH*(i+1)-1 : `SIGNED_WIDTH*i    ];
      assign adder_num2[i] = zero[i] ? {`SIGNED_WIDTH{1'b0}} : complement_num_buf[`SIGNED_WIDTH*(i+5)-1 : `SIGNED_WIDTH*(i+4)];
  end
  endgenerate

endmodule
