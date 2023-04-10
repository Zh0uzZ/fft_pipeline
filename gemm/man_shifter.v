module SIG_SHIFTER #(
  parameter expWidth   = 3,
  parameter sigWidth   = 3,
  parameter low_expand = 2
) (
  input  [             (expWidth*4-1) : 0] exp_offset_num,
  input  [             (sigWidth*4-1) : 0] significand,
  input  [                            3:0] sign,
  input  [                            3:0] complement_sign1,
  input  [                            3:0] complement_sign2,
  output [(sigWidth+4+low_expand)*4-1 : 0] adder_num1,
  output [(sigWidth+4+low_expand)*4-1 : 0] adder_num2

);

  localparam FIXWIDTH = sigWidth + 4 + low_expand;
  wire [FIXWIDTH*4-1:0] 
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : ushifter0
      assign sig_off[FIXWIDTH*(i+1)-2 : FIXWIDTH*i] = 
      {3'b001 , significand[sigWidth*i+:sigWidth] , {low_expand{1'b0}}} >> exp_offset_num[expWidth*i+:expWidth];
    end
  endgenerate

  generate
    for (i = 0; i < 4; i = i + 1) begin : ushifter1
      assign sig_off[FIXWIDTH*(i+1)-1] = sign[i];
    end
  endgenerate

endmodule
