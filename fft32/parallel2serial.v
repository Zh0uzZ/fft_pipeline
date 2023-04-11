`include "parameter.vh"
module PA2SE(CLK,RST,START,DR,DI,OR,OI);
`FFTsfpw

    input CLK,RST,START;
    input [nb*4-1:0] DR,DI;
    output reg [nb-1] OR,OI;
    output RDY;

    reg [1:0] count;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            count <= 0;
            RDY <= 0;
        end else if (START) begin
            count <= 0;
            RDY <= 0;
        end else begin
            count <= count + 1;
            case(count)
            2'b00: begin
                OR <= DR[nb-1:0];
                OI <= DI[nb-1:0];
                RDY <= 1'b0;
            end
            2'b01: begin
                OR <= DR[nb*2-1:nb];
                OI <= DI[nb*2-1:nb];
                RDY <= 1'b0;
            end
            2'b10: begin
                OR <= DR[nb*3-1:nb*2];
                OI <= DI[nb*3-1:nb*2];
                RDY <= 1'b0;
            end
            2'b11: begin
                OR <= DR[nb*4-1:nb*3];
                OI <= DI[nb*4-1:nb*3];
                RDY <= 1'b1;
            end
            endcase
        end
    end
endmodule