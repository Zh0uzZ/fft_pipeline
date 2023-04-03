`timescale 1ns / 1ns
`define dump_level 10 
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
  wire [formatWidth-1:0] input_real[31:0];
  wire [formatWidth-1:0] input_imag[31:0];
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
        $fwrite(out_file , "%d    %d\n" , output_real[i] , output_imag[i]);
      end
      // for(i=0;i<32;i=i+1) begin
      //   $fwrite(out_file , "%d\n" , output_imag[i]);
      // end
      // outfile_flag <= 3;
      $fclose(out_file);
      // $stop;
    end
  end



//read data from data txt
  integer hand_input;
  reg [formatWidth-1:0] input_data[0:1000];
  initial begin
    hand_input = $fopen("out.txt" , "r");
    for(integer j=0;j<400;j=j+1) begin
      $fscanf(hand_input , "%0d" , input_data[j]);
    end
    $fclose(hand_input);
    // $readmemh("out.txt" , input_data);
  end

  initial begin
    clk = 0;
    fft_start = 0;
    outfile_flag = 0;
    out_file = $fopen("verilog.txt" , "w");
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
    #940 $stop;
    // #20 fft_start = 0;

  end

  always #10 clk = ~clk;

  reg [formatWidth*32-1:0] vector_input_real;
  reg [formatWidth*32-1:0] vector_input_imag;

  reg [2:0] count_i;
      always@(posedge clk or negedge rst) begin
        if(~fft_start) begin
          count_i <= 0;
        end
        else begin
          count_i <= count_i + 1;
          if(fft_start) begin
            vector_input_real <= {input_data[0+64*count_i],input_data[1+64*count_i],input_data[2+64*count_i],input_data[3+64*count_i],input_data[4+64*count_i],
            input_data[5+64*count_i],input_data[6+64*count_i],input_data[7+64*count_i],input_data[8+64*count_i],input_data[9+64*count_i],input_data[10+64*count_i],input_data[11+64*count_i],
            input_data[12+64*count_i],input_data[13+64*count_i],input_data[14+64*count_i],input_data[15+64*count_i],input_data[16+64*count_i],input_data[17+64*count_i],input_data[18+64*count_i],
            input_data[19+64*count_i],input_data[20+64*count_i],input_data[21+64*count_i],input_data[22+64*count_i],input_data[23+64*count_i],input_data[24+64*count_i],input_data[25+64*count_i],
            input_data[26+64*count_i],input_data[27+64*count_i],input_data[28+64*count_i],input_data[29+64*count_i],input_data[30+64*count_i],input_data[31+64*count_i]};

            vector_input_imag <= {input_data[0+32+64*count_i],input_data[1+32+64*count_i],input_data[2+32+64*count_i],input_data[3+32+64*count_i],input_data[4+32+64*count_i],
            input_data[5+32+64*count_i],input_data[6+32+64*count_i],input_data[7+32+64*count_i],input_data[8+32+64*count_i],input_data[9+32+64*count_i],input_data[10+32+64*count_i],input_data[11+32+64*count_i],
            input_data[12+32+64*count_i],input_data[13+32+64*count_i],input_data[14+32+64*count_i],input_data[15+32+64*count_i],input_data[16+32+64*count_i],input_data[17+32+64*count_i],input_data[18+32+64*count_i],
            input_data[19+32+64*count_i],input_data[20+32+64*count_i],input_data[21+32+64*count_i],input_data[22+32+64*count_i],input_data[23+32+64*count_i],input_data[24+32+64*count_i],input_data[25+32+64*count_i],
            input_data[26+32+64*count_i],input_data[27+32+64*count_i],input_data[28+32+64*count_i],input_data[29+32+64*count_i],input_data[30+32+64*count_i],input_data[31+32+64*count_i]};
          end
          if(count_i == 5)
            count_i <= 0;
          end
        end



