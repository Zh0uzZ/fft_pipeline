module exp_normalizer #( //36LUT
  parameter expWidth = 4
) (
  input  [(expWidth*4-1):0] input_exp,
  output [(expWidth - 1):0] max_exp,
  output [(expWidth*4-1):0] exp_offset_num
);
  exp_comparison #(
    .expWidth(expWidth)
  ) u_exp_comparson (
    .input_exp (input_exp),
    .output_com(max_exp)
  );
  exp_offset #(
    .expWidth(expWidth)
  ) u_exp_offset (
    .input_exp     (input_exp),
    .max_exp       (max_exp),
    .exp_offset_num(exp_offset_num)
  );
endmodule
