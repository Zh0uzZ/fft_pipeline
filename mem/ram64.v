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
`include "parameter.vh"	 

module RAM64 ( CLK, ED,WE ,ADDR_0,ADDR_1,ADDR_2,ADDR_3 ,DI_0,DI_1,DI_2,DI_3 ,DO_0,DO_1,DO_2,DO_3 );
	`FFTsfpw	
	output reg [nb-1:0] DO_0,DO_1,DO_2,DO_3 ;
	input CLK ;
	wire CLK ;	 
	input ED;
	input WE ;
	wire WE ;
	input wire [5:0] ADDR_0,ADDR_1,ADDR_2,ADDR_3 ;
	input wire [nb-1:0] DI_0,DI_1,DI_2,DI_3 ;
//	(* ramstyle = "AUTO" *) reg [nb-1:0] mem [63:0];
    (*ram_style = "distributed"*) reg [nb-1:0] mem [63:0];
	reg [5:0] addrrd;		  
	
	always @(posedge CLK) begin
			if (ED) begin
					if (WE)	begin	
						mem[ADDR_0] <= DI_0;
						mem[ADDR_1] <= DI_1;
						mem[ADDR_2] <= DI_2;
						mem[ADDR_3] <= DI_3;
					end
//					addrrd <= ADDR;	         //storing the address
					DO_0 <= mem[ADDR_0];	   // registering the read datum
					DO_1 <= mem[ADDR_1];	   // registering the read datum
					DO_2 <= mem[ADDR_2];	   // registering the read datum
					DO_3 <= mem[ADDR_3];	   // registering the read datum
				end	  
		end
	
	
endmodule
