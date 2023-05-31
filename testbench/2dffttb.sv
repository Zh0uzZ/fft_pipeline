`include "parameter.vh"
module fft2d_tb;

`FFTsfpw
parameter type sfp_t = logic [nb-1:0];
  logic clk_i , rst_ni , start_d , start_i , rdy_o;
  logic [nb-1:0] data [64][64];
  sfp_t [3:0] dr_i , di_i , dr_o , di_o;

  integer file;

  initial begin
    $readmemh("/home/hank/workspace/kcf/sfp_fft/sfp44_rtl/sfp44/rtl.txt" , data);
    file = $fopen("/home/hank/workspace/repos/fft32/fft_pipeline/work/result.txt","w");
    for(int i = 0; i < 32; i++) begin
        for(int j = 0; j < 32; j++) begin
            $fwrite(file , "data[%0d][%0d] = %03h  ", i, j, data[i][j]);
        end
    end
    $fclose(file);
  end

  initial begin
    clk_i = 0; rst_ni = 1; start_d = 0;
    #20 rst_ni = 0; #10 rst_ni = 1;
    @(posedge clk_i) start_d = 1;
    #10 start_d = 0;
  end
  always #5 clk_i = ~ clk_i;

  logic [2:0] count;
  logic [4:0] row;
  always_ff @(posedge clk_i) begin
    if(start_d) begin
        count <= 0;
        row <= 0;
        start_i <= 1;
        // dr_i <= {data[0][0]    , data[0][8]  , data[0][16] , data[0][24]};
        // di_i <= {data[0][0+32] , data[0][40] , data[0][48] , data[0][56]};
    end else begin
        start_i <= 0;
        count <= count + 1;
        dr_i <= {data[row][count] , data[row][count+8] , data[row][count+16] , data[row][count+24]};
        di_i <= {data[row][count+32] , data[row][count+40] , data[row][count+48] , data[row][count+56]};
        if(count == 3'b111)
            row <= row + 1;
    end
  end

  fft_2d u_2dfft(
    .clk_i , .rst_ni , .start_i , .dr_i , .di_i , .dr_o , .di_o , .rdy_o
  );

endmodule