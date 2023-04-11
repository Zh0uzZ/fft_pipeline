`include "parameter.vh"
module FFT32(CLK,RST,DR,DI,OR,OI);

`FFTsfpw

    input CLK,RST,START;
    input [nb-1:0] DR,DI;
    output [nb-1:0] OR,OI;

    wire [nb-1:0] dr1,di1;
    wire rdy1;
    BUFRAM32C1 #(nb) U_BUF1(.CLK(CLK), .RST(RST), .ED(ED),	.START(START),
	.DR(DR), .DI(DI), .RDY(rdy1), .DOR(dr1), .DOI(di1));

    wire [nb*4-1:0] dr2,di2;
    SE2PA U_SE2PA_0(.CLK(CLK), .RST(RST) , .START(rdy1) , .DR(dr1) , .DI(di1),
    .OR(dr2) , .OI(di2));
    
    wire [nb*4-1:0] dr3,di3,dr4,di4;
    GEMM #(
        .expWidth   (expWidth),
        .sigWidth   (sigWidth),
        .formatWidth(formatWidth),
        .low_expand (low_expand)
    ) U_GEMM0 (
        .clk        (CLK),
        .rst        (RST),
        .start      (rdy1),
        .control    (1'b1),
        .input_real (dr2),
        .input_imag (di2),
        .output_real(dr3),
        .output_imag(di3),
        .gemm_done  (gemm_done)
    );
    HADAMARD #(
        .expWidth   (expWidth),
        .sigWidth   (sigWidth),
        .formatWidth(formatWidth),
        .low_expand (low_expand)
    ) U_HADAMARD0 (
        .clk          (CLK),
        .rst          (RST),
        .start        (gemm_done),
        .input_real   (dr3),
        .input_imag   (di3),
        .twiddle_real (twiddle_real),
        .twiddle_imag (twiddle_imag),
        .output_real  (wire_output_real),
        .output_imag  (wire_output_imag),
        .hadamard_done(hadamard_done)
    );
endmodule