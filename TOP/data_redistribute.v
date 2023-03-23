module data_redistribute #(
  parameter formatWidth = 9
) (
  input                      clk,
  input                      rst,
  input                      start,
  input [              11:0] fft_size,
  input [formatWidth*32-1:0] input_real,
  input [formatWidth*32-1:0] input_imag,

  input [formatWidth*4-1:0] vector_output_real_0,
  input [formatWidth*4-1:0] vector_output_imag_0,
  input [formatWidth*4-1:0] vector_output_real_1,
  input [formatWidth*4-1:0] vector_output_imag_1,
  input [formatWidth*4-1:0] vector_output_real_2,
  input [formatWidth*4-1:0] vector_output_imag_2,
  input [formatWidth*4-1:0] vector_output_real_3,
  input [formatWidth*4-1:0] vector_output_imag_3,
  input [formatWidth*4-1:0] vector_output_real_4,
  input [formatWidth*4-1:0] vector_output_imag_4,
  input [formatWidth*4-1:0] vector_output_real_5,
  input [formatWidth*4-1:0] vector_output_imag_5,
  input [formatWidth*4-1:0] vector_output_real_6,
  input [formatWidth*4-1:0] vector_output_imag_6,
  input [formatWidth*4-1:0] vector_output_real_7,
  input [formatWidth*4-1:0] vector_output_imag_7,

  output [ formatWidth*4-1:0] vector_input_real_0,
  output [ formatWidth*4-1:0] vector_input_imag_0,
  output [ formatWidth*4-1:0] vector_input_real_1,
  output [ formatWidth*4-1:0] vector_input_imag_1,
  output [ formatWidth*4-1:0] vector_input_real_2,
  output [ formatWidth*4-1:0] vector_input_imag_2,
  output [ formatWidth*4-1:0] vector_input_real_3,
  output [ formatWidth*4-1:0] vector_input_imag_3,
  output [ formatWidth*4-1:0] vector_input_real_4,
  output [ formatWidth*4-1:0] vector_input_imag_4,
  output [ formatWidth*4-1:0] vector_input_real_5,
  output [ formatWidth*4-1:0] vector_input_imag_5,
  output [ formatWidth*4-1:0] vector_input_real_6,
  output [ formatWidth*4-1:0] vector_input_imag_6,
  output [ formatWidth*4-1:0] vector_input_real_7,
  output [ formatWidth*4-1:0] vector_input_imag_7,
  output [formatWidth*32-1:0] output_real,
  output [formatWidth*32-1:0] output_imag

);

  reg [formatWidth-1:0] temp_output_real[31:0];
  reg [formatWidth-1:0] temp_output_imag[31:0];
  genvar i;

  always @(posedge clk or negedge rst) begin
    if (~rst) begin
    end else begin
      if (start) begin
        case (fft_size_reg)
          6'b100000: begin
            vector_input_real_0 <= {
              input_real[formatWidth-1 : formatWidth*0],
              input_real[formatWidth*9-1:formatWidth*8],
              input_real[formatWidth*17-1:formatWidth*16],
              input_real[formatWidth*25-1:formatWidth*24]
            };
            vector_input_real_1 <= {
              input_real[formatWidth*2-1:formatWidth*1],
              input_real[formatWidth*10-1:formatWidth*9],
              input_real[formatWidth*18-1:formatWidth*17],
              input_real[formatWidth*26-1:formatWidth*25]
            };
            vector_input_real_2 = {
              input_real[formatWidth*3-1:formatWidth*2],
              input_real[formatWidth*11-1:formatWidth*10],
              input_real[formatWidth*19-1:formatWidth*18],
              input_real[formatWidth*27-1:formatWidth*26]
            };
            vector_input_real_3 <= {
              input_real[formatWidth*4-1:formatWidth*3],
              input_real[formatWidth*12-1:formatWidth*11],
              input_real[formatWidth*20-1:formatWidth*19],
              input_real[formatWidth*28-1:formatWidth*27]
            };
            vector_input_real_4 <= {
              input_real[formatWidth*5-1:formatWidth*4],
              input_real[formatWidth*13-1:formatWidth*12],
              input_real[formatWidth*21-1:formatWidth*20],
              input_real[formatWidth*29-1:formatWidth*28]
            };
            vector_input_real_5 <= {
              input_real[formatWidth*6-1:formatWidth*5],
              input_real[formatWidth*14-1:formatWidth*13],
              input_real[formatWidth*22-1:formatWidth*21],
              input_real[formatWidth*30-1:formatWidth*29]
            };
            vector_input_real_6 <= {
              input_real[formatWidth*7-1:formatWidth*6],
              input_real[formatWidth*15-1:formatWidth*14],
              input_real[formatWidth*23-1:formatWidth*22],
              input_real[formatWidth*31-1:formatWidth*30]
            };
            vector_input_real_7 <= {
              input_real[formatWidth*8-1:formatWidth*7],
              input_real[formatWidth*16-1:formatWidth*15],
              input_real[formatWidth*24-1:formatWidth*23],
              input_real[formatWidth*32-1:formatWidth*31]
            };


            vector_input_imag_0 <= {
              input_imag[formatWidth-1 : formatWidth*0],
              input_imag[formatWidth*9-1:formatWidth*8],
              input_imag[formatWidth*17-1:formatWidth*16],
              input_imag[formatWidth*25-1:formatWidth*24]
            };
            vector_input_imag_1 <= {
              input_imag[formatWidth*2-1:formatWidth*1],
              input_imag[formatWidth*10-1:formatWidth*9],
              input_imag[formatWidth*18-1:formatWidth*17],
              input_imag[formatWidth*26-1:formatWidth*25]
            };
            vector_input_imag_2 <= {
              input_imag[formatWidth*3-1:formatWidth*2],
              input_imag[formatWidth*11-1:formatWidth*10],
              input_imag[formatWidth*19-1:formatWidth*18],
              input_imag[formatWidth*27-1:formatWidth*26]
            };
            vector_input_imag_3 <= {
              input_imag[formatWidth*4-1:formatWidth*3],
              input_imag[formatWidth*12-1:formatWidth*11],
              input_imag[formatWidth*20-1:formatWidth*19],
              input_imag[formatWidth*28-1:formatWidth*27]
            };
            vector_input_imag_4 <= {
              input_imag[formatWidth*5-1:formatWidth*4],
              input_imag[formatWidth*13-1:formatWidth*12],
              input_imag[formatWidth*21-1:formatWidth*20],
              input_imag[formatWidth*29-1:formatWidth*28]
            };
            vector_input_imag_5 <= {
              input_imag[formatWidth*6-1:formatWidth*5],
              input_imag[formatWidth*14-1:formatWidth*13],
              input_imag[formatWidth*22-1:formatWidth*21],
              input_imag[formatWidth*30-1:formatWidth*29]
            };
            vector_input_imag_6 <= {
              input_imag[formatWidth*7-1:formatWidth*6],
              input_imag[formatWidth*15-1:formatWidth*14],
              input_imag[formatWidth*23-1:formatWidth*22],
              input_imag[formatWidth*31-1:formatWidth*30]
            };
            vector_input_imag_7 <= {
              input_imag[formatWidth*8-1:formatWidth*7],
              input_imag[formatWidth*16-1:formatWidth*15],
              input_imag[formatWidth*24-1:formatWidth*23],
              input_imag[formatWidth*32-1:formatWidth*31]
            };
          end
          6'b001000: begin
            
            vector_input_real_0 <= {temp_output_real[0]  , temp_output_real[2] ,  temp_output_real[4] ,  temp_output_real[6]};
            vector_input_real_1 <= {temp_output_real[1]  , temp_output_real[3] ,  temp_output_real[5] ,  temp_output_real[7]};
            vector_input_real_2 <= {temp_output_real[8]  , temp_output_real[10] , temp_output_real[12] , temp_output_real[14]};
            vector_input_real_3 <= {temp_output_real[9]  , temp_output_real[11] , temp_output_real[13] , temp_output_real[15]};
            vector_input_real_4 <= {temp_output_real[16] , temp_output_real[18] , temp_output_real[20] , temp_output_real[22]};
            vector_input_real_5 <= {temp_output_real[17] , temp_output_real[19] , temp_output_real[21] , temp_output_real[23]};
            vector_input_real_6 <= {temp_output_real[24] , temp_output_real[26] , temp_output_real[28] , temp_output_real[30]};
            vector_input_real_7 <= {temp_output_real[25] , temp_output_real[27] , temp_output_real[29] , temp_output_real[31]};

            vector_input_imag_0 <= {temp_output_imag[0]  , temp_output_imag[2] ,  temp_output_imag[4] ,  temp_output_imag[6]};
            vector_input_imag_1 <= {temp_output_imag[1]  , temp_output_imag[3] ,  temp_output_imag[5] ,  temp_output_imag[7]};
            vector_input_imag_2 <= {temp_output_imag[8]  , temp_output_imag[10] , temp_output_imag[12] , temp_output_imag[14]};
            vector_input_imag_3 <= {temp_output_imag[9]  , temp_output_imag[11] , temp_output_imag[13] , temp_output_imag[15]};
            vector_input_imag_4 <= {temp_output_imag[16] , temp_output_imag[18] , temp_output_imag[20] , temp_output_imag[22]};
            vector_input_imag_5 <= {temp_output_imag[17] , temp_output_imag[19] , temp_output_imag[21] , temp_output_imag[23]};
            vector_input_imag_6 <= {temp_output_imag[24] , temp_output_imag[26] , temp_output_imag[28] , temp_output_imag[30]};
            vector_input_imag_7 <= {temp_output_imag[25] , temp_output_imag[27] , temp_output_imag[29] , temp_output_imag[31]};
            
          end

          6'b000010: begin
            vector_input_real_0 <= {temp_output_real[0]  , temp_output_real[1] ,  temp_output_real[2] ,  temp_output_real[3]};
            vector_input_real_1 <= {temp_output_real[4]  , temp_output_real[5] ,  temp_output_real[6] ,  temp_output_real[7]};
            vector_input_real_2 <= {temp_output_real[8]  , temp_output_real[9] ,  temp_output_real[10] , temp_output_real[11]};
            vector_input_real_3 <= {temp_output_real[12] , temp_output_real[13] , temp_output_real[14] , temp_output_real[15]};
            vector_input_real_4 <= {temp_output_real[16] , temp_output_real[17] , temp_output_real[18] , temp_output_real[19]};
            vector_input_real_5 <= {temp_output_real[20] , temp_output_real[21] , temp_output_real[22] , temp_output_real[23]};
            vector_input_real_6 <= {temp_output_real[24] , temp_output_real[25] , temp_output_real[26] , temp_output_real[27]};
            vector_input_real_7 <= {temp_output_real[28] , temp_output_real[29] , temp_output_real[30] , temp_output_real[31]};

            vector_input_real_0 <= {temp_output_real[0]  , temp_output_real[1] ,  temp_output_real[2] ,  temp_output_real[3]};
            vector_input_real_1 <= {temp_output_real[4]  , temp_output_real[5] ,  temp_output_real[6] ,  temp_output_real[7]};
            vector_input_real_2 <= {temp_output_real[8]  , temp_output_real[9] ,  temp_output_real[10] , temp_output_real[11]};
            vector_input_real_3 <= {temp_output_real[12] , temp_output_real[13] , temp_output_real[14] , temp_output_real[15]};
            vector_input_real_4 <= {temp_output_real[16] , temp_output_real[17] , temp_output_real[18] , temp_output_real[19]};
            vector_input_real_5 <= {temp_output_real[20] , temp_output_real[21] , temp_output_real[22] , temp_output_real[23]};
            vector_input_real_6 <= {temp_output_real[24] , temp_output_real[25] , temp_output_real[26] , temp_output_real[27]};
            vector_input_real_7 <= {temp_output_real[28] , temp_output_real[29] , temp_output_real[30] , temp_output_real[31]};
            
          end
        endcase
      end
    end
  end

  always @(*) begin
    case (fft_size_reg)
      6'b001000: begin
        for (i = 0; i < 4; i = i + 1) begin
          {temp_output_real[0+8*i] , temp_output_real[1+8*i] , temp_output_real[2+8*i] , temp_output_real[3+8*i] , temp_output_real[4+8*i] , temp_output_real[5+8*i] , temp_output_real[6+8*i] , temp_output_real[7+8*i]} = 
                {
            vector_output_real_0[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_1[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_2[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_3[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_4[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_5[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_6[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_real_7[formatWidth*(4-i)-1:formatWidth*(3-i)]
          };

          {temp_output_imag[0+8*i] , temp_output_imag[1+8*i] , temp_output_imag[2+8*i] , temp_output_imag[3+8*i] , temp_output_imag[4+8*i] , temp_output_imag[5+8*i] , temp_output_imag[6+8*i] , temp_output_imag[7+8*i]} = 
                {
            vector_output_imag_0[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_1[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_2[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_3[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_4[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_5[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_6[formatWidth*(4-i)-1:formatWidth*(3-i)],
            vector_output_imag_7[formatWidth*(4-i)-1:formatWidth*(3-i)]
          };
        end
        end
      6'b000010: begin
        {temp_output_real[0]  , temp_output_real[2] ,  temp_output_real[4] ,  temp_output_real[6]}  = vector_output_real_0;
        {temp_output_real[1]  , temp_output_real[3]  , temp_output_real[5]  , temp_output_real[7]}  = vector_output_real_1;
        {temp_output_real[8]  , temp_output_real[10] , temp_output_real[12] , temp_output_real[14]} = vector_output_real_2;
        {temp_output_real[9]  , temp_output_real[11] , temp_output_real[13] , temp_output_real[15]} = vector_output_real_3;
        {temp_output_real[16] , temp_output_real[18] , temp_output_real[20] , temp_output_real[22]} = vector_output_real_4;
        {temp_output_real[17] , temp_output_real[19] , temp_output_real[21] , temp_output_real[23]} = vector_output_real_5;
        {temp_output_real[24] , temp_output_real[26] , temp_output_real[28] , temp_output_real[30]} = vector_output_real_6;
        {temp_output_real[25] , temp_output_real[27] , temp_output_real[29] , temp_output_real[31]} = vector_output_real_7;
      end

      
    endcase
  end


endmodule
