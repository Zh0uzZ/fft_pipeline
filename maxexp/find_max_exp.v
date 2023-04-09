// find max exponent in 64 exponents


module find_max_exp #(
    parameter expWidth = 4
) (
    input [64*expWidth-1:0] input_exp,
    output [expWidth-1:0] output_exp
);

  wire [expWidth-1:0] temp_exp[0:19];

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : u0
      exp_comparison #(
          .expWidth(expWidth)
      ) u_exp_comparison (
          .input_exp (input_exp[4*expWidth*(i+1)-1 : 4*expWidth*(i)]),
          .output_com(temp_exp[i])
      );
    end
  endgenerate

  generate
    for(i = 0; i < 4; i = i + 1) begin : u1
      exp_comparison #(
          .expWidth(expWidth)
      ) u1_exp_comparison (
          .input_exp ({temp_exp[i*4+3] , temp_exp[i*4+2] , temp_exp[i*4+1] , temp_exp[i*4]}),
          .output_com(temp_exp[16+i])
      );
    end
  endgenerate

  exp_comparison #(
      .expWidth(expWidth)
  ) u2_exp_comparison (
      .input_exp ({temp_exp[16] , temp_exp[17] , temp_exp[18] , temp_exp[19]}),
      .output_com(output_exp)
  );
endmodule
