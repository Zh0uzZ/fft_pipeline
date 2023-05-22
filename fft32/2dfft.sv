`include "parameter.vh"
module 2dfft #(
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

logic stage1 , start_fft_1 , start_mdc_i;
logic [3:0] wen_1;

sfp_t [3:0] dr_sram_i , di_sram_i;
sfp_t [3:0] dr_sram_o , di_sram_o;
addr_t_long [3:0] addr1;

addr_gen_0 #(
    .AddrWidth(7)
) u_address_gen0(
    .clk_i,
    .rst_ni,
    .start_i,
    .start_fft_o(start_fft_1),
    .wen_o(wen_1),
    .addr_gen_o(addr1),
    .stage1
);

addr_gen_1 #(
    .AddrWidth(7)
) u_address_gen0(
    .clk_i,
    .rst_ni,
    .start_i,
    .start_fft_o(start_fft_1),
    .wen_o(wen_1),
    .addr_gen_o(addr1),
    .stage1
);

always_comb begin
    unique case({stage1 , stage2 , stage3})
    3'b1??: begin
        dr_sram_i[3] = dr_i[3]; dr_sram_i[2] = dr_i[2]; dr_sram_i[1] = dr_i[1]; dr_sram_i[0] = dr_i[0];
        di_sram_i[3] = di_i[3]; di_sram_i[2] = di_i[2]; di_sram_i[1] = di_i[1]; di_sram_i[0] = di_i[0];
        for(int unsigned i = 0; i < 4; i++) begin
            addr_l_i[i] = addr1[i];
            dr_mdc_i[i] = dr_sram_o[i];
            di_mdc_i[i] = di_sram_o[i];
        end
        for(int unsigned i = 0; i < 12; i++) begin
            addr_s_i[i] = {AddrSWidth{1'b0}};
        end
        wen_i = wen_1;
        di_en_i = 2'b00;
        do_en_i = 2'b00;
        start_mdc_i = start_fft_1;
    end
    3'b01?: begin
    end
    3'b001: begin
    end
    endcase
end

sram_system #(
    .AddrLWidth(7),
    .AddrSWidth(5)
) u_sram_system(
    .clk_i,
    .wen_i,
    .di_en_i,
    .addr_l_i,
    .addr_s_i,

    .dr_sram_i,
    .di_sram_i,

    .do_en_i,
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