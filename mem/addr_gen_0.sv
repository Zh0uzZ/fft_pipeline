module addr_gen_0 #(
    parameter AddrWidth = 7,
    parameter type sfp_t  = logic [`SFP_WIDTH-1:0],
    parameter type addr_t = logic [AddrWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,
    input logic start_i,

    output logic  start_fft_o,
    output logic  stage1,
    input  logic  stage2,
    output logic  stage3,

    output logic  [4:0] wen_o,
    output logic  [7:0] ren_o,
    output addr_t addr_wr_o,
    output addr_t addr_rd_o
);

logic  start_fft_d;
logic stage_d;
logic stage_flag;

logic  [4:0] wen_d;

logic[AddrWidth+1:0] count_q , count_d;


//stage 1 store all data in 4 sram
always_comb begin
    start_fft_d = (count_q=={1'b1 , {AddrWidth{1'b0}}}) ? 1'b1 : 1'b0;
    stage_d    = (count_q<={(AddrWidth+1){1'b1}})? 1'b1 : 1'b0;

    count_d  = (count_q!={(AddrWidth+2){1'b1}}) ? count_q + 1 : count_q;
    wen_d       = (count_q<{(AddrWidth){1'b1}})   ? 5'b00001 : 5'b00000;
    addr_wr_o   = (count_q[AddrWidth])  ? {(AddrWidth-1){1'b0}}  : count_q[AddrWidth-1:0] ;
    addr_rd_o   = (count_q[AddrWidth])  ? count_q[AddrWidth-1:0] : {(AddrWidth-1){1'b0}};
end

always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        start_fft_o <= 1'b0;
        stage1      <= 1'b0;
        stage3      <= 1'b0;
        stage_flag  <= 1'b0;

        count_q  <= {(AddrWidth+2){1'b1}};
        wen_o       <= 5'b00000;
        ren_o       <= 8'h00;
    end else begin
        if(start_i) begin
            start_fft_o <= 1'b0;
            if(stage2) begin stage3 <= 1'b1; stage1 <= 1'b0; stage_flag <= 1'b1; end
            else begin stage1 <= 1'b1; stage3 <= 1'b0; stage_flag <= 1'b0; end

            count_q <= {(AddrWidth+2){1'b0}};
            wen_o <= 5'h01;
            ren_o <= 8'h01;
        end else begin
            start_fft_o <= start_fft_d;
            stage1 <= stage_flag ? 1'b0 : stage_d;
            stage3 <= stage_flag ? stage_d : 1'b0;

            count_q <= count_d;
            wen_o <= wen_d;
            ren_o <= 8'h01;
        end
    end
end


endmodule