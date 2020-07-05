//===================================================================
// Design name:		Pre Normalization For Multiplication and Divition							
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	Pre_Normalization_MD
(
	output	logic	[DIVIDEND_LENGTH-1:0]				pre_dividend,
	output	logic	[DIVIDEND_LENGTH-1:0]				pre_divisor,
	output 	logic	[NORMALIZE_MANTISSA_LENGTH-1:0]		mul_op1,
														mul_op2,
	output 	logic	[EXPONENT_LENGTH-1:0]				exp,
	output 												sign,
	output 												enable,
	output	logic [FORMAT_LENGTH-1:0] 					mul_special_result,
														div_special_result,
	output 	logic										pre_overflow,
	output 	logic 										pre_underflow,
	output 												fra_ge,	
	
	input	[EXPONENT_LENGTH-1:0] 						exp_a,
	input 	[EXPONENT_LENGTH-1:0] 						exp_b,
	input	[FRACTION_LENGTH-1:0] 						fra_a,
	input 	[FRACTION_LENGTH-1:0] 						fra_b,	
	input 												sign_a,
	input 												sign_b,
	input 												div_mul
);
//=============================Parameters=============================

	localparam 	ZERO = 2'b00;
	localparam 	NAN = 2'b01;
	localparam 	INFINITY = 2'b10;
	localparam 	NORMAL = 2'b11;

//====================================================================	
	logic	[EXPONENT_LENGTH-1:0] 	exp_cin,
//									exp_cal,
									nor_exp_b,
									nor_carry_out,
//									exp_cal_c_out,
									base_exp;
									
	logic 	[EXPONENT_LENGTH:0]		nor_carry_in,
									exp_cal_c_out,	
									exp_cal,
									exp_a_extern,
									exp_b_extern;
									
	logic 	[EXPONENT_LENGTH+1:0]	exp_cal_c_in;
										
									
	logic 							p1_cin,
									G0,
									P0,
									pos_neg;
									
	logic		[1:0]				a_type,
									b_type;
									
	logic 	[FRACTION_LENGTH-1:0] 	fr_eq_check,
									fr_ge_check,
									fr_g_check;	
									
