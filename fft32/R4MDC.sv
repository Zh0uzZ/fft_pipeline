//multi-path delay commutator (MDC)
//Radix-4
`include "../include/parameter.vh"
module R4MDC #(  //4736 LUT     2634FF
    parameter type sfp_t = logic [`SFP_WIDTH-1 : 0]
) (
    input logic clk_i,
    input logic rst_ni,
    input logic start_mdc_i,
    input sfp_t [3:0] dr_mdc_i,
    input sfp_t [3:0] di_mdc_i,

    output sfp_t [3:0] dr_mdc_o,
    output sfp_t [3:0] di_mdc_o,
    output logic rdy_mdc_o
);

parameter nb = `SFP_WIDTH;
//every twiddle factor rom or delay commutator start signal generate
    logic [5:0] count_start_reg;
    logic [5:0] count_start;
    logic rdy1 , rdy2 , rdy3 , rdy4 , rdy5;

    //STAGE 1
    logic [nb*4-1:0] dr1,di1,dr2,di2,dr3,di3;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM0 (
        .clk        (clk_i),
        .rst        (rst_ni),
        .start      (start_mdc_i),
        .control    (1'b1),
        .input_real ({{dr_mdc_i[3]},{dr_mdc_i[2]},{dr_mdc_i[1]},{dr_mdc_i[0]}}),
        .input_imag ({{di_mdc_i[3]},{di_mdc_i[2]},{di_mdc_i[1]},{di_mdc_i[0]}}),
        .output_real(dr1),
        .output_imag(di1),
        .ready(rdy1)
    );
    logic [nb*4-1:0] tr0,ti0;
    WROM32_MDC U_WROM0(.CLK(clk_i) , .RST(rst_ni) , .STAGE(1'b0) , .START(rdy1) , .OR(tr0) , .OI(ti0));
    HADAMARD #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_HADAMARD0 (
        .clk          (clk_i),
        .rst          (rst_ni),
        .start        (rdy1),
        .input_real   (dr1),
        .input_imag   (di1),
        .twiddle_real (tr0),
        .twiddle_imag (ti0),
        .output_real  (dr2),
        .output_imag  (di2),
        .hadamard_done(rdy2)
    );
    commutator4 #(.stage(2)) u0_commutator4_real(
        .clk(clk_i), .reset_n(rst_ni), .start(rdy2), .input_data(dr2), .output_data(dr3), .done(rdy3)
    );
    commutator4 #(.stage(2)) u0_commutator4_imag(
        .clk(clk_i), .reset_n(rst_ni), .start(rdy2), .input_data(di2), .output_data(di3), .done()
    );

    //STAGE2

    logic [nb*4-1:0] dr4,di4,dr5,di5,dr6,di6;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM1 (
        .clk        (clk_i),
        .rst        (rst_ni),
        .start      (rdy3),
        .control    (1'b1),
        .input_real (dr3),
        .input_imag (di3),
        .output_real(dr4),
        .output_imag(di4),
        .ready      (rdy4)
    );
    logic [nb*4-1:0] tr1,ti1;
    WROM32_MDC U_WROM1(.CLK(clk_i) , .RST(rst_ni) , .STAGE(1'b1) , .START(rdy4) , .OR(tr1) , .OI(ti1));
    HADAMARD #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_HADAMARD1 (
        .clk          (clk_i),
        .rst          (rst_ni),
        .start        (rdy4),
        .input_real   (dr4),
        .input_imag   (di4),
        .twiddle_real (tr1),
        .twiddle_imag (ti1),
        .output_real  (dr5),
        .output_imag  (di5),
        .hadamard_done(rdy5)
    );

    logic rdy6;
    commutator2 #(.stage(1)) u1_commutator2_real(
        .clk(clk_i), .reset_n(rst_ni), .start(rdy5), .input_data(dr5), .output_data(dr6),.done(rdy6)
    );
    commutator2 #(.stage(1)) u1_commutator2_imag(
        .clk(clk_i), .reset_n(rst_ni), .start(rdy5), .input_data(di5), .output_data(di6)
    );

    //STAGE 3

    logic [nb*4-1:0] dr7,di7,dr8,di8;
    GEMM #(
        .expWidth   (`EXPWIDTH),
        .sigWidth   (`SIGWIDTH),
        .formatWidth(`SFPWIDTH),
        .low_expand (`LOW_EXPAND)
    ) U_GEMM2 (
        .clk        (clk_i),
        .rst        (rst_ni),
        .start      (rdy6),
        .control    (1'b0),
        .input_real (dr6),
        .input_imag (di6),
        .output_real(dr7),
        .output_imag(di7),
        .ready      ()
    );
    assign {dr_mdc_o[3] , dr_mdc_o[2] , dr_mdc_o[1] , dr_mdc_o[0]} = dr7;
    assign {di_mdc_o[3] , di_mdc_o[2] , di_mdc_o[1] , di_mdc_o[0]} = di7;


    logic rdy_d;
    always_ff@(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            rdy_d <= 1'b0;
            rdy_mdc_o <= 1'b0;
        end else begin
            rdy_d     <= rdy6;
            rdy_mdc_o <= rdy_d;
        end
    end

    // out_commutator u_out_commutator_real(
    //     .clk(clk_i) , .reset_n(rst_ni) , .start(rdy5) , .input_data(dr7) , .output_data(dr8)
    // );
    // out_commutator u_out_commutator_imag(
    //     .clk(clk_i) , .reset_n(rst_ni) , .start(rdy5) , .input_data(di7) , .output_data(di8)
    // );

    // logic [nb-1:0] output_real [3:0];
    // logic [nb-1:0] output_imag [3:0];
    // genvar i;
    // generate
    //     for(i=0;i<4;i=i+1) begin : data_wire
    //         assign output_real[i] = dr8[nb*(4-i)-1:nb*(3-i)];
    //         assign output_imag[i] = di8[nb*(4-i)-1:nb*(3-i)];
    //     end
    // endgenerate

endmodule