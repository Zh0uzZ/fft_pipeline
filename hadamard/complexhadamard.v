module complexhadamard #(
    parameter expWidth    = 4,
    parameter sigWidth    = 4,
    parameter formatWidth = 9,
    parameter low_expand  = 2
) (
    input                          clk,
    input                          rst,
    input                          start,
    input      [formatWidth*4-1:0] input_real,
    input      [formatWidth*4-1:0] input_imag,
    input      [formatWidth*4-1:0] twiddle_real,
    input      [formatWidth*4-1:0] twiddle_imag,
    output reg [formatWidth*4-1:0] output_real,
    output reg [formatWidth*4-1:0] output_imag,
    output reg                     hadamard_done
);
  localparam IDLE = 3'b000;
  localparam SFP_MULTIPLY = 3'b001;
  localparam EXP_NORMALIZER = 3'b010;
  localparam MANTISSA_OFF = 3'b011;
  localparam ADDER = 3'b100;
  localparam FIX2SFP = 3'b101;
  localparam DONE = 3'b110;



  genvar j;
  reg  [                          3:0] i;
  reg  [                          2:0] current_state;
  reg  [                          2:0] next_state;
  wire [              formatWidth-1:0] sfp_real          [7:0];
  wire [              formatWidth-1:0] sfp_imag          [7:0];
  reg  [            formatWidth*8-1:0] sfp_real_reg;
  reg  [            formatWidth*8-1:0] sfp_imag_reg;
  wire [                 expWidth-1:0] max_exp           [7:0];
  wire [               expWidth*2-1:0] exp_offset_num    [7:0];
  reg  [               expWidth*2-1:0] exp_offset_num_reg[7:0];
  wire [(sigWidth+4+low_expand)*2-1:0] man_off           [7:0];
  reg  [(sigWidth+4+low_expand)*2-1:0] man_off_reg       [7:0];
  wire [    sigWidth+3+low_expand : 0] adder_num         [7:0];
  reg  [    sigWidth+3+low_expand : 0] adder_num_reg     [7:0];
  wire [              formatWidth-1:0] sfpout            [7:0];




  //debug signals 
  wire [              formatWidth-1:0] wire_input_real   [3:0];
  wire [              formatWidth-1:0] wire_input_imag   [3:0];
  wire [              formatWidth-1:0] wire_output_real  [3:0];
  wire [              formatWidth-1:0] wire_output_imag  [3:0];
  wire [              formatWidth-1:0] wire_twiddle_real [3:0];
  wire [              formatWidth-1:0] wire_twiddle_imag [3:0];
  genvar k;
  generate
    for (k = 0; k < 4; k = k + 1) begin
      assign wire_input_real[k]   = input_real[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_input_imag[k]   = input_imag[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_output_real[k]  = output_real[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_output_imag[k]  = output_imag[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_twiddle_real[k] = twiddle_real[formatWidth*(k+1)-1:formatWidth*k];
      assign wire_twiddle_imag[k] = twiddle_imag[formatWidth*(k+1)-1:formatWidth*k];
    end
  endgenerate





  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      current_state <= 0;
      sfp_real_reg  <= 0;
      sfp_imag_reg  <= 0;
      output_real   <= 0;
      output_imag   <= 0;
      for (i = 0; i < 8; i = i + 1) begin
        exp_offset_num_reg[i] <= {(2 * expWidth) {1'b0}};
        man_off_reg[i]        <= {((sigWidth + 4 + low_expand) * 2) {1'b0}};
        adder_num_reg[i]      <= {(sigWidth + 4 + low_expand) {1'b0}};
      end

    end else begin
      current_state <= next_state;
    end
  end

  always @(*) begin
    case (current_state)
      IDLE: begin
        if (start) begin
          next_state = SFP_MULTIPLY;
        end else begin
          next_state = IDLE;
        end
        hadamard_done = 0;
      end
      SFP_MULTIPLY: begin
        sfp_real_reg = {
          sfp_real[7],
          sfp_real[6],
          sfp_real[5],
          sfp_real[4],
          sfp_real[3],
          sfp_real[2],
          sfp_real[1],
          sfp_real[0]
        };
        sfp_imag_reg = {
          sfp_imag[7],
          sfp_imag[6],
          sfp_imag[5],
          sfp_imag[4],
          sfp_imag[3],
          sfp_imag[2],
          sfp_imag[1],
          sfp_imag[0]
        };
        next_state = EXP_NORMALIZER;
      end
      EXP_NORMALIZER: begin
        for (i = 0; i < 8; i = i + 1) begin
          exp_offset_num_reg[i] = exp_offset_num[i];
        end
        next_state = MANTISSA_OFF;
      end
      MANTISSA_OFF: begin
        for (i = 0; i < 8; i = i + 1) begin
          man_off_reg[i] = man_off[i];
        end
        next_state = ADDER;
      end
      ADDER: begin
        for (i = 0; i < 8; i = i + 1) begin
          adder_num_reg[i] = adder_num[i];
        end
        next_state = FIX2SFP;
      end
      FIX2SFP: begin
        output_real = {sfpout[3], sfpout[2], sfpout[1], sfpout[0]};
        output_imag = {sfpout[7], sfpout[6], sfpout[5], sfpout[4]};
        hadamard_done = 1;
        next_state = IDLE;
      end

    endcase
  end



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


  // 指数找到最大值以及算出偏移量
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


  //指数部分右移
  generate
    for (j = 0; j < 4; j = j + 1) begin : u0_man_shifter
      man_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_man_shifter (
          .exp_offset_num(exp_offset_num_reg[j]),
          .mantissa({
            sfp_real_reg[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_real_reg[formatWidth*(j+5)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_real_reg[formatWidth*(j+1)-1], 1'b1 ^ sfp_real_reg[formatWidth*(j+5)-1]}),
          .man_off(man_off[j])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 4; j = j + 1) begin : u1_man_shifter
      man_shifter_2 #(
          .expWidth  (expWidth),
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_man_shifter (
          .exp_offset_num(exp_offset_num_reg[j+4]),
          .mantissa({
            sfp_imag_reg[formatWidth*(j+1)-2-expWidth-:sigWidth],
            sfp_imag_reg[formatWidth*(j+5)-2-expWidth-:sigWidth]
          }),
          .sign({sfp_imag_reg[formatWidth*(j+1)-1], sfp_imag_reg[formatWidth*(j+5)-1]}),
          .man_off(man_off[j+4])
      );
    end
  endgenerate


  //求补码并且10bit数据相加
  generate
    for (j = 0; j < 8; j = j + 1) begin : u_adder_2in
      adder_2in #(
          .sigWidth  (sigWidth),
          .low_expand(low_expand)
      ) u_adder_2in (
          .input_num(man_off_reg[j]),
          .adder_num(adder_num[j])
      );
    end
  endgenerate


  //对得到的10bit定点数，求补码并且转换为sfp数

  generate
    for (j = 0; j < 8; j = j + 1) begin : u_fix2sfp
      fix2sfp #(
          .expWidth(expWidth),
          .sigWidth(sigWidth),
          .formatWidth(formatWidth),
          .low_expand(low_expand)
      ) u_fix2sfp (
          .fixin  (adder_num_reg[j]),
          .max_exp(max_exp[j]),
          .sfpout (sfpout[j])
      );
    end
  endgenerate



endmodule
