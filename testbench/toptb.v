`timescale 1ns / 1ns
module toptb;

  localparam formatWidth = 9;
  localparam expWidth = 4;
  localparam sigWidth = 4;
  localparam low_expand = 2;
  localparam fixWidth = 21;


  reg clk, rst, fft_start;
  reg [6:0] i;
  wire fft_done;
  reg [10:0] fft_size;
  reg [formatWidth-1:0] input_real[31:0];
  reg [formatWidth-1:0] input_imag[31:0];
  reg [formatWidth-1:0] twiddle_real[31:0];
  reg [formatWidth-1:0] twiddle_imag[31:0];
  wire [formatWidth-1:0] output_real[31:0];
  wire [formatWidth-1:0] output_imag[31:0];
  integer out_file;
  reg [4:0] outfile_flag;

  always@(negedge fft_done) begin
    outfile_flag <= outfile_flag + 1;
  end
  always@(posedge clk) begin
    if(outfile_flag == 2) begin
      for(i=0;i<32;i=i+1) begin
        $fwrite(out_file , "%d\n" , output_real[i]);
      end
      for(i=0;i<32;i=i+1) begin
        $fwrite(out_file , "%d\n" , output_imag[i]);
      end
      // outfile_flag <= 3;
      $fclose(out_file);
      // $stop;
    end
  end

  initial begin
    clk = 0;
    fft_start = 0;
    outfile_flag = 0;
    out_file = $fopen("/home/hank/code/matlab/track/tracker_release2/fft_sfp44/outfile/verilog.txt" , "w");
    {input_real[0],input_real[1],input_real[2],input_real[3],input_real[4],input_real[5],input_real[6],input_real[7],input_real[8],input_real[9],input_real[10],input_real[11],input_real[12],input_real[13],input_real[14],input_real[15],input_real[16],input_real[17],input_real[18],input_real[19],input_real[20],input_real[21],input_real[22],input_real[23],input_real[24],input_real[25],input_real[26],input_real[27],input_real[28],input_real[29],input_real[30],input_real[31]}=
    {
      9'b001001001,
      9'b001011001,
      9'b001100011,
      9'b001101001,
      9'b001110000,
      9'b001110011,
      9'b001110110,
      9'b001111001,
      9'b001111100,
      9'b010000000,
      9'b010000001,
      9'b010000011,
      9'b010000100,
      9'b010000110,
      9'b010001000,
      9'b010001001,
      9'b010001011,
      9'b010001100,
      9'b010001110,
      9'b010010000,
      9'b010010000,
      9'b010010001,
      9'b010010010,
      9'b010010011,
      9'b010010100,
      9'b010010100,
      9'b010010101,
      9'b010010110,
      9'b010010111,
      9'b010011000,
      9'b010011000,
      9'b010011001
    };

    {input_imag[0],input_imag[1],input_imag[2],input_imag[3],input_imag[4],input_imag[5],input_imag[6],input_imag[7],input_imag[8],input_imag[9],input_imag[10],input_imag[11],input_imag[12],input_imag[13],input_imag[14],input_imag[15],input_imag[16],input_imag[17],input_imag[18],input_imag[19],input_imag[20],input_imag[21],input_imag[22],input_imag[23],input_imag[24],input_imag[25],input_imag[26],input_imag[27],input_imag[28],input_imag[29],input_imag[30],input_imag[31]}=
    {
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000,
      9'b000000000
    };
    {twiddle_real[3], twiddle_real[2], twiddle_real[1], twiddle_real[0]} = {
      9'b010000000, 9'b010000000, 9'b010000000, 9'b010000000
    };
    {twiddle_real[7], twiddle_real[6], twiddle_real[5], twiddle_real[4]} = {
      9'b010000000, 9'b001111111, 9'b001111110, 9'b001111011
    };
    {twiddle_real[11], twiddle_real[10], twiddle_real[9], twiddle_real[8]} = {
      9'b010000000, 9'b001111110, 9'b001110111, 9'b001101000
    };
    {twiddle_real[15], twiddle_real[14], twiddle_real[13], twiddle_real[12]} = {
      9'b010000000, 9'b001111011, 9'b001101000, 9'b101011001
    };
    {twiddle_real[19], twiddle_real[18], twiddle_real[17], twiddle_real[16]} = {
      9'b010000000, 9'b001110111, 9'b000000000, 9'b101110111
    };
    {twiddle_real[23], twiddle_real[22], twiddle_real[21], twiddle_real[20]} = {
      9'b010000000, 9'b001110010, 9'b101101000, 9'b101111111
    };
    {twiddle_real[27], twiddle_real[26], twiddle_real[25], twiddle_real[24]} = {
      9'b010000000, 9'b001101000, 9'b101110111, 9'b101111110
    };
    {twiddle_real[31], twiddle_real[30], twiddle_real[29], twiddle_real[28]} = {
      9'b010000000, 9'b001011001, 9'b101111110, 9'b101110010
    };

    {twiddle_imag[3], twiddle_imag[2], twiddle_imag[1], twiddle_imag[0]} = {
      9'b000000000, 9'b000000000, 9'b000000000, 9'b000000000
    };
    {twiddle_imag[7], twiddle_imag[6], twiddle_imag[5], twiddle_imag[4]} = {
      9'b000000000, 9'b101011001, 9'b101101000, 9'b101110010
    };
    {twiddle_imag[11], twiddle_imag[10], twiddle_imag[9], twiddle_imag[8]} = {
      9'b000000000, 9'b101101000, 9'b101110111, 9'b101111110
    };
    {twiddle_imag[15], twiddle_imag[14], twiddle_imag[13], twiddle_imag[12]} = {
      9'b000000000, 9'b101110010, 9'b101111110, 9'b101111111
    };
    {twiddle_imag[19], twiddle_imag[18], twiddle_imag[17], twiddle_imag[16]} = {
      9'b000000000, 9'b101110111, 9'b110000000, 9'b101110111
    };
    {twiddle_imag[23], twiddle_imag[22], twiddle_imag[21], twiddle_imag[20]} = {
      9'b000000000, 9'b101111011, 9'b101111110, 9'b101011001
    };
    {twiddle_imag[27], twiddle_imag[26], twiddle_imag[25], twiddle_imag[24]} = {
      9'b000000000, 9'b101111110, 9'b101110111, 9'b001101000
    };
    {twiddle_imag[31], twiddle_imag[30], twiddle_imag[29], twiddle_imag[28]} = {
      9'b000000000, 9'b101111111, 9'b101101000, 9'b001111011
    };
    fft_size = 32;
    rst = 1;
    #20 rst = 0;
    #20 rst = 1;
    #20 fft_start = 1;
    #20 fft_start = 0;

  end

  always #10 clk = ~clk;
  top_control #(
      .formatWidth(formatWidth),
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u_top_control (
      .clk(clk),
      .rst(rst),
      .fft_size(fft_size),
      .fft_start(fft_start),
      .input_real({
        input_real[31],
        input_real[30],
        input_real[29],
        input_real[28],
        input_real[27],
        input_real[26],
        input_real[25],
        input_real[24],
        input_real[23],
        input_real[22],
        input_real[21],
        input_real[20],
        input_real[19],
        input_real[18],
        input_real[17],
        input_real[16],
        input_real[15],
        input_real[14],
        input_real[13],
        input_real[12],
        input_real[11],
        input_real[10],
        input_real[9],
        input_real[8],
        input_real[7],
        input_real[6],
        input_real[5],
        input_real[4],
        input_real[3],
        input_real[2],
        input_real[1],
        input_real[0]
      }),
      .input_imag({
        input_imag[31],
        input_imag[30],
        input_imag[29],
        input_imag[28],
        input_imag[27],
        input_imag[26],
        input_imag[25],
        input_imag[24],
        input_imag[23],
        input_imag[22],
        input_imag[21],
        input_imag[20],
        input_imag[19],
        input_imag[18],
        input_imag[17],
        input_imag[16],
        input_imag[15],
        input_imag[14],
        input_imag[13],
        input_imag[12],
        input_imag[11],
        input_imag[10],
        input_imag[9],
        input_imag[8],
        input_imag[7],
        input_imag[6],
        input_imag[5],
        input_imag[4],
        input_imag[3],
        input_imag[2],
        input_imag[1],
        input_imag[0]
      }),
      .twiddle_real({
        twiddle_real[31],
        twiddle_real[30],
        twiddle_real[29],
        twiddle_real[28],
        twiddle_real[27],
        twiddle_real[26],
        twiddle_real[25],
        twiddle_real[24],
        twiddle_real[23],
        twiddle_real[22],
        twiddle_real[21],
        twiddle_real[20],
        twiddle_real[19],
        twiddle_real[18],
        twiddle_real[17],
        twiddle_real[16],
        twiddle_real[15],
        twiddle_real[14],
        twiddle_real[13],
        twiddle_real[12],
        twiddle_real[11],
        twiddle_real[10],
        twiddle_real[9],
        twiddle_real[8],
        twiddle_real[7],
        twiddle_real[6],
        twiddle_real[5],
        twiddle_real[4],
        twiddle_real[3],
        twiddle_real[2],
        twiddle_real[1],
        twiddle_real[0]
      }),
      .twiddle_imag({
        twiddle_imag[31],
        twiddle_imag[30],
        twiddle_imag[29],
        twiddle_imag[28],
        twiddle_imag[27],
        twiddle_imag[26],
        twiddle_imag[25],
        twiddle_imag[24],
        twiddle_imag[23],
        twiddle_imag[22],
        twiddle_imag[21],
        twiddle_imag[20],
        twiddle_imag[19],
        twiddle_imag[18],
        twiddle_imag[17],
        twiddle_imag[16],
        twiddle_imag[15],
        twiddle_imag[14],
        twiddle_imag[13],
        twiddle_imag[12],
        twiddle_imag[11],
        twiddle_imag[10],
        twiddle_imag[9],
        twiddle_imag[8],
        twiddle_imag[7],
        twiddle_imag[6],
        twiddle_imag[5],
        twiddle_imag[4],
        twiddle_imag[3],
        twiddle_imag[2],
        twiddle_imag[1],
        twiddle_imag[0]
      }),
      .output_real({
        output_real[31],
        output_real[30],
        output_real[29],
        output_real[28],
        output_real[27],
        output_real[26],
        output_real[25],
        output_real[24],
        output_real[23],
        output_real[22],
        output_real[21],
        output_real[20],
        output_real[19],
        output_real[18],
        output_real[17],
        output_real[16],
        output_real[15],
        output_real[14],
        output_real[13],
        output_real[12],
        output_real[11],
        output_real[10],
        output_real[9],
        output_real[8],
        output_real[7],
        output_real[6],
        output_real[5],
        output_real[4],
        output_real[3],
        output_real[2],
        output_real[1],
        output_real[0]
      }),
      .output_imag({
        output_imag[31],
        output_imag[30],
        output_imag[29],
        output_imag[28],
        output_imag[27],
        output_imag[26],
        output_imag[25],
        output_imag[24],
        output_imag[23],
        output_imag[22],
        output_imag[21],
        output_imag[20],
        output_imag[19],
        output_imag[18],
        output_imag[17],
        output_imag[16],
        output_imag[15],
        output_imag[14],
        output_imag[13],
        output_imag[12],
        output_imag[11],
        output_imag[10],
        output_imag[9],
        output_imag[8],
        output_imag[7],
        output_imag[6],
        output_imag[5],
        output_imag[4],
        output_imag[3],
        output_imag[2],
        output_imag[1],
        output_imag[0]
      }),
      .fft_done(fft_done)
  );

endmodule
