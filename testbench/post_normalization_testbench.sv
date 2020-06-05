//===================================================================
// Design name:		Post Normalization Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================
`timescale 10ps/1ps

module Post_Normal_Testbench();

	parameter	FORMAT_LENGTH = 32;
	parameter	EXPONENT_LENGTH = 8;
	parameter	FRACTION_LENGTH = 23;
	parameter 	NORMALIZE_MANTISSA_LENGTH = 24;
	localparam 	ZERO = 2'b00;
	localparam 	NAN = 2'b01;
	localparam 	INFINITY = 2'b10;
	localparam 	NORMAL = 2'b11;
	
	wire overflow;
	wire underflow;
	wire [FORMAT_LENGTH-1:0] nor_result;
	reg	[EXPONENT_LENGTH-1:0] exp;
	reg	[NORMALIZE_MANTISSA_LENGTH-1:0] man;
	reg	cout;
	reg	sign;
	wire 	[7:0] lv1_inc_dec;
	wire 	[6:0] lv2_inc_dec;
	wire 	[5:0] lv3_inc_dec;	
	wire 	[4:0] lv4_inc_dec;	
	wire 	[3:0] lv5_inc_dec;
	wire 	[7:0] lv1_ex;
	wire 	[6:0] lv2_ex;
	wire 	[5:0] lv3_ex;
	wire 	[4:0] lv4_ex;
	wire 	[3:0] lv5_ex;
	wire 	[7:0] nor_ex;
	wire 	[6:0] gp_1_1;
	wire 	[5:0] gp_2_1;
	wire 	[4:0] gp_3_1;
	wire 	[3:0] gp_4_1;
	wire 	[2:0] gp_5_1;
	wire 	[6:0] gp_1_2;
	wire 	[5:0] gp_2_2;
	wire 	[4:0] gp_3_2;
	wire 	[3:0] gp_4_2;
	wire 	[2:0] gp_5_2;
	wire 	[6:0] gp_1_3;
	wire 	[5:0] gp_2_3;
	wire 	[4:0] gp_3_3;
	wire 	[3:0] gp_4_3;
	wire 	[2:0] gp_5_3;	
	wire 	[4:0] c_exp_o;
	wire 	[4:0] left_count;
	wire 	left_right;
	
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

	include"Post_Normalization.v";
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