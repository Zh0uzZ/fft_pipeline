
`include "parameter.vh"
module commutator2(clk,reset_n,start,input_data,output_data);

input clk , reset_n , start;
input  [nb*4-1:0] input_data;
output [nb*4-1:0] output_data;

`FFTsfpw
parameter stage = 1;

reg [3:0] count;
always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        count <= 0;
    end else if(start) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

wire [nb-1:0] buffer_data [3:0];
wire [nb-1:0] switch_data [3:0];


buffer #(.depth(stage)) u0_buffer(
    .clk(clk),
    .data(input_data[nb-1:0]),
    .data_out(buffer_data[0])
);
assign buffer_data[1] = input_data[nb*2-1:nb];

buffer #(.depth(stage)) u2_buffer(
    .clk(clk),
    .data(input_data[nb*3-1:nb*2]),
    .data_out(buffer_data[2])
);
assign buffer_data[3] = input_data[nb*4-1:nb*3];


always@(*) begin
    case(i)
        0:begin
            switch_data[3] = buffer_data[3];
            switch_data[2] = buffer_data[2];
            switch_data[1] = buffer_data[1];
            switch_data[0] = buffer_data[0];
        end
        1:begin
            switch_data[3] = buffer_data[2];
            switch_data[2] = buffer_data[3];
            switch_data[1] = buffer_data[0];
            switch_data[0] = buffer_data[1];
        end
    endcase
end


buffer #(.depth(stage)) u4_buffer(
    .clk(clk),
    .data(switch_data[3]),
    .data_out(output_data[4*nb-1:3*nb])
);
assign output_data[3*nb-1:2*nb] = switch_data[2];
buffer #(.depth(stage)) u6_buffer(
    .clk(clk),
    .data(switch_data[1]),
    .data_out(output_data[2*nb-1:nb])
);
assign output_data[nb-1:0] = switch_data[0];

endmodule