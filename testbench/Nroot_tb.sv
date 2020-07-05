//===================================================================
// Design name:		N root Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
module Nroot_tb();
	timeunit 10us;
	parameter 	BIT_LENGTH = 24;
	parameter 	QUOTIENT_LENGTH = 10;
	parameter 	DIVISOR_LENGTH = 3;	
	logic 	error;
	logic 	[31:0]					root_result;
	logic 	[BIT_LENGTH-1:0]		man;
	logic 	[7:0]					exp;
	logic 							sign;
	logic 	[1:0]					n_th;
	logic 	[8-1:0][8-1:0]	and_out		;
	logic	[8-1:0][8-2:0]	carry_out	;
	logic	[8-1:0][8-2:0]	sum_out		;
	logic 	[QUOTIENT_LENGTH-2:0][DIVISOR_LENGTH-2:0]	new_dividend;
	logic	[QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0]	carry_out_div,
														sum_out_div;
	logic 	[23:0][23:0]								carry_out_nrd,
														sum_out_nrd;
	logic 	[22:0][22:0]								new_dividend_nrd;
//	logic 	[QUOTIENT_LENGTH*2-2:0]						dividend;											

	include"Nth_Root.sv";
	
	Nth_Root	DUT
	(
	.*
	);
	
	assign 	and_out = DUT.EXP_MUL.and_out;
	assign 	carry_out = DUT.EXP_MUL.carry_out;
	assign 	sum_out = DUT.EXP_MUL.sum_out;
	assign 	carry_out_div = DUT.EXP_DIV.carry_out;
	assign 	sum_out_div = DUT.EXP_DIV.sum_out;
	assign 	new_dividend = DUT.EXP_DIV.new_dividend;
	assign 	new_dividend_nrd = DUT.DROOT_1.new_dividend;
	assign 	sum_out_nrd = DUT.DROOT_1.sum_out;
	assign 	carry_out_nrd = DUT.DROOT_1.carry_out;
	
	initial begin
	//	32'h08700000
		sign = 0;
		exp = 8'h10;
		man	= 24'hf00000;
		n_th = 2'b0;
		#1
		n_th = 2'b01;
		#1
		n_th = 2'b10;
		#1
		n_th = 2'b11;
		#1
	//	32'h78dc00	
		sign = 0;
		exp = 8'hf1;
		man = 24'hdc0000;
		n_th = 2'b0;
		#1
		n_th = 2'b01;
		#1
		n_th = 2'b10;
		#1
		n_th = 2'b11;	
	end

endmodule