//求补码
`include "../include/parameter.vh"
`define UNSIGNED_WIDTH (`SIGWIDTH+4+`LOW_EXPAND)
module complement (
    input  [                  3:0] sign,
    input  [`UNSIGNED_WIDTH*4-1:0] input_num,
    output [`UNSIGNED_WIDTH*4-1:0] complement_num
);

  wire [3:0] zero;
  wire [3:0] complement_sign;
  wire [`UNSIGNED_WIDTH*4-1:0] complement_num_buf;

  genvar i;
  generate
    for(i = 0;i < 4;i = i + 1) begin
    assign zero[i] = (input_num[`UNSIGNED_WIDTH*(i+1)-1 : `UNSIGNED_WIDTH*i] == {`UNSIGNED_WIDTH{1'b0}});
  end
  endgenerate

  assign complement_sign[0] = sign[0] ^ input_num[`UNSIGNED_WIDTH*1-1];
  assign complement_sign[1] = sign[1] ^ input_num[`UNSIGNED_WIDTH*2-1];
  assign complement_sign[2] = sign[2] ^ input_num[`UNSIGNED_WIDTH*3-1];
  assign complement_sign[3] = sign[3] ^ input_num[`UNSIGNED_WIDTH*4-1];
  assign complement_num_buf[`UNSIGNED_WIDTH*1-2:`UNSIGNED_WIDTH*0] = complement_sign[0] ? ~input_num[`UNSIGNED_WIDTH*1-2:`UNSIGNED_WIDTH*0] + 1 : input_num[`UNSIGNED_WIDTH*1-2:`UNSIGNED_WIDTH*0];
  assign complement_num_buf[`UNSIGNED_WIDTH*2-2:`UNSIGNED_WIDTH*1] = complement_sign[1] ? ~input_num[`UNSIGNED_WIDTH*2-2:`UNSIGNED_WIDTH*1] + 1 : input_num[`UNSIGNED_WIDTH*2-2:`UNSIGNED_WIDTH*1];
  assign complement_num_buf[`UNSIGNED_WIDTH*3-2:`UNSIGNED_WIDTH*2] = complement_sign[2] ? ~input_num[`UNSIGNED_WIDTH*3-2:`UNSIGNED_WIDTH*2] + 1 : input_num[`UNSIGNED_WIDTH*3-2:`UNSIGNED_WIDTH*2];
  assign complement_num_buf[`UNSIGNED_WIDTH*4-2:`UNSIGNED_WIDTH*3] = complement_sign[3] ? ~input_num[`UNSIGNED_WIDTH*4-2:`UNSIGNED_WIDTH*3] + 1 : input_num[`UNSIGNED_WIDTH*4-2:`UNSIGNED_WIDTH*3];
  assign complement_num_buf[`UNSIGNED_WIDTH*1-1] = complement_sign[0];
  assign complement_num_buf[`UNSIGNED_WIDTH*2-1] = complement_sign[1];
  assign complement_num_buf[`UNSIGNED_WIDTH*3-1] = complement_sign[2];
  assign complement_num_buf[`UNSIGNED_WIDTH*4-1] = complement_sign[3];

  generate
    for(i = 0;i < 4;i = i + 1) begin
    assign complement_num[`UNSIGNED_WIDTH*(i+1)-1 : `UNSIGNED_WIDTH*i] = zero[i] ? {`UNSIGNED_WIDTH{1'b0}} : complement_num_buf[`UNSIGNED_WIDTH*(i+1)-1 : `UNSIGNED_WIDTH*i];
  end
  endgenerate


endmodule
