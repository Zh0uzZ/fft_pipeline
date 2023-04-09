`include "parameter.vh"
module FFT32(CLK,RST,DR,DI,OR,OI);

`FFTsfpw

    input CLK,RST,START;
    input [nb-1:0] DR,DI;
    output [nb-1:0] OR,OI;

    BUFRAM64C1 #(nb) U_BUF1(.CLK(CLK), .RST(RST), .ED(ED),	.START(START),
	.DR(DR), .DI(DI), .RDY(rdy1), .DOR(dr1), .DOI(di1));

endmodule