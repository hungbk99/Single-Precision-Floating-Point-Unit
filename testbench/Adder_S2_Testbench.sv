//===================================================================
// Design name:		Addition & Subtraction Testbench
// Note: 			Carry Lookahead Adder & Han Carlson Adder								
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

import FPU_192_Package::*;
module AdderS2_Testbench();

	parameter	FORMAT_LENGTH = 32;
	parameter	EXPONENT_LENGTH = 8;
	parameter	FRACTION_LENGTH = 23;
	parameter 	NORMALIZE_MANTISSA_LENGTH = 24;
	
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] result;
	logic 	cout;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] man_x;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] man_y;
	logic 	sign_x;
	logic 	sign_y;
	logic 	add_sub;

	logic 	operate;
	logic	[NORMALIZE_MANTISSA_LENGTH-1:0] g;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] p;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] c_in;
//	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] c_out;
	logic 	[5:0] cout_L2;
	logic 	[1:0] cout_L3;
	logic 	[5:0] pin_L2;
	logic 	[1:0] pin_L3;
	logic 	[5:0] gin_L2;
	logic 	[1:0] gin_L3;
	
`ifdef	SIMULATE	
	include"Addition_Subtraction_CLA.sv";
`endif
	
	Addition_Subtraction_CLA DUT(
	result,
	cout,
	man_x,
	man_y,
	sign_x,
	sign_y,
	add_sub);
	
	assign 	operate = DUT.operate;
	assign 	g = DUT.g;
	assign 	p = DUT.p;
	assign 	c_in = DUT.c_in;
	assign 	cout_L2 = DUT.cout_L2;
	assign 	cout_L3 = DUT.cout_L3;
	assign 	pin_L2 = DUT.pin_L2;
	assign 	pin_L3 = DUT.pin_L3;
	assign 	gin_L2 = DUT.gin_L2;
	assign 	gin_L3 = DUT.gin_L3;
	
	initial begin
//	(+) + (+) = + 1111_1101_1101_1011_1101_1111
	sign_x = 0;
	sign_y = 0;
	add_sub = 0;
	man_x = 24'b1011_0011_0000_1001_0110_0111;
	man_y = 24'b0100_1010_1101_0010_0111_1000;
	#1
//	(+) - (+) = + 0110_1000_0011_0110_1110_1111
	add_sub = 1;
	#1
//	(-) - (+) = - 1111_1101_1101_1011_1101_1111
	sign_x = 1;
	#1
//	(-) - (-) = - 0110_1000_0011_0110_1110_1111
	sign_y = 1;
	#1
//	(-) + (-) = - 1111_1101_1101_1011_1101_1111
	add_sub = 0;
	#1
//	(-) + (-) = - 1_1000_0010_1011_0000_0100_1000
	man_x = 24'b1011_0011_0000_1001_0110_0111;
	man_y = 24'b1000_1111_1010_0110_1110_0001;
	#1
//	(-) - (-) = - 0010_0011_0110_0010_1000_0110
	add_sub = 1;
	#1	
//  (+) - (-) = + 1_1000_0010_1011_0000_0100_1000	
	sign_x = 0;
	#1
//	(+) + (-) = + 0010_0011_0110_0010_1000_0110
	add_sub = 0;
	#1
//	(+) - (+) = + 0010_0011_0110_0010_1000_0110	
	sign_y = 0;
	#1
//	(+) + (+) = + 1_1000_0010_1011_0000_0100_1000	
	add_sub = 0;
	#1
	add_sub = 1;
	man_x = 24'h800000;
	man_y = 24'h580000;
	#1
	man_x = 24'h940000;
	man_y = 24'h000410;
	end
	
endmodule	
