`include "parameter.vh"
module SE2PA(CLK,RST,START,DR,DI,OR,OI);
`FFTsfpw

    input CLK,RST,START;
    input [nb-1:0] DR,DI;
    output reg [nb*4-1] OR,OI;
    output RDY;

    reg [1:0] count;
    reg [nb-1:0] real_reg0;
    reg [nb-1:0] imag_reg0;
    reg [nb-1:0] real_reg1;
    reg [nb-1:0] imag_reg1;
    reg [nb-1:0] real_reg2;
    reg [nb-1:0] imag_reg2;

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
                real_reg0 <= DR;
                imag_reg0 <= DI;
                RDY <= 1'b0;
            end
            2'b01: begin
                real_reg1 <= DR;
                imag_reg1 <= DI;
                RDY <= 1'b0;
            end
            2'b10: begin
                real_reg2 <= DR;
                imag_reg2 <= DI;
                RDY <= 1'b0;
            end
            2'b11: begin
                OR <= {DR,real_reg2,real_reg1,real_reg0};
                OI <= {OI,imag_reg2,imag_reg1,imag_reg0};
                RDY <= 1'b1;
            end
            endcase
        end
    end
endmodule