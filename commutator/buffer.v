`include "parameter.vh"
module buffer(clk,data,data_out);
`FFTsfpw
parameter depth = 3;
input clk;
input [nb-1:0] data;
output reg [nb-1:0] data_out;

genvar i;
generate
    if(depth==1) begin : buffer_1
        always @(posedge clk) begin
            data_out <= data;
        end
    end
    else begin : buffer_n
        reg [nb-1:0] data_array [depth-2:0];

        always @(posedge clk) begin
            data_array[0] <= data;
        end
        for(i=1;i<depth-1;i=i+1) begin : generate_buffer
            always@(posedge clk) begin
                data_array[i] <= data_array[i-1];
            end
        end
        always @(posedge clk) begin
            data_out <= data_array[depth-2];
        end
    end
endgenerate

endmodule