`timescale 1ns / 1ns
module fftb ();

  reg clk;
  reg flag, start;
  reg [2:0] a, b;

  initial begin
    clk = 0;
    a   = 3'b000;
    b   = 3'b000;
    #100 start = 1;
    #20 start = 0;
  end
  always #10 clk = ~clk;

  always @(posedge clk) begin
    if (start) begin
      a <= 3'b001;
    end else begin
      flag <= 0;
      if (a != 3'b000) begin
        a <= a + 1;
        if (a == 3'b111) begin
          a    <= 3'b000;
          flag <= 1;
        end
      end
    end
  end
  always @(posedge clk) begin
    if (flag) begin
      b <= 3'b001;
    end else begin
      start <= 0;
      if (b) begin
        b <= b + 1;
        if (b == 3'b111) begin
          start <= 1;
        end
      end
    end
  end
endmodule
