//===================================================================
// Design name:		Multiplication Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
module Multiplication_Testbench();

	timeunit	100ns;
	timeprecision	1ps;
	logic	[24-1:0]		result;
	logic 					redundant_mul;
	logic	[24-1:0]		man_x;
	logic 	[24-1:0]		man_y;
	logic 	[24*2-1:0]		check;
	
`ifdef	SECOND_ALGORITHM
	include"Vedic_Multiplication.sv";
	Vedic_Multiplication 
	#(
	.BIT_LENGTH(24)
	)
	DUT
	(
	.*
	);	
`else
	include"Braun_Multiplication.sv"; 
	
	Braun_Multiplication 
	#(
	.BIT_LENGTH(24)
	)
	DUT
	(
	.*
	);
`endif	

	assign 	check = DUT.check;

	initial begin
	man_x = '0;
	man_y = '0;	
	#1
	man_x = 24'hffffff;
	man_y = 24'hffffff;
	#1
	man_x = 24'h800000;
	man_y = 24'h580000;
	#1
	man_x = 24'h940000;
	man_y = 24'h000410;	
	#1
	man_x = 5;
	man_y = 6;
	#1 
	man_x = 6;
	man_y = 5;
	#1
	man_x = 16;
	man_y = 15;
	end
	
endmodule