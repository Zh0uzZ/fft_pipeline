/////////////////////////////////////////////////////////////////////
// FUNCTION: 2-port RAM with 1 port to write and 1 port to read
// FILES: RAM2x64C_1.v - dual ported synchronous RAM, contains:
//	    RAM64.v -single ported synchronous RAM
// PROPERTIES: 1)Has the volume of 2x64 complex data
//	         2)Contains 4 single port RAMs for real and
//               imaginary parts of data in the 2-fold volume
//		     Two halves of RAM are switched on and off in the
//               write mode by the signal ODD
//		   3)RAM is synchronous one, the read datum is
//               outputted in 2 cycles after the address setting
//		   4)Can be substituted to any 2-port synchronous
//		     RAM for example, to one RAMB16_S36_S36 in XilinxFPGAs
/////////////////////////////////////////////////////////////////////

//`timescale 1 ns / 1 ps
`include "../include/parameter.vh"

module RAM2x32C_1 ( CLK ,ED ,WE ,ODD ,ADDRW ,ADDRR ,DR ,DI ,DOR ,DOI );
	`FFTsfpw


	output wire [nb-1:0] DOR ;
	output wire [nb-1:0] DOI ;
	input wire CLK , ED;
	input wire WE ;	     //write enable
	input wire ODD ;	  // RAM part switshing
	input wire [`ADDR_Width-1:0] ADDRW ;
	input wire [`ADDR_Width-1:0] ADDRR ;
	input wire [nb-1:0] DR ;
	input wire [nb-1:0] DI ;

	reg	oddd,odd2;
	always @( posedge CLK) begin //switch which reswiches the RAM parts
			if (ED)	begin
					oddd<=ODD;
					odd2<=oddd;
				end
		end
	`ifdef 	USFFT64bufferports1
	//One-port RAMs are used
	wire we0,we1;
	wire	[nb-1:0] dor0,dor1,doi0,doi1;
	wire	[`ADDR_Width-1:0] addr0,addr1;



	assign	addr0 =ODD?  ADDRW: ADDRR;		//MUXA0
	assign	addr1 = ~ODD? ADDRW:ADDRR;		// MUXA1
	assign	we0   =ODD?  WE: 0;		     // MUXW0:
	assign	we1   =~ODD? WE: 0;			 // MUXW1:

	//1-st half - write when odd=1	 read when odd=0
	RAM64 #(nb) URAM0(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DR),.DO(dor0)); //
	RAM64 #(nb) URAM1(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DI),.DO(doi0));

	//2-d half
	RAM64 #(nb) URAM2(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DR),.DO(dor1));//
	RAM64 #(nb) URAM3(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DI),.DO(doi1));

	assign	DOR=~odd2? dor0 : dor1;		 // MUXDR:
	assign	DOI=~odd2? doi0 : doi1;	//  MUXDI:

	`else
	//Two-port RAM is used
	wire [`ADDR_Width:0] addrr2 = {ODD,ADDRR};
	wire [`ADDR_Width:0] addrw2 = {~ODD,ADDRW};
	wire [2*nb-1:0] di= {DR,DI} ;
	wire [2*nb-1:0] doi;

	reg [2*nb-1:0] ram [63:0];
	reg [`ADDR_Width:0] read_addra;
	always @(posedge CLK) begin
			if (ED)
				begin
					if (WE)
						ram[addrw2] <= di;
						read_addra <= addrr2;
				end
		end
	assign doi = ram[read_addra];

	assign	DOR=doi[2*nb-1:nb];		 // Real read data
	assign	DOI=doi[nb-1:0];		 // Imaginary read data


	`endif
endmodule
