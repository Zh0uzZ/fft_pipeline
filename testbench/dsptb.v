module dsptb;
    reg clk;
    reg [18:0] a;
    reg [18:0] b;
    wire [19:0] c;
    wire [20:0] d;
    reg [4:0] mantissa;
    reg [7:0] test [4:0];
    reg [7:0] test1;
    initial begin
        clk = 0;
        a = 18'h434;
        b = 18'h234;
        mantissa = 4'b1111+1;
        #200 a = 18'h222; b = 18'h333; mantissa = 4'b1110+1;
        #200 a = 18'h522; b = 18'h433; mantissa = 4'b1011+1;
        #200 a = 18'h422; b = 18'h363; mantissa = 4'b1001+1;
        test[0] = 8'h77;
        // #100 test1 = {~test[7][0] , test[6:0][0]};
        #100 test1 = {~test[0][7] , test[0][6:0]};
    end
    always #10 clk = ~clk;
    xbip_dsp48_macro_0 u1dsp(
        .CLK(clk),
        .A(a),
        .D(b),
        .P(c)
    );
    add_21 uadd21(
        .CLK(clk),
        .A({3'b0 , a}),
        .C({3'b0 , b}),
        .P(d)
    );
    
endmodule