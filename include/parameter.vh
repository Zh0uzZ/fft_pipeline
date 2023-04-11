//define SFP format
`define formatSFP 9
`define exponent 4
`define significand 4


//define calculation process variable
`define SFPWIDTH `formatSFP
`define EXPWIDTH `exponent
`define SIGWIDTH `significand
`define LOW_EXPAND 2
`define FIXWIDTH 21

//define parameter
`define FFTsfpw parameter nb=`formatSFP;

//define sram width
`define ADDR_Width 5
