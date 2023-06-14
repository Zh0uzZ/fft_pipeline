module addr_gen_1 #(
    parameter AddrWidth   = 7,
    parameter type sfp_t  = logic [`SFP_WIDTH-1:0],
    parameter type addr_t = logic [AddrWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,
//stage 2
    input logic start_i,
    input logic stage1,

    output logic start_fft_o,
    output logic stage2,

    output logic  [4:0] wen_o,
    output logic  [7:0] ren_o,
    output addr_t addr_wr_o,
    output addr_t addr_rd_o
);

parameter logic [2:0] index [8] = {3'b000 , 3'b100 , 3'b001 , 3'b101 , 3'b010 , 3'b110 , 3'b011 , 3'b111};

logic  start_fft_d;
logic  stage2_d;


logic  [4:0] wen_d;
logic  [7:0] ren_d;

logic  [AddrWidth+1:0] count_q , count_d;



//stage 1 store all data in 4 sram
always_comb begin
    start_fft_d = ((count_q[AddrWidth-1:0]=={(AddrWidth){1'b1}})&stage2) ? 1'b1 : 1'b0;
    stage2_d    = (count_q<={(AddrWidth+1){1'b1}}) ? 1'b1 : 1'b0;

    //address
    count_d = (count_q != {(AddrWidth+2){1'b1}}) ? count_q + 1 : count_q;
    addr_wr_o = count_q[AddrWidth] ? {(AddrWidth-1){1'b0}} : { 2'b00 , count_q[3+:(AddrWidth-5)] , index[count_q[2:0]]};
    addr_rd_o = count_q[AddrWidth] ? {2'b00 , count_q[AddrWidth-3:0]} : {(AddrWidth-1){1'b0}} ;

    //wen && cs
    unique case(count_q[AddrWidth-:3])
        3'b000: begin wen_d = 5'b00001; end
        3'b001: begin wen_d = 5'b00010; end
        3'b010: begin wen_d = 5'b00100; end
        3'b011: begin wen_d = 5'b01000; end
        default : wen_d = 5'b00000;
    endcase
    ren_d = count_q[AddrWidth] ? (8'h10 << count_q[AddrWidth-1-:2]) : 8'h00 ;

    wen_o = wen_d;

end

always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        stage2 <= 1'b0;
        start_fft_o <= 1'b0;

        ren_o <= 0;
        count_q <= {(AddrWidth+2){1'b1}};
    end else begin
        if(start_i && stage1) begin
            ren_o <= 0;
            stage2 <= 1'b1;
            count_q <= {(AddrWidth+2){1'b0}};
        end else begin
            ren_o <= ren_d;
            start_fft_o <= start_fft_d;
            stage2 <= stage2_d;
            count_q <= count_d;
        end
    end
end
endmodule