`timescale 1ns/1ns
module testaddertb();
    reg [0:3] a,b,f;
    reg c;
    wire [4:0] d,e;
    reg clk;
    reg [5:0] fft_size;
    reg [2:0] tmp1 , tmp2 , tmp3;
    
    wire [3:0] tmp4;
    reg [2:0] tmp5;
    
 
    initial begin
        a = 3'b011;
        b = 3'b011;
        f = 3'b001;
        c = 1;
        clk = 0;
        fft_size = 6'b100000;
        tmp5 = 2;
    end
    testadder utest(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e)
    );
    assign tmp4 = tmp5;
    always #10 clk = ~clk;
    always@(posedge clk) begin
        case (fft_size)
            6'b100000:begin
                fft_size <= fft_size>>1;
                tmp1 <= tmp2;
            end
            6'b010000:begin
                fft_size <= fft_size>>1;
                tmp1 <= tmp2+1;
            end
        endcase
    end
    always@(*) begin
        case(fft_size)
            6'b100000:begin
                tmp2 = 2;
            end
            6'b010000:begin
                tmp2 = 4;
            end
        endcase
    end
    always@(posedge clk) begin
        if(tmp2 == 4)
            tmp3 <= 1;
    end

endmodule