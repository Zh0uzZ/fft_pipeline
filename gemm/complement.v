//求补码
module complement #(
    parameter sigWidth   = 4,
    parameter low_expand = 2
) (
    input  [                          3:0] sign,
    input  [(sigWidth+4+low_expand)*4-1:0] input_num,
    output [(sigWidth+4+low_expand)*4-1:0] complement_num
);

  wire [3:0] zero;
  wire [3:0] complement_sign;
  wire [(sigWidth+4+low_expand)*4-1:0] complement_num_buf;

  genvar i;
  generate 
    for(i = 0;i < 4;i = i + 1) begin
    assign zero[i] = (input_num[(sigWidth+4+low_expand)*(i+1)-1 : (sigWidth+4+low_expand)*i] == {(sigWidth+4+low_expand){1'b0}});
  end
  endgenerate
  
  assign complement_sign[0] = sign[0] ^ input_num[(sigWidth+4+low_expand)*1-1];
  assign complement_sign[1] = sign[1] ^ input_num[(sigWidth+4+low_expand)*2-1];
  assign complement_sign[2] = sign[2] ^ input_num[(sigWidth+4+low_expand)*3-1];
  assign complement_sign[3] = sign[3] ^ input_num[(sigWidth+4+low_expand)*4-1];
  assign complement_num_buf[(sigWidth+4+low_expand)*1-2:(sigWidth+4+low_expand)*0] = complement_sign[0] ? ~input_num[(sigWidth+4+low_expand)*1-2:(sigWidth+4+low_expand)*0] + 1 : input_num[(sigWidth+4+low_expand)*1-2:(sigWidth+4+low_expand)*0];
  assign complement_num_buf[(sigWidth+4+low_expand)*2-2:(sigWidth+4+low_expand)*1] = complement_sign[1] ? ~input_num[(sigWidth+4+low_expand)*2-2:(sigWidth+4+low_expand)*1] + 1 : input_num[(sigWidth+4+low_expand)*2-2:(sigWidth+4+low_expand)*1];
  assign complement_num_buf[(sigWidth+4+low_expand)*3-2:(sigWidth+4+low_expand)*2] = complement_sign[2] ? ~input_num[(sigWidth+4+low_expand)*3-2:(sigWidth+4+low_expand)*2] + 1 : input_num[(sigWidth+4+low_expand)*3-2:(sigWidth+4+low_expand)*2];
  assign complement_num_buf[(sigWidth+4+low_expand)*4-2:(sigWidth+4+low_expand)*3] = complement_sign[3] ? ~input_num[(sigWidth+4+low_expand)*4-2:(sigWidth+4+low_expand)*3] + 1 : input_num[(sigWidth+4+low_expand)*4-2:(sigWidth+4+low_expand)*3];
  assign complement_num_buf[(sigWidth+4+low_expand)*1-1] = complement_sign[0];
  assign complement_num_buf[(sigWidth+4+low_expand)*2-1] = complement_sign[1];
  assign complement_num_buf[(sigWidth+4+low_expand)*3-1] = complement_sign[2];
  assign complement_num_buf[(sigWidth+4+low_expand)*4-1] = complement_sign[3];

  generate 
    for(i = 0;i < 4;i = i + 1) begin
    assign complement_num[(sigWidth+4+low_expand)*(i+1)-1 : (sigWidth+4+low_expand)*i] = zero[i] ? {(sigWidth+4+low_expand){1'b0}} : complement_num_buf[(sigWidth+4+low_expand)*(i+1)-1 : (sigWidth+4+low_expand)*i];
  end
  endgenerate
  

endmodule
