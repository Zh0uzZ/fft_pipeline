module exp_comparison_2 #(
    parameter expWidth = 3
) (
    input  [expWidth*2-1:0] input_exp,
    output [(expWidth-1):0] output_com
);

  comparison #(
      .expWidth(expWidth)
  ) u_comp (
      .a(input_exp[expWidth-1:0]),
      .b(input_exp[expWidth*2-1:expWidth]),
      .c(output_com)
  );


endmodule
