`timescale 1ns/1ns
module sram_tb;

parameter DataWidth = 32'd10;
parameter AddrWidth = 32'd3;
parameter Latency = 32'd1;
parameter NumPorts= 32'd2;
parameter SimInit = "zeros";


logic rst_ni;
logic [NumPorts-1:0] clk_i , wen_i , cs_i;
logic [NumPorts-1:0] [AddrWidth-1:0] addr_i;
logic [NumPorts-1:0] [DataWidth-1:0] wdata_i;
logic [NumPorts-1:0] [DataWidth-1:0] rdata_o;

always begin
    #5
    clk_i[0] = ~clk_i[0];
    clk_i[1] = ~clk_i[1];
    end

initial begin
    for(int i = 0; i < NumPorts; i++) begin
        clk_i[i] = 0;
    end
        rst_ni = 1;
    #20 rst_ni = 0;
    #20 rst_ni = 1;
    #20//同步写0-15，port1写1，port2写2
    wen_i = 2'b01;
    addr_i[0] = 0;
    wdata_i = {{0},{0}};
    repeat(15) begin
        #20 addr_i[0] = addr_i[0]+1'b1;
        wdata_i[0] = wdata_i[0] + 1;
    end

    addr_i[1] = 20;
    repeat(15) begin
        #20 addr_i[1] = addr_i[1]+1'b1;
        wdata_i[1] = wdata_i[1] + 1;
    end
    wen_i = 2'b00;
    addr_i[0] = 0;
    repeat(15) begin
        #20 addr_i[0] = addr_i[0]+1'b1;
        wdata_i[0] = wdata_i[0] + 1;
    end

    addr_i[1] = 20;
    repeat(15) begin
        #20 addr_i[1] = addr_i[1]+1'b1;
        wdata_i[1] = wdata_i[1] + 1;
    end
    // we1 = 1'b0;
    // we2 = 1'b0;
    // a1 = 11'b0000;
    // a2 = 11'b0000;
    // repeat(15) begin
    //     #20 a1 = a1+1'b1;
    //     din1 = 1'b1;
    //     a2 = a2+1'b1;
    //     din2 = 2'd2;
    // end
end

sram #(
    .AddrWidth(AddrWidth),
    .DataWidth(DataWidth),
    .Latency(Latency),
    .NumPorts(NumPorts),
    .SimInit(SimInit)
) u_sram(
    .clk_i,
    .cs_i({{1'b1} , {1'b1}}),
    .wen_i,
    .addr_i,
    .wdata_i,
    .rst_ni,
    .rdata_o
);

endmodule