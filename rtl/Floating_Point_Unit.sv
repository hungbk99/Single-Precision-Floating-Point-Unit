//===================================================================
// Design name:		Floating Point Unit DD192
// Note: 			Addition, Subtraction, Multiply, Divide, Square Root
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	Floating_Point_Unit
(
	output	logic	[FORMAT_LENGTH-1:0]	result,
	output	logic						overflow,
	output	logic						underflow,
	input	[FORMAT_LENGTH-1:0]			op_a,
	input	[FORMAT_LENGTH-1:0]			op_b,
	input	[2:0]						operation
);
	
//===================================================================
`ifdef	SIMULATE
	include"Pre_Normalization.sv";
	include"Addition_Subtraction_CLA.sv";
	include"Addition_Subtraction_RCA.sv";
	include"Post_Normalization.sv";
	include"Pre_Normalization_MD.sv";
	include"Post_Normalization_MD.sv";
	include"Braun_Multiplication.sv";
	include"Vedic_Multiplication.sv";
	include"NRD_Division.sv";
	include"Newton_Raphson_Division.sv";	
`endif
	
	localparam	ADD = 3'b000;
	localparam 	SUB = 3'b001;
	localparam 	MUL = 3'b010;
	localparam 	DIV = 3'b011;
	localparam	ROOT = 3'b100;
	
//===================================================================
//	Internal Signals
	logic	[EXPONENT_LENGTH-1:0] exp_a;
	logic 	[EXPONENT_LENGTH-1:0] exp_b;
	logic	[FRACTION_LENGTH-1:0] fra_a;
	logic	[FRACTION_LENGTH-1:0] fra_b;	
	logic 	sign_a;
	logic 	sign_b;
	logic 	add_sub;	
	logic 	[EXPONENT_LENGTH-1:0] 			exp,
											add_sub_pre_exp,
											mul_div_pre_exp;
									
	logic	[NORMALIZE_MANTISSA_LENGTH-1:0] add_sub_man_x,
											add_sub_man_y,
											mul_op1,
											mul_op2;
											
	logic 									sign_x,
											sign_y,
											add_sub_sign,
											mul_div_enable,
											enable,
											add_sub_enable,
											add_sub_overflow,
											add_sub_underflow,
											mul_div_overflow,
											mul_div_underflow,
											div_mul,
											add_sub_cout;	
											
	logic	[FORMAT_LENGTH-1:0] 			special_result,
											add_sub_nor_result,
											add_sub_special_result,
											mul_div_nor_result,	
											cal_result,
											mul_special_result,
											div_special_result;
											
	logic	[NORMALIZE_MANTISSA_LENGTH-1:0] CLA_result,
											mul_result;
											
	logic									add_sub_sign_x,
											add_sub_sign_y,
											mul_div_sign,
											redundant_mul,
											pre_overflow,
											pre_underflow,
											fra_ge;	
	

											
	logic	[DIVIDEND_LENGTH-1:0]			pre_dividend;
	logic	[DIVISOR_LENGTH-1:0]			pre_divisor;											
	logic 	[QUOTIENT_LENGTH-1:0]			div_result;
	logic 	[DIVISOR_LENGTH-1:0] 			remainder;	
	
//===================================================================
//	Extraction
	assign	exp_a = op_a[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	exp_b = op_b[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	fra_a = op_a[FRACTION_LENGTH-1:0];
	assign 	fra_b = op_b[FRACTION_LENGTH-1:0];
	assign 	sign_a = op_a[FORMAT_LENGTH-1];
	assign 	sign_b = op_b[FORMAT_LENGTH-1];

//	Decoder
	always_comb begin
		add_sub = 1'b0;	
		cal_result = '0;	
		special_result	= '0;	
		enable = 1'b0;
		overflow = 1'b0;
		underflow = 1'b0;
		div_mul = 1'b0;
		case(operation)
		ADD:	
		begin
			add_sub = 0;
			cal_result = add_sub_nor_result;
			special_result = add_sub_special_result;
			enable = add_sub_enable;
			overflow = add_sub_overflow;
			underflow = add_sub_underflow;
		end	
		SUB:	
		begin
			add_sub = 1;
			cal_result = add_sub_nor_result;
			special_result = add_sub_special_result;		
			enable = add_sub_enable;		
			overflow = add_sub_overflow;
			underflow = add_sub_underflow;			
		end
		MUL:
		begin	
			cal_result = mul_div_nor_result;
			enable = mul_div_enable;
			special_result = mul_special_result;
			overflow = mul_div_overflow || pre_overflow;
			underflow = mul_div_underflow || pre_underflow;		
		end
		DIV:
		begin
			cal_result = mul_div_nor_result;		
			enable = mul_div_enable;		
			special_result = div_special_result;
			overflow = mul_div_overflow || pre_overflow;
			underflow = mul_div_underflow || pre_underflow;
			div_mul = 1'b1;
		end
//		ROOT:
		default: cal_result = 32'b0;
		endcase
	end

	Pre_Normalization	PRNU_AS
	(
	.exp(add_sub_pre_exp),
	.man_x(add_sub_man_x),
	.man_y(add_sub_man_y),
	.sign(add_sub_sign),
	.sign_x(add_sub_sign_x),
	.sign_y(add_sub_sign_y),
	.enable(add_sub_enable),
	.special_result(add_sub_special_result),
	.*
	);	

	Pre_Normalization_MD	PRNU_MD
	(
	.exp(mul_div_pre_exp),
	.sign(mul_div_sign),
	.enable(mul_div_enable),												
	.*
	);

`ifdef	SECOND_ALGORITHM	
	Addition_Subtraction_RCA	RCAU
	(
	.result(CLA_result),
	.cout(add_sub_cout),
	.man_x(add_sub_man_x),
	.man_y(add_sub_man_y),
	.sign_x(add_sub_sign_x),
	.sign_y(add_sub_sign_y),
	.*
	);
	
	Vedic_Multiplication	V_MUL
	(
	.result(mul_result),
	.man_x(mul_op1),
	.man_y(mul_op2),
	.*
	);	
	
	Newton_Raphson_Division	NRA_DIV
	(
	.quotient(div_result),
	.initial_guess(24'hefffff),
	.*
	);
`else 
	Addition_Subtraction_CLA	CLAU
	(
	.result(CLA_result),
	.cout(add_sub_cout),
	.man_x(add_sub_man_x),
	.man_y(add_sub_man_y),
	.sign_x(add_sub_sign_x),
	.sign_y(add_sub_sign_y),
	.*
	);
	
	Braun_Multiplication	B_MUL
	(
	.result(mul_result),
	.man_x(mul_op1),
	.man_y(mul_op2),
	.*
	);

	NRD_Division	NRD_DIV
	(
	.quotient(div_result),
	.ge(fra_ge),
	.*
	);
`endif

	Post_Normalization_MD	PONU_MD
	(
	.overflow(mul_div_overflow),
	.underflow(mul_div_underflow),
	.nor_result(mul_div_nor_result),
	.exp(mul_div_pre_exp),
	.sign(mul_div_sign),
	.*
	);	


	Post_Normalization	PONU_AS
	(
	.overflow(add_sub_overflow),
	.underflow(add_sub_underflow),
	.nor_result(add_sub_nor_result),
	.exp(add_sub_pre_exp),
	.man(CLA_result),
	.cout(add_sub_cout),
	.sign(add_sub_sign)
	);	
	
//	Output 
	assign	result = (enable) ? cal_result : special_result;	
	
endmodule	
	
	