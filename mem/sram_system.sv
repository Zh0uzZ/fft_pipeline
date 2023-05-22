`include "parameter.vh"
module sram_system #(
    parameter type sfp_t = logic [`SFP_WIDTH-1:0],
    parameter AddrLWidth = 7,
    parameter AddrSWidth = 5,
    parameter type addr_t_long = logic [AddrLWidth-1:0],
    parameter type addr_t_short = logic [AddrSWidth-1:0]
) (
    input logic clk_i,
    input logic [3:0] wen_i,
    input logic [1:0] di_en_i,
    input addr_t_long [3:0] addr_i,
    input sfp_t [3:0] dr_sram_i,
    input sfp_t [3:0] di_sram_i,
    input logic [1:0] do_en_i,

    output sfp_t [3:0] dr_sram_o,
    output sfp_t [3:0] di_sram_o
);

addr_t_long [3:0] addr_l_i;
addr_t_short [11:0] addr_s_i;

logic sfp_t [3:0] dr_i_long , di_i_long;
logic sfp_t [3:0] dr_o_long , di_o_long;
logic sfp_t [11:0] dr_i_short , di_i_short;
logic sfp_t [11:0] dr_o_short , di_o_short;

always_comb begin
    unique case(di_en_i)
        2'b00: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_l_i[i] = addr_i[i];
                dr_i_long[i] = dr_sram_i[i];
                di_i_long[i] = di_sram_i[i];
            end
        end
        2'b01: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_i[i] = addr_i[i][AddrSWidth-1:0];
                dr_i_short[i] = dr_sram_i[i];
                di_i_short[i] = di_sram_i[i];
            end
        end
        2'b10: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_i  [i+4] = addr_i[i][AddrSWidth-1:0];
                dr_i_short[i+4] = dr_sram_i[i];
                di_i_short[i+4] = di_sram_i[i];
            end
        end
        2'b11: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_i  [i+8] = addr_i[i][AddrSWidth-1:0];
                dr_i_short[i+8] = dr_sram_i[i];
                di_i_short[i+8] = di_sram_i[i];
            end
        end
    endcase
    unique case(do_en_i)
        2'b00: begin
            dr_sram_o[3] = dr_o_long[3]; dr_sram_o[2] = dr_o_long[2]; dr_sram_o[1] = dr_o_long[1]; dr_sram_o[0] = dr_o_long[0];
            di_sram_o[3] = di_o_long[3]; di_sram_o[2] = di_o_long[2]; di_sram_o[1] = di_o_long[1]; di_sram_o[0] = di_o_long[0];
        end
        2'b01: begin
            dr_sram_o[3] = dr_o_short[3]; dr_sram_o[2] = dr_o_short[2]; dr_sram_o[1] = dr_o_short[1]; dr_sram_o[0] = dr_o_short[0];
            di_sram_o[3] = di_o_short[3]; di_sram_o[2] = di_o_short[2]; di_sram_o[1] = di_o_short[1]; di_sram_o[0] = di_o_short[0];
        end
        2'b10: begin
            dr_sram_o[3] = dr_o_short[7]; dr_sram_o[2] = dr_o_short[6]; dr_sram_o[1] = dr_o_short[5]; dr_sram_o[0] = dr_o_short[4];
            di_sram_o[3] = di_o_short[7]; di_sram_o[2] = di_o_short[6]; di_sram_o[1] = di_o_short[5]; di_sram_o[0] = di_o_short[4];
        end
        2'b11: begin
            dr_sram_o[3] = dr_o_short[11]; dr_sram_o[2] = dr_o_short[10]; dr_sram_o[1] = dr_o_short[9]; dr_sram_o[0] = dr_o_short[8];
            di_sram_o[3] = di_o_short[11]; di_sram_o[2] = di_o_short[10]; di_sram_o[1] = di_o_short[9]; di_sram_o[0] = di_o_short[8];
        end
    endcase
end

sram_wrapper #(.AddrWidth(7)) r_sram0(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[0]),.wdata_i(dr_i_long[0]),.rdata_o(dr_o_long[0]));
sram_wrapper #(.AddrWidth(7)) r_sram1(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[1]),.wdata_i(dr_i_long[1]),.rdata_o(dr_o_long[1]));
sram_wrapper #(.AddrWidth(7)) r_sram2(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[2]),.wdata_i(dr_i_long[2]),.rdata_o(dr_o_long[2]));
sram_wrapper #(.AddrWidth(7)) r_sram3(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[3]),.wdata_i(dr_i_long[3]),.rdata_o(dr_o_long[3]));
sram_wrapper #(.AddrWidth(7)) i_sram0(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[0]),.wdata_i(di_i_long[0]),.rdata_o(di_o_long[0]));
sram_wrapper #(.AddrWidth(7)) i_sram1(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[1]),.wdata_i(di_i_long[1]),.rdata_o(di_o_long[1]));
sram_wrapper #(.AddrWidth(7)) i_sram2(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[2]),.wdata_i(di_i_long[2]),.rdata_o(di_o_long[2]));
sram_wrapper #(.AddrWidth(7)) i_sram3(.clk_i,.cs_i(1'b1),.wen_i(wen_i[0]),.addr_i(addr_l_i[3]),.wdata_i(di_i_long[3]),.rdata_o(di_o_long[3]));


