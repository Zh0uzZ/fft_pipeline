`timescale  1ps/1ps
module testbench_gemm;
    parameter expWidth = 4;
    parameter sigWidth = 4;
    parameter formatWidth = 9;
    parameter low_expand = 4;
    reg rst , clk , start;
    reg [formatWidth-1:0] input_real [3:0];
    reg [formatWidth-1:0] input_imag [3:0];
    wire [(formatWidth-1) : 0] output_real [3:0];
    wire [(formatWidth-1) : 0] output_imag [3:0];
    wire gemm_done;

    initial begin
        clk = 0;
        rst = 1;
        #50 rst = 0;
        #50 rst = 1;
        {input_real[3] , input_real[2] , input_real[1] , input_real[0]} = {9'b1_1100_1000 , 9'b0_1000_1000 , 9'b1_0111_1111 , 9'b1_1100_1000};
        {input_imag[3] , input_imag[2] , input_imag[1] , input_imag[0]} = {9'b1_1100_1000 , 9'b0_1000_1000 , 9'b1_0111_1111 , 9'b1_1100_1000};
        start = 1;
    end
    always #10 clk = ~clk;
    gemm #(
        .expWidth(expWidth),
        .sigWidth(sigWidth),
        .formatWidth(formatWidth),
        .low_expand(low_expand)
    ) gemm0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .input_real({input_real[3] , input_real[2] , input_real[1] , input_real[0]}),
        .input_imag({input_imag[3] , input_imag[2] , input_imag[1] , input_imag[0]}),
        .output_real({output_real[3] , output_real[2] , output_real[1] , output_real[0]}),
        .output_imag({output_imag[3] , output_imag[2] , output_imag[1] , output_imag[0]}),
        .gemm_done(gemm_done)

    );

endmodule