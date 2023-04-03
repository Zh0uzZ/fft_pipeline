// FFT 向量大小为4时，vector_size4
//
`include "parameter.vh"
module vector_size4 (
    input                          clk,
    input                          rst,
    input                          start,
    input  [                1 : 0] control,
    input  [(`SFPWIDTH*4-1) : 0] input_real,
    input  [(`SFPWIDTH*4-1) : 0] input_imag,
    input  [(`SFPWIDTH*4-1) : 0] twiddle_real,
    input  [(`SFPWIDTH*4-1) : 0] twiddle_imag,
    output [(`SFPWIDTH*4-1) : 0] output_real,
    output [(`SFPWIDTH*4-1) : 0] output_imag,
    output                         vector_done
);

  parameter expWidth    = `EXPWIDTH;
  parameter sigWidth    = `SIGWIDTH;
  parameter formatWidth = `SFPWIDTH;
  parameter low_expand  = `LOW_EXPAND;
  parameter fixWidth    = `FIXWIDTH;

  wire gemm_done;
  wire hadamard_start, hadamard_done;
  wire vector_done;
  wire [formatWidth*4-1 : 0] temp_real, temp_imag, wire_output_real, wire_output_imag;



  //debug signals 
  wire [formatWidth-1:0] wire_input_real   [3:0];
  wire [formatWidth-1:0] wire_input_imag   [3:0];
  wire [formatWidth-1:0] wire_output_real_1[3:0];
  wire [formatWidth-1:0] wire_output_imag_1[3:0];
  wire [formatWidth-1:0] wire_twiddle_real [3:0];
  wire [formatWidth-1:0] wire_twiddle_imag [3:0];
  genvar j;
  generate
    for (j = 0; j < 4; j = j + 1) begin
      assign wire_input_real[j] = input_real[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_input_imag[j] = input_imag[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_output_real_1[j] = output_real[formatWidth*(j+1)-1:formatWidth*j];
      assign wire_output_imag_1[j] = output_imag[formatWidth*(j+1)-1:formatWidth*j];
      // assign wire_twiddle_real[j] = twiddle_real[formatWidth*(j+1)-1:formatWidth*j];
      // assign wire_twiddle_imag[j] = twiddle_imag[formatWidth*(j+1)-1:formatWidth*j];
    end
  endgenerate



  gemm #(
      .expWidth   (expWidth),
      .sigWidth   (sigWidth),
      .formatWidth(formatWidth),
      .low_expand (low_expand)
  ) u_gemm (
      .clk        (clk),
      .rst        (rst),
      .start      (start),
      .control    (control[1]),
      .input_real (input_real),
      .input_imag (input_imag),
      .output_real(temp_real),
      .output_imag(temp_imag),
      .gemm_done  (gemm_done)
  );


  complexhadamard #(
      .expWidth   (expWidth),
      .sigWidth   (sigWidth),
      .formatWidth(formatWidth),
      .low_expand (low_expand)
  ) u_complexhadamard (
      .clk          (clk),
      .rst          (rst),
      .start        (gemm_done),
      .input_real   (temp_real),
      .input_imag   (temp_imag),
      .twiddle_real (twiddle_real),
      .twiddle_imag (twiddle_imag),
      .output_real  (wire_output_real),
      .output_imag  (wire_output_imag),
      .hadamard_done(hadamard_done)
  );
  assign hadamard_start = control[0] ? gemm_done : 1'b0;
  assign vector_done    = control[0] ? hadamard_done : gemm_done;
  assign output_real = control[0] ? wire_output_real : temp_real;
  assign output_imag = control[0] ? wire_output_imag : temp_imag;

endmodule
