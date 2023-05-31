`define Simulation
`undef Simulation
module sram_sp #(
    parameter int unsigned AddrWidth = 32'd10,
    parameter int unsigned DataWidth = 32'd9,
    parameter              SimInit   = "none"
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

localparam int unsigned NumWords = (1<<AddrWidth)-1;

//memory array
(*ram_style = "block"*)logic [DataWidth-1:0] sram_array [NumWords:0];

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


//write flip-flop
`ifdef Simulation
generate
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            for (int unsigned i = 0; i <= NumWords; i++) begin
                sram_array[i] <= init_val[i];
                rdata_o       <= {DataWidth{1'b0}};
            end
        end else begin
            if(wen_i) begin
                sram_array[addr_i[1]] <= wdata_i;
            end
            rdata_o <= sram_array[addr_i[0]];
        end
    end
endgenerate
`else
generate
    always_ff @(posedge clk_i) begin
        if(wen_i) begin
            sram_array[addr_i[1]] <= wdata_i;
        end
        rdata_o <= sram_array[addr_i[0]];
    end
endgenerate
`endif

endmodule