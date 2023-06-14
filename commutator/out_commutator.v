`include "../include/parameter.vh"
module out_commutator (clk,reset_n,start,input_data,output_data);
`FFTsfpw

input clk,reset_n,start;
input [nb*4-1:0] input_data;
output [nb*4-1:0] output_data;

serial_remap u0_serial_remap(
    .clk(clk) , .reset_n(reset_n) , .start(start) ,
    .input_data(input_data[nb*4-1:nb*3]) , .output_data(output_data[nb*4-1:nb*3])
);
serial_remap u1_serial_remap(
    .clk(clk) , .reset_n(reset_n) , .start(start) ,
    .input_data(input_data[nb*2-1:nb*1]) , .output_data(output_data[nb*3-1:nb*2])
);
serial_remap u2_serial_remap(
    .clk(clk) , .reset_n(reset_n) , .start(start) ,
    .input_data(input_data[nb*3-1:nb*2]) , .output_data(output_data[nb*2-1:nb*1])
);
serial_remap u3_serial_remap(
    .clk(clk) , .reset_n(reset_n) , .start(start) ,
    .input_data(input_data[nb-1:0]) , .output_data(output_data[nb-1:0])
);

endmodule