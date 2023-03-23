// control[1:0] , control[1] = 1 : size4  

module gemm #(
    parameter expWidth    = 4,
    parameter sigWidth    = 4,
    parameter formatWidth = 9,
    parameter low_expand  = 2
) (
    input                              clk,
    input                              rst,
    input                              start,
    input                              control,
    input      [(formatWidth*4-1) : 0] input_real,
    input      [(formatWidth*4-1) : 0] input_imag,
    output reg [(formatWidth*4-1) : 0] output_real,
    output reg [(formatWidth*4-1) : 0] output_imag,
    output reg                         gemm_done
);
  localparam IDLE = 3'b000;  //等待start信号
  localparam EXPONENT_NORMALIZE = 3'b001;  //指数归一化，找到最大指数
  localparam MANTISSA_OFFSET = 3'b010;  //尾数对齐
  localparam COMPLEMENT = 3'b011;  //取尾数的补码
  localparam ADDER = 3'b100;  //尾数补码进行加法
  localparam FIX2SFP = 3'b101;  //对sfp数字进行指数、尾数的拼接


  //debug signals 
  wire [formatWidth-1:0] wire_input_real     [3:0];
  wire [formatWidth-1:0] wire_input_imag     [3:0];
  wire [formatWidth-1:0] wire_output_real    [3:0];
  wire [formatWidth-1:0] wire_output_imag    [3:0];
  wire [formatWidth-1:0] wire_twiddle_real   [3:0];
  wire [formatWidth-1:0] wire_twiddle_imag   [3:0];
  genvar j;
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



  reg  [                          3:0] i;
  wire [             (expWidth*4-1):0] exp_offset_num      [3:0];
  reg  [             (expWidth*4-1):0] exp_offset_num_reg  [3:0];
  wire [(sigWidth+4+low_expand)*4-1:0] man_off             [3:0];
  reg  [(sigWidth+4+low_expand)*4-1:0] man_off_reg         [3:0];
  wire [(sigWidth+4+low_expand)*4-1:0] adder_num           [7:0];
  reg  [(sigWidth+4+low_expand)*4-1:0] adder_num_reg       [7:0];

  wire [    sigWidth+4+low_expand-1:0] mantissa            [7:0];
  reg  [    sigWidth+4+low_expand-1:0] mantissa_reg        [7:0];

  wire [              formatWidth-1:0] sfpout              [7:0];

