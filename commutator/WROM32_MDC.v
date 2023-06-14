`include "../include/parameter.vh"
module WROM32_MDC(CLK,RST,START, STAGE ,OR,OI);
    `FFTsfpw
    input CLK,RST,START,STAGE;
    output reg [nb*4-1:0] OR,OI;

    parameter [nb-1:0] wr0  = 9'b010000000;
    parameter [nb-1:0] wr1  = 9'b010000000;
    parameter [nb-1:0] wr2  = 9'b010000000;
    parameter [nb-1:0] wr3  = 9'b010000000;
    parameter [nb-1:0] wr4  = 9'b001111011;
    parameter [nb-1:0] wr5  = 9'b001111110;
    parameter [nb-1:0] wr6  = 9'b001111111;
    parameter [nb-1:0] wr7  = 9'b010000000;
    parameter [nb-1:0] wr8  = 9'b001101000;
    parameter [nb-1:0] wr9  = 9'b001110111;
    parameter [nb-1:0] wr10 = 9'b001111110;
    parameter [nb-1:0] wr11 = 9'b010000000;
    parameter [nb-1:0] wr12 = 9'b101011001;
    parameter [nb-1:0] wr13 = 9'b001101000;
    parameter [nb-1:0] wr14 = 9'b001111011;
    parameter [nb-1:0] wr15 = 9'b010000000;
    parameter [nb-1:0] wr16 = 9'b101110111;
    parameter [nb-1:0] wr17 = 9'b000000000;
    parameter [nb-1:0] wr18 = 9'b001110111;
    parameter [nb-1:0] wr19 = 9'b010000000;
    parameter [nb-1:0] wr20 = 9'b101111111;
    parameter [nb-1:0] wr21 = 9'b101101000;
    parameter [nb-1:0] wr22 = 9'b001110010;
    parameter [nb-1:0] wr23 = 9'b010000000;
    parameter [nb-1:0] wr24 = 9'b101111110;
    parameter [nb-1:0] wr25 = 9'b101110111;
    parameter [nb-1:0] wr26 = 9'b001101000;
    parameter [nb-1:0] wr27 = 9'b010000000;
    parameter [nb-1:0] wr28 = 9'b101110010;
    parameter [nb-1:0] wr29 = 9'b101111110;
    parameter [nb-1:0] wr30 = 9'b001011001;
    parameter [nb-1:0] wr31 = 9'b010000000;


    parameter [nb-1:0] wi0  = 9'b000000000;
    parameter [nb-1:0] wi1  = 9'b000000000;
    parameter [nb-1:0] wi2  = 9'b000000000;
    parameter [nb-1:0] wi3  = 9'b000000000;
    parameter [nb-1:0] wi4  = 9'b101110010;
    parameter [nb-1:0] wi5  = 9'b101101000;
    parameter [nb-1:0] wi6  = 9'b101011001;
    parameter [nb-1:0] wi7  = 9'b000000000;
    parameter [nb-1:0] wi8  = 9'b101111110;
    parameter [nb-1:0] wi9  = 9'b101110111;
    parameter [nb-1:0] wi10 = 9'b101101000;
    parameter [nb-1:0] wi11 = 9'b000000000;
    parameter [nb-1:0] wi12 = 9'b101111111;
    parameter [nb-1:0] wi13 = 9'b101111110;
    parameter [nb-1:0] wi14 = 9'b101110010;
    parameter [nb-1:0] wi15 = 9'b000000000;
    parameter [nb-1:0] wi16 = 9'b101110111;
    parameter [nb-1:0] wi17 = 9'b110000000;
    parameter [nb-1:0] wi18 = 9'b101110111;
    parameter [nb-1:0] wi19 = 9'b000000000;
    parameter [nb-1:0] wi20 = 9'b101011001;
    parameter [nb-1:0] wi21 = 9'b101111110;
    parameter [nb-1:0] wi22 = 9'b101111011;
    parameter [nb-1:0] wi23 = 9'b000000000;
    parameter [nb-1:0] wi24 = 9'b001101000;
    parameter [nb-1:0] wi25 = 9'b101110111;
    parameter [nb-1:0] wi26 = 9'b101111110;
    parameter [nb-1:0] wi27 = 9'b000000000;
    parameter [nb-1:0] wi28 = 9'b001111011;
    parameter [nb-1:0] wi29 = 9'b101101000;
    parameter [nb-1:0] wi30 = 9'b101111111;
    parameter [nb-1:0] wi31 = 9'b000000000;


    reg [2:0] count;
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            count <= 0;
        end else if (START) begin
            count <= 0;
        end else begin
            count <= count + 1;
            end
    end

    always@(*) begin
    case(STAGE)
    1'b0:   case(count)
            3'd0: begin
                OR = {wr3,wr2,wr1,wr0};
                OI = {wi3,wi2,wi1,wi0};
            end
            3'd1: begin
                OR = {wr7,wr6,wr5,wr4};
                OI = {wi7,wi6,wi5,wi4};
            end
            3'd2: begin
                OR = {wr11,wr10,wr9,wr8};
                OI = {wi11,wi10,wi9,wi8};
            end
            3'd3: begin
                OR = {wr15,wr14,wr13,wr12};
                OI = {wi15,wi14,wi13,wi12};
            end
            3'd4: begin
                OR = {wr19,wr18,wr17,wr16};
                OI = {wi19,wi18,wi17,wi16};
            end
            3'd5: begin
                OR = {wr23,wr22,wr21,wr20};
                OI = {wi23,wi22,wi21,wi20};
            end
            3'd6: begin
                OR = {wr27,wr26,wr25,wr24};
                OI = {wi27,wi26,wi25,wi24};
            end
            3'd7: begin
                OR = {wr31,wr30,wr29,wr28};
                OI = {wi31,wi30,wi29,wi28};
            end
            endcase
    1'b1:   case(count)
            3'd0,3'd2,3'd4,3'd6: begin
                OR = {wr3,wr2,wr1,wr0};
                OI = {wi3,wi2,wi1,wi0};
            end
            3'd1,3'd3,3'd5,3'd7: begin
                OR = {wr19,wr18,wr17,wr16};
                OI = {wi19,wi18,wi17,wi16};
            end
            endcase
    endcase

end

endmodule