sram_wrapper #(.AddrWidth(5)) r_sram4(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[0]),.wdata_i(dr_i_short[0]),.rdata_o(dr_o_short[0]));
sram_wrapper #(.AddrWidth(5)) r_sram5(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[1]),.wdata_i(dr_i_short[1]),.rdata_o(dr_o_short[1]));
sram_wrapper #(.AddrWidth(5)) r_sram6(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[2]),.wdata_i(dr_i_short[2]),.rdata_o(dr_o_short[2]));
sram_wrapper #(.AddrWidth(5)) r_sram7(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[3]),.wdata_i(dr_i_short[3]),.rdata_o(dr_o_short[3]));
sram_wrapper #(.AddrWidth(5)) i_sram4(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[0]),.wdata_i(di_i_short[0]),.rdata_o(di_o_short[0]));
sram_wrapper #(.AddrWidth(5)) i_sram5(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[1]),.wdata_i(di_i_short[1]),.rdata_o(di_o_short[1]));
sram_wrapper #(.AddrWidth(5)) i_sram6(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[2]),.wdata_i(di_i_short[2]),.rdata_o(di_o_short[2]));
sram_wrapper #(.AddrWidth(5)) i_sram7(.clk_i,.cs_i(1'b1),.wen_i(wen_i[1]),.addr_i(addr_s_i[3]),.wdata_i(di_i_short[3]),.rdata_o(di_o_short[3]));


sram_wrapper #(.AddrWidth(5)) r_sram8 (.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[4]),.wdata_i(dr_i_short[4]),.rdata_o(dr_o_short[4]));
sram_wrapper #(.AddrWidth(5)) r_sram9 (.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[5]),.wdata_i(dr_i_short[5]),.rdata_o(dr_o_short[5]));
sram_wrapper #(.AddrWidth(5)) r_sram10(.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[6]),.wdata_i(dr_i_short[6]),.rdata_o(dr_o_short[6]));
sram_wrapper #(.AddrWidth(5)) r_sram11(.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[7]),.wdata_i(dr_i_short[7]),.rdata_o(dr_o_short[7]));
sram_wrapper #(.AddrWidth(5)) i_sram8 (.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[4]),.wdata_i(di_i_short[4]),.rdata_o(di_o_short[4]));
sram_wrapper #(.AddrWidth(5)) i_sram9 (.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[5]),.wdata_i(di_i_short[5]),.rdata_o(di_o_short[5]));
sram_wrapper #(.AddrWidth(5)) i_sram10(.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[6]),.wdata_i(di_i_short[6]),.rdata_o(di_o_short[6]));
sram_wrapper #(.AddrWidth(5)) i_sram11(.clk_i,.cs_i(1'b1),.wen_i(wen_i[2]),.addr_i(addr_s_i[7]),.wdata_i(di_i_short[7]),.rdata_o(di_o_short[7]));


sram_wrapper #(.AddrWidth(5)) r_sram12(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[8] ),.wdata_i(dr_i_short[8] ),.rdata_o(dr_o_short[8] ));
sram_wrapper #(.AddrWidth(5)) r_sram13(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[9] ),.wdata_i(dr_i_short[9] ),.rdata_o(dr_o_short[9] ));
sram_wrapper #(.AddrWidth(5)) r_sram14(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[10]),.wdata_i(dr_i_short[10]),.rdata_o(dr_o_short[10]));
sram_wrapper #(.AddrWidth(5)) r_sram15(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[11]),.wdata_i(dr_i_short[11]),.rdata_o(dr_o_short[11]));
sram_wrapper #(.AddrWidth(5)) i_sram12(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[8] ),.wdata_i(di_i_short[8] ),.rdata_o(di_o_short[8] ));
sram_wrapper #(.AddrWidth(5)) i_sram13(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[9] ),.wdata_i(di_i_short[9] ),.rdata_o(di_o_short[9] ));
sram_wrapper #(.AddrWidth(5)) i_sram14(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[10]),.wdata_i(di_i_short[10]),.rdata_o(di_o_short[10]));
sram_wrapper #(.AddrWidth(5)) i_sram15(.clk_i,.cs_i(1'b1),.wen_i(wen_i[3]),.addr_i(addr_s_i[11]),.wdata_i(di_i_short[11]),.rdata_o(di_o_short[11]));

endmodule