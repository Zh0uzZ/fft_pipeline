module addr_gen_1 #(
    parameter AddrWidth   = 7,
    parameter type sfp_t  = logic [`SFP_WIDTH-1:0],
    parameter type addr_t = logic [AddrWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,
//stage 2
    input logic start_i,

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

logic  [AddrWidth:0] count , count_d;



//stage 1 store all data in 4 sram
always_comb begin
    start_fft_d = (count[AddrWidth-2:0]!={(AddrWidth-1){1'b1}}) ? 1'b1 : 1'b0;
    stage2_d    = (count<={(AddrWidth){1'b1}}) ? 1'b1 : 1'b0;


    //address
    count_d = (count != {(AddrWidth+1){1'b1}}) ? count + 1 : count;
    addr_wr_o = count[AddrWidth] ? {(AddrWidth-1){1'b0}} : {count[AddrWidth-1-:2] , index[count[2:0]]};
    addr_rd_o = count[AddrWidth] ? count[AddrWidth-3:0] : {(AddrWidth-1){1'b0}} ;

    //wen && cs
    unique case(count[AddrWidth-:3])
        3'b000: begin wen_d = 5'b00001; end
        3'b001: begin wen_d = 5'b00010; end
        3'b010: begin wen_d = 5'b00100; end
        3'b011: begin wen_d = 5'b01000; end
        default : wen_d = 5'b00000;
    endcase
    ren_d = count[AddrWidth] ? {(AddrWidth-1){1'b0}} : {1'b1 , {AddrWidth/2{1'b0}}}<<count[AddrWidth-:3] ;

end

always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        stage2 <= 1'b0;
        start_fft_o <= 1'b0;

        wen_o <= 5'b00000;
        ren_o <= 0;
        count <= {(AddrWidth+1){1'b1}};
    end else begin
        if(start_i) begin
            wen_o <= 5'b00000;
            ren_o <= 0;
            stage2 <= 1'b1;
            count <= {{AddrWidth}{1'b0}};
        end else begin
            wen_o <= wen_d;
            ren_o <= ren_d;
            start_fft_o <= start_fft_d;
            stage2 <= stage2_d;
            count <= count_d;
        end
    end
end
endmodule