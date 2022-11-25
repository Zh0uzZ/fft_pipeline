module adder_4in #(
    parameter sigWidth   = 4,
    parameter low_expand = 2
) (
    input  [(sigWidth+4+low_expand)*4-1:0] manOffset,
    output [ (sigWidth+4+low_expand) -1:0] mantissa
);

  assign mantissa =  manOffset[sigWidth+low_expand+3:0] 
                  + manOffset[2*(sigWidth+4+low_expand)-1:sigWidth+4+low_expand] 
                  + manOffset[3*(sigWidth+low_expand+4)-1:2*(sigWidth+low_expand+4)] 
                  + manOffset[4*(sigWidth+4+low_expand)-1:3*(sigWidth+4+low_expand)];

endmodule