// debug input_real and input_imag
    genvar k;
    generate
      for(k=0;k<32;k=k+1) begin : debug_input
      assign  input_real[k] = vector_input_real[formatWidth*(k+1)-1:formatWidth*k];
      assign  input_imag[k] = vector_input_imag[formatWidth*(k+1)-1:formatWidth*k];
      end
    endgenerate

  
  wire [formatWidth*32-1:0] output_real_all;
  wire [formatWidth*32-1:0] output_imag_all;
  assign {output_real[0],output_real[1],output_real[2],output_real[3],output_real[4],output_real[5],output_real[6],output_real[7],output_real[8],
          output_real[9],output_real[10],output_real[11],output_real[12],output_real[13],output_real[14],output_real[15],output_real[16],output_real[17],
          output_real[18],output_real[19],output_real[20],output_real[21],output_real[22],output_real[23],output_real[24],output_real[25],output_real[26],
          output_real[27],output_real[28],output_real[29],output_real[30],output_real[31]}= output_real_all;
  assign {output_imag[0],output_imag[1],output_imag[2],output_imag[3],output_imag[4],output_imag[5],output_imag[6],output_imag[7],output_imag[8],
          output_imag[9],output_imag[10],output_imag[11],output_imag[12],output_imag[13],output_imag[14],output_imag[15],output_imag[16],output_imag[17],
          output_imag[18],output_imag[19],output_imag[20],output_imag[21],output_imag[22],output_imag[23],output_imag[24],output_imag[25],output_imag[26],
          output_imag[27],output_imag[28],output_imag[29],output_imag[30],output_imag[31]}= output_imag_all;
  
  vector_control #(
      .formatWidth(formatWidth),
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u_vector_control (
      .clk(clk),
      .rst(rst),
      .fft_size(fft_size),
      .fft_start(fft_start),
      .input_real(vector_input_real),
      .input_imag(vector_input_imag),
      .twiddle_real({twiddle_real[31],twiddle_real[30],twiddle_real[29],twiddle_real[28],twiddle_real[27],twiddle_real[26],twiddle_real[25],twiddle_real[24],twiddle_real[23],
      twiddle_real[22],twiddle_real[21],twiddle_real[20],twiddle_real[19],twiddle_real[18],twiddle_real[17],twiddle_real[16],twiddle_real[15],twiddle_real[14],twiddle_real[13],
      twiddle_real[12],twiddle_real[11],twiddle_real[10],twiddle_real[9],twiddle_real[8],twiddle_real[7],twiddle_real[6],twiddle_real[5],twiddle_real[4],twiddle_real[3],
      twiddle_real[2],twiddle_real[1],twiddle_real[0]
      }),
      .twiddle_imag({twiddle_imag[31],twiddle_imag[30],twiddle_imag[29],twiddle_imag[28],twiddle_imag[27],twiddle_imag[26],twiddle_imag[25],twiddle_imag[24],twiddle_imag[23],
      twiddle_imag[22],twiddle_imag[21],twiddle_imag[20],twiddle_imag[19],twiddle_imag[18],twiddle_imag[17],twiddle_imag[16],twiddle_imag[15],twiddle_imag[14],twiddle_imag[13],
      twiddle_imag[12],twiddle_imag[11],twiddle_imag[10],twiddle_imag[9],twiddle_imag[8],twiddle_imag[7],twiddle_imag[6],twiddle_imag[5],twiddle_imag[4],twiddle_imag[3],
      twiddle_imag[2],twiddle_imag[1],twiddle_imag[0]
      }),
      .output_real(output_real_all),
      .output_imag(output_imag_all),
      .fft_done(fft_done)
  );





initial begin#1; //延迟1ns记录，方便与其他仿真动作协调  
    `ifdef VCS_DUMP //Synopsys VCD+格式存储  
    $display("Start Recording Waveform in VPD format!");  
    $vcdpluson();  
    $vcdplustraceon;  
    `endif  
     
    `ifdef FSDB_DUMP //Synopsys fsdb格式存储  
    $display("Start Recording Waveform in FSDB format!");  
    $fsdbDumpfile("dump.fsdb");  
    $fsdbDumpvars('dump_level);  
    `endif  
     
     
    `ifdef NC_DUMP//cadence 格式存储  
    $recordsetup("dump","version=1","run=1","directory=.");  
    $recordvars("depth=6");  
    `endif  
     
    `ifdef VCD_DUMP//工业标准VCD格式存储  
    $display("Start Recording Waveform in VCD format!");  
    $dumpfile("dump.vcd");  
    $dumpvars('dump_level);  
    `endif  
end 


endmodule