//====================================================================	
	assign	sign = sign_a ^ sign_b;
	assign	enable = (a_type == NORMAL) && (b_type == NORMAL);
	assign 	exp = exp_cal[EXPONENT_LENGTH-1:0];
	assign 	mul_op1 = {1'b1, fra_a};
	assign 	mul_op2 = {1'b1, fra_b};
	assign 	pre_dividend = {1'b1, fra_a};
	assign 	pre_divisor = {1'b1, fra_b};
	
//====================================================================	
//	Compare
	genvar m;
	generate
		for(m = 0; m < FRACTION_LENGTH; m = m + 1)
		begin: comp_fra_1
			assign fr_eq_check[m] = fra_a[m]~^fra_b[m];
			assign fr_g_check[m] = fra_a[m]&&(~fra_b[m]);
		end
	endgenerate

	genvar n;
	generate
		assign fr_ge_check[0] = fr_eq_check[0] || fr_g_check[0];
		for(n = 1; n < FRACTION_LENGTH; n = n + 1)
		begin: comp_fra_2
			assign fr_ge_check[n] = (fr_eq_check[n]&&fr_ge_check[n-1])||fr_g_check[n];
		end
	endgenerate
	
	assign	fra_ge = fr_ge_check[FRACTION_LENGTH-1];
	
//	Check type of operands
//	Type check A	
	always_comb begin
		a_type = '0;
		if((~(|exp_a))&&(!(|fra_a)))	//	zero
			a_type = ZERO;
//		else if((~(|exp_a))&&(!man_a))	// 	subnormal
//			a_type = SUBNORMAL;
		else if((|exp_a)&&(!(&exp_a)))	// 	normal
			a_type = NORMAL;
		else if((&exp_a)&&(!(|fra_a)))	// 	infinity
			a_type = INFINITY;
		else if((&exp_a)&&((|fra_a))) 	// 	NaN
			a_type = NAN;
	end	
	
//	Type check B	
	always_comb begin
		b_type = '0;	
		if((~(|exp_b))&&(!(|fra_b)))	//	zero 		
			b_type = ZERO;
//		else if((~(|exp_b))&&(!man_b))	// 	subnormal
//			b_type = SUBNORMAL;
		else if((|exp_b)&&(!(&exp_b)))	// 	normal
			b_type = NORMAL;
		else if((&exp_b)&&(!(|fra_b)))	// 	infinity
			b_type = INFINITY;
		else if((&exp_b)&&((|fra_b))) 	// 	NaN
			b_type = NAN;
	end	
//	Normalize exponent of Op_B
//	Ripple Carry Adder
	assign	base_exp = 8'h80;
	assign 	nor_carry_in[0] = 1'b1;
	
	genvar 	w;
	generate
		for(w = 0; w < EXPONENT_LENGTH; w++)
		begin: sub_base_gen
			assign nor_exp_b[w] = exp_b[w] ^ base_exp[w] ^ nor_carry_in[w];
			assign nor_carry_out[w] = exp_b[w] && base_exp[w] || nor_carry_in[w] && (exp_b[w] ^ base_exp[w]);
			assign nor_carry_in[w+1] = nor_carry_out[w];
		end 
	endgenerate

//	Check operation for next Calculation
	assign 	pos_neg = nor_carry_out[EXPONENT_LENGTH-1];
	
//	Pre Multiplication
	always_comb begin
		mul_special_result[FORMAT_LENGTH-1] = sign_a ^ sign_b;	
		mul_special_result[FORMAT_LENGTH-2:0] = '0;
		if((a_type != ZERO) && (b_type != ZERO))
		begin	
			if(a_type == NAN)
			begin
				mul_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
				mul_special_result[FRACTION_LENGTH-1:0] = fra_a;			
			end
			else if(b_type ==  NAN)
			begin
				mul_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
				mul_special_result[FRACTION_LENGTH-1:0] = fra_b;				
			end
			else if (a_type == INFINITY)
			begin
				mul_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
				mul_special_result[FRACTION_LENGTH-1:0] = fra_a;				
			end
			else if(b_type == INFINITY)
			begin
				mul_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
				mul_special_result[FRACTION_LENGTH-1:0] = fra_b;			
			end
		end
	end

//	Div Multiplication	
	always_comb begin
		div_special_result[FORMAT_LENGTH-1] = sign_a ^ sign_b;
		div_special_result[FORMAT_LENGTH-2:0] = '0;
		if(b_type == ZERO)
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = '1;
			div_special_result[FRACTION_LENGTH-1:0] = '1;				
		end
		else if((a_type == ZERO)||((a_type == NORMAL)&&(b_type == INFINITY)))
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = '0;
			div_special_result[FRACTION_LENGTH-1:0] = '0;			
		end
		else if(a_type == NAN)
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			div_special_result[FRACTION_LENGTH-1:0] = fra_a;		
		end
		else if(b_type == NAN)
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			div_special_result[FRACTION_LENGTH-1:0] = fra_b;		
		end
		else if((a_type == INFINITY)&&(b_type == NORMAL))
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			div_special_result[FRACTION_LENGTH-1:0] = fra_a;			
		end
		else if((a_type == INFINITY)&&(b_type == INFINITY))
		begin
			div_special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = '1;
			div_special_result[FRACTION_LENGTH-1:0] = '1;			
		end
	end

//	EXP Calculation

	assign 	exp_cal_c_in[0] =  div_mul;
	assign	exp_a_extern = {1'b0, exp_a};
	assign 	exp_b_extern = {1'b0, nor_exp_b};
	
	genvar p;
	generate
		for(p = 0; p < EXPONENT_LENGTH+1; p = p + 1)
		begin:	fa_exp
			assign exp_cal[p] = exp_a_extern[p] ^ (div_mul ^ exp_b_extern[p]) ^ exp_cal_c_in[p];
			assign exp_cal_c_out[p] = exp_a_extern[p] && (div_mul ^ exp_b_extern[p]) || exp_cal_c_in[p] && (exp_a_extern[p] ^ (div_mul ^ exp_b_extern[p]));
			assign exp_cal_c_in[p+1] = exp_cal_c_out[p];
		end		
	endgenerate
	
	assign 	pre_overflow =	div_mul ? (!pos_neg && !exp_cal[EXPONENT_LENGTH]) : (pos_neg && exp_cal[EXPONENT_LENGTH]);
	assign 	pre_underflow = !div_mul ? (!pos_neg && !exp_cal[EXPONENT_LENGTH]) : (pos_neg && exp_cal[EXPONENT_LENGTH]);
	
endmodule