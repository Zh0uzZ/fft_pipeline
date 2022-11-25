module find_max_exp #(
    parameter expWidth = 4
) (
    input [32*expWidth-1:0] input_exp,
    output [expWidth-1:0] output_exp
);

  wire [expWidth-1:0] temp_exp[0:8];

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : u0
      exp_comparsion #(
          .expWidth(expWidth)
      ) u_exp_comparsion (
          .input_exp (input_exp[4*expWidth*(i+1)-1 : 4*expWidth*(i)]),
          .output_com(temp_exp[i])
      );
    end
  endgenerate

  exp_comparsion #(
      .expWidth(expWidth)
  ) u1 (
      .input_exp ({temp_exp[3] , temp_exp[2] , temp_exp[1] , temp_exp[0]}),
      .output_com(temp_exp[8])
  );

  exp_comparsion #(
      .expWidth(expWidth)
  ) u2 (
      .input_exp ({temp_exp[7] , temp_exp[6] , temp_exp[5] , temp_exp[4]}),
      .output_com(temp_exp[9])
  );

  exp_comparsion_2 #(
      .expWidth(expWidth)
  ) u3 (
      .input_exp ({temp_exp[9] , temp_exp[8]}),
      .output_com(output_exp)
  );
endmodule
