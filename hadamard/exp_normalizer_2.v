module exp_normalizer_2 #(  //8LUT
  parameter expWidth = 3
) (
  input  [(expWidth*2-1):0] input_exp,
  output [(expWidth - 1):0] max_exp,
  output [(expWidth*2-1):0] exp_offset_num
);
  exp_comparison_2 #(
    .expWidth(expWidth)
  ) u_exp_comparson (
    .input_exp (input_exp),
    .output_com(max_exp)
  );
  exp_offset_2 #(
    .expWidth(expWidth)
  ) u_exp_offset (
    .input_exp     (input_exp),
    .max_exp       (max_exp),
    .exp_offset_num(exp_offset_num)
  );
endmodule
