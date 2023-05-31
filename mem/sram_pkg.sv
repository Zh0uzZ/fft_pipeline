package sram_pkg;
    parameter AddrLWidth = 7;
    parameter AddrSWidth = 5;
    parameter type sfp_t = logic [`SFP_WIDTH-1:0];
    parameter type addr_t_long  = logic [AddrLWidth-1:0];
    parameter type addr_t_short = logic [AddrSWidth-1:0];

    addr_t_long  [3:0]  addr_l_wr_i , addr_l_rd_i;
    addr_t_short [11:0] addr_s_wr_i , addr_s_rd_i;

    sfp_t [3:0] dr_i_long , di_i_long;
    sfp_t [3:0] dr_o_long , di_o_long;
    sfp_t [11:0] dr_i_short , di_i_short;
    sfp_t [11:0] dr_o_short , di_o_short;

    function long_wr_reset;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_l_wr_i[i] = 0;
            dr_i_long[i]   = 0;
            di_i_long[i]   = 0;
        end

    end
    endfunction

    function short_wr_reset1;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_s_wr_i[i] = 0;
            dr_i_short[i]  = 0;
            di_i_short[i]  = 0;
        end

    end
    endfunction

    function short_wr_reset2;
    begin
        for(int unsigned i = 4; i < 8; i++) begin
            addr_s_wr_i[i] = 0;
            dr_i_short[i]  = 0;
            di_i_short[i]  = 0;
        end

    end
    endfunction

    function short_wr_reset3;
    begin
        for(int unsigned i = 8; i < 12; i++) begin
            addr_s_wr_i[i] = 0;
            dr_i_short[i]  = 0;
            di_i_short[i]  = 0;
        end

    end
    endfunction

// row write reset
    function row0_wr_reset;
        short_wr_reset1;
        short_wr_reset2;
        short_wr_reset3;
    endfunction

    function row1_wr_reset;
        long_wr_reset;
        short_wr_reset2;
        short_wr_reset3;
    endfunction

    function row2_wr_reset;
        long_wr_reset;
        short_wr_reset1;
        short_wr_reset3;
    endfunction

    function row3_wr_reset;
        long_wr_reset;
        short_wr_reset1;
        short_wr_reset2;
    endfunction

    function column0_wr_reset;
        for(int unsigned i = 1; i < 4; i++) begin
            addr_l_wr_i[i] = 0; addr_s_wr_i[i] = 0; addr_s_wr_i[i+4] = 0; addr_s_wr_i[i+8] = 0;
            dr_i_long[i] = 0; dr_i_short[i] = 0; dr_i_short[i+4] = 0; dr_i_short[i+8] = 0;
            di_i_long[i] = 0; di_i_short[i] = 0; di_i_short[i+4] = 0; di_i_short[i+8] = 0;
        end
    endfunction


// row read reset
    function row0_rd_reset;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function row1_rd_reset;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function row2_rd_reset;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function row3_rd_reset;
    begin
        for(int unsigned i=0 ; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0;
        end
    end
    endfunction

// column read reset
    function column0_rd_reset;
    begin
        for(int unsigned i = 1; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function column1_rd_reset;
    begin
        for(int unsigned i=0 ; i < 1; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
        for(int unsigned i = 2; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function column2_rd_reset;
    begin
        for(int unsigned i=0 ; i < 2; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
        for(int unsigned i = 3; i < 4; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction

    function column3_rd_reset;
    begin
        for(int unsigned i=0 ; i < 3; i++) begin
            addr_l_rd_i[i] = 0; addr_s_rd_i[i] = 0; addr_s_rd_i[i+4] = 0; addr_s_rd_i[i+8] = 0;
        end
    end
    endfunction
endpackage