/////////////////////////////////////////////////////////////////////
// Design_Version       : 1.0
// File name            : RAM64.v
// File Revision        :
// Last modification    : Sun Dec 1 20:11:56 2020
/////////////////////////////////////////////////////////////////////
// FUNCTION: 1-port synchronous RAM
// FILES:    RAM64.v -single ported synchronous RAM
// PROPERTIES: 1) Has the volume of 64 data
//	         2) RAM is synchronous one, the read datum is outputted
//                in 2 cycles after the address setting
//		   3) Can be substituted to any 2-port synchronous RAM
/////////////////////////////////////////////////////////////////////

//`timescale 1 ns / 1 ps
`include "../include/parameter.vh"

module RAM64 ( CLK, ED,WE ,ADDR ,DI,DO );
	`FFTsfpw
	output reg [nb-1:0] DO;
	input CLK ;
	wire CLK ;
	input ED;
	input WE ;
	wire WE ;
	input wire [5:0] ADDR;
	input wire [nb-1:0] DI ;
//	(* ramstyle = "AUTO" *) reg [nb-1:0] mem [63:0];
    (*ram_style = "distributed"*) reg [nb-1:0] mem [63:0];
	reg [5:0] addrrd;

	always @(posedge CLK) begin
			if (ED) begin
					if (WE)	begin
						mem[ADDR] <= DI;
					end
					// addrrd <= ADDR;	         //storing the address
					DO <= mem[ADDR];	   // registering the read datum

				end
		end


endmodule
