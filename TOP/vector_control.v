//32位SFP FFT
// 23/4/2
`include "parameter.vh"
module vector_control (
    input clk,
    input rst,
    input [10:0] fft_size,
    input fft_start,
    input [`SFPWIDTH*32-1:0] input_real,
    input [`SFPWIDTH*32-1:0] input_imag,
    input [`SFPWIDTH*32-1:0] twiddle_real,
    input [`SFPWIDTH*32-1:0] twiddle_imag,
    output reg [`SFPWIDTH*32-1:0] output_real,
    output reg [`SFPWIDTH*32-1:0] output_imag,
    output reg fft_done
);

  localparam vector_length = 4 * `SFPWIDTH;

  reg [ 5:0] i;
  genvar     k;


  reg                      vector_start;
  reg  [             10:0] fft_size_reg;
  reg  [              1:0] control [0:2];
  reg  [`SFPWIDTH*4-1:0] vector_input_real      [ 23:0];
  reg  [`SFPWIDTH*4-1:0] vector_input_imag      [ 23:0];
  reg  [`SFPWIDTH*4-1:0] twiddle_real_reg       [ 23:0];
  reg  [`SFPWIDTH*4-1:0] twiddle_imag_reg       [ 23:0];
  wire [`SFPWIDTH*4-1:0] vector_output_real     [ 23:0];
  wire [`SFPWIDTH*4-1:0] vector_output_imag     [ 23:0];

  //debug signals 
  wire [  `SFPWIDTH-1:0] wire_input_real        [ 3:0];
  wire [  `SFPWIDTH-1:0] wire_input_imag        [ 3:0];
  wire [  `SFPWIDTH-1:0] wire_output_real       [31:0];
  wire [  `SFPWIDTH-1:0] wire_output_imag       [31:0];
  wire [  `SFPWIDTH-1:0] wire_twiddle_real      [ 3:0];
  wire [  `SFPWIDTH-1:0] wire_twiddle_imag      [ 3:0];
  wire [  `SFPWIDTH-1:0] wire_vector_output_real[ 3:0];
  wire [  `SFPWIDTH-1:0] wire_vector_output_imag[ 3:0];

  // generate
  //   for (k = 0; k < 32; k = k + 1) begin
  //     // assign wire_input_real[k]   = input_real[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     // assign wire_input_imag[k]   = input_imag[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     assign wire_output_real[k] = output_real[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     assign wire_output_imag[k] = output_imag[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     // assign wire_twiddle_real[k] = twiddle_real[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     // assign wire_twiddle_imag[k] = twiddle_imag[`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     // assign wire_vector_output_real[k] = vector_output_real[0][`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //     // assign wire_vector_output_imag[k] = vector_output_imag[0][`SFPWIDTH*(k+1)-1:`SFPWIDTH*k];
  //   end
  // endgenerate

//计数方式判断
  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      // for (i = 0; i < 8; i = i + 1) begin
      //   vector_input_real[i] = {(`SFPWIDTH * 4 - 1) {1'b0}};
      // end
      // for (i = 0; i < 8; i = i + 1) begin
      //   vector_input_imag[i] = {(`SFPWIDTH * 4 - 1) {1'b0}};
      // end
      vector_start <= 0;
      fft_size_reg <= 0;
      fft_done <= 0;
      // output_real <= 0;
      // output_imag <= 0;
      control[0] <= 2'b11;
      control[1] <= 2'b11;
      control[2] <= 2'b00;
    end else begin

    end
  end

wire [`EXPWIDTH-1:0] max_exp;
wire [`EXPWIDTH-1:0] input_real_exp [0:31];
wire [`EXPWIDTH-1:0] input_imag_exp [0:31];
wire [`SIGWIDTH:0]   input_real_sig [0:31];
wire [`SIGWIDTH:0]   input_imag_sig [0:31];

generate 
  for(k=0;k<32;k=k+1) begin
    assign input_real_exp[k] = input_real[`SFPWIDTH*(k+1)-2:`SFPWIDTH*k+`SIGWIDTH];
    assign input_imag_exp[k] = input_imag[`SFPWIDTH*(k+1)-2:`SFPWIDTH*k+`SIGWIDTH];
    assign input_real_sig[k] = {input_real[`SFPWIDTH-1] , input_real[`SFPWIDTH*(k+1)-2-`EXPWIDTH:`SFPWIDTH*k]};
    assign input_imag_sig[k] = {input_imag[`SFPWIDTH-1] , input_imag[`SFPWIDTH*(k+1)-2-`EXPWIDTH:`SFPWIDTH*k]};
end
endgenerate

//1CYCLE 第一个时钟计算最大指数
find_max_exp u_find_max_exp(
  .input_exp({input_real_exp[0],input_real_exp[1],input_real_exp[2] ,input_real_exp[3],input_real_exp[4],input_real_exp[5],input_real_exp[6],input_real_exp[7],
              input_real_exp[8],input_real_exp[9],input_real_exp[10] ,input_real_exp[11],input_real_exp[12],input_real_exp[13],input_real_exp[14],input_real_exp[15],
              input_real_exp[16],input_real_exp[17],input_real_exp[18] ,input_real_exp[19],input_real_exp[20],input_real_exp[21],input_real_exp[22],input_real_exp[23],
              input_real_exp[24],input_real_exp[25],input_real_exp[26] ,input_real_exp[27],input_real_exp[28],input_real_exp[29],input_real_exp[30],input_real_exp[31],
              input_imag_exp[0],input_imag_exp[1],input_imag_exp[2] ,input_imag_exp[3],input_imag_exp[4],input_imag_exp[5],input_imag_exp[6],input_imag_exp[7],
              input_imag_exp[8],input_imag_exp[9],input_imag_exp[10] ,input_imag_exp[11],input_imag_exp[12],input_imag_exp[13],input_imag_exp[14],input_imag_exp[15],
              input_imag_exp[16],input_imag_exp[17],input_imag_exp[18] ,input_imag_exp[19],input_imag_exp[20],input_imag_exp[21],input_imag_exp[22],input_imag_exp[23],
              input_imag_exp[24],input_imag_exp[25],input_imag_exp[26] ,input_imag_exp[27],input_imag_exp[28],input_imag_exp[29],input_imag_exp[30],input_imag_exp[31]
              }),
  .output_exp(max_exp)
);

//2CYCLE 取最大指数的倒数
reg [`EXPWIDTH-1:0] max_exp_ff [0:27];
always@(posedge clk or negedge rst) begin
  if(~rst) begin 
    for (i=0; i<20;i=i+1)
      max_exp_ff[i] <= 4'b0; 
  end else begin
    max_exp_ff[0] <= max_exp;
    for (i=1; i<28;i=i+1)
      max_exp_ff[i] <= max_exp_ff[i-1]; 
  end
end

reg [`EXPWIDTH-1:0] input_exp_ff0 [0:63];
reg [`SIGWIDTH:0] input_sig_ff0 [0:63];
reg [`SIGWIDTH:0] input_sig_ff1 [0:63];
wire [`EXPWIDTH-1:0] input_exp [0:63];

//
//  输入的SFP，exponent延迟了1个CLK，significant 延迟了2个CLK
always@(posedge clk or negedge rst) begin
  if(~rst) begin 
    for (i=0; i<32;i=i+1) begin
      input_exp_ff0[i]    <= 4'b0;
      input_exp_ff0[i+32] <= 4'b0;
      input_sig_ff0[i]    <= 4'b0;
      input_sig_ff0[i+32] <= 4'b0;
      input_sig_ff1[i]    <= 4'b0;
      input_sig_ff1[i+32] <= 4'b0;
    end
  end else begin
    for (i=0; i<32;i=i+1) begin
      input_exp_ff0[i]    <= input_real_exp[i];
      input_exp_ff0[i+32] <= input_imag_exp[i];
      input_sig_ff0[i]    <= input_real_sig[i];
      input_sig_ff0[i+32] <= input_imag_sig[i];
      input_sig_ff1[i]    <= input_sig_ff0[i];
      input_sig_ff1[i+32] <= input_sig_ff0[i];
    end
  end
end

// exponent 根据最大exponent计算之后的exponent
exponent_reciprocal u_exp_reciprocal(
  .input_exp({
    input_exp_ff0[63],input_exp_ff0[62],input_exp_ff0[61],input_exp_ff0[60],input_exp_ff0[59],input_exp_ff0[58],input_exp_ff0[57],input_exp_ff0[56],
    input_exp_ff0[55],input_exp_ff0[54],input_exp_ff0[53],input_exp_ff0[52],input_exp_ff0[51],input_exp_ff0[50],input_exp_ff0[49],input_exp_ff0[48],
    input_exp_ff0[47],input_exp_ff0[46],input_exp_ff0[45],input_exp_ff0[44],input_exp_ff0[43],input_exp_ff0[42],input_exp_ff0[41],input_exp_ff0[40],
    input_exp_ff0[39],input_exp_ff0[38],input_exp_ff0[37],input_exp_ff0[36],input_exp_ff0[35],input_exp_ff0[34],input_exp_ff0[33],input_exp_ff0[32],
    input_exp_ff0[31],input_exp_ff0[30],input_exp_ff0[29],input_exp_ff0[28],input_exp_ff0[27],input_exp_ff0[26],input_exp_ff0[25],input_exp_ff0[24],
    input_exp_ff0[23],input_exp_ff0[22],input_exp_ff0[21],input_exp_ff0[20],input_exp_ff0[19],input_exp_ff0[18],input_exp_ff0[17],input_exp_ff0[16],
    input_exp_ff0[15],input_exp_ff0[14],input_exp_ff0[13],input_exp_ff0[12],input_exp_ff0[11],input_exp_ff0[10],input_exp_ff0[9],input_exp_ff0[8],
    input_exp_ff0[7],input_exp_ff0[6],input_exp_ff0[5],input_exp_ff0[4],input_exp_ff0[3],input_exp_ff0[2],input_exp_ff0[1],input_exp_ff0[0]
  }),
  .max_exp(max_exp_ff[0]),
  .output_exp({
    input_exp[63],input_exp[62],input_exp[61],input_exp[60],input_exp[59],input_exp[58],input_exp[57],input_exp[56],
    input_exp[55],input_exp[54],input_exp[53],input_exp[52],input_exp[51],input_exp[50],input_exp[49],input_exp[48],
    input_exp[47],input_exp[46],input_exp[45],input_exp[44],input_exp[43],input_exp[42],input_exp[41],input_exp[40],
    input_exp[39],input_exp[38],input_exp[37],input_exp[36],input_exp[35],input_exp[34],input_exp[33],input_exp[32],
    input_exp[31],input_exp[30],input_exp[29],input_exp[28],input_exp[27],input_exp[26],input_exp[25],input_exp[24],
    input_exp[23],input_exp[22],input_exp[21],input_exp[20],input_exp[19],input_exp[18],input_exp[17],input_exp[16],
    input_exp[15],input_exp[14],input_exp[13],input_exp[12],input_exp[11],input_exp[10],input_exp[9],input_exp[8],
    input_exp[7],input_exp[6],input_exp[5],input_exp[4],input_exp[3],input_exp[2],input_exp[1],input_exp[0]
  })
);  
  

  wire [`SFPWIDTH-1:0] input_real_label [0:31];
  wire [`SFPWIDTH-1:0] input_imag_label [0:31];
  wire [`SFPWIDTH-1:0] twiddle_real_label [0:31];
  wire [`SFPWIDTH-1:0] twiddle_imag_label [0:31];
  generate
    for(k = 0; k < 32; k = k + 1) begin
      //  assign input_real_label[k]   = input_real[`SFPWIDTH*(k+1)-1 : `SFPWIDTH*k];
      //  assign input_imag_label[k]   = input_imag[`SFPWIDTH*(k+1)-1 : `SFPWIDTH*k];
       assign input_real_label[k]   = {input_sig_ff1[k][`SIGWIDTH],input_exp[k],input_sig_ff1[k][`SIGWIDTH-1:0]};
       assign input_imag_label[k]   = {input_sig_ff1[k+32][`SIGWIDTH],input_exp[k+32],input_sig_ff1[k+32][`SIGWIDTH-1:0]};
       assign twiddle_real_label[k] = twiddle_real[`SFPWIDTH*(k+1)-1 : `SFPWIDTH*k];
       assign twiddle_imag_label[k] = twiddle_imag[`SFPWIDTH*(k+1)-1 : `SFPWIDTH*k];
    end
  endgenerate



reg [`SFPWIDTH-1:0] output_real_vector [0:31];
reg [`SFPWIDTH-1:0] output_imag_vector [0:31];
always@(*) begin
//STAGE 1

        vector_input_real[0] = { input_real_label[0] , input_real_label[8] , input_real_label[16] , input_real_label[24]};
        vector_input_real[1] = { input_real_label[1] , input_real_label[9] , input_real_label[17] , input_real_label[25]};
        vector_input_real[2] = { input_real_label[2] , input_real_label[10] , input_real_label[18] , input_real_label[26]};
        vector_input_real[3] = { input_real_label[3] , input_real_label[11] , input_real_label[19] , input_real_label[27]};
        vector_input_real[4] = { input_real_label[4] , input_real_label[12] , input_real_label[20] , input_real_label[28]};
        vector_input_real[5] = { input_real_label[5] , input_real_label[13] , input_real_label[21] , input_real_label[29]};
        vector_input_real[6] = { input_real_label[6] , input_real_label[14] , input_real_label[22] , input_real_label[30]};
        vector_input_real[7] = { input_real_label[7] , input_real_label[15] , input_real_label[23] , input_real_label[31]};


        vector_input_imag[0] = { input_imag_label[0] , input_imag_label[8]  , input_imag_label[16] , input_imag_label[24]};
        vector_input_imag[1] = { input_imag_label[1] , input_imag_label[9]  , input_imag_label[17] , input_imag_label[25]};
        vector_input_imag[2] = { input_imag_label[2] , input_imag_label[10] , input_imag_label[18] , input_imag_label[26]};
        vector_input_imag[3] = { input_imag_label[3] , input_imag_label[11] , input_imag_label[19] , input_imag_label[27]};
        vector_input_imag[4] = { input_imag_label[4] , input_imag_label[12] , input_imag_label[20] , input_imag_label[28]};
        vector_input_imag[5] = { input_imag_label[5] , input_imag_label[13] , input_imag_label[21] , input_imag_label[29]};
        vector_input_imag[6] = { input_imag_label[6] , input_imag_label[14] , input_imag_label[22] , input_imag_label[30]};
        vector_input_imag[7] = { input_imag_label[7] , input_imag_label[15] , input_imag_label[23] , input_imag_label[31]};


        twiddle_real_reg[0] = {twiddle_real[`SFPWIDTH*4-1:0]};
        twiddle_real_reg[1] = {twiddle_real[`SFPWIDTH*8-1:`SFPWIDTH*4]};
        twiddle_real_reg[2] = {twiddle_real[`SFPWIDTH*12-1:`SFPWIDTH*8]};
        twiddle_real_reg[3] = {twiddle_real[`SFPWIDTH*16-1:`SFPWIDTH*12]};
        twiddle_real_reg[4] = {twiddle_real[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_real_reg[5] = {twiddle_real[`SFPWIDTH*24-1:`SFPWIDTH*20]};
        twiddle_real_reg[6] = {twiddle_real[`SFPWIDTH*28-1:`SFPWIDTH*24]};
        twiddle_real_reg[7] = {twiddle_real[`SFPWIDTH*32-1:`SFPWIDTH*28]};


        twiddle_imag_reg[0] = {twiddle_imag[`SFPWIDTH*4-1:0]};
        twiddle_imag_reg[1] = {twiddle_imag[`SFPWIDTH*8-1:`SFPWIDTH*4]};
        twiddle_imag_reg[2] = {twiddle_imag[`SFPWIDTH*12-1:`SFPWIDTH*8]};
        twiddle_imag_reg[3] = {twiddle_imag[`SFPWIDTH*16-1:`SFPWIDTH*12]};
        twiddle_imag_reg[4] = {twiddle_imag[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_imag_reg[5] = {twiddle_imag[`SFPWIDTH*24-1:`SFPWIDTH*20]};
        twiddle_imag_reg[6] = {twiddle_imag[`SFPWIDTH*28-1:`SFPWIDTH*24]};
        twiddle_imag_reg[7] = {twiddle_imag[`SFPWIDTH*32-1:`SFPWIDTH*28]};

//STAGE 2

        vector_input_real[8] = {
          vector_output_real[0][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[2][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[4][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[6][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        vector_input_real[9] = {
          vector_output_real[1][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[3][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[5][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[7][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        vector_input_real[10] = {
          vector_output_real[0][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[2][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[4][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[6][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[11] = {
          vector_output_real[1][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[3][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[5][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[7][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[12] = {
          vector_output_real[0][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[2][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[4][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[6][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        vector_input_real[13] = {
          vector_output_real[1][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[3][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[5][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[7][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        vector_input_real[14] = {
          vector_output_real[0][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[2][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[4][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[6][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_real[15] = {
          vector_output_real[1][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[3][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[5][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[7][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };


        vector_input_imag[8] = {
          vector_output_imag[0][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[2][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[4][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[6][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        vector_input_imag[9] = {
          vector_output_imag[1][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[3][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[5][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[7][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        vector_input_imag[10] = {
          vector_output_imag[0][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[2][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[4][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[6][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[11] = {
          vector_output_imag[1][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[3][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[5][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[7][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[12] = {
          vector_output_imag[0][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[2][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[4][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[6][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        vector_input_imag[13] = {
          vector_output_imag[1][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[3][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[5][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[7][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        vector_input_imag[14] = {
          vector_output_imag[0][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[2][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[4][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[6][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_imag[15] = {
          vector_output_imag[1][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[3][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[5][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[7][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };


        twiddle_real_reg[8]  = {twiddle_real[`SFPWIDTH*4-1:0]};
        twiddle_real_reg[9]  = {twiddle_real[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_real_reg[10] = {twiddle_real[`SFPWIDTH*4-1:0]};
        twiddle_real_reg[11] = {twiddle_real[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_real_reg[12] = {twiddle_real[`SFPWIDTH*4-1:0]};
        twiddle_real_reg[13] = {twiddle_real[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_real_reg[14] = {twiddle_real[`SFPWIDTH*4-1:0]};
        twiddle_real_reg[15] = {twiddle_real[`SFPWIDTH*20-1:`SFPWIDTH*16]};


        twiddle_imag_reg[8]  = {twiddle_imag[`SFPWIDTH*4-1:0]};
        twiddle_imag_reg[9]  = {twiddle_imag[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_imag_reg[10] = {twiddle_imag[`SFPWIDTH*4-1:0]};
        twiddle_imag_reg[11] = {twiddle_imag[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_imag_reg[12] = {twiddle_imag[`SFPWIDTH*4-1:0]};
        twiddle_imag_reg[13] = {twiddle_imag[`SFPWIDTH*20-1:`SFPWIDTH*16]};
        twiddle_imag_reg[14] = {twiddle_imag[`SFPWIDTH*4-1:0]};
        twiddle_imag_reg[15] = {twiddle_imag[`SFPWIDTH*20-1:`SFPWIDTH*16]};

// STAGE 3
        vector_input_real[16] = {
          vector_output_real[8][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[9][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[8][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[9][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[17] = {
          vector_output_real[8][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[9][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[8][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[9][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_real[18] = {
          vector_output_real[10][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[11][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[10][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[11][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[19] = {
          vector_output_real[10][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[11][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[10][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[11][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_real[20] = {
          vector_output_real[12][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[13][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[12][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[13][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[21] = {
          vector_output_real[12][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[13][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[12][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[13][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_real[22] = {
          vector_output_real[14][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[15][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[14][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[15][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_real[23] = {
          vector_output_real[14][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[15][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[14][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[15][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };


        vector_input_imag[16] = {
          vector_output_imag[8][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[9][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[8][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[9][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[17] = {
          vector_output_imag[8][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[9][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[8][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[9][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_imag[18] = {
          vector_output_imag[10][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[11][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[10][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[11][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[19] = {
          vector_output_imag[10][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[11][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[10][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[11][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_imag[20] = {
          vector_output_imag[12][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[13][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[12][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[13][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[21] = {
          vector_output_imag[12][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[13][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[12][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[13][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        vector_input_imag[22] = {
          vector_output_imag[14][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[15][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[14][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[15][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        vector_input_imag[23] = {
          vector_output_imag[14][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[15][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[14][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[15][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };




        {output_real_vector[3],output_real_vector[2],output_real_vector[1],output_real_vector[0]} = {
          vector_output_real[22][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[20][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[18][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[16][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        {output_real_vector[19],output_real_vector[18],output_real_vector[17],output_real_vector[16]} = {
          vector_output_real[22][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[20][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[18][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[16][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        {output_real_vector[7],output_real_vector[6],output_real_vector[5],output_real_vector[4]} = {
          vector_output_real[22][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[20][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[18][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[16][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        {output_real_vector[23],output_real_vector[22],output_real_vector[21],output_real_vector[20]} = {
          vector_output_real[22][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[20][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[18][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[16][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        {output_real_vector[11],output_real_vector[10],output_real_vector[9],output_real_vector[8]} = {
          vector_output_real[23][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[21][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[19][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_real[17][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        {output_real_vector[27],output_real_vector[26],output_real_vector[25],output_real_vector[24]} = {
          vector_output_real[23][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[21][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[19][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_real[17][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        {output_real_vector[15],output_real_vector[14],output_real_vector[13],output_real_vector[12]} = {
          vector_output_real[23][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[21][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[19][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_real[17][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        {output_real_vector[31],output_real_vector[30],output_real_vector[29],output_real_vector[28]} = {
          vector_output_real[23][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[21][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[19][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_real[17][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };


        {output_imag_vector[3],output_imag_vector[2],output_imag_vector[1],output_imag_vector[0]} = {
          vector_output_imag[22][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[20][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[18][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[16][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        {output_imag_vector[19],output_imag_vector[18],output_imag_vector[17],output_imag_vector[16]} = {
          vector_output_imag[22][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[20][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[18][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[16][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        {output_imag_vector[7],output_imag_vector[6],output_imag_vector[5],output_imag_vector[4]} = {
          vector_output_imag[22][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[20][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[18][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[16][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        {output_imag_vector[23],output_imag_vector[22],output_imag_vector[21],output_imag_vector[20]} = {
          vector_output_imag[22][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[20][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[18][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[16][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
        {output_imag_vector[11],output_imag_vector[10],output_imag_vector[9],output_imag_vector[8]} = {
          vector_output_imag[23][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[21][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[19][`SFPWIDTH*4-1:`SFPWIDTH*3],
          vector_output_imag[17][`SFPWIDTH*4-1:`SFPWIDTH*3]
        };
        {output_imag_vector[27],output_imag_vector[26],output_imag_vector[25],output_imag_vector[24]} = {
          vector_output_imag[23][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[21][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[19][`SFPWIDTH*2-1:`SFPWIDTH*1],
          vector_output_imag[17][`SFPWIDTH*2-1:`SFPWIDTH*1]
        };
        {output_imag_vector[15],output_imag_vector[14],output_imag_vector[13],output_imag_vector[12]} = {
          vector_output_imag[23][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[21][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[19][`SFPWIDTH*3-1:`SFPWIDTH*2],
          vector_output_imag[17][`SFPWIDTH*3-1:`SFPWIDTH*2]
        };
        {output_imag_vector[31],output_imag_vector[30],output_imag_vector[29],output_imag_vector[28]} = {
          vector_output_imag[23][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[21][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[19][`SFPWIDTH*1-1:`SFPWIDTH*0],
          vector_output_imag[17][`SFPWIDTH*1-1:`SFPWIDTH*0]
        };
end

wire [`EXPWIDTH-1:0] real_exponent_resize_input  [0:31];
wire [`EXPWIDTH-1:0] imag_exponent_resize_input  [0:31];
wire [`EXPWIDTH-1:0] real_exponent_resize_output [0:31];
wire [`EXPWIDTH-1:0] imag_exponent_resize_output [0:31];
reg  [`SIGWIDTH:0] output_real_sig_ff  [0:31];
reg  [`SIGWIDTH:0] output_imag_sig_ff  [0:31];
generate
  for(k = 0;k < 32;k = k + 1) begin
    assign real_exponent_resize_input[k] = output_real_vector[k][`SFPWIDTH-2-:`SIGWIDTH];
    assign imag_exponent_resize_input[k] = output_imag_vector[k][`SFPWIDTH-2-:`SIGWIDTH];
  end
endgenerate


//27CYCLE 对计算出的SFP44的指数部分进行重新resize。
exponent_resize u_exp_resize(
  .input_exp({
    real_exponent_resize_input[31],real_exponent_resize_input[30],real_exponent_resize_input[29],real_exponent_resize_input[28],real_exponent_resize_input[27],real_exponent_resize_input[26],real_exponent_resize_input[25],real_exponent_resize_input[24],
    real_exponent_resize_input[23],real_exponent_resize_input[22],real_exponent_resize_input[21],real_exponent_resize_input[20],real_exponent_resize_input[19],real_exponent_resize_input[18],real_exponent_resize_input[17],real_exponent_resize_input[16],
    real_exponent_resize_input[15],real_exponent_resize_input[14],real_exponent_resize_input[13],real_exponent_resize_input[12],real_exponent_resize_input[11],real_exponent_resize_input[10],real_exponent_resize_input[9],real_exponent_resize_input[8],
    real_exponent_resize_input[7],real_exponent_resize_input[6],real_exponent_resize_input[5],real_exponent_resize_input[4],real_exponent_resize_input[3],real_exponent_resize_input[2],real_exponent_resize_input[1],real_exponent_resize_input[0],
    imag_exponent_resize_input[31],imag_exponent_resize_input[30],imag_exponent_resize_input[29],imag_exponent_resize_input[28],imag_exponent_resize_input[27],imag_exponent_resize_input[26],imag_exponent_resize_input[25],imag_exponent_resize_input[24],
    imag_exponent_resize_input[23],imag_exponent_resize_input[22],imag_exponent_resize_input[21],imag_exponent_resize_input[20],imag_exponent_resize_input[19],imag_exponent_resize_input[18],imag_exponent_resize_input[17],imag_exponent_resize_input[16],
    imag_exponent_resize_input[15],imag_exponent_resize_input[14],imag_exponent_resize_input[13],imag_exponent_resize_input[12],imag_exponent_resize_input[11],imag_exponent_resize_input[10],imag_exponent_resize_input[9],imag_exponent_resize_input[8],
    imag_exponent_resize_input[7],imag_exponent_resize_input[6],imag_exponent_resize_input[5],imag_exponent_resize_input[4],imag_exponent_resize_input[3],imag_exponent_resize_input[2],imag_exponent_resize_input[1],imag_exponent_resize_input[0]
  }),
  .max_exp(max_exp_ff[27]),
  .output_exp({
    real_exponent_resize_output[31],real_exponent_resize_output[30],real_exponent_resize_output[29],real_exponent_resize_output[28],real_exponent_resize_output[27],real_exponent_resize_output[26],real_exponent_resize_output[25],real_exponent_resize_output[24],
    real_exponent_resize_output[23],real_exponent_resize_output[22],real_exponent_resize_output[21],real_exponent_resize_output[20],real_exponent_resize_output[19],real_exponent_resize_output[18],real_exponent_resize_output[17],real_exponent_resize_output[16],
    real_exponent_resize_output[15],real_exponent_resize_output[14],real_exponent_resize_output[13],real_exponent_resize_output[12],real_exponent_resize_output[11],real_exponent_resize_output[10],real_exponent_resize_output[9] ,real_exponent_resize_output[8],
    real_exponent_resize_output[7] ,real_exponent_resize_output[6] ,real_exponent_resize_output[5] ,real_exponent_resize_output[4] ,real_exponent_resize_output[3] ,real_exponent_resize_output[2] ,real_exponent_resize_output[1] ,real_exponent_resize_output[0],
    imag_exponent_resize_output[31],imag_exponent_resize_output[30],imag_exponent_resize_output[29],imag_exponent_resize_output[28],imag_exponent_resize_output[27],imag_exponent_resize_output[26],imag_exponent_resize_output[25],imag_exponent_resize_output[24],
    imag_exponent_resize_output[23],imag_exponent_resize_output[22],imag_exponent_resize_output[21],imag_exponent_resize_output[20],imag_exponent_resize_output[19],imag_exponent_resize_output[18],imag_exponent_resize_output[17],imag_exponent_resize_output[16],
    imag_exponent_resize_output[15],imag_exponent_resize_output[14],imag_exponent_resize_output[13],imag_exponent_resize_output[12],imag_exponent_resize_output[11],imag_exponent_resize_output[10],imag_exponent_resize_output[9] ,imag_exponent_resize_output[8],
    imag_exponent_resize_output[7] ,imag_exponent_resize_output[6] ,imag_exponent_resize_output[5] ,imag_exponent_resize_output[4] ,imag_exponent_resize_output[3] ,imag_exponent_resize_output[2] ,imag_exponent_resize_output[1] ,imag_exponent_resize_output[0]
  })
);  
//28CYCLY 输出最终结果 output_real , ouput_imag为寄存器类型数据

always@(posedge clk or negedge rst) begin
  if(~rst) begin 
    for (i=0; i<32;i=i+1) begin
      output_real_sig_ff[i]<={(`EXPWIDTH){1'b0}};
      output_imag_sig_ff[i]<={(`EXPWIDTH){1'b0}};
    end
  end else begin
    for (i=0; i<32;i=i+1) begin
      output_real_sig_ff[i] <= {output_real_vector[i][`SFPWIDTH-1] , output_real_vector[i][0+:`SIGWIDTH]};
      output_imag_sig_ff[i] <= {output_imag_vector[i][`SFPWIDTH-1] , output_imag_vector[i][0+:`SIGWIDTH]};
      output_real[`SFPWIDTH*i+:`SFPWIDTH] <= {output_real_sig_ff[i][`SIGWIDTH] , real_exponent_resize_output[i] , output_real_sig_ff[i][0+:`SIGWIDTH]};
      output_imag[`SFPWIDTH*i+:`SFPWIDTH] <= {output_imag_sig_ff[i][`SIGWIDTH] , imag_exponent_resize_output[i] , output_imag_sig_ff[i][0+:`SIGWIDTH]};
    end
  end
end

  vector_size4 u0_vector (
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

  vector_size4 u1_vector (
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

  vector_size4 u2_vector (
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

  vector_size4 u3_vector (
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

  vector_size4 u4_vector (
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

  vector_size4 u5_vector (
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

  vector_size4 u6_vector (
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

  vector_size4 u7_vector (
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




  vector_size4 u8_vector (
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

  vector_size4 u9_vector (
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

  vector_size4 u10_vector (
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

  vector_size4 u11_vector (
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

  vector_size4 u12_vector (
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

  vector_size4 u13_vector (
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

  vector_size4 u14_vector (
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

  vector_size4 u15_vector (
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



  vector_size4 u16_vector (
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

  vector_size4 u17_vector (
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

  vector_size4 u18_vector (
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

  vector_size4 u19_vector (
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

  vector_size4 u20_vector (
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

  vector_size4 u21_vector (
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

  vector_size4 u22_vector (
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

  vector_size4 u23_vector (
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
