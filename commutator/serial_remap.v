`include "../include/parameter.vh"
module serial_remap (clk,reset_n,start,input_data,output_data);
`FFTsfpw

input clk,reset_n,start;
input [nb-1:0] input_data;
output reg [nb-1:0] output_data;

reg [3:0] count;
reg count_stage;
wire count_stage_next;

always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        count <= 0;
        count_stage <= 0;
    end else if(start) begin
        count <= 0;
        count_stage <= 0;
    end else begin
        count <= count + 1;
        count_stage <= count_stage_next;
    end
end
assign count_stage_next = (count==7||count==15) ? ~count_stage : count_stage;


reg [nb-1:0] buffer_data [15:0];
always@(posedge clk) begin
    buffer_data[count] <= input_data;
end

always@(*) begin
    case(count_stage)
    0:begin
        case(count)
        0,8 :output_data = buffer_data[8];
        1,9 :output_data = buffer_data[10];
        2,10:output_data = buffer_data[12];
        3,11:output_data = buffer_data[14];
        4,12:output_data = buffer_data[9];
        5,13:output_data = buffer_data[11];
        6,14:output_data = buffer_data[13];
        7,15:output_data = buffer_data[15];
        endcase
    end
    1:begin
        case(count)
        0,8 :output_data = buffer_data[0];
        1,9 :output_data = buffer_data[2];
        2,10:output_data = buffer_data[4];
        3,11:output_data = buffer_data[6];
        4,12:output_data = buffer_data[1];
        5,13:output_data = buffer_data[3];
        6,14:output_data = buffer_data[5];
        7,15:output_data = buffer_data[7];
        endcase
    end
    endcase
end

endmodule