`define SIGNED_WIDTH (sigWidth+4+low_expand)
module HADAMARD_1 #(  //1244 LUT  595FF
    parameter expWidth    = 4,
    parameter sigWidth    = 4,
    parameter formatWidth = 9,
    parameter low_expand  = 2,
    parameter type sfp_t = logic [formatWidth-1:0]
) (
    input              clk,
    input              rst,
    input              start,
    input  sfp_t [3:0] input_real,
    input  sfp_t [3:0] input_imag,
    input  sfp_t [3:0] twiddle_real,
    input  sfp_t [3:0] twiddle_imag,
    output sfp_t [3:0] output_real,
    output sfp_t [3:0] output_imag,
    output reg         hadamard_done
);


  genvar j;
  reg  [                3:0] i;
  wire [    formatWidth-1:0] sfp_real          [5:0];
  wire [    formatWidth-1:0] sfp_imag          [5:0];

  wire [     expWidth*2-1:0] exp_offset_num    [5:0];
  reg  [     expWidth*2-1:0] exp_offset_num_reg[5:0];

  wire [`SIGNED_WIDTH*2-1:0] sig_off           [5:0];
  reg  [`SIGNED_WIDTH*2-1:0] sig_off_reg       [5:0];

  wire [`SIGNED_WIDTH-1 : 0] adder_num         [5:0];
  reg  [`SIGNED_WIDTH-1 : 0] adder_num_reg     [5:0];
  wire [    formatWidth-1:0] sfpout            [5:0];

  assign output_real = {sfpout[3], sfpout[2], sfpout[1], sfpout[0]};
  assign output_imag = {sfpout[7], sfpout[6], sfpout[5], sfpout[4]};

  //ready signal
  reg [1:0] count_r;
  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      count_r <= 2'b11;
    end else if (start) begin
      count_r <= 0;
    end else begin
      hadamard_done <= 0;
      if (count_r != 2'b11) count_r <= count_r + 1;
      if (count_r == 2'b10) hadamard_done <= 1;
    end
  end

  //1CYCLE , 计算sfp和twiddle factor的乘积
  //sfp相乘，输入与twiddle factor相乘
  generate
    for (j = 1; j < 4; j = j + 1) begin : u_sfpmulti_real_real
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_real[j]),
          .b(twiddle_real[j]),
          .c(sfp_real[j-1])
      );
    end
  endgenerate
  generate
    for (j = 1; j < 4; j = j + 1) begin : u_sfpmulti_real_imag
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_real[j]),
          .b(twiddle_imag[j]),
          .c(sfp_imag[j-1])
      );
    end
  endgenerate
  generate
    for (j = 1; j < 4; j = j + 1) begin : u_sfpmulti_imag_real
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_imag[(j+1)*formatWidth-1 : j*formatWidth]),
          .b(twiddle_real[(j+1)*formatWidth-1 : j*formatWidth]),
          .c(sfp_imag[j+2])
      );
    end
  endgenerate
  generate
    for (j = 1; j < 4; j = j + 1) begin : u_sfpmulti_imag_imag
      sfpmulti #(
          .expWidth   (expWidth),
          .sigWidth   (sigWidth),
          .formatWidth(formatWidth)
      ) u_sfpmulti (
          .a(input_imag[j]),
          .b(twiddle_imag[j]),
          .c(sfp_real[j+2])
      );
    end
  endgenerate

  reg [formatWidth*6-1:0] sfp_real_reg;
  reg [formatWidth*6-1:0] sfp_imag_reg;
  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      sfp_real_reg <= 0;
      sfp_imag_reg <= 0;
    end else begin
      sfp_real_reg <= {
        sfp_real[5], sfp_real[4], sfp_real[3], sfp_real[2], sfp_real[1], sfp_real[0]
      };
      sfp_imag_reg <= {
        sfp_imag[5], sfp_imag[4], sfp_imag[3], sfp_imag[2], sfp_imag[1], sfp_imag[0]
      };
    end
  end

  //2CYCLE,找到指数最大值
  // 指数找到最大值以及算出偏移量
  wire [expWidth-1:0] max_exp[5:0];
  generate
    for (j = 0; j < 3; j = j + 1) begin : u0_exp_normalizer
      exp_normalizer_2 #(
          .expWidth(expWidth)
      ) u_exp_normalizer (
          .input_exp({
            sfp_real_reg[formatWidth*(j+1)-2-:expWidth], sfp_real_reg[formatWidth*(j+4)-2-:expWidth]
          }),
          .max_exp(max_exp[j]),
          .exp_offset_num(exp_offset_num[j])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 3; j = j + 1) begin : u1_exp_normalizer
      exp_normalizer_2 #(
          .expWidth(expWidth)
      ) u_exp_normalizer (
          .input_exp({
            sfp_imag_reg[formatWidth*(j+1)-2-:expWidth], sfp_imag_reg[formatWidth*(j+4)-2-:expWidth]
          }),
          .max_exp(max_exp[j+3]),
          .exp_offset_num(exp_offset_num[j+3])
      );
    end
  endgenerate

  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 6; i = i + 1) begin
        exp_offset_num_reg[i] <= {(2 * expWidth) {1'b0}};
      end
    end else begin
      for (i = 0; i < 6; i = i + 1) begin
        exp_offset_num_reg[i] <= exp_offset_num[i];
      end
    end
  end


  //3CYCLE
  //指数部分右移
  reg [formatWidth*6-1 : 0] sfp_real_ff;
  reg [formatWidth*6-1 : 0] sfp_imag_ff;
  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      sfp_real_ff <= 0;
      sfp_imag_ff <= 0;
    end else begin
      sfp_real_ff <= sfp_real_reg;
      sfp_imag_ff <= sfp_imag_reg;
    end
  end


  generate
    for (j = 0; j < 3; j = j + 1) begin : u0_sig_shifter
      sig_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_sig_shifter (
          .exp_offset_num(exp_offset_num_reg[j]),
          .significand({
            sfp_real_ff[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_real_ff[formatWidth*(j+4)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_real_ff[formatWidth*(j+1)-1], 1'b1 ^ sfp_real_ff[formatWidth*(j+4)-1]}),
          .adder_num(sig_off[j])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 3; j = j + 1) begin : u1_sig_shifter
      sig_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_sig_shifter (
          .exp_offset_num(exp_offset_num_reg[j+4]),
          .significand({
            sfp_imag_ff[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_imag_ff[formatWidth*(j+4)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_imag_ff[formatWidth*(j+1)-1], sfp_imag_ff[formatWidth*(j+4)-1]}),
          .adder_num(sig_off[j+3])
      );
    end
  endgenerate

  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 6; i++) begin
        sig_off_reg[i] <= {(`SIGNED_WIDTH * 2) {1'b0}};
      end
    end else begin
      for (i = 0; i < 6; i++) begin
        sig_off_reg[i] <= sig_off[i];
      end
    end
  end


  //4CYCLE , 计算加法
  //求补码并且10bit数据相加
  generate
    for (j = 0; j < 6; j = j + 1) begin : u_adder_2in
      adder_2in #(
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_adder_2in (
          .input_num(sig_off_reg[j]),
          .adder_num(adder_num[j])
      );
    end
  endgenerate

  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 6; i++) begin
        adder_num_reg[i] <= {(`SIGNED_WIDTH) {1'b0}};
      end
    end else begin
      for (i = 0; i < 6; i++) begin
        adder_num_reg[i] <= adder_num[i];
      end
    end
  end


  //5CYCLE，fix -->  sfp44
  //对得到的10bit定点数，求补码并且转换为sfp数
  //将max_exp最大指数部分延迟三个时钟沿
  reg [expWidth-1:0] max_exp_ff1[5:0];
  reg [expWidth-1:0] max_exp_ff2[5:0];
  reg [expWidth-1:0] max_exp_ff3[5:0];
  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 6; i = i + 1) begin
        max_exp_ff1[i] <= 0;
        max_exp_ff2[i] <= 0;
        max_exp_ff3[i] <= 0;
      end
    end else begin
      for (i = 0; i < 6; i = i + 1) begin
        max_exp_ff1[i] <= max_exp[i];
        max_exp_ff2[i] <= max_exp_ff1[i];
        max_exp_ff3[i] <= max_exp_ff2[i];
      end
    end
  end

  generate
    for (j = 0; j < 6; j = j + 1) begin : u_fix2sfp
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

  reg [formatWidth-1:0] sfpout_real_d[4:0];
  reg [formatWidth-1:0] sfpout_imag_d[4:0];
  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < 8; i++) begin
        sfpout_d[i] <= 0;
      end
    end else begin
      sfpout_real_d[0] <= input_real[0];
      sfpout_real_d[1] <= sfpout_real_d[0];
      sfpout_real_d[2] <= sfpout_real_d[1];
      sfpout_real_d[3] <= sfpout_real_d[2];
      sfpout_real_d[4] <= sfpout_real_d[3];

      sfpout_imag_d[0] <= input_imag[0];
      sfpout_imag_d[1] <= sfpout_imag_d[0];
      sfpout_imag_d[2] <= sfpout_imag_d[1];
      sfpout_imag_d[3] <= sfpout_imag_d[2];
      sfpout_imag_d[4] <= sfpout_imag_d[3];
    end
  end

endmodule