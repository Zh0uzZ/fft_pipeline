module exponent_reciprocal #(
    parameter expWidth = 4
) (
    input [64*expWidth-1:0] input_exp, 
    input [expWidth-1 : 0] max_exp,
    output [64*expWidth-1:0] output_exp
);
    wire [expWidth:0] temp_exp [63:0];
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
            assign temp_exp[i] = (input_exp[expWidth*(i+1) -1: expWidth*i]== 4'b0) ? 5'b0 :input_exp[expWidth*(i+1) -1: expWidth*i] + 8 - max_exp;
            assign output_exp[expWidth*(i+1)-1:expWidth*i] = temp_exp[i][expWidth] ? 4'b0 : temp_exp[i][expWidth-1:0];
        end
    endgenerate

    
endmodule