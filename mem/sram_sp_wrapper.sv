`undef Simulation
module sram_sp_wrapper #(
    parameter AddrWidth = 32'd10,
    parameter DataWidth = 32'd9
) (
    input  logic clk_i,
    input  logic wen_i,
    input  logic [1:0] [AddrWidth-1:0] addr_i ,
    input  logic [DataWidth-1:0] wdata_i,

`ifdef Simulation
  	input  logic rst_ni,
`endif

    output logic [DataWidth-1:0] rdata_o
);

parameter Latency = 1'd1;
parameter SimInit = "zeros";
sram_sp #(
    .AddrWidth(AddrWidth),
    .DataWidth(DataWidth),
    .SimInit(SimInit)
) u_sram(
    .clk_i,
    .wen_i,
    .addr_i,
    .wdata_i,
`ifdef Simulation
    .rst_ni,
`endif
    .rdata_o
);


endmodule