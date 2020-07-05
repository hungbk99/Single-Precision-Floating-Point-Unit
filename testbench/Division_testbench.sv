//===================================================================
// Design name:		Division Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	Division_testbench();

	timeunit	100ns;
	timeprecision	1ps;
	
	logic 	[QUOTIENT_LENGTH-1:0]	quotient;
	logic 	[DIVISOR_LENGTH-1:0] 	remainder;
	logic 	[DIVIDEND_LENGTH-1:0]	pre_dividend;
	logic 	[DIVISOR_LENGTH-1:0]	divisor;
	logic	[QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0]	carry_out,
														sum_out;
	logic 	[25-12-1:0][12-1-1:0]	new_dividend;

`ifdef	SECOND_ALGORITHM
	`include"Newton_Raphson_Division.sv";
`else	
	`include"NRD_Division.sv";
	NRD_Division
	#(
	.DIVIDEND_LENGTH(25),
	.DIVISOR_LENGTH(24)
	)
	DUT
	(
	.*
	);		
`endif
	
	assign 	new_dividend = DUT.new_dividend;
	assign 	sum_out = DUT.sum_out;
	assign	carry_out = DUT.carry_out;
	
	initial begin
		pre_dividend = 25'h0851230;
		divisor = 24'h800953;
		#1
		divisor = 25'ha15800;
		#1
		pre_dividend = 25'h0e81240;
		#1
		pre_dividend = 25'h0100000;
		divisor = 24'hb00000;
	end
	
endmodule