//触发器数据

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      for (i = 0; i < 4; i = i + 1) begin
        exp_offset_num_reg[i] <= {(expWidth * 4) {1'b0}};
      end
      for (i = 0; i < 4; i = i + 1) begin
        man_off_reg[i] <= {(40) {1'b0}};
      end
      for (i = 0; i < 8; i = i + 1) begin
        adder_num_reg[i] <= {(40) {1'b0}};
      end
      for (i = 0; i < 8; i = i + 1) begin
        mantissa_reg[i] <= {(sigWidth + 4 + low_expand) {1'b0}};
      end
      output_real <= 36'b0;
      output_imag <= 36'b0;
    end else begin
      for (i = 0; i < 4; i = i + 1) begin
        exp_offset_num_reg[i] <= exp_offset_num[i];
      end

      for (i = 0; i < 4; i = i + 1) begin
        man_off_reg[i] <= man_off[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        adder_num_reg[i] <= adder_num[i];
      end

      for (i = 0; i < 8; i = i + 1) begin
        mantissa_reg[i] <= mantissa[i];
      end

      begin
        output_real <= {sfpout[0], sfpout[1], sfpout[2], sfpout[3]};
        output_imag <= {sfpout[4], sfpout[5], sfpout[6], sfpout[7]};
      end

    end
  end

  //找出最大指数值，并进行尾数移位
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



  //根据max_exp 求得mantissa移位结果
  wire [           3:0] man_shifter_sign    [3:0];
  wire [4*sigWidth-1:0] man_shifter_input   [3:0];

  assign man_shifter_sign[0] = control ? {
      input_real[formatWidth*4-1],
      input_real[formatWidth*3-1],
      input_real[formatWidth*2-1],
      input_real[formatWidth-1]
    } : {
      input_real[formatWidth*4-1],
      input_real[formatWidth*3-1],
      2'b00
    };
  assign man_shifter_input[0] = control ? {
      input_real[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_real[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_real[formatWidth-2-expWidth:0]
    } : {
      input_real[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real[(formatWidth*3-2-expWidth):(formatWidth*2)],
      8'b0000_0000
    } ;
  man_shifter #(  //real[3:0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u0_man_shifter (
      .exp_offset_num(exp_offset_num_reg[0]),
      .mantissa      (man_shifter_input[0]),
      .sign          (man_shifter_sign[0]),
      .man_off       (man_off[0])
  );


  assign man_shifter_sign[1] = control ? {
      input_real[formatWidth*4-1],
      input_real[formatWidth*2-1],
      input_imag[formatWidth*3-1],
      input_imag[formatWidth-1]
    } : {
      input_real[formatWidth*2-1],
      input_real[formatWidth*1-1],
      2'b00
    };
  assign man_shifter_input[1] = control ? {
      input_real[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_real[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_imag[formatWidth-2-expWidth:0]
    } : {
      input_real[(formatWidth*2-2-expWidth):(formatWidth)],
      input_real[(formatWidth*1-2-expWidth):0],
      8'b0000_0000
    } ;
  man_shifter #(  //real[3] , real[1] , imag[2] , imag[0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_man_shifter (
      .exp_offset_num(exp_offset_num_reg[1]),
      .mantissa      (man_shifter_input[1]),
      .sign          (man_shifter_sign[1]),
      .man_off       (man_off[1])
  );


  assign man_shifter_sign[2] = control ? {
      input_imag[formatWidth*4-1],
      input_imag[formatWidth*3-1],
      input_imag[formatWidth*2-1],
      input_imag[formatWidth-1]
    } : {
      input_imag[formatWidth*4-1],
      input_imag[formatWidth*3-1],
      2'b00
    };
  assign man_shifter_input[2] = control ? {
      input_imag[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_imag[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag[formatWidth-2-expWidth:0]
    } : {
      input_imag[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag[(formatWidth*3-2-expWidth):(formatWidth*2)],
      8'b0000_0000
    } ;
  man_shifter #(  //imag[3:0]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u2_man_shifter (
      .exp_offset_num(exp_offset_num_reg[2]),
      .mantissa      (man_shifter_input[2]),
      .sign          (man_shifter_sign[2]),
      .man_off       (man_off[2])
  );


  assign man_shifter_sign[3] = control ? {
      input_real[formatWidth*3-1],
      input_real[formatWidth*1-1],
      input_imag[formatWidth*4-1],
      input_imag[formatWidth*2-1]
    } : {
      input_imag[formatWidth*2-1],
      input_imag[formatWidth*1-1],
      2'b00
    };
  assign man_shifter_input[3] = control ? {
      input_real[(formatWidth*3-2-expWidth):(formatWidth*2)],
      input_real[(formatWidth*1-2-expWidth):(formatWidth*0)],
      input_imag[(formatWidth*4-2-expWidth):(formatWidth*3)],
      input_imag[formatWidth*2-2-expWidth:formatWidth*1]
    } : {
      input_imag[(formatWidth*2-2-expWidth):(formatWidth*1)],
      input_imag[(formatWidth*1-2-expWidth):0],
      8'b0000_0000
    } ;
  man_shifter #(  //real[2] real[0] imag[3] imag[1]
      .expWidth  (expWidth),
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u3_man_shifter (
      .exp_offset_num(exp_offset_num_reg[3]),
      .mantissa      (man_shifter_input[3]),
      .sign          (man_shifter_sign[3]),
      .man_off       (man_off[3])
  );




  //求出adder_4in的加数

  wire [3:0] complement_sign     [7:0];
  assign complement_sign[0] = control ? 4'b0000 : 4'b0000;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u0_complement (
      .sign          (complement_sign[0]),
      .input_num     (man_off_reg[0]),
      .complement_num(adder_num[0])
  );

  assign complement_sign[1] = control ? 4'b0101 : 4'b0000;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_complement (
      .sign          (complement_sign[1]),
      .input_num     (man_off_reg[1]),
      .complement_num(adder_num[1])
  );


  assign complement_sign[2] = control ? 4'b0101 : 4'b0100;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u2_complement (
      .sign          (complement_sign[2]),
      .input_num     (man_off_reg[0]),
      .complement_num(adder_num[2])
  );


  assign complement_sign[3] = control ? 4'b0110 : 4'b0100;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u3_complement (
      .sign          (complement_sign[3]),
      .input_num     (man_off_reg[1]),
      .complement_num(adder_num[3])
  );


  assign complement_sign[4] = control ? 4'b0000 : 4'b0000;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u4_complement (
      .sign          (complement_sign[4]),
      .input_num     (man_off_reg[2]),
      .complement_num(adder_num[4])
  );


  assign complement_sign[5] = control ? 4'b1001 : 4'b0000;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u5_complement (
      .sign          (complement_sign[5]),
      .input_num     (man_off_reg[3]),
      .complement_num(adder_num[5])
  );


  assign complement_sign[6] = control ? 4'b0101 : 4'b0100;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u6_complement (
      .sign          (complement_sign[6]),
      .input_num     (man_off_reg[2]),
      .complement_num(adder_num[6])
  );


  assign complement_sign[7] = control ? 4'b0101 : 4'b0100;
  complement #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u7_complement (
      .sign          (complement_sign[7]),
      .input_num     (man_off_reg[3]),
      .complement_num(adder_num[7])
  );




  //计算加法的部分
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u0_adder (
      .manOffset(adder_num_reg[0]),
      .mantissa (mantissa[0])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_adder (
      .manOffset(adder_num_reg[1]),
      .mantissa (mantissa[1])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u2_adder (
      .manOffset(adder_num_reg[2]),
      .mantissa (mantissa[2])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u3_adder (
      .manOffset(adder_num_reg[3]),
      .mantissa (mantissa[3])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u4_adder (
      .manOffset(adder_num_reg[4]),
      .mantissa (mantissa[4])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u5_adder (
      .manOffset(adder_num_reg[5]),
      .mantissa (mantissa[5])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u6_adder (
      .manOffset(adder_num_reg[6]),
      .mantissa (mantissa[6])
  );
  adder_4in #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u7_adder (
      .manOffset(adder_num_reg[7]),
      .mantissa (mantissa[7])
  );


  //将10bit定点数转化为sfp数
  generate
    for (j = 0; j < 2; j = j + 1) begin : u0_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (mantissa_reg[j]),
          .max_exp(max_exp[j]),
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
          .fixin  (mantissa_reg[j]),
          .max_exp(max_exp[j-2]),
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
          .fixin  (mantissa_reg[j]),
          .max_exp(max_exp[j-4]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate

endmodule
