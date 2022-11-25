module adder_bits #(
  parameter sigWidth   = 4,
  parameter low_expand = 2
) (
  input  [sigWidth+low_expand+3:0] a,
  input  [sigWidth+low_expand+3:0] b,
  output [sigWidth+low_expand+3:0] sum
);
  wire [sigWidth+low_expand+3:0] cin;
  adder_1bit u1_adder (
    .a   (a[0]),
    .b   (b[0]),
    .cin (1'b0),
    .s   (sum[0]),
    .cout(cin[0])
  );
  genvar i;
  generate
    for (i = 1; i < (sigWidth + 4 + low_expand); i = i + 1) begin : u2_adder_list
      adder_1bit u2_adder (
        .a   (a[i]),
        .b   (b[i]),
        .cin (cin[i-1]),
        .s   (sum[i]),
        .cout(cin[i])
      );
    end
  endgenerate
  //   assign sum[sigWidth+low_expand+3] = cin[sigWidth+4];
endmodule
