module exp_comparison #(
  parameter expWidth = 4
) (
  input  [expWidth*4-1:0] input_exp,
  output [(expWidth-1):0] output_com
);

  wire [(expWidth-1):0] exp_temp[1:0];

  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin : compare
      comparison #(
        .expWidth(expWidth)
      ) u_comp (
        .a(input_exp[expWidth*i*2+expWidth-1:expWidth*i*2]),
        .b(input_exp[expWidth*(i+1)*2-1:expWidth*i*2+expWidth]),
        .c(exp_temp[i])
      );
    end
  endgenerate

  generate
    for (i = 0; i < 1; i = i + 1) begin : compare1
      comparison #(
        .expWidth(expWidth)
      ) u_comp (
        .a(exp_temp[i]),
        .b(exp_temp[i+1]),
        .c(output_com)
      );
    end
  endgenerate

endmodule
