
`include "../include/parameter.vh"
module wrom_rst(CLK,RST,START,OR,OI);
    `FFTsfpw
    input CLK,RST,START;
    output reg [nb*4-1:0] OR,OI;

    reg [nb-1:0] wr0 ;
    reg [nb-1:0] wr1 ;
    reg [nb-1:0] wr2 ;
    reg [nb-1:0] wr3 ;
    reg [nb-1:0] wr4 ;
    reg [nb-1:0] wr5 ;
    reg [nb-1:0] wr6 ;
    reg [nb-1:0] wr7 ;
    reg [nb-1:0] wr8 ;
    reg [nb-1:0] wr9 ;
    reg [nb-1:0] wr10 ;
    reg [nb-1:0] wr11 ;
    reg [nb-1:0] wr12 ;
    reg [nb-1:0] wr13 ;
    reg [nb-1:0] wr14 ;
    reg [nb-1:0] wr15 ;
    reg [nb-1:0] wr16 ;
    reg [nb-1:0] wr17 ;
    reg [nb-1:0] wr18 ;
    reg [nb-1:0] wr19 ;
    reg [nb-1:0] wr20 ;
    reg [nb-1:0] wr21 ;
    reg [nb-1:0] wr22 ;
    reg [nb-1:0] wr23 ;
    reg [nb-1:0] wr24 ;
    reg [nb-1:0] wr25 ;
    reg [nb-1:0] wr26 ;
    reg [nb-1:0] wr27 ;
    reg [nb-1:0] wr28 ;
    reg [nb-1:0] wr29 ;
    reg [nb-1:0] wr30 ;
    reg [nb-1:0] wr31 ;



    reg [nb-1:0] wi0 ;
    reg [nb-1:0] wi1 ;
    reg [nb-1:0] wi2 ;
    reg [nb-1:0] wi3 ;
    reg [nb-1:0] wi4 ;
    reg [nb-1:0] wi5 ;
    reg [nb-1:0] wi6 ;
    reg [nb-1:0] wi7 ;
    reg [nb-1:0] wi8 ;
    reg [nb-1:0] wi9 ;
    reg [nb-1:0] wi10 ;
    reg [nb-1:0] wi11 ;
    reg [nb-1:0] wi12 ;
    reg [nb-1:0] wi13 ;
    reg [nb-1:0] wi14 ;
    reg [nb-1:0] wi15 ;
    reg [nb-1:0] wi16 ;
    reg [nb-1:0] wi17 ;
    reg [nb-1:0] wi18 ;
    reg [nb-1:0] wi19 ;
    reg [nb-1:0] wi20 ;
    reg [nb-1:0] wi21 ;
    reg [nb-1:0] wi22 ;
    reg [nb-1:0] wi23 ;
    reg [nb-1:0] wi24 ;
    reg [nb-1:0] wi25 ;
    reg [nb-1:0] wi26 ;
    reg [nb-1:0] wi27 ;
    reg [nb-1:0] wi28 ;
    reg [nb-1:0] wi29 ;
    reg [nb-1:0] wi30 ;
    reg [nb-1:0] wi31 ;


    reg [2:0] count;
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            wr0 <= 9'b010000000;
            wr1 <= 9'b010000000;
            wr2 <= 9'b010000000;
            wr3 <= 9'b010000000;
            wr4 <= 9'b001111011;
            wr5 <= 9'b001111110;
            wr6 <= 9'b001111111;
            wr7 <= 9'b010000000;
            wr8 <= 9'b001101000;
            wr9 <= 9'b001110111;
            wr10 <= 9'b001111110;
            wr11 <= 9'b010000000;
            wr12 <= 9'b101011001;
            wr13 <= 9'b001101000;
            wr14 <= 9'b001111011;
            wr15 <= 9'b010000000;
            wr16 <= 9'b101110111;
            wr17 <= 9'b000000000;
            wr18 <= 9'b001110111;
            wr19 <= 9'b010000000;
            wr20 <= 9'b101111111;
            wr21 <= 9'b101101000;
            wr22 <= 9'b001110010;
            wr23 <= 9'b010000000;
            wr24 <= 9'b101111110;
            wr25 <= 9'b101110111;
            wr26 <= 9'b001101000;
            wr27 <= 9'b010000000;
            wr28 <= 9'b101110010;
            wr29 <= 9'b101111110;
            wr30 <= 9'b001011001;
            wr31 <= 9'b010000000;



            wi0 <= 9'b000000000;
            wi1 <= 9'b000000000;
            wi2 <= 9'b000000000;
            wi3 <= 9'b000000000;
            wi4 <= 9'b101110010;
            wi5 <= 9'b101101000;
            wi6 <= 9'b101011001;
            wi7 <= 9'b000000000;
            wi8 <= 9'b101111110;
            wi9 <= 9'b101110111;
            wi10 <= 9'b101101000;
            wi11 <= 9'b000000000;
            wi12 <= 9'b101111111;
            wi13 <= 9'b101111110;
            wi14 <= 9'b101110010;
            wi15 <= 9'b000000000;
            wi16 <= 9'b101110111;
            wi17 <= 9'b110000000;
            wi18 <= 9'b101110111;
            wi19 <= 9'b000000000;
            wi20 <= 9'b101011001;
            wi21 <= 9'b101111110;
            wi22 <= 9'b101111011;
            wi23 <= 9'b000000000;
            wi24 <= 9'b001101000;
            wi25 <= 9'b101110111;
            wi26 <= 9'b101111110;
            wi27 <= 9'b000000000;
            wi28 <= 9'b001111011;
            wi29 <= 9'b101101000;
            wi30 <= 9'b101111111;
            wi31 <= 9'b000000000;
        end else if (START) begin
            count <= 0;
        end else begin
            count <= count + 1;
            case(count)
            3'd0: begin
                OR <= {wr3,wr2,wr1,wr0};
                OI <= {wi3,wi2,wi1,wi0};
            end
            3'd1: begin
                OR <= {wr7,wr6,wr5,wr4};
                OI <= {wi7,wi6,wi5,wi4};
            end
            3'd2: begin
                OR <= {wr11,wr10,wr9,wr8};
                OI <= {wi11,wi10,wi9,wi8};
            end
            3'd3: begin
                OR <= {wr15,wr14,wr13,wr12};
                OI <= {wi15,wi14,wi13,wi12};
            end
            3'd4: begin
                OR <= {wr19,wr18,wr17,wr16};
                OI <= {wi19,wi18,wi17,wi16};
            end
            3'd5: begin
                OR <= {wr23,wr22,wr21,wr20};
                OI <= {wi23,wi22,wi21,wi20};
            end
            3'd6: begin
                OR <= {wr27,wr26,wr25,wr24};
                OI <= {wi27,wi26,wi25,wi24};
            end
            3'd7: begin
                OR <= {wr31,wr30,wr29,wr28};
                OI <= {wi31,wi30,wi29,wi28};
            end
            endcase
        end
    end

endmodule