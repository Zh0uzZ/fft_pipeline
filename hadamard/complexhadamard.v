`define SIGNED_WIDTH (sigWidth+4+low_expand)
module HADAMARD #(
    parameter expWidth    = 4,
    parameter sigWidth    = 4,
    parameter formatWidth = 9,
    parameter low_expand  = 2
) (
    input                      clk,
    input                      rst,
    input                      start,
    input  [formatWidth*4-1:0] input_real,
    input  [formatWidth*4-1:0] input_imag,
    input  [formatWidth*4-1:0] twiddle_real,
    input  [formatWidth*4-1:0] twiddle_imag,
    output [formatWidth*4-1:0] output_real,
    output [formatWidth*4-1:0] output_imag,
    output reg                 hadamard_done
);


  genvar j;
  reg  [                3:0] i;
  wire [    formatWidth-1:0] sfp_real          [7:0];
  wire [    formatWidth-1:0] sfp_imag          [7:0];
  reg  [  formatWidth*8-1:0] sfp_real_reg;
  reg  [  formatWidth*8-1:0] sfp_imag_reg;

  wire [     expWidth*2-1:0] exp_offset_num    [7:0];
  reg  [     expWidth*2-1:0] exp_offset_num_reg[7:0];

  wire [`SIGNED_WIDTH*2-1:0] sig_off           [7:0];
  reg  [`SIGNED_WIDTH*2-1:0] sig_off_reg       [7:0];

  wire [`SIGNED_WIDTH-1 : 0] adder_num         [7:0];
  reg  [`SIGNED_WIDTH-1 : 0] adder_num_reg     [7:0];
  wire [    formatWidth-1:0] sfpout            [7:0];

  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      sfp_real_reg  <= 0;
      sfp_imag_reg  <= 0;
      for (i = 0; i < 8; i = i + 1) begin
        exp_offset_num_reg[i] <= {(2 * expWidth) {1'b0}};
        sig_off_reg[i]        <= {((sigWidth + 4 + low_expand) * 2) {1'b0}};
        adder_num_reg[i]      <= {(sigWidth + 4 + low_expand) {1'b0}};
      end
    end else begin
      sfp_real_reg <= {
        sfp_real[7],
        sfp_real[6],
        sfp_real[5],
        sfp_real[4],
        sfp_real[3],
        sfp_real[2],
        sfp_real[1],
        sfp_real[0]
      };
      sfp_imag_reg <= {
        sfp_imag[7],
        sfp_imag[6],
        sfp_imag[5],
        sfp_imag[4],
        sfp_imag[3],
        sfp_imag[2],
        sfp_imag[1],
        sfp_imag[0]
      };

      for (i = 0; i < 8; i = i + 1) begin
        exp_offset_num_reg[i] <= exp_offset_num[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        sig_off_reg[i] = sig_off[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        adder_num_reg[i] <= adder_num[i];
      end


    end
  end
  assign  output_real = {sfpout[3], sfpout[2], sfpout[1], sfpout[0]};
  assign  output_imag = {sfpout[7], sfpout[6], sfpout[5], sfpout[4]};

  //ready signal 
  reg [3:0] count_r;
  always@(posedge clk or negedge rst) begin
    if(~rst) begin
      count_r <= 3'b111;
    end else if (start) begin
      count_r <= 0;
    end else begin
      hadamard_done <= 0;
      if(count_r != 3'b111)
        count_r <= count_r + 1;
      if(count_r == 3'b10) 
        hadamard_done <= 1;
    end
  end

  //1CYCLE , 计算sfp和twiddle factor的乘积
  //sfp相乘，输入与twiddle factor相乘
  generate
    for (j = 0; j < 4; j = j + 1) begin : u0_sfpmulti
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_real[(j+1)*formatWidth-1 : j*formatWidth]),
          .b(twiddle_real[(j+1)*formatWidth-1 : j*formatWidth]),
          .c(sfp_real[j])
      );
    end
  endgenerate
  generate
    for (j = 0; j < 4; j = j + 1) begin : u1_sfpmulti
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_real[(j+1)*formatWidth-1 : j*formatWidth]),
          .b(twiddle_imag[(j+1)*formatWidth-1 : j*formatWidth]),
          .c(sfp_imag[j])
      );
    end
  endgenerate
  generate
    for (j = 0; j < 4; j = j + 1) begin : u2_sfpmulti
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_imag[(j+1)*formatWidth-1 : j*formatWidth]),
          .b(twiddle_real[(j+1)*formatWidth-1 : j*formatWidth]),
          .c(sfp_imag[j+4])
      );
    end
  endgenerate
  generate
    for (j = 0; j < 4; j = j + 1) begin : u3_sfpmulti
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_imag[(j+1)*formatWidth-1 : j*formatWidth]),
          .b(twiddle_imag[(j+1)*formatWidth-1 : j*formatWidth]),
          .c(sfp_real[j+4])
      );
    end
  endgenerate

  //2CYCLE,找到指数最大值
  // 指数找到最大值以及算出偏移量
  wire [expWidth-1:0] max_exp [7:0];
  generate
    for (j = 0; j < 4; j = j + 1) begin : u0_exp_normalizer
      exp_normalizer_2 #(
          .expWidth(expWidth)
      ) u_exp_normalizer (
          .input_exp({
            sfp_real_reg[formatWidth*(j+1)-2-:expWidth], 
            sfp_real_reg[formatWidth*(j+5)-2-:expWidth]
          }),
          .max_exp(max_exp[j]),
          .exp_offset_num(exp_offset_num[j])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 4; j = j + 1) begin : u1_exp_normalizer
      exp_normalizer_2 #(
          .expWidth(expWidth)
      ) u_exp_normalizer (
          .input_exp({
            sfp_imag_reg[formatWidth*(j+1)-2-:expWidth], 
            sfp_imag_reg[formatWidth*(j+5)-2-:expWidth]
          }),
          .max_exp(max_exp[j+4]),
          .exp_offset_num(exp_offset_num[j+4])
      );
    end
  endgenerate


  //3CYCLE
  //指数部分右移
  reg [formatWidth*8-1 : 0] sfp_real_ff;
  reg [formatWidth*8-1 : 0] sfp_imag_ff;
  always@(posedge clk or negedge rst) begin
    if(~rst) begin
      sfp_real_ff <= 0;
      sfp_imag_ff <= 0;
    end else begin
      sfp_real_ff <= sfp_real_reg;
      sfp_imag_ff <= sfp_imag_reg;
    end
  end


  generate
    for (j = 0; j < 4; j = j + 1) begin : u0_sig_shifter
      sig_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_sig_shifter (
          .exp_offset_num(exp_offset_num_reg[j]),
          .significand({
            sfp_real_ff[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_real_ff[formatWidth*(j+5)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_real_ff[formatWidth*(j+1)-1], 1'b1 ^ sfp_real_ff[formatWidth*(j+5)-1]}),
          .adder_num(sig_off[j])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 4; j = j + 1) begin : u1_sig_shifter
      sig_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_sig_shifter (
          .exp_offset_num(exp_offset_num_reg[j+4]),
          .significand({
            sfp_imag_ff[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_imag_ff[formatWidth*(j+5)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_imag_ff[formatWidth*(j+1)-1], sfp_imag_ff[formatWidth*(j+5)-1]}),
          .adder_num(sig_off[j+4])
      );
    end
  endgenerate


  //4CYCLE , 计算加法
  //求补码并且10bit数据相加
  generate
    for (j = 0; j < 8; j = j + 1) begin : u_adder_2in
      adder_2in #(
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_adder_2in (
          .input_num(sig_off_reg[j]),
          .adder_num(adder_num[j])
      );
    end
  endgenerate


  //5CYCLE，fix -->  sfp44
  //对得到的10bit定点数，求补码并且转换为sfp数
  //将max_exp最大指数部分延迟三个时钟沿
  reg [expWidth-1:0] max_exp_ff1 [7:0];
  reg [expWidth-1:0] max_exp_ff2 [7:0];
  reg [expWidth-1:0] max_exp_ff3 [7:0];
  always@(posedge clk or negedge rst) begin
    if(~rst) begin
      for (i = 0; i < 8; i = i + 1) begin
        max_exp_ff1[i] <= 0;
        max_exp_ff2[i] <= 0;
        max_exp_ff3[i] <= 0;
      end
    end else begin
      for (i = 0; i < 8; i = i + 1) begin
        max_exp_ff1[i] <= max_exp[i];
        max_exp_ff2[i] <= max_exp_ff1[i];
        max_exp_ff3[i] <= max_exp_ff2[i];
      end
    end
  end

  generate
    for (j = 0; j < 8; j = j + 1) begin : u_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (adder_num_reg[j]),
          .max_exp(max_exp_ff3[j]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate



endmodule
