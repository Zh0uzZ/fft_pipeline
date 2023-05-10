`include "parameter.vh"
module start_delay(clk,reset_n,start,input_real,input_imag,output_real,output_imag);
`FFTsfpw

input clk,reset_n,start;
input [nb-1:0] input_real,input_imag;
output [nb*4-1:0] output_real,output_imag;



endmodule