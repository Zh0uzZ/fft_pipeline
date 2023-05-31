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
logic stage1_d , stage3_d;

logic  [4:0] wen_d;

logic[AddrWidth:0] addr_gen_reg , addr_gen_d;


//stage 1 store all data in 4 sram
always_comb begin
    start_fft_d = (addr_gen_reg=={1'b1 , {AddrWidth{1'b0}}}) ? 1'b1 : 1'b0;
    stage1_d    = (~stage3 && (addr_gen_reg<{(AddrWidth+1){1'b1}})) ? 1'b1 : 1'b0;

    addr_gen_d  = (addr_gen_reg!={(AddrWidth+1){1'b1}}) ? addr_gen_reg + 1 : addr_gen_reg;
    wen_d       = (addr_gen_reg<={(AddrWidth){1'b1}})   ? 5'b00001 : 5'b00000;
    addr_wr_o   = (!addr_gen_reg[AddrWidth]) ? addr_gen_reg[AddrWidth-1:0] : {(AddrWidth-1){1'b0}};
    addr_rd_o   = (addr_gen_reg[AddrWidth])  ? addr_gen_reg[AddrWidth-1:0] : {(AddrWidth-1){1'b0}};
end

always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        start_fft_o <= 1'b0;
        stage1      <= 1'b0;

        addr_gen_reg  <= {AddrWidth{1'b0}};
        wen_o       <= 5'b00000;
        ren_o       <= 8'h00;
    end else begin
        if(start_i) begin
            start_fft_o <= 1'b0;
            if(stage2) begin stage3 <= 1'b1; stage1 <= 1'b0; end
            else begin stage1 <= 1'b1; stage3 <= 1'b0; end

            addr_gen_reg <= {AddrWidth{1'b0}};
            wen_o <= 5'h01;
            ren_o <= 8'h01;
        end else begin
            start_fft_o <= start_fft_d;
            stage1 <= stage1_d;

            addr_gen_reg <= addr_gen_d;
            wen_o <= wen_d;
            ren_o <= 8'h01;
        end
    end
end


endmodule