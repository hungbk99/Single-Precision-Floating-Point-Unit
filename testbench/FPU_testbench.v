//===================================================================
// Design name:		Floating Point Unit DD192 Testbench
// Note: 			Addition, Subtraction, Multiply, Divide, Square Root
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================
`timescale 10ps/1ps

module	FPU_testbench();

	include"parameters.h";
	
	wire	[FORMAT_LENGTH-1:0] result;
	wire 	overflow;
	wire 	underflow;
	reg		[FORMAT_LENGTH-1:0] op_a;
	reg		[FORMAT_LENGTH-1:0] op_b;
	reg		[2:0] operation;	
	
	include"FLoating_Point_Unit.v";
	
	FPU_DD192	DUT(
	result,
	overflow,
	underflow,
	op_a,
	op_b,
	operation);

	initial begin
	//	ZERO + ZERO
	op_a = 32'h0;
	op_b = 32'h0;
	operation = 3'b0;
	#1
	//	ZERO - ZERO
	operation = 3'b1;
	#1
	//	ZERO + INFI
	op_b = 32'h7f800000;
	operation = 3'b0;
	#1
	//	ZERO - INFI
	operation = 3'b1;
	#1
	//	NUMBER - INFI
	op_a = 32'h3e808000;
	#1
	//	NUMBER + INFI
	operation = 3'b0;
	#1
	//	NAN + INFI
	op_a = 32'h7f801010;
	#1
	//	NAN + ZERO
	op_b = 32'h0;
	#1
	//	NUMBER_A + NUMBER_B	
	//	2^-1 + 1.375*2^-2 = 0.84375 = 32'h3f580000
	op_a = 32'h3f000000;
	op_b = 32'h3eb00000;
	#1
	//	2^-1 - 1.375*2^-2 = 0.15625 = 32'h3e200000
	operation = 3'b1;
	#1
	//	1.375*2^-2 - 2^-1 = -0.15625 = 32'hbe200000
	op_a = 32'h3eb00000;
	op_b = 32'h3f000000;
	#1
	//	1.2109375*2^6 - 1.015625*2^-7 = 77.492065429 = 32'h4294fbf0
	op_a = 32'h429b0000;
	op_b = 32'h3c020000;
	#1
	//	1.015625*2^-7 - 1.2109375*2^6 = -77.492065429 = 32'hc294fbf0
	op_a = 32'h3c020000;
	op_b = 32'h429b0000;
	#1
	//	1.015625*2^-7 + 1.2109375*2^6 = 77.5079345703 = 32'h429b0410
	operation = 3'b0;
	#1
	//	1.25*2^-126 + 1.90625*2^127 = 3.24331631*10^38 = 32'h7f7e0000
	op_a = 32'h41200000;
	op_b = 32'h7f740000;
	#1
	//	1.25*2^-126 - 1.90625*2^127	= -3.24331630972*10^38 = 32'hff740000
	operation = 3'b1;
	#1
	//	1.90625*2^127 -	1.25*2^-126 = 3.24331630972*10^38 = 32'h7f7e0000	
	op_a = 32'h7f740000;
	op_b = 32'h41200000;	
	#1
	//	1.90625*2^127 +	1.25*2^-126 
	operation = 3'b0;
	#1
	//	1.007812858*2^113 + 1.9921875*2^-123 => this case will cause overflow
	op_a = 32'h78010203;
	op_b = 32'h787f0000;
	#1
	// 	1.999999881*2^127 + 1.999999881*2^127 => result is INFI
	op_a = 32'h7f7fffff;
	op_b = 32'h7f7fffff;
	#1
	//	1.999999881*2^127 - 1.999999881*2^127
	operation = 3'b1;
	#1
	//	=> this case will cause underflow	
	op_a = 32'h00800030;
	op_b = 32'h00800005;
	end
	
endmodule	