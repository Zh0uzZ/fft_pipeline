package sram_pkg;
    parameter AddrLWidth = 7;
    parameter AddrSWidth = 5;
    parameter type sfp_t = logic [`SFP_WIDTH-1:0];
    parameter type addr_t_long  = logic [AddrLWidth-1:0];
    parameter type addr_t_short = logic [AddrSWidth-1:0];


    sfp_t [3:0] dr_i_long , di_i_long;
    sfp_t [3:0] dr_o_long , di_o_long;
    sfp_t [11:0] dr_i_short , di_i_short;
    sfp_t [11:0] dr_o_short , di_o_short;



endpackage