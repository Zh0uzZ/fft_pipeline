`include "../include/parameter.vh"
module sram_system_dp #(
    parameter AddrLWidth = 7,
    parameter AddrSWidth = 5
) (
    input logic clk_i,
    input logic [4:0] wen_i,
    input sram_pkg::addr_t_long addr_wr_i,
    input sram_pkg::sfp_t [3:0] dr_sram_i,
    input sram_pkg::sfp_t [3:0] di_sram_i,

    input logic [7:0] ren_i,
    input sram_pkg::addr_t_long addr_rd_i,
    output sram_pkg::sfp_t [3:0] dr_sram_o,
    output sram_pkg::sfp_t [3:0] di_sram_o
);

import sram_pkg::*;

always_comb begin
    unique case(wen_i)
        5'b00001: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_l_wr_i[i] = addr_wr_i;
                dr_i_long[i]   = dr_sram_i[i];
                di_i_long[i]   = di_sram_i[i];
            end
            short_wr_reset1;
            short_wr_reset2;
            short_wr_reset3;
        end
        5'b00010: begin
            addr_s_wr_i[0] = addr_wr_i;
            for(int unsigned i = 1; i < 4; i++) begin
                addr_s_wr_i[i] = addr_wr_i[AddrSWidth-1:0];
                dr_i_short [i] = dr_sram_i[i];
                di_i_short [i] = di_sram_i[i];
            end
            long_wr_reset;
            short_wr_reset2;
            short_wr_reset3;
        end
        5'b00100: begin
            addr_s_wr_i[4] = addr_wr_i;
            for(int unsigned i = 1; i < 4; i++) begin
                addr_s_wr_i[i+4] = addr_wr_i[AddrSWidth-1:0];
                dr_i_short [i+4] = dr_sram_i[i];
                di_i_short [i+4] = di_sram_i[i];
            end
            long_wr_reset;
            short_wr_reset1;
            short_wr_reset3;
        end
        5'b01000: begin
            addr_s_wr_i[8] = addr_wr_i;
            for(int unsigned i = 1; i < 4; i++) begin
                addr_s_wr_i[i+8] = addr_wr_i[AddrSWidth-1:0];
                dr_i_short [i+8] = dr_sram_i[i];
                di_i_short [i+8] = di_sram_i[i];
            end
            long_wr_reset;
            short_wr_reset1;
            short_wr_reset2;
        end
        5'b10000: begin
            addr_l_wr_i[0] = addr_wr_i; addr_s_wr_i[0] = addr_wr_i; addr_s_wr_i[4] = addr_wr_i; addr_s_wr_i[8] = addr_wr_i;
            dr_i_long[0] = dr_sram_i[3]; dr_i_short[0] = dr_sram_i[2]; dr_i_short[4] = dr_sram_i[1]; dr_i_short[8] = dr_sram_i[0];
            di_i_long[0] = di_sram_i[3]; di_i_short[0] = di_sram_i[2]; di_i_short[4] = di_sram_i[1]; di_i_short[8] = di_sram_i[0];

             for(int unsigned i = 1; i < 4; i++) begin
                addr_l_wr_i[i] = 0; addr_s_wr_i[i] = 0; addr_s_wr_i[i+4] = 0; addr_s_wr_i[i+8] = 0;
                dr_i_long[i] = 0; dr_i_short[i] = 0; dr_i_short[i+4] = 0; dr_i_short[i+8] = 0;
                di_i_long[i] = 0; di_i_short[i] = 0; di_i_short[i+4] = 0; di_i_short[i+8] = 0;
            end
        end
        default : begin
            long_wr_reset; short_wr_reset1; short_wr_reset2; short_wr_reset3;
        end
    endcase

    unique case(ren_i)
        8'h01: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_l_rd_i[i]  = addr_rd_i;
                dr_sram_o[i] = dr_o_long[i];
                di_sram_o[i] = di_o_long[i];
            end
            row0_rd_reset;
        end
        8'h02: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_rd_i[i]  = addr_rd_i[AddrSWidth-1:0];
                dr_sram_o[i] = dr_o_short[i];
                di_sram_o[i] = di_o_short[i];
            end
            row1_rd_reset;
        end
        8'h04: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_rd_i[i+4]  = addr_rd_i[AddrSWidth-1:0];
                dr_sram_o[i] = dr_o_short[i+4];
                di_sram_o[i] = di_o_short[i+4];
            end
            row2_rd_reset;
        end
        8'h08: begin
            for(int unsigned i = 0; i < 4; i++) begin
                addr_s_rd_i[i+8]  = addr_rd_i[AddrSWidth-1:0];
                dr_sram_o[i] = dr_o_short[i+8];
                di_sram_o[i] = di_o_short[i+8];
            end
            row3_rd_reset;
        end
        8'h10: begin
            addr_l_rd_i[0] = addr_rd_i;  addr_s_rd_i[0] = addr_rd_i;   addr_s_rd_i[4] = addr_rd_i;   addr_s_rd_i[8] = addr_rd_i;
            dr_sram_o[3] = dr_o_long[0]; dr_sram_o[2] = dr_o_short[0]; dr_sram_o[1] = dr_o_short[4]; dr_sram_o[0] = dr_o_short[8];
            di_sram_o[3] = di_o_long[0]; di_sram_o[2] = di_o_short[0]; di_sram_o[1] = di_o_short[4]; di_sram_o[0] = di_o_short[8];

            column0_rd_reset;
        end
        8'h20: begin
            addr_l_rd_i[1] = addr_rd_i;  addr_s_rd_i[1] = addr_rd_i;   addr_s_rd_i[5] = addr_rd_i;   addr_s_rd_i[9] = addr_rd_i;
            dr_sram_o[3] = dr_o_long[1]; dr_sram_o[2] = dr_o_short[1]; dr_sram_o[1] = dr_o_short[5]; dr_sram_o[0] = dr_o_short[9];
            di_sram_o[3] = di_o_long[1]; di_sram_o[2] = di_o_short[1]; di_sram_o[1] = di_o_short[5]; di_sram_o[0] = di_o_short[9];

            column1_rd_reset;
        end
        8'h40: begin
            addr_l_rd_i[2] = addr_rd_i; addr_s_rd_i[2] = addr_rd_i; addr_s_rd_i[6] = addr_rd_i; addr_s_rd_i[10] = addr_rd_i;
            dr_sram_o[3] = dr_o_long[2]; dr_sram_o[2] = dr_o_short[2]; dr_sram_o[1] = dr_o_short[6]; dr_sram_o[0] = dr_o_short[10];
            di_sram_o[3] = di_o_long[2]; di_sram_o[2] = di_o_short[2]; di_sram_o[1] = di_o_short[6]; di_sram_o[0] = di_o_short[10];

            column2_rd_reset;
        end
        8'h80: begin
            addr_l_rd_i[3] = addr_rd_i; addr_s_rd_i[3] = addr_rd_i; addr_s_rd_i[7] = addr_rd_i; addr_s_rd_i[11] = addr_rd_i;
            dr_sram_o[3] = dr_o_long[3]; dr_sram_o[2] = dr_o_short[3]; dr_sram_o[1] = dr_o_short[7]; dr_sram_o[0] = dr_o_short[11];
            di_sram_o[3] = di_o_long[3]; di_sram_o[2] = di_o_short[3]; di_sram_o[1] = di_o_short[7]; di_sram_o[0] = di_o_short[11];

            column3_rd_reset;
        end
    endcase
end


sram_sp_wrapper #(.AddrWidth(7)) r_sram0(.clk_i, .wen_i({wen_i[0]|wen_i[4],ren_i[0]|ren_i[4]}),.addr_i({{addr_l_wr_i[0]},{addr_l_rd_i[0]}}),.wdata_i(dr_i_long[0]) ,.rdata_o(dr_o_long[0]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram0(.clk_i, .wen_i({wen_i[0]|wen_i[4],ren_i[0]|ren_i[4]}),.addr_i({{addr_l_wr_i[0]},{addr_l_rd_i[0]}}),.wdata_i(di_i_long[0]) ,.rdata_o(di_o_long[0]));
sram_sp_wrapper #(.AddrWidth(7)) r_sram1(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[5]}),.addr_i({{addr_l_wr_i[1]},{addr_l_rd_i[1]}}),.wdata_i(dr_i_long[1]) ,.rdata_o(dr_o_long[1]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram1(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[5]}),.addr_i({{addr_l_wr_i[1]},{addr_l_rd_i[1]}}),.wdata_i(di_i_long[1]) ,.rdata_o(di_o_long[1]));
sram_sp_wrapper #(.AddrWidth(7)) r_sram2(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[6]}),.addr_i({{addr_l_wr_i[2]},{addr_l_rd_i[2]}}),.wdata_i(dr_i_long[2]) ,.rdata_o(dr_o_long[2]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram2(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[6]}),.addr_i({{addr_l_wr_i[2]},{addr_l_rd_i[2]}}),.wdata_i(di_i_long[2]) ,.rdata_o(di_o_long[2]));
sram_sp_wrapper #(.AddrWidth(7)) r_sram3(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[7]}),.addr_i({{addr_l_wr_i[3]},{addr_l_rd_i[3]}}),.wdata_i(dr_i_long[3]) ,.rdata_o(dr_o_long[3]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram3(.clk_i, .wen_i({wen_i[0]         ,ren_i[0]|ren_i[7]}),.addr_i({{addr_l_wr_i[3]},{addr_l_rd_i[3]}}),.wdata_i(di_i_long[3]) ,.rdata_o(di_o_long[3]));


sram_sp_wrapper #(.AddrWidth(7)) r_sram4(.clk_i, .wen_i({wen_i[1]|wen_i[4],ren_i[1]|ren_i[4]}),.addr_i({{addr_s_wr_i[0]},{addr_s_rd_i[0]}}),.wdata_i(dr_i_short[0]),.rdata_o(dr_o_short[0]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram4(.clk_i, .wen_i({wen_i[1]|wen_i[4],ren_i[1]|ren_i[4]}),.addr_i({{addr_s_wr_i[0]},{addr_s_rd_i[0]}}),.wdata_i(di_i_short[0]),.rdata_o(di_o_short[0]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram5(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[5]}),.addr_i({{addr_s_wr_i[1]},{addr_s_rd_i[1]}}),.wdata_i(dr_i_short[1]),.rdata_o(dr_o_short[1]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram5(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[5]}),.addr_i({{addr_s_wr_i[1]},{addr_s_rd_i[1]}}),.wdata_i(di_i_short[1]),.rdata_o(di_o_short[1]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram6(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[6]}),.addr_i({{addr_s_wr_i[2]},{addr_s_rd_i[2]}}),.wdata_i(dr_i_short[2]),.rdata_o(dr_o_short[2]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram6(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[6]}),.addr_i({{addr_s_wr_i[2]},{addr_s_rd_i[2]}}),.wdata_i(di_i_short[2]),.rdata_o(di_o_short[2]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram7(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[7]}),.addr_i({{addr_s_wr_i[3]},{addr_s_rd_i[3]}}),.wdata_i(dr_i_short[3]),.rdata_o(dr_o_short[3]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram7(.clk_i, .wen_i({wen_i[1]         ,ren_i[1]|ren_i[7]}),.addr_i({{addr_s_wr_i[3]},{addr_s_rd_i[3]}}),.wdata_i(di_i_short[3]),.rdata_o(di_o_short[3]));


sram_sp_wrapper #(.AddrWidth(7)) r_sram8 (.clk_i, .wen_i({wen_i[2]|wen_i[4],ren_i[2]|ren_i[4]}),.addr_i({addr_s_wr_i[4],addr_s_rd_i[4]}),.wdata_i(dr_i_short[4])   ,.rdata_o(dr_o_short[4]));
sram_sp_wrapper #(.AddrWidth(7)) i_sram8 (.clk_i, .wen_i({wen_i[2]|wen_i[4],ren_i[2]|ren_i[4]}),.addr_i({addr_s_wr_i[4],addr_s_rd_i[4]}),.wdata_i(di_i_short[4])   ,.rdata_o(di_o_short[4]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram9 (.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[5]}),.addr_i({addr_s_wr_i[5],addr_s_rd_i[5]}),.wdata_i(dr_i_short[5])   ,.rdata_o(dr_o_short[5]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram9 (.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[5]}),.addr_i({addr_s_wr_i[5],addr_s_rd_i[5]}),.wdata_i(di_i_short[5])   ,.rdata_o(di_o_short[5]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram10(.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[6]}),.addr_i({addr_s_wr_i[6],addr_s_rd_i[6]}),.wdata_i(dr_i_short[6])   ,.rdata_o(dr_o_short[6]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram10(.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[6]}),.addr_i({addr_s_wr_i[6],addr_s_rd_i[6]}),.wdata_i(di_i_short[6])   ,.rdata_o(di_o_short[6]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram11(.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[7]}),.addr_i({addr_s_wr_i[7],addr_s_rd_i[7]}),.wdata_i(dr_i_short[7])   ,.rdata_o(dr_o_short[7]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram11(.clk_i, .wen_i({wen_i[2]         ,ren_i[2]|ren_i[7]}),.addr_i({addr_s_wr_i[7],addr_s_rd_i[7]}),.wdata_i(di_i_short[7])   ,.rdata_o(di_o_short[7]));


sram_sp_wrapper #(.AddrWidth(7)) r_sram12(.clk_i, .wen_i({wen_i[3]|wen_i[4],ren_i[3]|ren_i[4]}),.addr_i({addr_s_wr_i[8] ,addr_s_rd_i[8] }),.wdata_i(dr_i_short[8] ),.rdata_o(dr_o_short[8] ));
sram_sp_wrapper #(.AddrWidth(7)) i_sram12(.clk_i, .wen_i({wen_i[3]|wen_i[4],ren_i[3]|ren_i[4]}),.addr_i({addr_s_wr_i[8] ,addr_s_rd_i[8] }),.wdata_i(di_i_short[8] ),.rdata_o(di_o_short[8] ));
sram_sp_wrapper #(.AddrWidth(5)) r_sram13(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[5]}),.addr_i({addr_s_wr_i[9] ,addr_s_rd_i[9] }),.wdata_i(dr_i_short[9] ),.rdata_o(dr_o_short[9] ));
sram_sp_wrapper #(.AddrWidth(5)) i_sram13(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[5]}),.addr_i({addr_s_wr_i[9] ,addr_s_rd_i[9] }),.wdata_i(di_i_short[9] ),.rdata_o(di_o_short[9] ));
sram_sp_wrapper #(.AddrWidth(5)) r_sram14(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[6]}),.addr_i({addr_s_wr_i[10],addr_s_rd_i[10]}),.wdata_i(dr_i_short[10]),.rdata_o(dr_o_short[10]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram14(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[6]}),.addr_i({addr_s_wr_i[10],addr_s_rd_i[10]}),.wdata_i(di_i_short[10]),.rdata_o(di_o_short[10]));
sram_sp_wrapper #(.AddrWidth(5)) r_sram15(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[7]}),.addr_i({addr_s_wr_i[11],addr_s_rd_i[11]}),.wdata_i(dr_i_short[11]),.rdata_o(dr_o_short[11]));
sram_sp_wrapper #(.AddrWidth(5)) i_sram15(.clk_i, .wen_i({wen_i[3]         ,ren_i[3]|ren_i[7]}),.addr_i({addr_s_wr_i[11],addr_s_rd_i[11]}),.wdata_i(di_i_short[11]),.rdata_o(di_o_short[11]));


// sram_sp_l_ip r_sram0 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]|wen_i[4]}) , .enb({ren_i[0]|ren_i[4]}),.addra({{addr_l_wr_i[0]}}) , .addrb({{addr_l_rd_i[0]}}),.dina(dr_i_long[0])  ,.doutb(dr_o_long[0]));
// sram_sp_l_ip i_sram0 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]|wen_i[4]}) , .enb({ren_i[0]|ren_i[4]}),.addra({{addr_l_wr_i[0]}}) , .addrb({{addr_l_rd_i[0]}}),.dina(di_i_long[0])  ,.doutb(di_o_long[0]));
// sram_sp_l_ip r_sram1 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[5]}),.addra({{addr_l_wr_i[1]}}) , .addrb({{addr_l_rd_i[1]}}),.dina(dr_i_long[1])  ,.doutb(dr_o_long[1]));
// sram_sp_l_ip i_sram1 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[5]}),.addra({{addr_l_wr_i[1]}}) , .addrb({{addr_l_rd_i[1]}}),.dina(di_i_long[1])  ,.doutb(di_o_long[1]));
// sram_sp_l_ip r_sram2 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[6]}),.addra({{addr_l_wr_i[2]}}) , .addrb({{addr_l_rd_i[2]}}),.dina(dr_i_long[2])  ,.doutb(dr_o_long[2]));
// sram_sp_l_ip i_sram2 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[6]}),.addra({{addr_l_wr_i[2]}}) , .addrb({{addr_l_rd_i[2]}}),.dina(di_i_long[2])  ,.doutb(di_o_long[2]));
// sram_sp_l_ip r_sram3 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[7]}),.addra({{addr_l_wr_i[3]}}) , .addrb({{addr_l_rd_i[3]}}),.dina(dr_i_long[3])  ,.doutb(dr_o_long[3]));
// sram_sp_l_ip i_sram3 (.clka(clk_i), .ena(1'b1), .wea({wen_i[0]         }) , .enb({ren_i[0]|ren_i[7]}),.addra({{addr_l_wr_i[3]}}) , .addrb({{addr_l_rd_i[3]}}),.dina(di_i_long[3])  ,.doutb(di_o_long[3]));


// sram_sp_l_ip r_sram4 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]|wen_i[4]}) , .enb({ren_i[1]|ren_i[4]}),.addra({{addr_s_wr_i[0]}}) , .addrb({{addr_s_rd_i[0]}}),.dina(dr_i_short[0]) ,.doutb(dr_o_short[0]));
// sram_sp_l_ip i_sram4 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]|wen_i[4]}) , .enb({ren_i[1]|ren_i[4]}),.addra({{addr_s_wr_i[0]}}) , .addrb({{addr_s_rd_i[0]}}),.dina(di_i_short[0]) ,.doutb(di_o_short[0]));
// sram_sp_l_ip r_sram5 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[5]}),.addra({{addr_s_wr_i[1]}}) , .addrb({{addr_s_rd_i[1]}}),.dina(dr_i_short[1]) ,.doutb(dr_o_short[1]));
// sram_sp_l_ip i_sram5 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[5]}),.addra({{addr_s_wr_i[1]}}) , .addrb({{addr_s_rd_i[1]}}),.dina(di_i_short[1]) ,.doutb(di_o_short[1]));
// sram_sp_l_ip r_sram6 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[6]}),.addra({{addr_s_wr_i[2]}}) , .addrb({{addr_s_rd_i[2]}}),.dina(dr_i_short[2]) ,.doutb(dr_o_short[2]));
// sram_sp_l_ip i_sram6 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[6]}),.addra({{addr_s_wr_i[2]}}) , .addrb({{addr_s_rd_i[2]}}),.dina(di_i_short[2]) ,.doutb(di_o_short[2]));
// sram_sp_l_ip r_sram7 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[7]}),.addra({{addr_s_wr_i[3]}}) , .addrb({{addr_s_rd_i[3]}}),.dina(dr_i_short[3]) ,.doutb(dr_o_short[3]));
// sram_sp_l_ip i_sram7 (.clka(clk_i), .ena(1'b1), .wea({wen_i[1]         }) , .enb({ren_i[1]|ren_i[7]}),.addra({{addr_s_wr_i[3]}}) , .addrb({{addr_s_rd_i[3]}}),.dina(di_i_short[3]) ,.doutb(di_o_short[3]));


// sram_sp_l_ip r_sram8 (.clka(clk_i), .ena(1'b1), .wea({wen_i[2]|wen_i[4]}) , .enb({ren_i[2]|ren_i[4]}),.addra({addr_s_wr_i[4] })  , .addrb({addr_s_rd_i[4]})  ,.dina(dr_i_short[4]) ,.doutb(dr_o_short[4]));
// sram_sp_l_ip i_sram8 (.clka(clk_i), .ena(1'b1), .wea({wen_i[2]|wen_i[4]}) , .enb({ren_i[2]|ren_i[4]}),.addra({addr_s_wr_i[4] })  , .addrb({addr_s_rd_i[4]})  ,.dina(di_i_short[4]) ,.doutb(di_o_short[4]));
// sram_sp_l_ip r_sram9 (.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[5]}),.addra({addr_s_wr_i[5] })  , .addrb({addr_s_rd_i[5]})  ,.dina(dr_i_short[5]) ,.doutb(dr_o_short[5]));
// sram_sp_l_ip i_sram9 (.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[5]}),.addra({addr_s_wr_i[5] })  , .addrb({addr_s_rd_i[5]})  ,.dina(di_i_short[5]) ,.doutb(di_o_short[5]));
// sram_sp_l_ip r_sram10(.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[6]}),.addra({addr_s_wr_i[6] })  , .addrb({addr_s_rd_i[6]})  ,.dina(dr_i_short[6]) ,.doutb(dr_o_short[6]));
// sram_sp_l_ip i_sram10(.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[6]}),.addra({addr_s_wr_i[6] })  , .addrb({addr_s_rd_i[6]})  ,.dina(di_i_short[6]) ,.doutb(di_o_short[6]));
// sram_sp_l_ip r_sram11(.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[7]}),.addra({addr_s_wr_i[7] })  , .addrb({addr_s_rd_i[7]})  ,.dina(dr_i_short[7]) ,.doutb(dr_o_short[7]));
// sram_sp_l_ip i_sram11(.clka(clk_i), .ena(1'b1), .wea({wen_i[2]         }) , .enb({ren_i[2]|ren_i[7]}),.addra({addr_s_wr_i[7] })  , .addrb({addr_s_rd_i[7]})  ,.dina(di_i_short[7]) ,.doutb(di_o_short[7]));


// sram_sp_l_ip r_sram12(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]|wen_i[4]}) , .enb({ren_i[3]|ren_i[4]}),.addra({addr_s_wr_i[8] })  , .addrb({addr_s_rd_i[8] }) ,.dina(dr_i_short[8] ),.doutb(dr_o_short[8] ));
// sram_sp_l_ip i_sram12(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]|wen_i[4]}) , .enb({ren_i[3]|ren_i[4]}),.addra({addr_s_wr_i[8] })  , .addrb({addr_s_rd_i[8] }) ,.dina(di_i_short[8] ),.doutb(di_o_short[8] ));
// sram_sp_l_ip r_sram13(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[5]}),.addra({addr_s_wr_i[9] })  , .addrb({addr_s_rd_i[9] }) ,.dina(dr_i_short[9] ),.doutb(dr_o_short[9] ));
// sram_sp_l_ip i_sram13(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[5]}),.addra({addr_s_wr_i[9] })  , .addrb({addr_s_rd_i[9] }) ,.dina(di_i_short[9] ),.doutb(di_o_short[9] ));
// sram_sp_l_ip r_sram14(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[6]}),.addra({addr_s_wr_i[10]})  , .addrb({addr_s_rd_i[10]}) ,.dina(dr_i_short[10]),.doutb(dr_o_short[10]));
// sram_sp_l_ip i_sram14(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[6]}),.addra({addr_s_wr_i[10]})  , .addrb({addr_s_rd_i[10]}) ,.dina(di_i_short[10]),.doutb(di_o_short[10]));
// sram_sp_l_ip r_sram15(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[7]}),.addra({addr_s_wr_i[11]})  , .addrb({addr_s_rd_i[11]}) ,.dina(dr_i_short[11]),.doutb(dr_o_short[11]));
// sram_sp_l_ip i_sram15(.clka(clk_i), .ena(1'b1), .wea({wen_i[3]         }) , .enb({ren_i[3]|ren_i[7]}),.addra({addr_s_wr_i[11]})  , .addrb({addr_s_rd_i[11]}) ,.dina(di_i_short[11]),.doutb(di_o_short[11]));

endmodule