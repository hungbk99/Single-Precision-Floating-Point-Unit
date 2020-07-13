//===================================================================
// Design name:		Floating Point to Decimal Converter
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

module FP2D_tb();
	timeunit 10ns;
	parameter 	DIVIDEND_LENGTH = 8;
	parameter 	DIVISOR_LENGTH = 4;
	parameter 	QUOTIENT_LENGTH = 4;
	logic	[8:0]	left_digit;
	logic 	[22:0]	right_digit;
	logic 			sign;
	logic 	[5:0]	exp_10;
	logic 			sign_exp_10;
	logic 	[31:0]	fp_num;
	include "FP2D_Converter.sv";
					
	FP2D_Converter	DUT
	(
	.*
	);
	
	initial begin
		fp_num = 32'h12345678;
		#1
		fp_num = 32'h01234567;
		#1
		fp_num = 32'h40123456;
	end

endmodule
