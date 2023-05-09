//multi-path delay commutator (MDC)
//Radix-4
`include "parameter.vh"
module R4MDC(CLK,RST,START,DR,DI,OR,OI,RDY);
`FFTsfpw
    input CLK,RST,START;
    input [nb-1:0] DR,DI;
    output [nb-1:0] OR,OI;
    output RDY;

    wire [nb-1:0] dr1,di1;
    wire rdy1;      //BUFRAM0 ready signal
    BUFRAM32C1 #(.nb(nb)) U_BUF0(.CLK(CLK), .RST(RST), .ED(1'b1), .START(START), .DR(DR), .DI(DI), .RDY(rdy1), .DOR(dr1), .DOI(di1));

    wire [nb*4-1:0] dr2,di2;
    wire rdy2;
    SE2PA U_SE2PA_0(.CLK(CLK), .RST(RST) , .START(rdy1) , .DR(dr1) , .DI(di1), .OR(dr2) , .OI(di2) , .RDY(rdy2));
    
    wire [nb*4-1:0] dr3,di3,dr4,di4;
    wire rdy3;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM0 (
        .clk        (CLK),
        .rst        (RST),
        .start      (rdy2),
        .control    (1'b1),
        .input_real (dr2),
        .input_imag (di2),
        .output_real(dr3),
        .output_imag(di3),
        .ready      (rdy3)
    );
    wire [nb*4-1:0] tr0,ti0;
    wire rdy4;
    WROM32 U_WROM0(.CLK(CLK) , .RST(RST) , .STAGE(1'b0) , .START(rdy2) , .OR(tr0) , .OI(ti0));
    HADAMARD #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_HADAMARD0 (
        .clk          (CLK),
        .rst          (RST),
        .start        (rdy3),
        .input_real   (dr3),
        .input_imag   (di3),
        .twiddle_real (tr0),
        .twiddle_imag (ti0),
        .output_real  (dr4),
        .output_imag  (di4),
        .hadamard_done(rdy4)
    );
    wire [nb*4-1:0] dr5,di5,dr6,di6;
    wire rdy5;

    commutator4 #(.stage(2)) u0_commutator4_real(
        .clk(CLK), .reset_n(RST), .start(rdy4), .input_data(dr4), .output_data(dr5), .done(rdy5)
    );
    commutator4 #(.stage(2)) u0_commutator4_imag(
        .clk(CLK), .reset_n(RST), .start(rdy4), .input_data(di4), .output_data(di5), .done()
    );

    // PA2SE U_PA2SE_0(.CLK(CLK) , .RST(RST) , .START(rdy4) , .DR(dr4) , .DI(di4), .OR(dr5) , .OI(di5));
    // BUFRAM32C1 #(.nb(nb)) U_BUF2(.CLK(CLK), .RST(RST), .ED(1'b1),	.START(rdy4), .DR(dr5), .DI(di5), .RDY(rdy5), .DOR(dr6), .DOI(di6));


    // //STAGE2
    // wire [nb*4-1:0] dr7,di7;
    // wire rdy6;
    // SE2PA U_SE2PA_1(.CLK(CLK) , .RST(RST) , .START(rdy5) , .DR(dr6) , .DI(di6) , .OR(dr7) , .OI(di7) , .RDY(rdy6));


    // wire [nb*4-1:0] dr8,di8,dr9,di9;
    // wire rdy7;
    // GEMM #(
    //     .expWidth   (`EXPWIDTH),
    //     .sigWidth   (`SIGWIDTH),
    //     .formatWidth(`SFPWIDTH),
    //     .low_expand (`LOW_EXPAND)
    // ) U_GEMM1 (
    //     .clk        (CLK),
    //     .rst        (RST),
    //     .start      (rdy6),
    //     .control    (1'b1),
    //     .input_real (dr7),
    //     .input_imag (di7),
    //     .output_real(dr8),
    //     .output_imag(di8),
    //     .ready      (rdy7)
    // );
    // wire [nb*4-1:0] tr1,ti1;
    // wire rdy8;
    // WROM32 U_WROM1(.CLK(CLK) , .RST(RST) , .STAGE(1'b1) , .START(rdy6) , .OR(tr1) , .OI(ti1));
    // HADAMARD #(
    //     .expWidth   (`EXPWIDTH),
    //     .sigWidth   (`SIGWIDTH),
    //     .formatWidth(`SFPWIDTH),
    //     .low_expand (`LOW_EXPAND)
    // ) U_HADAMARD1 (
    //     .clk          (CLK),
    //     .rst          (RST),
    //     .start        (rdy7),
    //     .input_real   (dr8),
    //     .input_imag   (di8),
    //     .twiddle_real (tr1),
    //     .twiddle_imag (ti1),
    //     .output_real  (dr9),
    //     .output_imag  (di9),
    //     .hadamard_done(rdy8)
    // );
    // wire [nb-1:0] dr10,di10,dr11,di11;
    // wire rdy9;
    // PA2SE U_PA2SE_1(.CLK(CLK) , .RST(RST) , .START(rdy8) , .DR(dr9) , .DI(di9), .OR(dr10) , .OI(di10));
    // BUFRAM32C1 #(.nb(nb),.INV_ADDR(1)) U_BUF3(.CLK(CLK), .RST(RST), .ED(1'b1),	.START(rdy8), .DR(dr10), .DI(di10), .RDY(rdy9), .DOR(dr11), .DOI(di11));

    // wire [nb*4-1:0] dr12,di12;
    // wire rdy10;
    // SE2PA U_SE2PA_2(.CLK(CLK), .RST(RST) , .START(rdy9) , .DR(dr11) , .DI(di11), .OR(dr12) , .OI(di12) , .RDY(rdy10));

    // wire [nb*4-1:0] dr13,di13;
    // wire rdy11;
    // GEMM #(
    //     .expWidth   (`EXPWIDTH),
    //     .sigWidth   (`SIGWIDTH),
    //     .formatWidth(`SFPWIDTH),
    //     .low_expand (`LOW_EXPAND)
    // ) U_GEMM2 (
    //     .clk        (CLK),
    //     .rst        (RST),
    //     .start      (rdy10),
    //     .control    (1'b0),
    //     .input_real (dr12),
    //     .input_imag (di12),
    //     .output_real(dr13),
    //     .output_imag(di13),
    //     .ready      (rdy11)
    // );
    // wire [nb-1:0] dr14,di14;
    // wire rdy12;
    // PA2SE U_PA2SE_2(.CLK(CLK) , .RST(RST) , .START(rdy11) , .DR(dr13) , .DI(di13), .OR(dr14) , .OI(di14) , .RDY(rdy12));


    // wire [nb-1:0] dr15 , di15;
    // wire rdy13;
    // BUFRAM32C1 #(.nb(nb)) U_BUF4(.CLK(CLK), .RST(RST), .ED(1'b1),	.START(rdy11), .DR(dr14), .DI(di14), .RDY(rdy13), .DOR(OR), .DOI(OI));
  
endmodule