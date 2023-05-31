`define Simulation
// `undef Simulation
module sram #(
    parameter int unsigned AddrWidth = 32'd10,
    parameter int unsigned DataWidth = 32'd9,
    parameter int unsigned Latency   = 32'd1,
    parameter int unsigned NumPorts  = 32'd1,
    parameter              SimInit   = "none"
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

localparam int unsigned NumWords = (1<<AddrWidth)-1;

//memory array
(*ram_style = "distributed"*)logic [DataWidth-1:0] sram_array [NumWords:0];

//initial sram value
`ifdef Simulation
    logic [DataWidth-1:0] init_val [NumWords:0];
    initial begin : initial_sram
        for(int unsigned i = 0 ; i <= NumWords ; i++) begin
            for(int unsigned j = 0; j <= DataWidth-1; j++) begin
                case (SimInit)
                    "zeros": init_val[i][j] = 1'b0;
                    "ones":   init_val[i][j] = 1'b1;
                    "random": init_val[i][j] = $urandom();
                    default: init_val[i][j] = 1'bx;
                endcase
            end
        end
    end
`endif


//read latency data
logic [NumPorts-1:0][AddrWidth-1:0] raddr_q;
logic [NumPorts-1:0][Latency-1:0][DataWidth-1:0] rdata_q , rdata_d;
if(Latency == 32'd0) begin : no_read_latency_gen
    for(genvar k= 0; k<NumPorts ; k++) begin
        assign rdata_o = (cs_i[k] && !wen_i[k]) ? sram_array[addr_i[k]] : sram_array[raddr_q];
    end
end else begin
    always_comb begin : read_latency_gen
        for(int unsigned i = 0; i < NumPorts; i++) begin
            rdata_o[i] = rdata_q[i][0];
            for(int unsigned j = 0; j < Latency-1; j++) begin
                rdata_d[i][j] = rdata_q[i][j+1];
            end
            rdata_d[i][Latency-1] = (cs_i[i] && !wen_i) ? sram_array[addr_i[i]] : sram_array[raddr_q[i]] ;
        end
    end
end


//write flip-flop
`ifdef Simulation
generate
     for(genvar k=0;k<NumPorts;k++) begin: sram_write_gen
        always_ff @(posedge clk_i[k] or negedge rst_ni) begin
            if(!rst_ni) begin
                for (int unsigned i = 0; i <= NumWords; i++) begin
                    sram_array[i] <= init_val[i];
                    for(int unsigned j = 0; j < Latency ; j++) begin
                        rdata_q[i][j] <= {DataWidth{1'b0}};
                    end
                end
            end else begin
                //read latency flip-flop
                raddr_q[k] <= addr_i[k];
                for (int unsigned i = 0; i < NumPorts; i++) begin
                    if (Latency != 0) begin
                      for (int unsigned j = 0; j < Latency; j++) begin
                        rdata_q[i][j] <= rdata_d[i][j];
                      end
                    end
                end

                //write value in selected address
                if(wen_i[k] && cs_i[k]) begin
                    sram_array[addr_i[k]] <= wdata_i[k];
                end
            end
        end
    end
endgenerate
`else
generate
    for(genvar k=0;k<NumPorts;k++) begin: sram_write_gen
        always_ff @(posedge clk_i[k]) begin
            //read latency flip-flop
            raddr_q[k] <= addr_i[k];
            for (int unsigned i = 0; i < NumPorts; i++) begin
                if (Latency != 0) begin
                  for (int unsigned j = 0; j < Latency; j++) begin
                    rdata_q[i][j] <= rdata_d[i][j];
                  end
                end
            end

            if(wen_i[k] && cs_i[k]) begin
                sram_array[addr_i[k]] <= wdata_i[k];
            end

        end
    end
endgenerate
`endif

endmodule