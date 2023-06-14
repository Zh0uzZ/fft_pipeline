`include "../include/parameter.vh"
module PA2SE(CLK,RST,START,DR,DI,OR,OI,RDY);
`FFTsfpw

    input CLK,RST,START;
    input [nb*4-1:0] DR,DI;
    output reg [nb-1:0] OR,OI;
    output reg RDY;

    reg [1:0] count , count_r;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            count <= 0;
            count_r <= 2'b11;
            RDY <= 0;
        end else if (START) begin
            count <= 1;
            OR <= DR[nb*4-1:nb*3];
            OI <= DI[nb*4-1:nb*3];
            count_r <= 0;
            RDY <= 0;
        end else begin
            count <= count + 1;
            case(count)
            2'b00: begin
                OR <= DR[nb*4-1:nb*3];
                OI <= DI[nb*4-1:nb*3];
            end
            2'b01: begin
                OR <= DR[nb*3-1:nb*2];
                OI <= DI[nb*3-1:nb*2];
            end
            2'b10: begin
                OR <= DR[nb*2-1:nb*1];
                OI <= DI[nb*2-1:nb*1];
            end
            2'b11: begin
                OR <= DR[nb*1-1:nb*0];
                OI <= DI[nb*1-1:nb*0];
            end
            endcase
            RDY <= 0;
            if(count_r != 2'b11)
                count_r <= count_r + 1;
            if(count_r == 2'b00)
                RDY <= 1;
        end
    end
endmodule