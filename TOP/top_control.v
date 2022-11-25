module top_control #(
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



  reg                      vector_start;
  reg  [              3:0] i;
  reg  [             10:0] fft_size_reg;
  reg  [              1:0] control;
  reg  [formatWidth*4-1:0] vector_input_real      [ 7:0];
  reg  [formatWidth*4-1:0] vector_input_imag      [ 7:0];
  reg  [formatWidth*4-1:0] twiddle_real_reg       [ 7:0];
  reg  [formatWidth*4-1:0] twiddle_imag_reg       [ 7:0];
  wire [formatWidth*4-1:0] vector_output_real     [ 7:0];
  wire [formatWidth*4-1:0] vector_output_imag     [ 7:0];

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

  genvar k;
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
    end else begin
      if (fft_start) begin
        fft_size_reg <= fft_size >> 2;
        vector_input_real[0] <= {
          input_real[formatWidth-1 : formatWidth*0],
          input_real[formatWidth*9-1:formatWidth*8],
          input_real[formatWidth*17-1:formatWidth*16],
          input_real[formatWidth*25-1:formatWidth*24]
        };
        vector_input_real[1] <= {
          input_real[formatWidth*2-1:formatWidth*1],
          input_real[formatWidth*10-1:formatWidth*9],
          input_real[formatWidth*18-1:formatWidth*17],
          input_real[formatWidth*26-1:formatWidth*25]
        };
        vector_input_real[2] <= {
          input_real[formatWidth*3-1:formatWidth*2],
          input_real[formatWidth*11-1:formatWidth*10],
          input_real[formatWidth*19-1:formatWidth*18],
          input_real[formatWidth*27-1:formatWidth*26]
        };
        vector_input_real[3] <= {
          input_real[formatWidth*4-1:formatWidth*3],
          input_real[formatWidth*12-1:formatWidth*11],
          input_real[formatWidth*20-1:formatWidth*19],
          input_real[formatWidth*28-1:formatWidth*27]
        };
        vector_input_real[4] <= {
          input_real[formatWidth*5-1:formatWidth*4],
          input_real[formatWidth*13-1:formatWidth*12],
          input_real[formatWidth*21-1:formatWidth*20],
          input_real[formatWidth*29-1:formatWidth*28]
        };
        vector_input_real[5] <= {
          input_real[formatWidth*6-1:formatWidth*5],
          input_real[formatWidth*14-1:formatWidth*13],
          input_real[formatWidth*22-1:formatWidth*21],
          input_real[formatWidth*30-1:formatWidth*29]
        };
        vector_input_real[6] <= {
          input_real[formatWidth*7-1:formatWidth*6],
          input_real[formatWidth*15-1:formatWidth*14],
          input_real[formatWidth*23-1:formatWidth*22],
          input_real[formatWidth*31-1:formatWidth*30]
        };
        vector_input_real[7] <= {
          input_real[formatWidth*8-1:formatWidth*7],
          input_real[formatWidth*16-1:formatWidth*15],
          input_real[formatWidth*24-1:formatWidth*23],
          input_real[formatWidth*32-1:formatWidth*31]
        };


        vector_input_imag[0] <= {
          input_imag[formatWidth-1 : formatWidth*0],
          input_imag[formatWidth*9-1:formatWidth*8],
          input_imag[formatWidth*17-1:formatWidth*16],
          input_imag[formatWidth*25-1:formatWidth*24]
        };
        vector_input_imag[1] <= {
          input_imag[formatWidth*2-1:formatWidth*1],
          input_imag[formatWidth*10-1:formatWidth*9],
          input_imag[formatWidth*18-1:formatWidth*17],
          input_imag[formatWidth*26-1:formatWidth*25]
        };
        vector_input_imag[2] <= {
          input_imag[formatWidth*3-1:formatWidth*2],
          input_imag[formatWidth*11-1:formatWidth*10],
          input_imag[formatWidth*19-1:formatWidth*18],
          input_imag[formatWidth*27-1:formatWidth*26]
        };
        vector_input_imag[3] <= {
          input_imag[formatWidth*4-1:formatWidth*3],
          input_imag[formatWidth*12-1:formatWidth*11],
          input_imag[formatWidth*20-1:formatWidth*19],
          input_imag[formatWidth*28-1:formatWidth*27]
        };
        vector_input_imag[4] <= {
          input_imag[formatWidth*5-1:formatWidth*4],
          input_imag[formatWidth*13-1:formatWidth*12],
          input_imag[formatWidth*21-1:formatWidth*20],
          input_imag[formatWidth*29-1:formatWidth*28]
        };
        vector_input_imag[5] <= {
          input_imag[formatWidth*6-1:formatWidth*5],
          input_imag[formatWidth*14-1:formatWidth*13],
          input_imag[formatWidth*22-1:formatWidth*21],
          input_imag[formatWidth*30-1:formatWidth*29]
        };
        vector_input_imag[6] <= {
          input_imag[formatWidth*7-1:formatWidth*6],
          input_imag[formatWidth*15-1:formatWidth*14],
          input_imag[formatWidth*23-1:formatWidth*22],
          input_imag[formatWidth*31-1:formatWidth*30]
        };
        vector_input_imag[7] <= {
          input_imag[formatWidth*8-1:formatWidth*7],
          input_imag[formatWidth*16-1:formatWidth*15],
          input_imag[formatWidth*24-1:formatWidth*23],
          input_imag[formatWidth*32-1:formatWidth*31]
        };


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


        control <= 2'b11;
        vector_start <= 1;
      end else if (vector_done) begin
        case (fft_size_reg[5:0])
          6'b001000: begin
            vector_input_real[0] <= {
              vector_output_real[0][formatWidth*4-1:formatWidth*3],
              vector_output_real[2][formatWidth*4-1:formatWidth*3],
              vector_output_real[4][formatWidth*4-1:formatWidth*3],
              vector_output_real[6][formatWidth*4-1:formatWidth*3]
            };
            vector_input_real[1] <= {
              vector_output_real[1][formatWidth*4-1:formatWidth*3],
              vector_output_real[3][formatWidth*4-1:formatWidth*3],
              vector_output_real[5][formatWidth*4-1:formatWidth*3],
              vector_output_real[7][formatWidth*4-1:formatWidth*3]
            };
            vector_input_real[2] <= {
              vector_output_real[0][formatWidth*3-1:formatWidth*2],
              vector_output_real[2][formatWidth*3-1:formatWidth*2],
              vector_output_real[4][formatWidth*3-1:formatWidth*2],
              vector_output_real[6][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[3] <= {
              vector_output_real[1][formatWidth*3-1:formatWidth*2],
              vector_output_real[3][formatWidth*3-1:formatWidth*2],
              vector_output_real[5][formatWidth*3-1:formatWidth*2],
              vector_output_real[7][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[4] <= {
              vector_output_real[0][formatWidth*2-1:formatWidth*1],
              vector_output_real[2][formatWidth*2-1:formatWidth*1],
              vector_output_real[4][formatWidth*2-1:formatWidth*1],
              vector_output_real[6][formatWidth*2-1:formatWidth*1]
            };
            vector_input_real[5] <= {
              vector_output_real[1][formatWidth*2-1:formatWidth*1],
              vector_output_real[3][formatWidth*2-1:formatWidth*1],
              vector_output_real[5][formatWidth*2-1:formatWidth*1],
              vector_output_real[7][formatWidth*2-1:formatWidth*1]
            };
            vector_input_real[6] <= {
              vector_output_real[0][formatWidth*1-1:formatWidth*0],
              vector_output_real[2][formatWidth*1-1:formatWidth*0],
              vector_output_real[4][formatWidth*1-1:formatWidth*0],
              vector_output_real[6][formatWidth*1-1:formatWidth*0]
            };
            vector_input_real[7] <= {
              vector_output_real[1][formatWidth*1-1:formatWidth*0],
              vector_output_real[3][formatWidth*1-1:formatWidth*0],
              vector_output_real[5][formatWidth*1-1:formatWidth*0],
              vector_output_real[7][formatWidth*1-1:formatWidth*0]
            };


            vector_input_imag[0] <= {
              vector_output_imag[0][formatWidth*4-1:formatWidth*3],
              vector_output_imag[2][formatWidth*4-1:formatWidth*3],
              vector_output_imag[4][formatWidth*4-1:formatWidth*3],
              vector_output_imag[6][formatWidth*4-1:formatWidth*3]
            };
            vector_input_imag[1] <= {
              vector_output_imag[1][formatWidth*4-1:formatWidth*3],
              vector_output_imag[3][formatWidth*4-1:formatWidth*3],
              vector_output_imag[5][formatWidth*4-1:formatWidth*3],
              vector_output_imag[7][formatWidth*4-1:formatWidth*3]
            };
            vector_input_imag[2] <= {
              vector_output_imag[0][formatWidth*3-1:formatWidth*2],
              vector_output_imag[2][formatWidth*3-1:formatWidth*2],
              vector_output_imag[4][formatWidth*3-1:formatWidth*2],
              vector_output_imag[6][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[3] <= {
              vector_output_imag[1][formatWidth*3-1:formatWidth*2],
              vector_output_imag[3][formatWidth*3-1:formatWidth*2],
              vector_output_imag[5][formatWidth*3-1:formatWidth*2],
              vector_output_imag[7][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[4] <= {
              vector_output_imag[0][formatWidth*2-1:formatWidth*1],
              vector_output_imag[2][formatWidth*2-1:formatWidth*1],
              vector_output_imag[4][formatWidth*2-1:formatWidth*1],
              vector_output_imag[6][formatWidth*2-1:formatWidth*1]
            };
            vector_input_imag[5] <= {
              vector_output_imag[1][formatWidth*2-1:formatWidth*1],
              vector_output_imag[3][formatWidth*2-1:formatWidth*1],
              vector_output_imag[5][formatWidth*2-1:formatWidth*1],
              vector_output_imag[7][formatWidth*2-1:formatWidth*1]
            };
            vector_input_imag[6] <= {
              vector_output_imag[0][formatWidth*1-1:formatWidth*0],
              vector_output_imag[2][formatWidth*1-1:formatWidth*0],
              vector_output_imag[4][formatWidth*1-1:formatWidth*0],
              vector_output_imag[6][formatWidth*1-1:formatWidth*0]
            };
            vector_input_imag[7] <= {
              vector_output_imag[1][formatWidth*1-1:formatWidth*0],
              vector_output_imag[3][formatWidth*1-1:formatWidth*0],
              vector_output_imag[5][formatWidth*1-1:formatWidth*0],
              vector_output_imag[7][formatWidth*1-1:formatWidth*0]
            };


            twiddle_real_reg[0] <= {twiddle_real[formatWidth*4-1:0]};
            twiddle_real_reg[1] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
            twiddle_real_reg[2] <= {twiddle_real[formatWidth*4-1:0]};
            twiddle_real_reg[3] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
            twiddle_real_reg[4] <= {twiddle_real[formatWidth*4-1:0]};
            twiddle_real_reg[5] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};
            twiddle_real_reg[6] <= {twiddle_real[formatWidth*4-1:0]};
            twiddle_real_reg[7] <= {twiddle_real[formatWidth*20-1:formatWidth*16]};


            twiddle_imag_reg[0] <= {twiddle_imag[formatWidth*4-1:0]};
            twiddle_imag_reg[1] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
            twiddle_imag_reg[2] <= {twiddle_imag[formatWidth*4-1:0]};
            twiddle_imag_reg[3] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
            twiddle_imag_reg[4] <= {twiddle_imag[formatWidth*4-1:0]};
            twiddle_imag_reg[5] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};
            twiddle_imag_reg[6] <= {twiddle_imag[formatWidth*4-1:0]};
            twiddle_imag_reg[7] <= {twiddle_imag[formatWidth*20-1:formatWidth*16]};


            control <= 2'b11;
            vector_start <= 1;
            fft_size_reg <= fft_size_reg >> 2;

          end
          6'b000010: begin
            vector_input_real[0] <= {
              vector_output_real[0][formatWidth*4-1:formatWidth*3],
              vector_output_real[1][formatWidth*4-1:formatWidth*3],
              vector_output_real[0][formatWidth*3-1:formatWidth*2],
              vector_output_real[1][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[1] <= {
              vector_output_real[0][formatWidth*2-1:formatWidth*1],
              vector_output_real[1][formatWidth*2-1:formatWidth*1],
              vector_output_real[0][formatWidth*1-1:formatWidth*0],
              vector_output_real[1][formatWidth*1-1:formatWidth*0]
            };
            vector_input_real[2] <= {
              vector_output_real[2][formatWidth*4-1:formatWidth*3],
              vector_output_real[3][formatWidth*4-1:formatWidth*3],
              vector_output_real[2][formatWidth*3-1:formatWidth*2],
              vector_output_real[3][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[3] <= {
              vector_output_real[2][formatWidth*2-1:formatWidth*1],
              vector_output_real[3][formatWidth*2-1:formatWidth*1],
              vector_output_real[2][formatWidth*1-1:formatWidth*0],
              vector_output_real[3][formatWidth*1-1:formatWidth*0]
            };
            vector_input_real[4] <= {
              vector_output_real[4][formatWidth*4-1:formatWidth*3],
              vector_output_real[5][formatWidth*4-1:formatWidth*3],
              vector_output_real[4][formatWidth*3-1:formatWidth*2],
              vector_output_real[5][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[5] <= {
              vector_output_real[4][formatWidth*2-1:formatWidth*1],
              vector_output_real[5][formatWidth*2-1:formatWidth*1],
              vector_output_real[4][formatWidth*1-1:formatWidth*0],
              vector_output_real[5][formatWidth*1-1:formatWidth*0]
            };
            vector_input_real[6] <= {
              vector_output_real[6][formatWidth*4-1:formatWidth*3],
              vector_output_real[7][formatWidth*4-1:formatWidth*3],
              vector_output_real[6][formatWidth*3-1:formatWidth*2],
              vector_output_real[7][formatWidth*3-1:formatWidth*2]
            };
            vector_input_real[7] <= {
              vector_output_real[6][formatWidth*2-1:formatWidth*1],
              vector_output_real[7][formatWidth*2-1:formatWidth*1],
              vector_output_real[6][formatWidth*1-1:formatWidth*0],
              vector_output_real[7][formatWidth*1-1:formatWidth*0]
            };


            vector_input_imag[0] <= {
              vector_output_imag[0][formatWidth*4-1:formatWidth*3],
              vector_output_imag[1][formatWidth*4-1:formatWidth*3],
              vector_output_imag[0][formatWidth*3-1:formatWidth*2],
              vector_output_imag[1][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[1] <= {
              vector_output_imag[0][formatWidth*2-1:formatWidth*1],
              vector_output_imag[1][formatWidth*2-1:formatWidth*1],
              vector_output_imag[0][formatWidth*1-1:formatWidth*0],
              vector_output_imag[1][formatWidth*1-1:formatWidth*0]
            };
            vector_input_imag[2] <= {
              vector_output_imag[2][formatWidth*4-1:formatWidth*3],
              vector_output_imag[3][formatWidth*4-1:formatWidth*3],
              vector_output_imag[2][formatWidth*3-1:formatWidth*2],
              vector_output_imag[3][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[3] <= {
              vector_output_imag[2][formatWidth*2-1:formatWidth*1],
              vector_output_imag[3][formatWidth*2-1:formatWidth*1],
              vector_output_imag[2][formatWidth*1-1:formatWidth*0],
              vector_output_imag[3][formatWidth*1-1:formatWidth*0]
            };
            vector_input_imag[4] <= {
              vector_output_imag[4][formatWidth*4-1:formatWidth*3],
              vector_output_imag[5][formatWidth*4-1:formatWidth*3],
              vector_output_imag[4][formatWidth*3-1:formatWidth*2],
              vector_output_imag[5][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[5] <= {
              vector_output_imag[4][formatWidth*2-1:formatWidth*1],
              vector_output_imag[5][formatWidth*2-1:formatWidth*1],
              vector_output_imag[4][formatWidth*1-1:formatWidth*0],
              vector_output_imag[5][formatWidth*1-1:formatWidth*0]
            };
            vector_input_imag[6] <= {
              vector_output_imag[6][formatWidth*4-1:formatWidth*3],
              vector_output_imag[7][formatWidth*4-1:formatWidth*3],
              vector_output_imag[6][formatWidth*3-1:formatWidth*2],
              vector_output_imag[7][formatWidth*3-1:formatWidth*2]
            };
            vector_input_imag[7] <= {
              vector_output_imag[6][formatWidth*2-1:formatWidth*1],
              vector_output_imag[7][formatWidth*2-1:formatWidth*1],
              vector_output_imag[6][formatWidth*1-1:formatWidth*0],
              vector_output_imag[7][formatWidth*1-1:formatWidth*0]
            };
            fft_size_reg <= fft_size_reg >> 1;
            control <= 2'b00;
            vector_start <= 1;


          end
          default: begin
            // output_real[vector_length*1-1:vector_length*0] <= {
            //   vector_output_real[6][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[4][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[2][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[0][formatWidth*4-1:formatWidth*3]
            // };
            // output_real[vector_length*2-1:vector_length*1] <= {
            //   vector_output_real[6][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[4][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[2][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[0][formatWidth*2-1:formatWidth*1]
            // };
            // output_real[vector_length*3-1:vector_length*2] <= {
            //   vector_output_real[6][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[4][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[2][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[0][formatWidth*3-1:formatWidth*2]
            // };
            // output_real[vector_length*4-1:vector_length*3] <= {
            //   vector_output_real[6][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[4][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[2][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[0][formatWidth*1-1:formatWidth*0]
            // };
            // output_real[vector_length*5-1:vector_length*4] <= {
            //   vector_output_real[7][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[5][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[3][formatWidth*4-1:formatWidth*3],
            //   vector_output_real[1][formatWidth*4-1:formatWidth*3]
            // };
            // output_real[vector_length*6-1:vector_length*5] <= {
            //   vector_output_real[7][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[5][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[3][formatWidth*2-1:formatWidth*1],
            //   vector_output_real[1][formatWidth*2-1:formatWidth*1]
            // };
            // output_real[vector_length*7-1:vector_length*6] <= {
            //   vector_output_real[7][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[5][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[3][formatWidth*3-1:formatWidth*2],
            //   vector_output_real[1][formatWidth*3-1:formatWidth*2]
            // };
            // output_real[vector_length*8-1:vector_length*7] <= {
            //   vector_output_real[7][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[5][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[3][formatWidth*1-1:formatWidth*0],
            //   vector_output_real[1][formatWidth*1-1:formatWidth*0]
            // };


            // output_imag[vector_length*1-1:vector_length*0] <= {
            //   vector_output_imag[6][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[4][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[2][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[0][formatWidth*4-1:formatWidth*3]
            // };                   
            // output_imag[vector_length*2-1:vector_length*1] <= {
            //   vector_output_imag[6][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[4][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[2][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[0][formatWidth*2-1:formatWidth*1]
            // };                   
            // output_imag[vector_length*3-1:vector_length*2] <= {
            //   vector_output_imag[6][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[4][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[2][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[0][formatWidth*3-1:formatWidth*2]
            // };                   
            // output_imag[vector_length*4-1:vector_length*3] <= {
            //   vector_output_imag[6][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[4][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[2][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[0][formatWidth*1-1:formatWidth*0]
            // };                   
            // output_imag[vector_length*5-1:vector_length*4] <= {
            //   vector_output_imag[7][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[5][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[3][formatWidth*4-1:formatWidth*3],
            //   vector_output_imag[1][formatWidth*4-1:formatWidth*3]
            // };                   
            // output_imag[vector_length*6-1:vector_length*5] <= {
            //   vector_output_imag[7][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[5][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[3][formatWidth*2-1:formatWidth*1],
            //   vector_output_imag[1][formatWidth*2-1:formatWidth*1]
            // };                   
            // output_imag[vector_length*7-1:vector_length*6] <= {
            //   vector_output_imag[7][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[5][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[3][formatWidth*3-1:formatWidth*2],
            //   vector_output_imag[1][formatWidth*3-1:formatWidth*2]
            // };                   
            // output_imag[vector_length*8-1:vector_length*7] <= {
            //   vector_output_imag[7][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[5][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[3][formatWidth*1-1:formatWidth*0],
            //   vector_output_imag[1][formatWidth*1-1:formatWidth*0]
            // };
            output_real[vector_length*1-1:vector_length*0] <= {
              vector_output_real[6][formatWidth*4-1:formatWidth*3],
              vector_output_real[4][formatWidth*4-1:formatWidth*3],
              vector_output_real[2][formatWidth*4-1:formatWidth*3],
              vector_output_real[0][formatWidth*4-1:formatWidth*3]
            };
            output_real[vector_length*5-1:vector_length*4] <= {
              vector_output_real[6][formatWidth*2-1:formatWidth*1],
              vector_output_real[4][formatWidth*2-1:formatWidth*1],
              vector_output_real[2][formatWidth*2-1:formatWidth*1],
              vector_output_real[0][formatWidth*2-1:formatWidth*1]
            };
            output_real[vector_length*2-1:vector_length*1] <= {
              vector_output_real[6][formatWidth*3-1:formatWidth*2],
              vector_output_real[4][formatWidth*3-1:formatWidth*2],
              vector_output_real[2][formatWidth*3-1:formatWidth*2],
              vector_output_real[0][formatWidth*3-1:formatWidth*2]
            };
            output_real[vector_length*6-1:vector_length*5] <= {
              vector_output_real[6][formatWidth*1-1:formatWidth*0],
              vector_output_real[4][formatWidth*1-1:formatWidth*0],
              vector_output_real[2][formatWidth*1-1:formatWidth*0],
              vector_output_real[0][formatWidth*1-1:formatWidth*0]
            };
            output_real[vector_length*3-1:vector_length*2] <= {
              vector_output_real[7][formatWidth*4-1:formatWidth*3],
              vector_output_real[5][formatWidth*4-1:formatWidth*3],
              vector_output_real[3][formatWidth*4-1:formatWidth*3],
              vector_output_real[1][formatWidth*4-1:formatWidth*3]
            };
            output_real[vector_length*7-1:vector_length*6] <= {
              vector_output_real[7][formatWidth*2-1:formatWidth*1],
              vector_output_real[5][formatWidth*2-1:formatWidth*1],
              vector_output_real[3][formatWidth*2-1:formatWidth*1],
              vector_output_real[1][formatWidth*2-1:formatWidth*1]
            };
            output_real[vector_length*4-1:vector_length*3] <= {
              vector_output_real[7][formatWidth*3-1:formatWidth*2],
              vector_output_real[5][formatWidth*3-1:formatWidth*2],
              vector_output_real[3][formatWidth*3-1:formatWidth*2],
              vector_output_real[1][formatWidth*3-1:formatWidth*2]
            };
            output_real[vector_length*8-1:vector_length*7] <= {
              vector_output_real[7][formatWidth*1-1:formatWidth*0],
              vector_output_real[5][formatWidth*1-1:formatWidth*0],
              vector_output_real[3][formatWidth*1-1:formatWidth*0],
              vector_output_real[1][formatWidth*1-1:formatWidth*0]
            };


            output_imag[vector_length*1-1:vector_length*0] <= {
              vector_output_imag[6][formatWidth*4-1:formatWidth*3],
              vector_output_imag[4][formatWidth*4-1:formatWidth*3],
              vector_output_imag[2][formatWidth*4-1:formatWidth*3],
              vector_output_imag[0][formatWidth*4-1:formatWidth*3]
            };
            output_imag[vector_length*5-1:vector_length*4] <= {
              vector_output_imag[6][formatWidth*2-1:formatWidth*1],
              vector_output_imag[4][formatWidth*2-1:formatWidth*1],
              vector_output_imag[2][formatWidth*2-1:formatWidth*1],
              vector_output_imag[0][formatWidth*2-1:formatWidth*1]
            };
            output_imag[vector_length*2-1:vector_length*1] <= {
              vector_output_imag[6][formatWidth*3-1:formatWidth*2],
              vector_output_imag[4][formatWidth*3-1:formatWidth*2],
              vector_output_imag[2][formatWidth*3-1:formatWidth*2],
              vector_output_imag[0][formatWidth*3-1:formatWidth*2]
            };
            output_imag[vector_length*6-1:vector_length*5] <= {
              vector_output_imag[6][formatWidth*1-1:formatWidth*0],
              vector_output_imag[4][formatWidth*1-1:formatWidth*0],
              vector_output_imag[2][formatWidth*1-1:formatWidth*0],
              vector_output_imag[0][formatWidth*1-1:formatWidth*0]
            };
            output_imag[vector_length*3-1:vector_length*2] <= {
              vector_output_imag[7][formatWidth*4-1:formatWidth*3],
              vector_output_imag[5][formatWidth*4-1:formatWidth*3],
              vector_output_imag[3][formatWidth*4-1:formatWidth*3],
              vector_output_imag[1][formatWidth*4-1:formatWidth*3]
            };
            output_imag[vector_length*7-1:vector_length*6] <= {
              vector_output_imag[7][formatWidth*2-1:formatWidth*1],
              vector_output_imag[5][formatWidth*2-1:formatWidth*1],
              vector_output_imag[3][formatWidth*2-1:formatWidth*1],
              vector_output_imag[1][formatWidth*2-1:formatWidth*1]
            };
            output_imag[vector_length*4-1:vector_length*3] <= {
              vector_output_imag[7][formatWidth*3-1:formatWidth*2],
              vector_output_imag[5][formatWidth*3-1:formatWidth*2],
              vector_output_imag[3][formatWidth*3-1:formatWidth*2],
              vector_output_imag[1][formatWidth*3-1:formatWidth*2]
            };
            output_imag[vector_length*8-1:vector_length*7] <= {
              vector_output_imag[7][formatWidth*1-1:formatWidth*0],
              vector_output_imag[5][formatWidth*1-1:formatWidth*0],
              vector_output_imag[3][formatWidth*1-1:formatWidth*0],
              vector_output_imag[1][formatWidth*1-1:formatWidth*0]
            };

            fft_done <= 1;
          end

        endcase
        // vector_start <= 1;
      end else begin
        fft_done <= 0;
        vector_start <= 0;
      end
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
      .control(control),
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
      .control(control),
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
      .control(control),
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
      .control(control),
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
      .control(control),
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
      .control(control),
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
      .control(control),
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
      .control(control),
      .input_real(vector_input_real[7]),
      .input_imag(vector_input_imag[7]),
      .twiddle_real(twiddle_real_reg[7]),
      .twiddle_imag(twiddle_imag_reg[7]),
      .output_real(vector_output_real[7]),
      .output_imag(vector_output_imag[7]),
      .vector_done()
  );


endmodule
