module exponent_resize #(
    parameter expWidth = 4
) (
    input [64*expWidth-1:0] input_exp, 
    input [expWidth-1 : 0] max_exp,
    output [64*expWidth-1:0] output_exp
);
    wire [expWidth:0] temp_exp [0:63];
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
            assign temp_exp[i] = (input_exp[expWidth*i+:expWidth]== 4'b0) ? 5'b0 :input_exp[expWidth*i+:expWidth] + max_exp -8;
            assign output_exp[expWidth*i+:expWidth] = temp_exp[i][expWidth] ? 4'b0 : temp_exp[i][expWidth-1:0];
        end
    endgenerate
    
endmodule