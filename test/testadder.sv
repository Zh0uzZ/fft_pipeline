module testadder #(
parameter type addr_t = logic [9:0]
)(
    input clk,
    input addr_t [2:0] in1 ,
    input [9:0] in2,
    input [9:0] in3,
    input [9:0] in4,
    input [9:0] in5,
    input [9:0] in6,
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
    assign out1 = (in1[0] == 10'b0)? 10'b0 :(in1[0][9] ? ~in2 + 1 : in2);
    assign out3 = {5'b00000 , in1[0][4:0]};
    // adder_bits u_adder(
    //     .in1(tmp1) ,
    //     .in2(tmp2) ,
    //     .sum(out2)
    // );
//    assign out2 = in3 + in4 + in5 + in6;

endmodule