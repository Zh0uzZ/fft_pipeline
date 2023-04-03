`timescale 1ns/1ns
module exponent_maxtb;
    reg [8*4-1:0] input_exp;
    reg [3:0] max_exp;
    wire [8*4-1:0] output_exp;
    wire [8*4-1:0] output_exp1;

    initial begin
        input_exp = {4'd13 , 4'd0 , 4'd8 , 4'd3 , 4'd2 , 4'd4 , 4'd1 , 4'd0};
        max_exp = 4'd13;
        #10 max_exp = 4'd8;
        #10 max_exp = 4'd7;
        #10 max_exp = 4'd3;
        #10 $finish;
    end
    exponent_reciprocal u1(
        .input_exp(input_exp),
        .max_exp(max_exp),
        .output_exp(output_exp)
    );
    exponent_resize u_resize(
        .input_exp(output_exp),
        .max_exp(max_exp),
        .output_exp(output_exp1)
    );
endmodule