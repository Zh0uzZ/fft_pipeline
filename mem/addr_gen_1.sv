module addr_gen_1 #(
    parameter AddrWidth   = 7,
    parameter type sfp_t  = logic [`SFP_WIDTH-1:0],
    parameter type addr_t = logic [AddrWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,

//stage 2
    input logic start_i,

    output logic start_fft_o
    output logic  [3:0] wen_o,
    output logic  [1:0] cs_o,
    output addr_t [3:0] addr_gen_o,
    output logic stage2
);

parameter logic [2:0] index [8] = {3'b000 , 3'b100 , 3'b001 , 3'b101 , 3'b010 , 3'b110 , 3'b011 , 3'b111};

addr_t [3:0] addr_gen_d;
logic  [3:0] wen_d;
logic  [AddrWidth-1:0] count , count_d;
logic  start_fft_d;

logic [1:0] msbs , msbs_d;

logic stage1 , stage1_d;

//stage 1 store all data in 4 sram
always_comb begin
    wen_d = (addr_gen_o[0]<={(AddrWidth){1'b1}}) ? 4'b0001 : 4'b0000;
    start_fft_d = (addr_gen_o[0]!={AddrWidth{1'b1}}) ? 1'b1 : 1'b0;
    stage1_d    = (addr_gen_o[0]<={(AddrWidth+1){1'b1}}) ? 1'b1 : 1'b0;

    //address
    count_d <= (count != (AddrWidth{1'b1})) ? count + 1 : count;
    for(int unsigned i = 0; i < 4; i++) begin
        addr_gen_d[i] = {count[AddrWidth-1-:2] , index[count[2:0]]};
    end

    //wen && cs
    unique case(count[AddrWidth-1-:2])
        2'b00: wen_d = 4'b0001 ;
        2'b01: wen_d = 4'b0010 ;
        2'b10: wen_d = 4'b0100 ;
        2'b11: wen_d = 4'b1000 ;
    endcase
    cs_q = count[AddrWidth-1-:2];

end




always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        wen_o <=4'b0000;
        for(int unsigned i = 0; i < 4; i++) begin
            addr_gen_o[i] <= {AddrWidth{1'b0}};
        end
        count <= {AddrWidth{1'b0}};
    end else begin
        if(start_i) begin
            stage1 <= 1'b1;
            wen_o <= 4'h0;
            for(int unsigned i = 0; i < 4; i++) begin
                addr_gen_o[i] <= {AddrWidth{1'b0}};
            end
            count <= {{AddrWidth}{1'b0}};
        end else begin
            wen_o <= wen_d;
            for(int unsigned i = 0; i < 4; i++) begin
                addr_gen_o[i] <= addr_gen_d[i];
            end
            start_fft_o <= start_fft_d;
            stage1 <= stage1_d;
            count <= count_d;
        end
    end
end


endmodule