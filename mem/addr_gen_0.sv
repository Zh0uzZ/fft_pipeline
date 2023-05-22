module addr_gen_0 #(
    parameter AddrWidth = 7,
    parameter type sfp_t  = logic [`SFP_WIDTH-1:0],
    parameter type addr_t = logic [AddrWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,

//stage 1
    input logic start_i,

    output logic  start_fft_o
    output logic  [3:0] wen_o,
    output addr_t [3:0] addr_gen_o,
    output logic  stage1
);

addr_t [3:0] addr_gen_d;
logic  [3:0] wen_d;
logic  start_d;

logic stage1 , stage1_d;

//stage 1 store all data in 4 sram
always_comb begin
    for(int unsigned i = 0; i < 4; i++) begin
        addr_gen_d[i] = (addr_gen_o[0]!={(AddrWidth+1){1'b1}}) ? addr_gen_o[i] + 1 : addr_gen_o[i];
    end
    wen_d = (addr_gen_o[0]<={(AddrWidth){1'b1}}) ? 4'b0001 : 4'b0000;
    start_d = (addr_gen_o[0]!={AddrWidth{1'b1}}) ? 1'b1 : 1'b0;
    stage1_d    = (addr_gen_o[0]<={(AddrWidth+1){1'b1}}) ? 1'b1 : 1'b0;
end

always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        wen_o <=4'b0000;
        for(int unsigned i = 0; i < 4; i++) begin
            addr_gen_o[i] <= {AddrWidth{1'b0}};
        end
    end else begin
        if(start_i) begin
            stage1 <= 1'b1;
            wen_o <= 4'h0;
            for(int unsigned i = 0; i < 4; i++) begin
                addr_gen_o[i] <= {AddrWidth{1'b0}};
            end
        end else begin
            wen_o <= wen_d;
            for(int unsigned i = 0; i < 4; i++) begin
                addr_gen_o[i] <= addr_gen_d[i];
            end
            start_fft_o <= start_d;
            stage1 <= stage1_d;
        end
    end
end


endmodule