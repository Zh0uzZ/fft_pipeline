`include "../include/parameter.vh"
module SE2PA(CLK,RST,START,DR,DI,OR,OI,RDY);
`FFTsfpw

    input CLK,RST,START;
    input [nb-1:0] DR,DI;
    output reg [nb*4-1:0] OR,OI;
    output reg RDY;

    reg [1:0] count,count_r;
    reg [nb-1:0] real_reg0;
    reg [nb-1:0] imag_reg0;
    reg [nb-1:0] real_reg1;
    reg [nb-1:0] imag_reg1;
    reg [nb-1:0] real_reg2;
    reg [nb-1:0] imag_reg2;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            count <= 0;
            count_r <= 3;
            RDY <= 0;
        end else if (START) begin
            count <= 1;
            count_r <= 0;
            RDY <= 0;
            real_reg0 <= DR;
            imag_reg0 <= DI;
        end else begin
            count <= count + 1;
            case(count)
            2'b00: begin
                real_reg0 <= DR;
                imag_reg0 <= DI;
            end
            2'b01: begin
                real_reg1 <= DR;
                imag_reg1 <= DI;
            end
            2'b10: begin
                real_reg2 <= DR;
                imag_reg2 <= DI;
            end
            2'b11: begin
                OR <= {real_reg0,real_reg1,real_reg2,DR};
                OI <= {imag_reg0,imag_reg1,imag_reg2,DI};
            end
            endcase
            RDY <= 0;
            if(count_r != 2'b11)
                count_r <= count_r + 1;
            if(count_r == 2'b10)
                RDY <= 1;
        end
    end
endmodule