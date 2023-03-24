module fsmtb;
  localparam PERIOD = 10;
  reg clk;
  reg [4:0] a , b , c;
  wire [8:0] sum;
  initial begin
    clk = 0;
    a = 4;
    repeat(20) begin
        @(negedge clk) ;
        a = a + 1;
    end
    $finish;
  end

  always begin
    #PERIOD clk = ~clk;
  end
  
  fsm u_fsm(
    .clk(clk),
    .start(1'b1),
    .a(a),
    .sum(sum)
  );
endmodule