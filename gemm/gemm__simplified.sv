// control[1:0] , control[1] = 1 : size4  0:size2
// control[0],only GEMM
`include "../include/parameter.vh"
module GEMM_SIMPLIFIED #(
    parameter expWidth    = `EXPWIDTH,
    parameter sigWidth    = `SIGWIDTH,
    parameter formatWidth = `SFPWIDTH,
    parameter low_expand  = `LOW_EXPAND,
    parameter type sfp_t = logic [`SFP_WIDTH-1:0]
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic start_i,
    input  logic control_i,
    input  sfp_t [3:0] dr_i,
    input  sfp_t [3:0] di_i,
    output sfp_t [3:0] dr_o,
    output sfp_t [3:0] di_o,
    output logic ready
);

localparam SIGNED_WIDTH = sigWidth+4+low_expand;
genvar j;
  //debug signals
  wire [formatWidth-1:0] wire_input_real     [3:0];
  wire [formatWidth-1:0] wire_input_imag     [3:0];
  wire [formatWidth-1:0] wire_output_real    [3:0];
  wire [formatWidth-1:0] wire_output_imag    [3:0];
  wire [formatWidth-1:0] wire_twiddle_real   [3:0];
  wire [formatWidth-1:0] wire_twiddle_imag   [3:0];
  generate
    for (j = 0; j < 4; j = j + 1) begin
      assign wire_input_real[j]  = input_real[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_input_imag[j]  = input_imag[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_output_real[j] = output_real[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_output_imag[j] = output_imag[formatWidth*(j+1)-1:formatWidth*j];
      // assign wire_twiddle_real[j] = twiddle_real[formatWidth*(j+1)-1:formatWidth*j];
      // assign wire_twiddle_imag[j] = twiddle_imag[formatWidth*(j+1)-1:formatWidth*j];
    end
  endgenerate



  reg  [             3:0  ] i;
  wire [(expWidth*4-1):0  ] exp_offset_num      [3:0];
  reg  [(expWidth*4-1):0  ] exp_offset_num_reg  [3:0];
  wire [SIGNED_WIDTH*4-1:0] sig_off             [3:0];
  reg  [SIGNED_WIDTH*4-1:0] sig_off_reg         [3:0];
  wire [SIGNED_WIDTH*4-1:0] adder_num           [7:0];
  reg  [SIGNED_WIDTH*4-1:0] adder_num_reg       [7:0];

  wire [  SIGNED_WIDTH-1:0] significand         [7:0];
  reg  [  SIGNED_WIDTH-1:0] significand_reg     [7:0];

  wire [   formatWidth-1:0] sfpout              [7:0];

//触发器数据

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      for (i = 0; i < 4; i = i + 1) begin
        exp_offset_num_reg[i] <= {(expWidth * 4) {1'b0}};
      end
      for (i = 0; i < 4; i = i + 1) begin
        sig_off_reg[i] <= {(40) {1'b0}};
      end
      for (i = 0; i < 8; i = i + 1) begin
        adder_num_reg[i] <= {(40) {1'b0}};
      end
      for (i = 0; i < 8; i = i + 1) begin
        significand_reg[i] <= {(sigWidth + 4 + low_expand) {1'b0}};
      end
      output_real <= 36'b0;
      output_imag <= 36'b0;
    end else begin
      for (i = 0; i < 4; i = i + 1) begin
        exp_offset_num_reg[i] <= exp_offset_num[i];
      end

      for (i = 0; i < 4; i = i + 1) begin
        sig_off_reg[i] <= sig_off[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        adder_num_reg[i] <= adder_num[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        significand_reg[i] <= significand[i];
      end

      output_real <= {sfpout[0], sfpout[1], sfpout[2], sfpout[3]};
      output_imag <= {sfpout[4], sfpout[5], sfpout[6], sfpout[7]};

    end
  end

  //GEMM ready signal
  reg [1:0] count_r;
  always @(posedge clk or negedge rst) begin
    if(~rst)
      count_r <= 2'b11;
    else if (start)
      count_r <= 2'b0;
    else begin
      if(count_r!=2'b11)
        count_r <= count_r + 1;
    end
  end
  assign ready = (count_r == 2);


  //1CYCLE
  //找出最大指数值,并计算出significand应该右移的位数
  //第一个指数对齐module
  wire [4*expWidth-1:0] exp_normalizer_input [3:0];
  wire [(expWidth-1):0] max_exp              [3:0];

  assign exp_normalizer_input[0] = control ? {
      input_real[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_real[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      input_real[(formatWidth*2-2):(formatWidth*2-1-expWidth)],
      input_real[(formatWidth-2) : (formatWidth-1-expWidth)]
    } : {
      input_real[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_real[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      8'b00000000
    };
  exp_normalizer #(  //real[3:0]  or real[3:2]
      .expWidth(expWidth)
  ) u0_exp_normalizer (
      .input_exp     (exp_normalizer_input[0]),
      .max_exp       (max_exp[0]),
      .exp_offset_num(exp_offset_num[0])
  );


  assign exp_normalizer_input[1] = control ? {
      input_real[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_real[(formatWidth*2-2):(formatWidth*2-1-expWidth)],
      input_imag[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      input_imag[(formatWidth-2) : (formatWidth-1-expWidth)]
    }: {
      input_real[(formatWidth*2-2):(formatWidth*2-1-expWidth)],
      input_real[(formatWidth*1-2):(formatWidth*1-1-expWidth)],
      8'b00000000
    };

  exp_normalizer #(  //real[3] , real[1] , imag[2] , imag[0]  or real[1:0]
      .expWidth(expWidth)
  ) u1_exp_normalizer (
      .input_exp     (exp_normalizer_input[1]),
      .max_exp       (max_exp[1]),
      .exp_offset_num(exp_offset_num[1])
  );


  assign exp_normalizer_input[2] = control ? {
      input_imag[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_imag[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      input_imag[(formatWidth*2-2):(formatWidth*2-1-expWidth)],
      input_imag[(formatWidth-2) : (formatWidth-1-expWidth)]
    }: {
      input_imag[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_imag[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      8'b00000000
    };
  exp_normalizer #(
      .expWidth(expWidth)
  ) u2_exp_normalizer (  //imag[3:0] or imag[3:2]
      .input_exp     (exp_normalizer_input[2]),
      .max_exp       (max_exp[2]),
      .exp_offset_num(exp_offset_num[2])
  );


  assign exp_normalizer_input[3] = control ? {
      input_real[(formatWidth*3-2):(formatWidth*3-1-expWidth)],
      input_real[(formatWidth-2):(formatWidth-1-expWidth)],
      input_imag[(formatWidth*4-2):(formatWidth*4-1-expWidth)],
      input_imag[(formatWidth*2-2) : (formatWidth*2-1-expWidth)]
    }: {
      input_imag[(formatWidth*2-2):(formatWidth*2-1-expWidth)],
      input_imag[(formatWidth*1-2):(formatWidth*1-1-expWidth)],
      8'b00000000
    };
  exp_normalizer #(  //real[2] real[0] imag[3] imag[1]   or  imag[1:0]
      .expWidth(expWidth)
  ) u3_exp_normalizer (
      .input_exp     (exp_normalizer_input[3]),
      .max_exp       (max_exp[3]),
      .exp_offset_num(exp_offset_num[3])
  );



  //2CYCLE
  //根据max_exp 求得significand移位结果,并进行尾数补齐为10bit的定点数


  wire [3:0] complement_sign     [7:0];
  assign complement_sign[0] = control ? 4'b0000 : 4'b0000;
  assign complement_sign[1] = control ? 4'b0101 : 4'b0000;
  assign complement_sign[2] = control ? 4'b0101 : 4'b0100;
  assign complement_sign[3] = control ? 4'b0110 : 4'b0100;
  assign complement_sign[4] = control ? 4'b0000 : 4'b0000;
  assign complement_sign[5] = control ? 4'b1001 : 4'b0000;
  assign complement_sign[6] = control ? 4'b0101 : 4'b0100;
  assign complement_sign[7] = control ? 4'b0101 : 4'b0100;

  wire [           3:0] sig_shifter_sign    [3:0];
  wire [4*sigWidth-1:0] sig_shifter_input   [3:0];

  reg [formatWidth*4-1:0] input_real_ff , input_imag_ff;
  always@(posedge clk or negedge rst) begin
    if(~rst) begin
      input_real_ff <= 0;
      input_imag_ff <= 0;
    end else begin
      input_real_ff <= input_real;
      input_imag_ff <= input_imag;
    end
  end

  assign sig_shifter_sign[0] = control ? {
      input_real_ff[formatWidth*4-1],
      input_real_ff[formatWidth*3-1],
      input_real_ff[formatWidth*2-1],
      input_real_ff[formatWidth-1]
    } : {
      input_real_ff[formatWidth*4-1],
      input_real_ff[formatWidth*3-1],
      2'b00
    };
  assign sig_shifter_input[0] = control ? {
      input_real_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_real_ff[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_real_ff[formatWidth-2-expWidth:0]
    } : {
      input_real_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      8'b0000_0000
    } ;
  SIG_SHIFTER #(  //real[3:0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u0_sig_shifter (
      .exp_offset_num  (exp_offset_num_reg[0]),
      .significand     (sig_shifter_input[0]),
      .sign            (sig_shifter_sign[0]),
      .complement_sign1(complement_sign[0]),
      .complement_sign2(complement_sign[2]),
      .adder_num1      (adder_num[0]),
      .adder_num2      (adder_num[2])
  );


  assign sig_shifter_sign[1] = control ? {
      input_real_ff[formatWidth*4-1],
      input_real_ff[formatWidth*2-1],
      input_imag_ff[formatWidth*3-1],
      input_imag_ff[formatWidth-1]
    } : {
      input_real_ff[formatWidth*2-1],
      input_real_ff[formatWidth*1-1],
      2'b00
    };
  assign sig_shifter_input[1] = control ? {
      input_real_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real_ff[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_imag_ff[formatWidth-2-expWidth:0]
    } : {
      input_real_ff[(formatWidth*2-2-expWidth):(formatWidth)],
      input_real_ff[(formatWidth*1-2-expWidth):0],
      8'b0000_0000
    } ;
  SIG_SHIFTER #(  //real[3] , real[1] , imag[2] , imag[0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_sig_shifter (
      .exp_offset_num  (exp_offset_num_reg[1]),
      .significand     (sig_shifter_input[1]),
      .sign            (sig_shifter_sign[1]),
      .complement_sign1(complement_sign[1]),
      .complement_sign2(complement_sign[3]),
      .adder_num1      (adder_num[1]),
      .adder_num2      (adder_num[3])
  );


  assign sig_shifter_sign[2] = control ? {
      input_imag_ff[formatWidth*4-1],
      input_imag_ff[formatWidth*3-1],
      input_imag_ff[formatWidth*2-1],
      input_imag_ff[formatWidth-1]
    } : {
      input_imag_ff[formatWidth*4-1],
      input_imag_ff[formatWidth*3-1],
      2'b00
    };
  assign sig_shifter_input[2] = control ? {
      input_imag_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_imag_ff[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag_ff[formatWidth-2-expWidth:0]
    } : {
      input_imag_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      8'b0000_0000
    } ;
  SIG_SHIFTER #(  //imag[3:0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u2_sig_shifter (
      .exp_offset_num(exp_offset_num_reg[2]),
      .significand   (sig_shifter_input[2]),
      .sign          (sig_shifter_sign[2]),
      .complement_sign1(complement_sign[4]),
      .complement_sign2(complement_sign[6]),
      .adder_num1(adder_num[4]),
      .adder_num2(adder_num[6])
  );


  assign sig_shifter_sign[3] = control ? {
      input_real_ff[formatWidth*3-1],
      input_real_ff[formatWidth*1-1],
      input_imag_ff[formatWidth*4-1],
      input_imag_ff[formatWidth*2-1]
    } : {
      input_imag_ff[formatWidth*2-1],
      input_imag_ff[formatWidth*1-1],
      2'b00
    };
  assign sig_shifter_input[3] = control ? {
      input_real_ff[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_real_ff[(formatWidth*1-2-expWidth):(formatWidth*0)],
      input_imag_ff[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag_ff[formatWidth*2-2-expWidth:formatWidth*1]
    } : {
      input_imag_ff[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag_ff[(formatWidth*1-2-expWidth):0],
      8'b0000_0000
    } ;
  SIG_SHIFTER #(  //real[2] real[0] imag[3] imag[1]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u3_sig_shifter (
      .exp_offset_num(exp_offset_num_reg[3]),
      .significand   (sig_shifter_input[3]),
      .sign          (sig_shifter_sign[3]),
      .complement_sign1(complement_sign[5]),
      .complement_sign2(complement_sign[7]),
      .adder_num1(adder_num[5]),
      .adder_num2(adder_num[7])
  );



  //3CYCLE 计算4个定点补码的和
  //计算加法的部分
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u0_adder (
      .sigOffset(adder_num_reg[0]),
      .significand (significand[0])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_adder (
      .sigOffset(adder_num_reg[1]),
      .significand (significand[1])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u2_adder (
      .sigOffset(adder_num_reg[2]),
      .significand (significand[2])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u3_adder (
      .sigOffset(adder_num_reg[3]),
      .significand (significand[3])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u4_adder (
      .sigOffset(adder_num_reg[4]),
      .significand (significand[4])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u5_adder (
      .sigOffset(adder_num_reg[5]),
      .significand (significand[5])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u6_adder (
      .sigOffset(adder_num_reg[6]),
      .significand (significand[6])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u7_adder (
      .sigOffset(adder_num_reg[7]),
      .significand (significand[7])
  );



  //4CYCLE ， 将得到的10bit定点数转化为小浮点数
  //将10bit定点数转化为sfp数
  reg [expWidth-1:0] max_exp_ff1 [3:0];
  reg [expWidth-1:0] max_exp_ff2 [3:0];
  reg [expWidth-1:0] max_exp_ff3 [3:0];
  // reg [expWidth-1:0] max_exp_ff4 [3:0];
  always@(posedge clk or negedge rst) begin
    if(~rst) begin
      for (i = 0; i < 4; i = i + 1) begin
        max_exp_ff1[i] <= 0;
        max_exp_ff2[i] <= 0;
        max_exp_ff3[i] <= 0;
        // max_exp_ff4[i] <= 0;
      end
    end else begin
      for (i = 0; i < 4; i = i + 1) begin
        max_exp_ff1[i] <= max_exp[i];
        max_exp_ff2[i] <= max_exp_ff1[i];
        max_exp_ff3[i] <= max_exp_ff2[i];
        // max_exp_ff4[i] <= max_exp_ff3[i];
      end
    end
  end

  generate
    for (j = 0; j < 2; j = j + 1) begin : u0_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (significand_reg[j]),
          .max_exp(max_exp_ff3[j]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate
  generate
    for (j = 2; j < 6; j = j + 1) begin : u1_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (significand_reg[j]),
          .max_exp(max_exp_ff3[j-2]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate
  generate
    for (j = 6; j < 8; j = j + 1) begin : u2_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (significand_reg[j]),
          .max_exp(max_exp_ff3[j-4]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate

endmodule
