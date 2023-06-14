`define SIGNED_WIDTH (sigWidth+4+low_expand)
//计算移位加补码
module sig_shifter_2 #(  //36LUT
  parameter expWidth   = 4,
  parameter sigWidth   = 4,
  parameter low_expand = 2
) (
  input  [   (expWidth*2-1) : 0] exp_offset_num,
  input  [   (sigWidth*2-1) : 0] significand,
  input  [                  1:0] sign,
  output [`SIGNED_WIDTH*2-1 : 0] adder_num
);

  wire [`SIGNED_WIDTH-2:0] sig_off [0:1];
  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin
        assign sig_off[i] = 
      {3'b001 , significand[sigWidth*i+:sigWidth] , {low_expand{1'b0}}} >> exp_offset_num[expWidth*i+:expWidth];
    end
  endgenerate


  wire [1:0] zero;
  wire [`SIGNED_WIDTH-2:0] complement_num [0:1];

  generate
    for (i = 0; i < 2; i = i + 1) begin
      assign zero[i] = (sig_off[i] == {(`SIGNED_WIDTH-2){1'b0}});
    end
  endgenerate

  assign complement_num[0] = sign[0] ? ~sig_off[0] + 1'b1 : sig_off[0];
  assign complement_num[1] = sign[1] ? ~sig_off[1] + 1'b1 : sig_off[1];

  generate
    for (i = 0; i < 2; i = i + 1) begin
      assign adder_num[`SIGNED_WIDTH*i+:`SIGNED_WIDTH] = zero[i] ? {`SIGNED_WIDTH{1'b0}} : {sign[i],complement_num[i]};
    end
  endgenerate

endmodule
