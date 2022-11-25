`timescale 1ns / 1ns
module hadamardtb;
  parameter expWidth = 4;
  parameter sigWidth = 4;
  parameter formatWidth = 9;
  parameter fixWidth = 21;
  
  reg rst, clk, start;
  reg flag;
  reg  [    formatWidth-1:0] input_real       [  3:0];
  reg  [    formatWidth-1:0] input_imag       [  3:0];
  wire [(formatWidth-1) : 0] output_real      [  3:0];
  wire [(formatWidth-1) : 0] output_imag      [  3:0];
  wire                       hadamard_done;
  (*black_box*)reg  [                8:0] twiddle_real     [0:255];
  (*black_box*)reg  [                8:0] twiddle_imag     [0:255];
  (*black_box*)reg                        twiddle_real_flag[0:255];
  (*black_box*)reg                        twiddle_imag_flag[0:255];


  initial begin
    $readmemb("./mem//twiddle_real.txt", twiddle_real);
    $readmemb("./mem//twiddle_imag.txt", twiddle_imag);
    $readmemb("./mem//twiddle_real_flag.txt", twiddle_real_flag);
    $readmemb("./mem//twiddle_imag_flag.txt", twiddle_imag_flag);
    clk = 0;
    rst = 1;
    #50 rst = 0;
    #50 rst = 1;
    #50
    {input_real[3], input_real[2], input_real[1], input_real[0]} = {
      9'b1_1100_1000, 9'b0_1000_1000, 9'b1_0111_1111, 9'b1_1100_1000
    };
    {input_imag[3], input_imag[2], input_imag[1], input_imag[0]} = {
      9'b1_1100_1000, 9'b0_1000_1000, 9'b1_0111_1111, 9'b1_1100_1000
    };
     start = 1;#25 start = 0;
    #200
    start =1; 
    {input_real[3], input_real[2], input_real[1], input_real[0]} = {
      9'b0_1100_1000, 9'b0_1000_1000, 9'b1_0101_1111, 9'b1_1100_1000
    };
    {input_imag[3], input_imag[2], input_imag[1], input_imag[0]} = {
      9'b0_1101_1000, 9'b0_1010_1000, 9'b1_0111_1111, 9'b1_1100_1000
    }; #25 start = 0;
    #150
    {input_real[3], input_real[2], input_real[1], input_real[0]} = {
      9'b1_1100_1000, 9'b0_1000_1000, 9'b1_0111_1111, 9'b1_1100_1000
    };
    {input_imag[3], input_imag[2], input_imag[1], input_imag[0]} = {
      9'b1_1100_1000, 9'b0_1000_1000, 9'b1_0111_1111, 9'b1_1100_1000
    };
    start = 1; #25 start = 0;
  end
  always #10 clk = ~clk;
  // Memory Array  
  complexhadamard #(
    .expWidth   (expWidth),
    .sigWidth   (sigWidth),
    .formatWidth(formatWidth),
    .fixWidth   (fixWidth)
  ) u_complexhadamard (
    .clk              (clk),
    .rst              (rst),
    .start            (start),
    .input_real       ({input_real[3], input_real[2], input_real[1], input_real[0]}),
    .input_imag       ({input_imag[3], input_imag[2], input_imag[1], input_imag[0]}),
    .twiddle_real     ({twiddle_real[0], twiddle_real[1], twiddle_real[2], twiddle_real[3]}),
    .twiddle_imag     ({twiddle_imag[0], twiddle_imag[1], twiddle_imag[2], twiddle_imag[3]}),
    .twiddle_real_flag({twiddle_real_flag[0] , twiddle_real_flag[1] , twiddle_real_flag[2] , twiddle_real_flag[3]}),
    .twiddle_imag_flag({twiddle_imag_flag[0] , twiddle_imag_flag[1] , twiddle_imag_flag[2] , twiddle_imag_flag[3]}),
    .output_real      ({output_real[3], output_real[2], output_real[1], output_real[0]}),
    .output_imag      ({output_imag[3], output_imag[2], output_imag[1], output_imag[0]}),
    .hadamard_done    (hadamard_done)
  );
  always @(posedge clk) begin
    if(hadamard_done)
      flag <= 1;
    else
      flag<=0;
  end

endmodule
