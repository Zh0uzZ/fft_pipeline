//求补码并且求出两个数的和    4LUT,7ns
`define SIGNED_WIDTH (sigWidth+4+low_expand)
module adder_2in #(  //10LUT
    parameter sigWidth   = 4,
    parameter low_expand = 2
) (
    input  [`SIGNED_WIDTH*2-1:0] input_num,
    output [`SIGNED_WIDTH-1 : 0] adder_num
);

  assign adder_num = input_num[`SIGNED_WIDTH*2-1 : `SIGNED_WIDTH] + input_num[`SIGNED_WIDTH-1:0];

endmodule
