//===================================================================
// Design name:		Post Normalization Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module Post_Normal_Testbench();

	parameter	FORMAT_LENGTH = 32;
	parameter	EXPONENT_LENGTH = 8;
	parameter	FRACTION_LENGTH = 23;
	parameter 	NORMALIZE_MANTISSA_LENGTH = 24;
	localparam 	ZERO = 2'b00;
	localparam 	NAN = 2'b01;
	localparam 	INFINITY = 2'b10;
	localparam 	NORMAL = 2'b11;
	
	logic overflow;
	logic underflow;
	logic [FORMAT_LENGTH-1:0] nor_result;
	logic	[EXPONENT_LENGTH-1:0] exp;
	logic	[NORMALIZE_MANTISSA_LENGTH-1:0] man;
	logic	cout;
	logic	sign;
	logic 	[7:0] lv1_inc_dec;
	logic 	[6:0] lv2_inc_dec;
	logic 	[5:0] lv3_inc_dec;	
	logic 	[4:0] lv4_inc_dec;	
	logic 	[3:0] lv5_inc_dec;
	logic 	[7:0] lv1_ex;
	logic 	[6:0] lv2_ex;
	logic 	[5:0] lv3_ex;
	logic 	[4:0] lv4_ex;
	logic 	[3:0] lv5_ex;
	logic 	[7:0] nor_ex;
	logic 	[6:0] gp_1_1;
	logic 	[5:0] gp_2_1;
	logic 	[4:0] gp_3_1;
	logic 	[3:0] gp_4_1;
	logic 	[2:0] gp_5_1;
	logic 	[6:0] gp_1_2;
	logic 	[5:0] gp_2_2;
	logic 	[4:0] gp_3_2;
	logic 	[3:0] gp_4_2;
	logic 	[2:0] gp_5_2;
	logic 	[6:0] gp_1_3;
	logic 	[5:0] gp_2_3;
	logic 	[4:0] gp_3_3;
	logic 	[3:0] gp_4_3;
	logic 	[2:0] gp_5_3;	
	logic 	[4:0] c_exp_o;
	logic 	[4:0] left_count;
	logic 	left_right;
	
	assign 	left_right =  DUT.left_right;
	assign 	left_count = DUT.left_count;
	assign 	lv1_inc_dec = DUT.lv1_inc_dec;
	assign 	lv2_inc_dec = DUT.lv2_inc_dec;
	assign 	lv3_inc_dec = DUT.lv3_inc_dec;
	assign 	lv4_inc_dec = DUT.lv4_inc_dec;
	assign 	lv5_inc_dec = DUT.lv5_inc_dec;
	assign 	lv1_ex = DUT.lv1_ex;
	assign 	lv2_ex = DUT.lv2_ex;	
	assign 	lv3_ex = DUT.lv3_ex;
	assign 	lv4_ex = DUT.lv4_ex;
	assign 	lv5_ex = DUT.lv5_ex;		
	assign 	gp_1_1 = DUT.gp_1_1;
	assign 	gp_1_2 = DUT.gp_1_2;
	assign 	gp_1_3 = DUT.gp_1_3;
	assign 	gp_2_1 = DUT.gp_2_1;
	assign 	gp_2_2 = DUT.gp_2_2;
	assign 	gp_2_3 = DUT.gp_2_3;
	assign 	gp_3_1 = DUT.gp_3_1;
	assign 	gp_3_2 = DUT.gp_3_2;
	assign 	gp_3_3 = DUT.gp_3_3;
	assign 	gp_4_1 = DUT.gp_4_1;
	assign 	gp_4_2 = DUT.gp_4_2;
	assign 	gp_4_3 = DUT.gp_4_3;
	assign 	gp_5_1 = DUT.gp_5_1;
	assign 	gp_5_2 = DUT.gp_5_2;
	assign 	gp_5_3 = DUT.gp_5_3;	

`ifdef	SIMULATE
	include"Post_Normalization.sv";
`endif

	Post_Normalization	DUT(
	overflow,
	underflow,
	nor_result,
	exp,
	man,
	cout,
	sign);
	
	initial begin
	sign = 0;
	cout = 0;
	exp = 8'h0;
	man = 24'hf5;
	#1
	exp = 8'h50;
	#1
	man = 24'hf6500f;
	exp = 8'h10;
	#1
	exp = 8'hf0;
	#1
	man = 24'h3f0012;
	#1 
	man = 24'h013034;
	#1
	man = 24'h000701;
	#1
	exp = 8'h5;
	#1
	man = 24'hf0f0f0;
	#1
	cout = 1;
	#1 
	man = 24'h010203;
	end
	
endmodule	
