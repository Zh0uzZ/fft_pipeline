`include "parameter.vh"
module fft_2d #(
    parameter type sfp_t = logic [`SFP_WIDTH-1:0],
    parameter AddrLWidth = 7,
    parameter AddrSWidth = 5,
    parameter type addr_t_long = logic [AddrLWidth-1:0],
    parameter type addr_t_short = logic [AddrSWidth-1:0]
) (
    input logic clk_i,
    input logic rst_ni,
    input logic start_i,
    input sfp_t [3:0] dr_i,
    input sfp_t [3:0] di_i,

    output sfp_t [3:0] dr_o,
    output sfp_t [3:0] di_o,
    output logic rdy_o
);

logic stage1 , stage2 , stage3 , start_fft_1 , start_fft_2 , start_mdc_i;
logic [4:0] wen_i , wen_1 , wen_2;
logic [7:0] ren_i , ren_1 , ren_2;
logic rdy_mdc_o;

sfp_t [3:0] dr_sram_i , di_sram_i;
sfp_t [3:0] dr_sram_o , di_sram_o;

sfp_t [3:0] dr_mdc_i , di_mdc_i;
sfp_t [3:0] dr_mdc_o , di_mdc_o;

addr_t_long [3:0] addr_wr_i , addr_rd_i;
addr_t_long addr_wr_1 , addr_rd_1;
addr_t_long addr_wr_2 , addr_rd_2;

addr_gen_0 #(
    .AddrWidth(7)
) u_address_gen0(
    .clk_i,
    .rst_ni,
    .start_i,

    .start_fft_o(start_fft_1),
    .stage1,
    .stage2,
    .stage3,

    .wen_o(wen_1),
    .ren_o(ren_1),
    .addr_wr_o(addr_wr_1),
    .addr_rd_o(addr_rd_1)

);

addr_gen_1 #(
    .AddrWidth(7)
) u_address_gen1(
    .clk_i,
    .rst_ni,
    .start_i(rdy_mdc_o),

    .start_fft_o(start_fft_2),
    .stage2,

    .wen_o(wen_2),
    .ren_o(ren_2),
    .addr_wr_o(addr_wr_2),
    .addr_rd_o(addr_rd_2)
);

always_comb begin
    unique case({stage1 , stage2 , stage3})
    3'b100: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = dr_i[i];
            di_sram_i[i] = di_i[i];
            dr_mdc_i[i]  = dr_sram_o[i];
            di_mdc_i[i]  = di_sram_o[i];
        end

        wen_i = wen_1;
        ren_i = ren_1;
        addr_wr_i  = {4{addr_wr_1}};
        addr_rd_i  = {4{addr_rd_1}};

        start_mdc_i = start_fft_1;
    end
    3'b110: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = dr_mdc_o[i];
            di_sram_i[i] = di_mdc_o[i];
            dr_mdc_i[i]  = dr_sram_o[i];
            di_mdc_i[i]  = di_sram_o[i];
        end

        wen_i = wen_2;
        ren_i = ren_1;
        addr_wr_i  = addr_wr_2;
        addr_rd_i  = addr_rd_1;

        start_mdc_i = start_fft_2;
    end
    3'b010: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = dr_mdc_o[i];
            di_sram_i[i] = di_mdc_o[i];
            dr_mdc_i[i]  = dr_sram_o[i];
            di_mdc_i[i]  = di_sram_o[i];
        end

        wen_i = wen_2;
        ren_i = ren_2;
        addr_wr_i  = {4{addr_wr_2}};
        addr_rd_i  = {4{addr_rd_2}};

        start_mdc_i = start_fft_2;
    end
    3'b011: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = dr_mdc_o[i];
            di_sram_i[i] = di_mdc_o[i];
            dr_mdc_i[i]  = dr_sram_o[i];
            di_mdc_i[i]  = di_sram_o[i];
        end

        wen_i = wen_1<<4;
        ren_i = ren_2;
        addr_wr_i  = {4{addr_wr_1}};
        addr_rd_i  = {4{addr_rd_2}};

        start_mdc_i = start_fft_1;
    end
    3'b001: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = dr_mdc_o[i];
            di_sram_i[i] = di_mdc_o[i];
            dr_mdc_i[i]  = dr_sram_o[i];
            di_mdc_i[i]  = di_sram_o[i];
        end

        wen_i = wen_1<<4;
        ren_i = ren_1<<4;
        addr_wr_i  = {4{addr_wr_1}};
        addr_rd_i  = {4{addr_rd_1}};

        start_mdc_i = start_fft_1;
    end
    default: begin
        for(int unsigned i = 0; i < 4; i++) begin
            dr_sram_i[i] = 0;
            di_sram_i[i] = 0;
            dr_mdc_i[i]  = 0;
            di_mdc_i[i]  = 0;
        end

        wen_i = 0;
        ren_i = 0;
        addr_wr_i  = 0;
        addr_rd_i  = 0;

        start_mdc_i = 0;
    end
    endcase
end

always_comb begin
    for(int unsigned i = 0; i < 4; i++) begin
        dr_o[i]  = stage3 ? dr_sram_o[i] : 0;
        di_o[i]  = stage3 ? di_sram_o[i] : 0;
    end
end


sram_system #(
    .AddrLWidth(7),
    .AddrSWidth(5)
) u_sram_system(
    .clk_i,
    .wen_i,
    .addr_wr_i,
    .dr_sram_i,
    .di_sram_i,

    .ren_i,
    .addr_rd_i,
    .dr_sram_o,
    .di_sram_o
);


R4MDC u0_fft4(
    .clk_i,
    .rst_ni,
    .start_mdc_i,
    .dr_mdc_i,
    .di_mdc_i,

    .dr_mdc_o,
    .di_mdc_o,
    .rdy_mdc_o
);

endmodule