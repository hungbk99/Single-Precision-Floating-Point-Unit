//===================================================================
// Design name:		Floating Point Unit DD192
// Note: 			Addition, Subtraction, Multiply, Divide, Square Root
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================
`timescale 10ps/1ps

module	FPU_DD192(
	result,
	overflow,
	underflow,
	op_a,
	op_b,
	operation);
	
//===================================================================
include"parameters.h"; 
include"Pre_Normalization.v";
include"Addition_Subtraction_CLA.v";
include"Post_Normalization.v";
//===================================================================
//	Outputs	
	output	[FORMAT_LENGTH-1:0] result;
	output	overflow;
	output	underflow;
	
//	Inputs	
	input	[FORMAT_LENGTH-1:0]	op_a;
	input	[FORMAT_LENGTH-1:0] op_b;
	input	[2:0]	operation;

//===================================================================
//	Internal Signals
	wire	[EXPONENT_LENGTH-1:0] exp_a;
	wire 	[EXPONENT_LENGTH-1:0] exp_b;
	wire	[FRACTION_LENGTH-1:0] fra_a;
	wire	[FRACTION_LENGTH-1:0] fra_b;	
	wire 	sign_a;
	wire 	sign_b;
	reg 	add_sub;	
	wire 	[EXPONENT_LENGTH-1:0] exp;
	wire	[NORMALIZE_MANTISSA_LENGTH-1:0] man_x;
	wire	[NORMALIZE_MANTISSA_LENGTH-1:0] man_y;
	wire 	sign_x;
	wire 	sign_y;
	wire 	enable;	
	wire	[FORMAT_LENGTH-1:0] special_result;	
	
	wire	[NORMALIZE_MANTISSA_LENGTH-1:0] CLA_result;
	wire	sign;
	wire	cout;	
	
	wire 	[FORMAT_LENGTH-1:0] nor_result;	
	
	reg 	[FORMAT_LENGTH-1:0] cal_result;
	
//===================================================================
//	Extraction
	assign	exp_a = op_a[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	exp_b = op_b[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	fra_a = op_a[FRACTION_LENGTH-1:0];
	assign 	fra_b = op_b[FRACTION_LENGTH-1:0];
	assign 	sign_a = op_a[FORMAT_LENGTH-1];
	assign 	sign_b = op_b[FORMAT_LENGTH-1];

//	Decoder
	always @(*) begin
		case(operation)
		3'b000:	
		begin
			add_sub = 0;
			cal_result = nor_result;
		end	
		3'b001:	
		begin
			add_sub = 1;
			cal_result = nor_result;
		end
//		3'b010:	
//		3'b011:
//		3'b100:
		default: cal_result = 32'b0;
		endcase
	end

	Pre_Normalization	PRNU(
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
	
	CLA	CLAU(
	CLA_result,
	cout,
	man_x,
	man_y,
	sign_x,
	sign_y,
	add_sub);

	Post_Normalization	PONU(
	overflow,
	underflow,
	nor_result,
	exp,
	CLA_result,
	cout,
	sign);	
	
//	Output 
	assign	result = (enable) ? cal_result : special_result;	
	
endmodule	
	
	