//===================================================================
// Design name:		Pre Normalization Testbench						
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================
`timescale 10ps/1ps

module Pre_Normal_Testbench();

	parameter	FORMAT_LENGTH = 32;
	parameter	EXPONENT_LENGTH = 8;
	parameter	FRACTION_LENGTH = 23;
	parameter 	NORMALIZE_MANTISSA_LENGTH = 24;
	localparam 	ZERO = 2'b00;
	localparam 	NAN = 2'b01;
	localparam 	INFINITY = 2'b10;
	localparam 	NORMAL = 2'b11;
	
	wire 	sign;
	wire 	[EXPONENT_LENGTH-1:0] exp;
	wire	[NORMALIZE_MANTISSA_LENGTH-1:0] man_x;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] man_y;
	wire 	sign_x;
	wire 	sign_y;
	wire 	enable;
	wire 	[FORMAT_LENGTH-1:0] special_result;

	reg		[EXPONENT_LENGTH-1:0] exp_a;
	reg 	[EXPONENT_LENGTH-1:0] exp_b;
	reg		[FRACTION_LENGTH-1:0] fra_a;
	reg 	[FRACTION_LENGTH-1:0] fra_b;	
	reg 	sign_a;
	reg 	sign_b;
	reg 	add_sub;
	wire 	[1:0] type_a;
	wire 	[1:0] type_b;
	wire 	swap;
	wire 	[EXPONENT_LENGTH-1:0] ex_eq_check;
	wire	[EXPONENT_LENGTH-1:0] ex_g_check;
	wire	[EXPONENT_LENGTH-1:0] ex_ge_check;	
	wire 	[FRACTION_LENGTH-1:0] fr_eq_check;
	wire	[FRACTION_LENGTH-1:0] fr_ge_check;
	wire	[FRACTION_LENGTH-1:0] fr_g_check;		
	wire 	[EXPONENT_LENGTH-1:0] shift_count;
	wire 	[EXPONENT_LENGTH-1:0] exp_p;
	wire 	[EXPONENT_LENGTH-1:0] exp_g;	
	wire	[NORMALIZE_MANTISSA_LENGTH-1:0]	shift_fra_1;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_2;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_3;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_4;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_5;
	wire 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_6;
	wire 	[FRACTION_LENGTH-1:0] shift_fra;
	
	include"Pre_Normalization.v";
	Pre_Normalization	DUT(
	special_result,
	enable,
	exp,
	man_x,
	man_y,
	sign,
	sign_x,
	sign_y,
	exp_a,
	exp_b,
	fra_a,
	fra_b,
	sign_a,
	sign_b,
	add_sub);
	
	assign type_a = DUT.a_type;
	assign type_b = DUT.b_type;
	assign swap = DUT.swap;
	assign fr_eq_check = DUT.fr_eq_check;
	assign fr_ge_check = DUT.fr_ge_check;
	assign fr_g_check = DUT.fr_g_check;	
	assign ex_eq_check = DUT.ex_eq_check;
	assign ex_ge_check = DUT.ex_ge_check;
	assign ex_g_check = DUT.ex_g_check;
	assign shift_count = DUT.shift_count;
	assign exp_g = DUT.exp_g;
	assign exp_p = DUT.exp_p;
	assign shift_fra_1 = DUT.shift_fra_1;
	assign shift_fra_2 = DUT.shift_fra_2;
	assign shift_fra_3 = DUT.shift_fra_3;
	assign shift_fra_4 = DUT.shift_fra_4;
	assign shift_fra_5 = DUT.shift_fra_5;
	assign shift_fra_6 = DUT.shift_fra_6;
	assign shift_fra = DUT.shift_fra;
	
	initial begin
	// 	ZERO + ZERO
		exp_a = 0;
		exp_b = 0;
		fra_a = 0;
		fra_b = 0;
		sign_a = 0;
		sign_b = 0;
		add_sub = 0;
	// 	ZERO + INFINITY
	#1
		exp_a = 0;
		exp_b = 8'hFF;
		fra_a = 0;
		fra_b = 0;
		sign_a = 0;
		sign_b = 0;
		add_sub = 0;
	//	INFINITY - NUMBER
	#1 
		exp_a = 8'hFF;
		exp_b = 1;
		fra_a = 0;
		fra_b = 6;
		sign_a = 0;
		sign_b = 0;
		add_sub = 1;
	//	ZERO - NUMBER
	#1
		exp_a = 0;
		exp_b = 1;
		fra_a = 0;
		fra_b = 1;
		sign_a = 0;
		sign_b = 0;
		add_sub = 1;
	//	ZERO - INFINITY
	#1
		exp_a = 0;
		exp_b = 8'hFF;
		fra_a = 0;
		fra_b = 0;
		sign_a = 0;
		sign_b = 0;
		add_sub = 1;
	//	ZERO + NAN
	#1
		exp_a = 0;
		exp_b = 8'hFF;
		fra_a = 0;
		fra_b = 1;
		sign_a = 0;
		sign_b = 0;
		add_sub = 0;	
	// NAN + INFINITY
	#1
		exp_a = 8'hFF;
		exp_b = 8'hFF;
		fra_a = 1;
		fra_b = 0;
		sign_a = 0;
		sign_b = 0;
		add_sub = 0;
	//	NORMAL + NORMAL
	//	1.0*2^-1+1.011*2^-2
	#1
		exp_a = 8'h7E;
		exp_b = 8'h7D;
		fra_a = 0;
		fra_b = 23'b011_0000_0000_0000_0000_0000;
		sign_a = 0;
		sign_b = 0;
		add_sub = 0;	
	//	1.0*2^-1 - 1.011*2^-2
 	#1
		add_sub = 1;
	//	1.011*2^-2 - 1.0 * 2^-1	
		exp_b = 8'h7E;
		exp_a = 8'h7D;
		fra_b = 0;
		fra_a = 23'b011_0000_0000_0000_0000_0000;	
	//	1.0011011*2^6 - 1.000001*2^-7
	#1
		exp_a = 8'h85;
		exp_b = 8'h78;
		fra_a = 23'b001_1011_0000_0000_0000_0000;
		fra_b = 23'b000_0010_0000_0000_0000_0000;	
	// 	1.000001*2^-7 - 1.0011011*2^6
	#1
		exp_b = 8'h85;
		exp_a = 8'h78;
		fra_b = 23'b001_1011_0000_0000_0000_0000;
		fra_a = 23'b000_0010_0000_0000_0000_0000;	
	//	1.01*2^-126 - 1.11101*2^127
	#1
		exp_a = 1;
		exp_b = 8'hFE;
		fra_a = 23'b010_0000_0000_0000_0000_0000;
		fra_b = 23'b111_0100_0000_0000_0000_0000;			
	end

endmodule	