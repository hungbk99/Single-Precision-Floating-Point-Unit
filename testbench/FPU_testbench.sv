//===================================================================
// Design name:		Floating Point Unit DD192 Testbench
// Note: 			Addition, Subtraction, Multiply, Divide, Square Root
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	FPU_testbench();
	timeunit	100ns;
	timeprecision	1ps;	
	logic	[FORMAT_LENGTH-1:0] result;
	parameter	BIT_LENGTH = 24;	
	logic 	overflow;
	logic 	underflow;
	logic		[FORMAT_LENGTH-1:0] op_a;
	logic		[FORMAT_LENGTH-1:0] op_b;
	logic		[2:0] operation;	
	logic 		[EXPONENT_LENGTH-1:0]	nor_exp_b,
										exp_cal;
	logic	[BIT_LENGTH-1:0][BIT_LENGTH-2:0]	sum_out,
												carry_out;	
	
	localparam	ADD = 3'b000;
	localparam 	SUB = 3'b001;
	localparam 	MUL = 3'b010;
	localparam 	DIV = 3'b011;
	localparam	ROOT = 3'b100;
	
`ifdef	SIMULATE	
include"FLoating_Point_Unit.sv";
`endif
	
	Floating_Point_Unit	DUT(
	result,
	overflow,
	underflow,
	op_a,
	op_b,
	operation);

	assign	nor_exp_b = DUT.PRNU_MD.nor_exp_b;
	assign	exp_cal = DUT.PRNU_MD.exp_cal;
//	assign	sum_out = DUT.NRD_DIV.sum_out;
//	assign 	carry_out = DUT.NRD_DIV.carry_out;
	
	initial begin
//========================================================ADD_SUB
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
	//	10 + 1.90625*2^127
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
	//	1.007812858*2^113 + 1.9921875*2^123 
	op_a = 32'h78010203;
	op_b = 32'h787f0000;
	#1
	// 	1.999999881*2^127 + 1.999999881*2^127 => result is INFI => this case will cause overflow
	op_a = 32'h7f7fffff;
	op_b = 32'h7f7fffff;
	#1
	//	1.999999881*2^127 - 1.999999881*2^127
	operation = 3'b1;
	#1
	//	=> this case will cause underflow	
	op_a = 32'h00800030;
	op_b = 32'h00800005;
//========================================================MUL_DIV
	#1
	//	ZERO & ZERO
	op_a = 32'h0;
	op_b = 32'h0;
	operation = MUL;
	#1						
	operation = DIV;
	#1
	//	ZERO & INFI
	op_b = 32'h7f800000;
	#1
	operation = MUL;
	//	INFI & ZERO
	#1
	op_a = 32'h7f800000;
	op_b = '0;
	#1
	operation = DIV;
	#1
	//	NUMBER & INFI
	op_a = 32'h3e808000;
	op_b = 32'h7f800000;	
	#1
	operation = MUL;
	#1
	//	INFI & NUMBER
	op_b = 32'h3e808000;
	op_a = 32'h7f800000;	
	#1
	operation = DIV;	
	#1
	//	NORMAL & ZERO
	op_a = 32'h3e808000;
	op_b = '0;		
	#1
	operation = MUL;
	#1
	//	ZERO & NORMAL
	op_b = 32'h3e808000;
	op_a = '0;	
	#1
	operation = DIV;
	#1
	//	NAN & INFI
	op_a = 32'h7f801010;
	op_b = 32'h7f800000;		
	#1
	operation = MUL;
	#1
	//	INFI & NAN
	op_b = 32'h7f801010;
	op_a = 32'h7f800000;	
	#1
	operation = DIV;
	#1
	//	NUMBER_A & NUMBER_B	
	//	2^-1 / 1.375*2^-2
	op_a = 32'h3f000000;
	op_b = 32'h3eb00000;
	#1
	//	2^-1 * 1.375*2^-2 
	operation = MUL;
	#1
	//	1.375*2^-2 * 2^-1 
	op_a = 32'h3eb00000;
	op_b = 32'h3f000000;
	#1
	//	1.375*2^-2 / 2^-1 	
	operation = DIV;
	#1
	//	1.2109375*2^6 / 1.015625*2^-7 
	op_a = 32'h429b0000;
	op_b = 32'h3c020000;
	#1
	//	1.2109375*2^6 * 1.015625*2^-7 
	operation = MUL;
	#1
	//	1.015625*2^-7 * 1.2109375*2^6
	op_a = 32'h3c020000;
	op_b = 32'h429b0000;
	#1
	//	1.015625*2^-7 / 1.2109375*2^6
	operation = DIV;
	#1
	//	10 / 1.90625*2^127		
	op_a = 32'h41200000;
	op_b = 32'h7f740000;
	#1
	//	10 * 1.90625*2^127	=> This causes overflow in pre_normalization step for mul
	operation = MUL;
	#1
	//	1.90625*2^127 *	10	=> This causes overflow in pre_normalization step for mul
	op_a = 32'h7f740000;
	op_b = 32'h41200000;	
	#1
	//	1.90625*2^127 /	10
	operation = DIV;
	#1
	//	1.007812858*2^113 / 1.9921875*2^-113	
	op_a = 32'h78010203;
	op_b = 32'h077f0000;
	#1						//	=> This causes underflow in pre_normalization step for div
	op_b = 32'h78010203;
	op_a = 32'h077f0000;
	#1	
	//	1.007812858*2^113 * 1.9921875*2^-113
	operation = MUL;
	#1
	// 	1.999999881*2^-120 * 1.999999881*2^-20	=> This causes underflow in pre_normalization step for mul
	op_a = 32'h03ffffff;
	op_b = 32'h35ffffff;
	#1
	//	1.999999881*2^-127 / 1.999999881*2^-127
	operation = DIV;
	#1
	op_a = 32'h00800030;
	op_b = 32'h00800005;	
	#1
	operation = MUL;	//	=> This causes underflow in pre_normalization step for mul
	end
endmodule	
