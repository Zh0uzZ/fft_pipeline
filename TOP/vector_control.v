module vector_control #(
    parameter formatWidth = 9,
    parameter expWidth = 4,
    parameter sigWidth = 4,
    parameter low_expand = 2,
    parameter fixWidth = 21
) (
    input clk,
    input rst,
    input [10:0] fft_size,
    input fft_start,
    input [formatWidth*32-1:0] input_real,
    input [formatWidth*32-1:0] input_imag,
    input [formatWidth*32-1:0] twiddle_real,
    input [formatWidth*32-1:0] twiddle_imag,
    output reg [formatWidth*32-1:0] output_real,
    output reg [formatWidth*32-1:0] output_imag,
    output reg fft_done
);

  localparam vector_length = 4 * formatWidth;

  wire [formatWidth-1:0] input_real_label [0:31];
  wire [formatWidth-1:0] input_imag_label [0:31];
  wire [formatWidth-1:0] twiddle_real_label [0:31];
  wire [formatWidth-1:0] twiddle_imag_label [0:31];
  reg [            4:0] i;
  genvar                k;

  generate
    for(k = 0; k < 32; k = k + 1) begin
       assign input_real_label[k]   = input_real[formatWidth*(k+1)-1 : formatWidth*k];
       assign input_imag_label[k]   = input_imag[formatWidth*(k+1)-1 : formatWidth*k];
       assign twiddle_real_label[k] = twiddle_real[formatWidth*(k+1)-1 : formatWidth*k];
       assign twiddle_imag_label[k] = twiddle_imag[formatWidth*(k+1)-1 : formatWidth*k];
    end
  endgenerate

  reg                      vector_start;
  reg  [             10:0] fft_size_reg;
  reg  [              1:0] control [0:2];
  reg  [formatWidth*4-1:0] vector_input_real      [ 23:0];
  reg  [formatWidth*4-1:0] vector_input_imag      [ 23:0];
  reg  [formatWidth*4-1:0] twiddle_real_reg       [ 23:0];
  reg  [formatWidth*4-1:0] twiddle_imag_reg       [ 23:0];
  wire [formatWidth*4-1:0] vector_output_real     [ 23:0];
  wire [formatWidth*4-1:0] vector_output_imag     [ 23:0];

  // reg [formatWidth-1:0] vector_input_real [0:31];
  // reg [formatWidth-1:0] vector_input_imag [0:31];

  // reg [formatWidth-1:0] vector_output_real[0:31];
  // reg [formatWidth-1:0] vector_output_imag[0:31];



  //debug signals 
  wire [  formatWidth-1:0] wire_input_real        [ 3:0];
  wire [  formatWidth-1:0] wire_input_imag        [ 3:0];
  wire [  formatWidth-1:0] wire_output_real       [31:0];
  wire [  formatWidth-1:0] wire_output_imag       [31:0];
  wire [  formatWidth-1:0] wire_twiddle_real      [ 3:0];
  wire [  formatWidth-1:0] wire_twiddle_imag      [ 3:0];
  wire [  formatWidth-1:0] wire_vector_output_real[ 3:0];
  wire [  formatWidth-1:0] wire_vector_output_imag[ 3:0];

  generate
    for (k = 0; k < 32; k = k + 1) begin
      // assign wire_input_real[k]   = input_real[formatWidth*(k+1)-1:formatWidth*k];
      // assign wire_input_imag[k]   = input_imag[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_output_real[k] = output_real[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_output_imag[k] = output_imag[formatWidth*(k+1)-1:formatWidth*k];
      // assign wire_twiddle_real[k] = twiddle_real[formatWidth*(k+1)-1:formatWidth*k];
      // assign wire_twiddle_imag[k] = twiddle_imag[formatWidth*(k+1)-1:formatWidth*k];
      // assign wire_vector_output_real[k] = vector_output_real[0][formatWidth*(k+1)-1:formatWidth*k];
      // assign wire_vector_output_imag[k] = vector_output_imag[0][formatWidth*(k+1)-1:formatWidth*k];
    end
  endgenerate

