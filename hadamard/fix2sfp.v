//相加之后定点数的补码转为sfp
module fix2sfp #(
    parameter expWidth    = 4,
    parameter sigWidth    = 4,
    parameter formatWidth = 9,
    parameter low_expand  =  2
) (
    input [sigWidth + 3 + low_expand:0] fixin,
    input [expWidth-1:0] max_exp,
    output [formatWidth-1:0] sfpout
);

  wire                           zero;
  wire [                    3:0] pos;
  wire [sigWidth+2+low_expand:0] expand_significand;
  reg  [           sigWidth-1:0] significand_reg;
  reg  [           expWidth-1:0] expOffset_reg;
  wire [             expWidth:0] expand_exp;

  assign zero = (fixin[sigWidth+2+low_expand:0] == 0);
  assign expand_significand = zero | (~fixin[sigWidth+3+low_expand]) ? fixin[sigWidth+2+low_expand:0] :  ~fixin[sigWidth+2+low_expand:0]+1 ;

  find_one #(
      .sigWidth  (sigWidth),
      .low_expand(low_expand)
  ) u1_findone (
      .input_num(expand_significand),
      .pos      (pos)
  );

  // //四舍五入之前尾数数据
  // always @(*) begin
  //   case (pos)
  //     // 4'd11: begin
  //     //   significand_reg = expand_significand[]
  //     //   significand[(sigWidth-1):0] = expand_significand[8:5];
  //     //   expOffset                = 7 - low_expand;
  //     // end
  //     4'd12: begin
  //       significand_reg  = expand_significand[7] ? expand_significand[11:8]         : expand_significand[11:8];
  //       // significand[(sigWidth-1):0] = expand_significand[8:5];
  //       expOffset_reg                = 8 - low_expand;
  //     end
  //     4'd11: begin
  //       significand_reg  = expand_significand[6] ? expand_significand[10:7]         : expand_significand[10:7];
  //       // significand[(sigWidth-1):0] = expand_significand[8:5];
  //       expOffset_reg                = 7 - low_expand;
  //     end
  //     4'd10: begin
  //       significand_reg  = expand_significand[5] ? expand_significand[9:6]         : expand_significand[9:6];
  //       // significand[(sigWidth-1):0] = expand_significand[8:5];
  //       expOffset_reg                = 6 - low_expand;
  //     end
  //     4'd9: begin
  //       significand_reg  = expand_significand[4] ? expand_significand[8:5]         : expand_significand[8:5];
  //       // significand[(sigWidth-1):0] = expand_significand[8:5];
  //       expOffset_reg                = 5 - low_expand;
  //     end
  //     4'd8: begin
  //       significand_reg  = expand_significand[3] ? expand_significand[7:4]         : expand_significand[7:4];
  //       // significand[(sigWidth-1):0] = expand_significand[7:4];
  //       expOffset_reg = 4 - low_expand;
  //     end
  //     4'd7: begin
  //       significand_reg  = expand_significand[2] ? expand_significand[6:3]         : expand_significand[6:3];
  //       // significand[(sigWidth-1):0] = expand_significand[6:3];
  //       expOffset_reg = 3 - low_expand;
  //     end
  //     4'd6: begin
  //       significand_reg  = expand_significand[1] ? expand_significand[5:2]         : expand_significand[5:2];
  //       // significand[(sigWidth-1):0] = expand_significand[5:2];
  //       expOffset_reg = 2 - low_expand;
  //     end
  //     4'd5: begin
  //       significand_reg  = expand_significand[0] ? expand_significand[4:1]         : expand_significand[4:1];
  //       // significand[(sigWidth-1):0] = expand_significand[4:1];
  //       expOffset_reg = 1 - low_expand;
  //     end
  //     4'd4: begin
  //       // significand_reg = {1'b0 , expand_significand[3:0]};
  //       significand_reg  = expand_significand[3:0];
  //       expOffset_reg = -low_expand;
  //     end
  //     4'd3: begin
  //       significand_reg  = {expand_significand[2:0], 1'b0};
  //       expOffset_reg = -1 - low_expand;
  //     end
  //     4'd2: begin
  //       significand_reg  = {expand_significand[1:0], 2'b0};
  //       expOffset_reg = -2 - low_expand;
  //     end
  //     4'd1: begin
  //       significand_reg  = {expand_significand[0], 3'b0};
  //       expOffset_reg = -3 - low_expand;
  //     end
  //     4'd0: begin
  //       significand_reg  = {4'b0};
  //       expOffset_reg = -4 - low_expand;
  //     end
  //     default: begin
  //       significand_reg  = 0;
  //       expOffset_reg = 4'b0;
  //     end
  //   endcase
  // end
  //尾数数据不经过四舍五入
  always @(*) begin
    case (pos)
//      4'd12: begin
//        significand_reg  = expand_significand[11:8];
//        expOffset_reg = 8 - low_expand;
//      end
//      4'd11: begin
//        significand_reg  = expand_significand[10:7];
//        expOffset_reg = 7 - low_expand;
//      end
//      4'd10: begin
//        significand_reg  = expand_significand[9:6];
//        expOffset_reg = 6 - low_expand;
//      end
      4'd9: begin
        significand_reg  = expand_significand[8:5];
        expOffset_reg = 5 - low_expand;
      end
      4'd8: begin
        significand_reg  = expand_significand[7:4];
        expOffset_reg = 4 - low_expand;
      end
      4'd7: begin
        significand_reg  = expand_significand[6:3];
        expOffset_reg = 3 - low_expand;
      end
      4'd6: begin
        significand_reg  = expand_significand[5:2];
        expOffset_reg = 2 - low_expand;
      end
      4'd5: begin
        significand_reg  = expand_significand[4:1];
        expOffset_reg = 1 - low_expand;
      end
      4'd4: begin
        significand_reg  = expand_significand[3:0];
        expOffset_reg = -low_expand;
      end
      4'd3: begin
        significand_reg  = {expand_significand[2:0], 1'b0};
        expOffset_reg = -1 - low_expand;
      end
      4'd2: begin
        significand_reg  = {expand_significand[1:0], 2'b0};
        expOffset_reg = -2 - low_expand;
      end
      4'd1: begin
        significand_reg  = {expand_significand[0], 3'b0};
        expOffset_reg = -3 - low_expand;
      end
      4'd0: begin
        significand_reg  = {4'b0};
        expOffset_reg = -4 - low_expand;
      end
      default: begin
        significand_reg  = 0;
        expOffset_reg = 4'b0;
      end
    endcase
  end
  assign expand_exp = expOffset_reg + max_exp;
  assign sfpout[sigWidth-1:0] = significand_reg;
  assign sfpout[formatWidth-2:sigWidth] = expOffset_reg[expWidth-1] ? (expand_exp[expWidth] ? expand_exp[expWidth-1:0] : {sigWidth{1'b0}} ) : (expand_exp[expWidth] ? {expWidth{1'b1}}:expand_exp[expWidth-1:0]);
  assign sfpout[formatWidth-1] = zero ? 1'b0 : fixin[sigWidth+3+low_expand];

endmodule
