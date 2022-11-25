// find top one
module find_one #(
  parameter sigWidth   = 4,
  parameter low_expand = 2
) (
  input  [(sigWidth+2+low_expand):0] input_num,
  output [                      3:0] pos
);
  wire [7:0] data_1;
  wire [3:0] data_2;
  wire [1:0] data_3;

  assign pos[3] = |input_num[(sigWidth+2+low_expand) : 8];
  assign data_1 = pos[3] ? {6'b0, input_num[(sigWidth+2+low_expand) : 8]} : input_num[7:0];
  assign pos[2] = |data_1[7:4];
  assign data_2 = pos[2] ? data_1[7:4] : data_1[3:0];
  assign pos[1] = |data_2[3:2];
  assign data_3 = pos[1] ? data_2[3:2] : data_2[1:0];
  assign pos[0] = data_3[1];
endmodule
