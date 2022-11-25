module exp_offset_2 #(
    parameter expWidth = 4
) (
    input  [expWidth*2-1:0] input_exp,
    input  [(expWidth-1):0] max_exp,
    output [expWidth*2-1:0] exp_offset_num
);
  genvar i;
  generate
    for (i = 0; i < 2; i = i + 1) begin : u_exp_offset
      assign exp_offset_num[expWidth*i+expWidth-1 : expWidth*i] = (input_exp[expWidth*(i+1)-1:expWidth*i] == 4'b0000) ? 9 : max_exp - input_exp[expWidth*i+expWidth-1 : expWidth*i];
    end
  endgenerate
endmodule
