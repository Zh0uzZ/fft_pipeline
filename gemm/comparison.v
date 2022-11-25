module comparison #(
  parameter expWidth = 4
) (
  input  [(expWidth-1):0] a,
  input  [(expWidth-1):0] b,
  output [(expWidth-1):0] c
);
  wire com_reg;
  assign com_reg = (a[3] == b[3]) ? ((a[2] == b[2]) ? ((a[1] == b[1]) ?((a[0] == b[0]) ? a[0] : a[0]) : a[1] ): a[2]) : a[3];
  assign c = com_reg ? a : b;
endmodule
