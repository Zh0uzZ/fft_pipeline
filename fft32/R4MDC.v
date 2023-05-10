//multi-path delay commutator (MDC)
//Radix-4
`include "parameter.vh"
module R4MDC(CLK,RST,START,DR,DI,OR,OI,RDY);
`FFTsfpw
    input CLK,RST,START;
    input  [nb*4-1:0] DR,DI;
    output [nb*4-1:0] OR,OI;
    output RDY;

//every twiddle factor rom or delay commutator start signal generate
    reg [5:0] count_start_reg;
    wire [5:0] count_start;
    wire rdy1 , rdy2 , rdy3 , rdy4 , rdy5;
    always@(posedge CLK) begin
        if(START)
            count_start_reg <= 0;
        else begin
            count_start_reg <= count_start;
        end
    end
    assign count_start = (count_start_reg != 6'b100111) ? count_start_reg + 1 : count_start_reg;
    assign rdy1 = (count_start_reg == 3);
    assign rdy2 = (count_start_reg == 7);
    assign rdy3 = (count_start_reg == 17);
    assign rdy4 = (count_start_reg == 21);
    assign rdy5 = (count_start_reg == 26);


    //STAGE 1
    wire [nb*4-1:0] dr1,di1,dr2,di2,dr3,di3;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM0 (
        .clk        (CLK),
        .rst        (RST),
        .start      (START),
        .control    (1'b1),
        .input_real (DR),
        .input_imag (DI),
        .output_real(dr1),
        .output_imag(di1)
    );
    wire [nb*4-1:0] tr0,ti0;
    WROM32_MDC U_WROM0(.CLK(CLK) , .RST(RST) , .STAGE(1'b0) , .START(rdy1) , .OR(tr0) , .OI(ti0));
    HADAMARD #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_HADAMARD0 (
        .clk          (CLK),
        .rst          (RST),
        .input_real   (dr1),
        .input_imag   (di1),
        .twiddle_real (tr0),
        .twiddle_imag (ti0),
        .output_real  (dr2),
        .output_imag  (di2)
    );
    commutator4 #(.stage(2)) u0_commutator4_real(
        .clk(CLK), .reset_n(RST), .start(rdy2), .input_data(dr2), .output_data(dr3), .done()
    );
    commutator4 #(.stage(2)) u0_commutator4_imag(
        .clk(CLK), .reset_n(RST), .start(rdy2), .input_data(di2), .output_data(di3), .done()
    );

    //STAGE2

    wire [nb*4-1:0] dr4,di4,dr5,di5,dr6,di6;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM1 (
        .clk        (CLK),
        .rst        (RST),
        .control    (1'b1),
        .input_real (dr3),
        .input_imag (di3),
        .output_real(dr4),
        .output_imag(di4)
    );
    wire [nb*4-1:0] tr1,ti1;
    WROM32_MDC U_WROM1(.CLK(CLK) , .RST(RST) , .STAGE(1'b1) , .START(rdy3) , .OR(tr1) , .OI(ti1));
    HADAMARD #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_HADAMARD1 (
        .clk          (CLK),
        .rst          (RST),
        .input_real   (dr4),
        .input_imag   (di4),
        .twiddle_real (tr1),
        .twiddle_imag (ti1),
        .output_real  (dr5),
        .output_imag  (di5)
    );

    commutator2 #(.stage(1)) u1_commutator2_real(
        .clk(CLK), .reset_n(RST), .start(rdy4), .input_data(dr5), .output_data(dr6)
    );
    commutator2 #(.stage(1)) u1_commutator2_imag(
        .clk(CLK), .reset_n(RST), .start(rdy4), .input_data(di5), .output_data(di6)
    );

    //STAGE 3

    wire [nb*4-1:0] dr7,di7,dr8,di8;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM2 (
        .clk        (CLK),
        .rst        (RST),
        .control    (1'b0),
        .input_real (dr6),
        .input_imag (di6),
        .output_real(dr7),
        .output_imag(di7)
    );

    out_commutator u_out_commutator_real(
        .clk(CLK) , .reset_n(RST) , .start(rdy5) , .input_data(dr7) , .output_data(dr8)
    );
    out_commutator u_out_commutator_imag(
        .clk(CLK) , .reset_n(RST) , .start(rdy5) , .input_data(di7) , .output_data(di8)
    );

    wire [nb-1:0] output_real [3:0];
    wire [nb-1:0] output_imag [3:0];
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : data_wire
            assign output_real[i] = dr8[nb*(4-i)-1:nb*(3-i)];
            assign output_imag[i] = di8[nb*(4-i)-1:nb*(3-i)];
        end
    endgenerate
  
endmodule