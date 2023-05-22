module sram_wrapper #(
    parameter AddrWidth = 32'd2,
    parameter DataWidth = 32'd9,
    parameter NumPorts  = 32'd1
) (
    input  logic [NumPorts-1:0] clk_i,
    input  logic [NumPorts-1:0] cs_i ,
    input  logic [NumPorts-1:0] wen_i,
    input  logic [NumPorts-1:0] [AddrWidth-1:0] addr_i ,
    input  logic [NumPorts-1:0] [DataWidth-1:0] wdata_i,

`ifdef Simulation
  	input  logic rst_ni,
`endif

    output logic [NumPorts-1:0] [DataWidth-1:0] rdata_o
);

parameter Latency = 1'd1;
parameter SimInit = "zeros";
sram #(
    .AddrWidth(AddrWidth),
    .DataWidth(DataWidth),
    .Latency(Latency),
    .NumPorts(NumPorts),
    .SimInit(SimInit)
) u_sram(
    .clk_i,
    .cs_i,
    .wen_i,
    .addr_i,
    .wdata_i,
    .rst_ni,
    .rdata_o
);


endmodule