//计数方式判断


  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 8; i = i + 1) begin
        vector_input_real[i] = {(formatWidth * 4 - 1) {1'b0}};
      end
      for (i = 0; i < 8; i = i + 1) begin
        vector_input_imag[i] = {(formatWidth * 4 - 1) {1'b0}};
      end
      vector_start <= 0;
      fft_size_reg <= 0;
      fft_done <= 0;
      output_real <= 0;
      output_imag <= 0;
      control[0] <= 2'b11;
      control[1] <= 2'b11;
      control[2] <= 2'b00;
    end else begin

//STAGE 1

        vector_input_real[0] <= { input_real_label[0] , input_real_label[8] , input_real_label[16] , input_real_label[24]};
        vector_input_real[1] <= { input_real_label[1] , input_real_label[9] , input_real_label[17] , input_real_label[25]};
        vector_input_real[2] <= { input_real_label[2] , input_real_label[10] , input_real_label[18] , input_real_label[26]};
        vector_input_real[3] <= { input_real_label[3] , input_real_label[11] , input_real_label[19] , input_real_label[27]};
        vector_input_real[4] <= { input_real_label[4] , input_real_label[12] , input_real_label[20] , input_real_label[28]};
        vector_input_real[5] <= { input_real_label[5] , input_real_label[13] , input_real_label[21] , input_real_label[29]};
        vector_input_real[6] <= { input_real_label[6] , input_real_label[14] , input_real_label[22] , input_real_label[30]};
        vector_input_real[7] <= { input_real_label[7] , input_real_label[15] , input_real_label[23] , input_real_label[31]};


        vector_input_imag[0] <= { input_imag_label[0] , input_imag_label[8]  , input_imag_label[16] , input_imag_label[24]};
        vector_input_imag[1] <= { input_imag_label[1] , input_imag_label[9]  , input_imag_label[17] , input_imag_label[25]};
        vector_input_imag[2] <= { input_imag_label[2] , input_imag_label[10] , input_imag_label[18] , input_imag_label[26]};
        vector_input_imag[3] <= { input_imag_label[3] , input_imag_label[11] , input_imag_label[19] , input_imag_label[27]};
        vector_input_imag[4] <= { input_imag_label[4] , input_imag_label[12] , input_imag_label[20] , input_imag_label[28]};
        vector_input_imag[5] <= { input_imag_label[5] , input_imag_label[13] , input_imag_label[21] , input_imag_label[29]};
        vector_input_imag[6] <= { input_imag_label[6] , input_imag_label[14] , input_imag_label[22] , input_imag_label[30]};
        vector_input_imag[7] <= { input_imag_label[7] , input_imag_label[15] , input_imag_label[23] , input_imag_label[31]};


        twiddle_real_reg[0] <= {twiddle_real[formatWidth*4-1:0]};
        twiddle_real_reg[1] <= {twiddle_real[formatWidth*8-1:formatWidth*4]};
        twiddle_real_reg[2] <= {twiddle_real[formatWidth*12-1:formatWidth*8]};
        twiddle_real_reg[3] <= {twiddle_real[formatWidth*16-1:formatWidth*12]};
        twiddle_real_reg[4] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
        twiddle_real_reg[5] <= {twiddle_real[formatWidth*24-1:formatWidth*20]};
        twiddle_real_reg[6] <= {twiddle_real[formatWidth*28-1:formatWidth*24]};
        twiddle_real_reg[7] <= {twiddle_real[formatWidth*32-1:formatWidth*28]};


        twiddle_imag_reg[0] <= {twiddle_imag[formatWidth*4-1:0]};
        twiddle_imag_reg[1] <= {twiddle_imag[formatWidth*8-1:formatWidth*4]};
        twiddle_imag_reg[2] <= {twiddle_imag[formatWidth*12-1:formatWidth*8]};
        twiddle_imag_reg[3] <= {twiddle_imag[formatWidth*16-1:formatWidth*12]};
        twiddle_imag_reg[4] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
        twiddle_imag_reg[5] <= {twiddle_imag[formatWidth*24-1:formatWidth*20]};
        twiddle_imag_reg[6] <= {twiddle_imag[formatWidth*28-1:formatWidth*24]};
        twiddle_imag_reg[7] <= {twiddle_imag[formatWidth*32-1:formatWidth*28]};

//STAGE 2

        vector_input_real[8] <= {
          vector_output_real[0][formatWidth*4-1:formatWidth*3],
          vector_output_real[2][formatWidth*4-1:formatWidth*3],
          vector_output_real[4][formatWidth*4-1:formatWidth*3],
          vector_output_real[6][formatWidth*4-1:formatWidth*3]
        };
        vector_input_real[9] <= {
          vector_output_real[1][formatWidth*4-1:formatWidth*3],
          vector_output_real[3][formatWidth*4-1:formatWidth*3],
          vector_output_real[5][formatWidth*4-1:formatWidth*3],
          vector_output_real[7][formatWidth*4-1:formatWidth*3]
        };
        vector_input_real[10] <= {
          vector_output_real[0][formatWidth*3-1:formatWidth*2],
          vector_output_real[2][formatWidth*3-1:formatWidth*2],
          vector_output_real[4][formatWidth*3-1:formatWidth*2],
          vector_output_real[6][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[11] <= {
          vector_output_real[1][formatWidth*3-1:formatWidth*2],
          vector_output_real[3][formatWidth*3-1:formatWidth*2],
          vector_output_real[5][formatWidth*3-1:formatWidth*2],
          vector_output_real[7][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[12] <= {
          vector_output_real[0][formatWidth*2-1:formatWidth*1],
          vector_output_real[2][formatWidth*2-1:formatWidth*1],
          vector_output_real[4][formatWidth*2-1:formatWidth*1],
          vector_output_real[6][formatWidth*2-1:formatWidth*1]
        };
        vector_input_real[13] <= {
          vector_output_real[1][formatWidth*2-1:formatWidth*1],
          vector_output_real[3][formatWidth*2-1:formatWidth*1],
          vector_output_real[5][formatWidth*2-1:formatWidth*1],
          vector_output_real[7][formatWidth*2-1:formatWidth*1]
        };
        vector_input_real[14] <= {
          vector_output_real[0][formatWidth*1-1:formatWidth*0],
          vector_output_real[2][formatWidth*1-1:formatWidth*0],
          vector_output_real[4][formatWidth*1-1:formatWidth*0],
          vector_output_real[6][formatWidth*1-1:formatWidth*0]
        };
        vector_input_real[15] <= {
          vector_output_real[1][formatWidth*1-1:formatWidth*0],
          vector_output_real[3][formatWidth*1-1:formatWidth*0],
          vector_output_real[5][formatWidth*1-1:formatWidth*0],
          vector_output_real[7][formatWidth*1-1:formatWidth*0]
        };


        vector_input_imag[8] <= {
          vector_output_imag[0][formatWidth*4-1:formatWidth*3],
          vector_output_imag[2][formatWidth*4-1:formatWidth*3],
          vector_output_imag[4][formatWidth*4-1:formatWidth*3],
          vector_output_imag[6][formatWidth*4-1:formatWidth*3]
        };
        vector_input_imag[9] <= {
          vector_output_imag[1][formatWidth*4-1:formatWidth*3],
          vector_output_imag[3][formatWidth*4-1:formatWidth*3],
          vector_output_imag[5][formatWidth*4-1:formatWidth*3],
          vector_output_imag[7][formatWidth*4-1:formatWidth*3]
        };
        vector_input_imag[10] <= {
          vector_output_imag[0][formatWidth*3-1:formatWidth*2],
          vector_output_imag[2][formatWidth*3-1:formatWidth*2],
          vector_output_imag[4][formatWidth*3-1:formatWidth*2],
          vector_output_imag[6][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[11] <= {
          vector_output_imag[1][formatWidth*3-1:formatWidth*2],
          vector_output_imag[3][formatWidth*3-1:formatWidth*2],
          vector_output_imag[5][formatWidth*3-1:formatWidth*2],
          vector_output_imag[7][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[12] <= {
          vector_output_imag[0][formatWidth*2-1:formatWidth*1],
          vector_output_imag[2][formatWidth*2-1:formatWidth*1],
          vector_output_imag[4][formatWidth*2-1:formatWidth*1],
          vector_output_imag[6][formatWidth*2-1:formatWidth*1]
        };
        vector_input_imag[13] <= {
          vector_output_imag[1][formatWidth*2-1:formatWidth*1],
          vector_output_imag[3][formatWidth*2-1:formatWidth*1],
          vector_output_imag[5][formatWidth*2-1:formatWidth*1],
          vector_output_imag[7][formatWidth*2-1:formatWidth*1]
        };
        vector_input_imag[14] <= {
          vector_output_imag[0][formatWidth*1-1:formatWidth*0],
          vector_output_imag[2][formatWidth*1-1:formatWidth*0],
          vector_output_imag[4][formatWidth*1-1:formatWidth*0],
          vector_output_imag[6][formatWidth*1-1:formatWidth*0]
        };
        vector_input_imag[15] <= {
          vector_output_imag[1][formatWidth*1-1:formatWidth*0],
          vector_output_imag[3][formatWidth*1-1:formatWidth*0],
          vector_output_imag[5][formatWidth*1-1:formatWidth*0],
          vector_output_imag[7][formatWidth*1-1:formatWidth*0]
        };


        twiddle_real_reg[8] <= {twiddle_real[formatWidth*4-1:0]};
        twiddle_real_reg[9] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
        twiddle_real_reg[10] <= {twiddle_real[formatWidth*4-1:0]};
        twiddle_real_reg[11] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
        twiddle_real_reg[12] <= {twiddle_real[formatWidth*4-1:0]};
        twiddle_real_reg[13] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
        twiddle_real_reg[14] <= {twiddle_real[formatWidth*4-1:0]};
        twiddle_real_reg[15] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};


        twiddle_imag_reg[8]  <= {twiddle_imag[formatWidth*4-1:0]};
        twiddle_imag_reg[9]  <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
        twiddle_imag_reg[10] <= {twiddle_imag[formatWidth*4-1:0]};
        twiddle_imag_reg[11] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
        twiddle_imag_reg[12] <= {twiddle_imag[formatWidth*4-1:0]};
        twiddle_imag_reg[13] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
        twiddle_imag_reg[14] <= {twiddle_imag[formatWidth*4-1:0]};
        twiddle_imag_reg[15] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};


// STAGE 3
        vector_input_real[16] <= {
          vector_output_real[8][formatWidth*4-1:formatWidth*3],
          vector_output_real[9][formatWidth*4-1:formatWidth*3],
          vector_output_real[8][formatWidth*3-1:formatWidth*2],
          vector_output_real[9][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[17] <= {
          vector_output_real[8][formatWidth*2-1:formatWidth*1],
          vector_output_real[9][formatWidth*2-1:formatWidth*1],
          vector_output_real[8][formatWidth*1-1:formatWidth*0],
          vector_output_real[9][formatWidth*1-1:formatWidth*0]
        };
        vector_input_real[18] <= {
          vector_output_real[10][formatWidth*4-1:formatWidth*3],
          vector_output_real[11][formatWidth*4-1:formatWidth*3],
          vector_output_real[10][formatWidth*3-1:formatWidth*2],
          vector_output_real[11][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[19] <= {
          vector_output_real[10][formatWidth*2-1:formatWidth*1],
          vector_output_real[11][formatWidth*2-1:formatWidth*1],
          vector_output_real[10][formatWidth*1-1:formatWidth*0],
          vector_output_real[11][formatWidth*1-1:formatWidth*0]
        };
        vector_input_real[20] <= {
          vector_output_real[12][formatWidth*4-1:formatWidth*3],
          vector_output_real[13][formatWidth*4-1:formatWidth*3],
          vector_output_real[12][formatWidth*3-1:formatWidth*2],
          vector_output_real[13][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[21] <= {
          vector_output_real[12][formatWidth*2-1:formatWidth*1],
          vector_output_real[13][formatWidth*2-1:formatWidth*1],
          vector_output_real[12][formatWidth*1-1:formatWidth*0],
          vector_output_real[13][formatWidth*1-1:formatWidth*0]
        };
        vector_input_real[22] <= {
          vector_output_real[14][formatWidth*4-1:formatWidth*3],
          vector_output_real[15][formatWidth*4-1:formatWidth*3],
          vector_output_real[14][formatWidth*3-1:formatWidth*2],
          vector_output_real[15][formatWidth*3-1:formatWidth*2]
        };
        vector_input_real[23] <= {
          vector_output_real[14][formatWidth*2-1:formatWidth*1],
          vector_output_real[15][formatWidth*2-1:formatWidth*1],
          vector_output_real[14][formatWidth*1-1:formatWidth*0],
          vector_output_real[15][formatWidth*1-1:formatWidth*0]
        };


        vector_input_imag[16] <= {
          vector_output_imag[8][formatWidth*4-1:formatWidth*3],
          vector_output_imag[9][formatWidth*4-1:formatWidth*3],
          vector_output_imag[8][formatWidth*3-1:formatWidth*2],
          vector_output_imag[9][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[17] <= {
          vector_output_imag[8][formatWidth*2-1:formatWidth*1],
          vector_output_imag[9][formatWidth*2-1:formatWidth*1],
          vector_output_imag[8][formatWidth*1-1:formatWidth*0],
          vector_output_imag[9][formatWidth*1-1:formatWidth*0]
        };
        vector_input_imag[18] <= {
          vector_output_imag[10][formatWidth*4-1:formatWidth*3],
          vector_output_imag[11][formatWidth*4-1:formatWidth*3],
          vector_output_imag[10][formatWidth*3-1:formatWidth*2],
          vector_output_imag[11][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[19] <= {
          vector_output_imag[10][formatWidth*2-1:formatWidth*1],
          vector_output_imag[11][formatWidth*2-1:formatWidth*1],
          vector_output_imag[10][formatWidth*1-1:formatWidth*0],
          vector_output_imag[11][formatWidth*1-1:formatWidth*0]
        };
        vector_input_imag[20] <= {
          vector_output_imag[12][formatWidth*4-1:formatWidth*3],
          vector_output_imag[13][formatWidth*4-1:formatWidth*3],
          vector_output_imag[12][formatWidth*3-1:formatWidth*2],
          vector_output_imag[13][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[21] <= {
          vector_output_imag[12][formatWidth*2-1:formatWidth*1],
          vector_output_imag[13][formatWidth*2-1:formatWidth*1],
          vector_output_imag[12][formatWidth*1-1:formatWidth*0],
          vector_output_imag[13][formatWidth*1-1:formatWidth*0]
        };
        vector_input_imag[22] <= {
          vector_output_imag[14][formatWidth*4-1:formatWidth*3],
          vector_output_imag[15][formatWidth*4-1:formatWidth*3],
          vector_output_imag[14][formatWidth*3-1:formatWidth*2],
          vector_output_imag[15][formatWidth*3-1:formatWidth*2]
        };
        vector_input_imag[23] <= {
          vector_output_imag[14][formatWidth*2-1:formatWidth*1],
          vector_output_imag[15][formatWidth*2-1:formatWidth*1],
          vector_output_imag[14][formatWidth*1-1:formatWidth*0],
          vector_output_imag[15][formatWidth*1-1:formatWidth*0]
        };




        output_real[vector_length*1-1:vector_length*0] <= {
          vector_output_real[22][formatWidth*4-1:formatWidth*3],
          vector_output_real[20][formatWidth*4-1:formatWidth*3],
          vector_output_real[18][formatWidth*4-1:formatWidth*3],
          vector_output_real[16][formatWidth*4-1:formatWidth*3]
        };
        output_real[vector_length*5-1:vector_length*4] <= {
          vector_output_real[22][formatWidth*2-1:formatWidth*1],
          vector_output_real[20][formatWidth*2-1:formatWidth*1],
          vector_output_real[18][formatWidth*2-1:formatWidth*1],
          vector_output_real[16][formatWidth*2-1:formatWidth*1]
        };
        output_real[vector_length*2-1:vector_length*1] <= {
          vector_output_real[22][formatWidth*3-1:formatWidth*2],
          vector_output_real[20][formatWidth*3-1:formatWidth*2],
          vector_output_real[18][formatWidth*3-1:formatWidth*2],
          vector_output_real[16][formatWidth*3-1:formatWidth*2]
        };
        output_real[vector_length*6-1:vector_length*5] <= {
          vector_output_real[22][formatWidth*1-1:formatWidth*0],
          vector_output_real[20][formatWidth*1-1:formatWidth*0],
          vector_output_real[18][formatWidth*1-1:formatWidth*0],
          vector_output_real[16][formatWidth*1-1:formatWidth*0]
        };
        output_real[vector_length*3-1:vector_length*2] <= {
          vector_output_real[23][formatWidth*4-1:formatWidth*3],
          vector_output_real[21][formatWidth*4-1:formatWidth*3],
          vector_output_real[19][formatWidth*4-1:formatWidth*3],
          vector_output_real[17][formatWidth*4-1:formatWidth*3]
        };
        output_real[vector_length*7-1:vector_length*6] <= {
          vector_output_real[23][formatWidth*2-1:formatWidth*1],
          vector_output_real[21][formatWidth*2-1:formatWidth*1],
          vector_output_real[19][formatWidth*2-1:formatWidth*1],
          vector_output_real[17][formatWidth*2-1:formatWidth*1]
        };
        output_real[vector_length*4-1:vector_length*3] <= {
          vector_output_real[23][formatWidth*3-1:formatWidth*2],
          vector_output_real[21][formatWidth*3-1:formatWidth*2],
          vector_output_real[19][formatWidth*3-1:formatWidth*2],
          vector_output_real[17][formatWidth*3-1:formatWidth*2]
        };
        output_real[vector_length*8-1:vector_length*7] <= {
          vector_output_real[23][formatWidth*1-1:formatWidth*0],
          vector_output_real[21][formatWidth*1-1:formatWidth*0],
          vector_output_real[19][formatWidth*1-1:formatWidth*0],
          vector_output_real[17][formatWidth*1-1:formatWidth*0]
        };


        output_imag[vector_length*1-1:vector_length*0] <= {
          vector_output_imag[22][formatWidth*4-1:formatWidth*3],
          vector_output_imag[20][formatWidth*4-1:formatWidth*3],
          vector_output_imag[18][formatWidth*4-1:formatWidth*3],
          vector_output_imag[16][formatWidth*4-1:formatWidth*3]
        };
        output_imag[vector_length*5-1:vector_length*4] <= {
          vector_output_imag[22][formatWidth*2-1:formatWidth*1],
          vector_output_imag[20][formatWidth*2-1:formatWidth*1],
          vector_output_imag[18][formatWidth*2-1:formatWidth*1],
          vector_output_imag[16][formatWidth*2-1:formatWidth*1]
        };
        output_imag[vector_length*2-1:vector_length*1] <= {
          vector_output_imag[22][formatWidth*3-1:formatWidth*2],
          vector_output_imag[20][formatWidth*3-1:formatWidth*2],
          vector_output_imag[18][formatWidth*3-1:formatWidth*2],
          vector_output_imag[16][formatWidth*3-1:formatWidth*2]
        };
        output_imag[vector_length*6-1:vector_length*5] <= {
          vector_output_imag[22][formatWidth*1-1:formatWidth*0],
          vector_output_imag[20][formatWidth*1-1:formatWidth*0],
          vector_output_imag[18][formatWidth*1-1:formatWidth*0],
          vector_output_imag[16][formatWidth*1-1:formatWidth*0]
        };
        output_imag[vector_length*3-1:vector_length*2] <= {
          vector_output_imag[23][formatWidth*4-1:formatWidth*3],
          vector_output_imag[21][formatWidth*4-1:formatWidth*3],
          vector_output_imag[19][formatWidth*4-1:formatWidth*3],
          vector_output_imag[17][formatWidth*4-1:formatWidth*3]
        };
        output_imag[vector_length*7-1:vector_length*6] <= {
          vector_output_imag[23][formatWidth*2-1:formatWidth*1],
          vector_output_imag[21][formatWidth*2-1:formatWidth*1],
          vector_output_imag[19][formatWidth*2-1:formatWidth*1],
          vector_output_imag[17][formatWidth*2-1:formatWidth*1]
        };
        output_imag[vector_length*4-1:vector_length*3] <= {
          vector_output_imag[23][formatWidth*3-1:formatWidth*2],
          vector_output_imag[21][formatWidth*3-1:formatWidth*2],
          vector_output_imag[19][formatWidth*3-1:formatWidth*2],
          vector_output_imag[17][formatWidth*3-1:formatWidth*2]
        };
        output_imag[vector_length*8-1:vector_length*7] <= {
          vector_output_imag[23][formatWidth*1-1:formatWidth*0],
          vector_output_imag[21][formatWidth*1-1:formatWidth*0],
          vector_output_imag[19][formatWidth*1-1:formatWidth*0],
          vector_output_imag[17][formatWidth*1-1:formatWidth*0]
        };
    end
  end


  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u0_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[0]),
      .input_imag(vector_input_imag[0]),
      .twiddle_real(twiddle_real_reg[0]),
      .twiddle_imag(twiddle_imag_reg[0]),
      .output_real(vector_output_real[0]),
      .output_imag(vector_output_imag[0]),
      .vector_done(vector_done)
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u1_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[1]),
      .input_imag(vector_input_imag[1]),
      .twiddle_real(twiddle_real_reg[1]),
      .twiddle_imag(twiddle_imag_reg[1]),
      .output_real(vector_output_real[1]),
      .output_imag(vector_output_imag[1]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u2_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[2]),
      .input_imag(vector_input_imag[2]),
      .twiddle_real(twiddle_real_reg[2]),
      .twiddle_imag(twiddle_imag_reg[2]),
      .output_real(vector_output_real[2]),
      .output_imag(vector_output_imag[2]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u3_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[3]),
      .input_imag(vector_input_imag[3]),
      .twiddle_real(twiddle_real_reg[3]),
      .twiddle_imag(twiddle_imag_reg[3]),
      .output_real(vector_output_real[3]),
      .output_imag(vector_output_imag[3]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u4_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[4]),
      .input_imag(vector_input_imag[4]),
      .twiddle_real(twiddle_real_reg[4]),
      .twiddle_imag(twiddle_imag_reg[4]),
      .output_real(vector_output_real[4]),
      .output_imag(vector_output_imag[4]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u5_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[5]),
      .input_imag(vector_input_imag[5]),
      .twiddle_real(twiddle_real_reg[5]),
      .twiddle_imag(twiddle_imag_reg[5]),
      .output_real(vector_output_real[5]),
      .output_imag(vector_output_imag[5]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u6_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[6]),
      .input_imag(vector_input_imag[6]),
      .twiddle_real(twiddle_real_reg[6]),
      .twiddle_imag(twiddle_imag_reg[6]),
      .output_real(vector_output_real[6]),
      .output_imag(vector_output_imag[6]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u7_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[0]),
      .input_real(vector_input_real[7]),
      .input_imag(vector_input_imag[7]),
      .twiddle_real(twiddle_real_reg[7]),
      .twiddle_imag(twiddle_imag_reg[7]),
      .output_real(vector_output_real[7]),
      .output_imag(vector_output_imag[7]),
      .vector_done()
  );




  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u8_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[8]),
      .input_imag(vector_input_imag[8]),
      .twiddle_real(twiddle_real_reg[8]),
      .twiddle_imag(twiddle_imag_reg[8]),
      .output_real(vector_output_real[8]),
      .output_imag(vector_output_imag[8]),
      .vector_done(vector_done)
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u9_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[9]),
      .input_imag(vector_input_imag[9]),
      .twiddle_real(twiddle_real_reg[9]),
      .twiddle_imag(twiddle_imag_reg[9]),
      .output_real(vector_output_real[9]),
      .output_imag(vector_output_imag[9]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u10_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[10]),
      .input_imag(vector_input_imag[10]),
      .twiddle_real(twiddle_real_reg[10]),
      .twiddle_imag(twiddle_imag_reg[10]),
      .output_real(vector_output_real[10]),
      .output_imag(vector_output_imag[10]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u11_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[11]),
      .input_imag(vector_input_imag[11]),
      .twiddle_real(twiddle_real_reg[11]),
      .twiddle_imag(twiddle_imag_reg[11]),
      .output_real(vector_output_real[11]),
      .output_imag(vector_output_imag[11]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u12_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[12]),
      .input_imag(vector_input_imag[12]),
      .twiddle_real(twiddle_real_reg[12]),
      .twiddle_imag(twiddle_imag_reg[12]),
      .output_real(vector_output_real[12]),
      .output_imag(vector_output_imag[12]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u13_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[13]),
      .input_imag(vector_input_imag[13]),
      .twiddle_real(twiddle_real_reg[13]),
      .twiddle_imag(twiddle_imag_reg[13]),
      .output_real(vector_output_real[13]),
      .output_imag(vector_output_imag[13]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u14_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[14]),
      .input_imag(vector_input_imag[14]),
      .twiddle_real(twiddle_real_reg[14]),
      .twiddle_imag(twiddle_imag_reg[14]),
      .output_real(vector_output_real[14]),
      .output_imag(vector_output_imag[14]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u15_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[1]),
      .input_real(vector_input_real[15]),
      .input_imag(vector_input_imag[15]),
      .twiddle_real(twiddle_real_reg[15]),
      .twiddle_imag(twiddle_imag_reg[15]),
      .output_real(vector_output_real[15]),
      .output_imag(vector_output_imag[15]),
      .vector_done()
  );



  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u16_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[16]),
      .input_imag(vector_input_imag[16]),
      .twiddle_real(twiddle_real_reg[16]),
      .twiddle_imag(twiddle_imag_reg[16]),
      .output_real(vector_output_real[16]),
      .output_imag(vector_output_imag[16]),
      .vector_done(vector_done)
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u17_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[17]),
      .input_imag(vector_input_imag[17]),
      .twiddle_real(twiddle_real_reg[17]),
      .twiddle_imag(twiddle_imag_reg[17]),
      .output_real(vector_output_real[17]),
      .output_imag(vector_output_imag[17]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u18_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[18]),
      .input_imag(vector_input_imag[18]),
      .twiddle_real(twiddle_real_reg[18]),
      .twiddle_imag(twiddle_imag_reg[18]),
      .output_real(vector_output_real[18]),
      .output_imag(vector_output_imag[18]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u19_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[19]),
      .input_imag(vector_input_imag[19]),
      .twiddle_real(twiddle_real_reg[19]),
      .twiddle_imag(twiddle_imag_reg[19]),
      .output_real(vector_output_real[19]),
      .output_imag(vector_output_imag[19]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u20_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[20]),
      .input_imag(vector_input_imag[20]),
      .twiddle_real(twiddle_real_reg[20]),
      .twiddle_imag(twiddle_imag_reg[20]),
      .output_real(vector_output_real[20]),
      .output_imag(vector_output_imag[20]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u21_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[21]),
      .input_imag(vector_input_imag[21]),
      .twiddle_real(twiddle_real_reg[21]),
      .twiddle_imag(twiddle_imag_reg[21]),
      .output_real(vector_output_real[21]),
      .output_imag(vector_output_imag[21]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u22_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[22]),
      .input_imag(vector_input_imag[22]),
      .twiddle_real(twiddle_real_reg[22]),
      .twiddle_imag(twiddle_imag_reg[22]),
      .output_real(vector_output_real[22]),
      .output_imag(vector_output_imag[22]),
      .vector_done()
  );

  vector_size4 #(
      .expWidth(expWidth),
      .sigWidth(sigWidth),
      .formatWidth(formatWidth),
      .low_expand(low_expand),
      .fixWidth(fixWidth)
  ) u23_vector (
      .clk(clk),
      .rst(rst),
      .start(vector_start),
      .control(control[2]),
      .input_real(vector_input_real[23]),
      .input_imag(vector_input_imag[23]),
      .twiddle_real(twiddle_real_reg[23]),
      .twiddle_imag(twiddle_imag_reg[23]),
      .output_real(vector_output_real[23]),
      .output_imag(vector_output_imag[23]),
      .vector_done()
  );

endmodule
