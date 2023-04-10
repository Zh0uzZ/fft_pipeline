module adder_4in #(
    parameter sigWidth   = 4,
    parameter low_expand = 2
) (
    input  [(sigWidth+4+low_expand)*4-1:0] sigOffset,
    output [ (sigWidth+4+low_expand) -1:0] significand
);

  assign significand =  sigOffset[sigWidth+low_expand+3:0] 
                  + sigOffset[2*(sigWidth+4+low_expand)-1:sigWidth+4+low_expand] 
                  + sigOffset[3*(sigWidth+low_expand+4)-1:2*(sigWidth+low_expand+4)] 
                  + sigOffset[4*(sigWidth+4+low_expand)-1:3*(sigWidth+4+low_expand)];

endmodule
