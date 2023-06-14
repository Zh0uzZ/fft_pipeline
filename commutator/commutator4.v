`include "../include/parameter.vh"
module commutator4(clk,reset_n,start,input_data,output_data,done);

input clk , reset_n , start;
input  [nb*4-1:0] input_data  ;
output [nb*4-1:0] output_data ;
output wire done;

`FFTsfpw
parameter stage = 2;

reg [2:0] count , count_r;
always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        count <= 0;
        count_r <= 3'b111;
    end else if(start) begin
        count <= 0;
        count_r <= 0;
    end else begin
        count <= count + 1;
        if(count_r!=3'b111)
            count_r <= count_r + 1;
    end
end
assign done = (count_r==6) ? 1: 0;

wire [nb-1:0] buffer_data [3:0];
reg  [nb-1:0] switch [3:0];


buffer #(.depth(3*stage)) u0_buffer(
    .clk(clk),
    .data(input_data[nb-1:0]),
    .data_out(buffer_data[0])
);
buffer #(.depth(2*stage)) u1_buffer(
    .clk(clk),
    .data(input_data[nb*2-1:nb]),
    .data_out(buffer_data[1])
);
buffer #(.depth(1*stage)) u2_buffer(
    .clk(clk),
    .data(input_data[nb*3-1:nb*2]),
    .data_out(buffer_data[2])
);
assign buffer_data[3] = input_data[nb*4-1:nb*3];


always@(*) begin
    case(count)
        0,1:begin
            switch[3] = buffer_data[3];
            switch[2] = buffer_data[0];
            switch[1] = buffer_data[1];
            switch[0] = buffer_data[2];
        end
        2,3:begin
            switch[3] = buffer_data[2];
            switch[2] = buffer_data[3];
            switch[1] = buffer_data[0];
            switch[0] = buffer_data[1];
        end
        4,5:begin
            switch[3] = buffer_data[1];
            switch[2] = buffer_data[2];
            switch[1] = buffer_data[3];
            switch[0] = buffer_data[0];
        end
        6,7:begin
            switch[3] = buffer_data[0];
            switch[2] = buffer_data[1];
            switch[1] = buffer_data[2];
            switch[0] = buffer_data[3];
        end
    endcase
end


buffer #(.depth(3*stage)) u4_buffer(
    .clk(clk),
    .data(switch[3]),
    .data_out(output_data[4*nb-1:3*nb])
);
buffer #(.depth(2*stage)) u5_buffer(
    .clk(clk),
    .data(switch[2]),
    .data_out(output_data[3*nb-1:2*nb])
);
buffer #(.depth(1*stage)) u6_buffer(
    .clk(clk),
    .data(switch[1]),
    .data_out(output_data[2*nb-1:nb])
);
assign output_data[nb-1:0] = switch[0];

endmodule