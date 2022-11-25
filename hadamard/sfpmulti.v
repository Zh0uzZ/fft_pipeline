module sfpmulti #(
  parameter expWidth    = 4,
  parameter sigWidth    = 4,
  parameter formatWidth = 9
) (
  input  [formatWidth-1:0] a,
  input  [formatWidth-1:0] b,
  output [formatWidth-1:0] c
);

  wire [2*(sigWidth+1)-1:0] out_multi;
  wire [      expWidth : 0] expExpand;
  wire [      expWidth : 0] exponent;
  wire [    sigWidth-1 : 0] mantissa;


  assign out_multi = {1'b1, a[sigWidth-1:0]} * {1'b1, b[sigWidth-1:0]};
  assign mantissa[sigWidth-1:0] = (expExpand>8) ? (out_multi[2*sigWidth+1] ? 
                            (out_multi[sigWidth*2:sigWidth+1]) : 
                            ((out_multi[sigWidth*2-1:sigWidth])))
                            :{(sigWidth){1'b0}};
  assign expExpand = a[formatWidth-2:sigWidth] + b[formatWidth-2:sigWidth] + out_multi[2*(sigWidth+1)-1];
  assign exponent = (expExpand > 8) ? {expExpand + 5'b11000} : {5'b0};
  assign c = ((a[formatWidth-2:sigWidth] == 4'b0000)|(b[formatWidth-2:sigWidth] == 4'b0000)) ? ({formatWidth{1'b0}}) : {a[formatWidth-1] ^ b[formatWidth-1], exponent[expWidth-1:0], mantissa};
endmodule
