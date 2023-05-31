module testadder #(
parameter type addr_t = logic [9:0]
)(
    input clk,
    input addr_t [2:0] in1 ,
    input logic [2:0] in2,
    output logic [3:0] in3,
    output logic [3:0] in4,
    output logic [3:0] in5,
    output logic [3:0] in6,
    output [9:0] out3,
    output [9:0] out4,
    output [9:0] out1 ,
    output [9:0] out2
);
    // assign out3 = in1+in2;
    // assign out4 = in1+in3;
    // wire [9:0] tmp1 , tmp2 , tmp3 , tmp4 , tmp5;


    // assign {tmp1 , tmp2 , tmp3 , tmp4 , tmp5} = {in1,in2,in3,in4,in1};
    // assign out1 = tmp1 + tmp2 + tmp4 + tmp3;
//    assign out1 = in1 + in2;
    // assign out1 = (in1[0] == 10'b0)? 10'b0 :(in1[0][9] ? ~in2 + 1 : in2);
    // assign out3 = {5'b00000 , in1[0][4:0]};

    always_comb begin
        case(in2)
        3'b000 : begin in3 = 4'h1; in4 = 4'h0; in5 = 4'h0; end
        3'b001 : begin in4 = 4'h2; in3 = 4'h0; in5 = 4'h0; end
        3'b100 : begin in5 = 4'h4; in4 = 4'h0; in3 = 4'h0; end
        default : begin
            in3 = 4'h0;
            in4 = 4'h0;
            in5 = 4'h0;
        end
        endcase
    end
    // adder_bits u_adder(
    //     .in1(tmp1) ,
    //     .in2(tmp2) ,
    //     .sum(out2)
    // );
//    assign out2 = in3 + in4 + in5 + in6;

endmodule