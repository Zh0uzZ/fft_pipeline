/////////////////////////////////////////////////////////////////////
// FUNCTION: FIFO - buffer with direct input order and 4-th inverse
//           output order
// FILES: BUFRAM32C1.v	- 1-st,2-nd,3-d data buffer, contains:
//        RAM2x32C_1.v - dual ported synchronous RAM, contains:
//	    RAM64.v -single ported synchronous RAM
// PROPERTIES: 1)Has the volume of 2x32 complex data
//		   2)Contains 2- port RAM and address counter
//		   3)Has 32-clock cycle period starting with the START
//               impulse and continuing forever
//		   4)Signal RDY precedes the 1-st correct datum output
//               from the buffer
/////////////////////////////////////////////////////////////////////
//`timescale 1 ns / 1 ps
`include "../include/parameter.vh"

module BUFRAM32C1 ( CLK ,RST ,ED ,START ,DR ,DI ,RDY ,DOR ,DOI );
	parameter INV_ADDR=2;
	`FFTsfpw
	output reg RDY ;
	output wire [nb-1:0] DOR ;
	output wire [nb-1:0] DOI ;

	input CLK ;
	input RST ;
	input ED ;
	input START ;
	input wire [nb-1:0] DR ;
	input wire [nb-1:0] DI ;

	wire odd, we;
	wire [`ADDR_Width - 1 : 0] addrw,addrr;
	reg [`ADDR_Width:0] addr;
	reg [`ADDR_Width + 1:0] ct2;		//counter for the RDY signal

	always @(posedge CLK)	//   CTADDR
		begin
			if (~RST) begin
					addr<={(`ADDR_Width){1'b0}};
					ct2<= 6'b100001;
				RDY<=1'b0; end
			else if (START) begin
					addr<={`ADDR_Width{1'b0}};
					ct2<= 6'b000000;
				RDY<=1'b0;end
			else if (ED)	begin
					RDY<=1'b0;
					addr<=addr+1;
					if (ct2!=33)
					ct2<=ct2+1;
					if (ct2==32)
					RDY<=1'b1;
				end
		end


assign	addrw=	addr[`ADDR_Width-1:0];
assign	odd=addr[`ADDR_Width];	   			// signal which switches the 2 parts of the buffer
assign	addrr={addr[INV_ADDR-1 : 0], addr[`ADDR_Width - 1 : INV_ADDR]};	  // 4-th inverse output address
assign	we = ED;

	RAM2x32C_1 #(nb)	URAM(.CLK(CLK),.ED(ED),.WE(we),.ODD(odd),
	.ADDRW(addrw),	.ADDRR(addrr),
	.DR(DR),.DI(DI),
	.DOR(DOR),	.DOI(DOI));

endmodule
