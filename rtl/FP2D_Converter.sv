//===================================================================
// Design name:		Floating Point to Decimal Converter
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	FP2D_Converter
(
	output	logic	[8:0]	left_digit,
	output 	logic	[22:0]	right_digit,
	output 	logic			sign,
	output 	logic 	[5:0]	exp_10,
	output 	logic			sign_exp_10,
	input 	[31:0]	fp_num
);
	parameter	EXPONENT_LENGTH = 8;
	logic 	[23:0]	fp_man;
	logic 	[7:0]	fp_exp;
	logic 	[EXPONENT_LENGTH-1:0] 	ex_eq_check;
	logic	[EXPONENT_LENGTH-1:0] 	ex_g_check;
	logic	[EXPONENT_LENGTH-1:0] 	ex_ge_check,
									a_swap,
									b_swap,
									pre_dividend,
									exp_a,
									exp_b;
									
	logic 	[3:0]					quotient,
									remainder;	
					
	logic  	[4:0]					remainder_raw,
									quotient_raw;
									
	logic 							exp_ge;
	
	assign	sign = fp_num[31];
	assign 	fp_exp = fp_num[30:23];
	assign 	fp_man = {1'b1, fp_num[22:0]};
	assign 	exp_a = fp_exp;
	assign 	exp_b = 8'h7f;

//	Compare
	genvar i;
	generate
		for(i = 0; i < EXPONENT_LENGTH; i = i + 1)
		begin: comp_exp_1
			assign 	ex_eq_check[i] = exp_a[i]~^exp_b[i];
			assign 	ex_g_check[i] = exp_a[i]&&(~exp_b[i]);
		end	
	endgenerate
	
	genvar j;
	generate
		assign 	ex_ge_check[0] = ex_eq_check[0] || ex_g_check[0];	
		for(j = 1; j < EXPONENT_LENGTH; j = j + 1)
		begin: comp_exp_2
			assign ex_ge_check[j] = (ex_eq_check[j]&&ex_ge_check[j-1])||ex_g_check[j];
		end
//		assign 	ex_ge_check[0] = ex_eq_check[0] || ex_g_check[0];		
	endgenerate

	assign	exp_ge = ex_ge_check[EXPONENT_LENGTH-1];
	assign 	a_swap = exp_ge ? fp_exp : 8'h7f;
	assign 	b_swap = exp_ge ? 8'h7f : fp_exp;
	assign 	sign_exp_10 = !exp_ge;
	
//	Exp 10-radix base Calculate
	Modified_NRD_Division_CV	DIV
	(
	.quotient(quotient_raw),
	.remainder(remainder_raw),
	.*,
	.pre_divisor(5'ha)	
	);
	
	assign 	quotient = quotient_raw[3:0];
	assign 	remainder = remainder_raw[3:0];
	
	Subtraction_CV	SUB
	(
	.result(pre_dividend), 
	.op1(a_swap),
	.op2(b_swap)
	);	
	
	Modified_Multiplication	
	#(
	.BIT_LENGTH(6)
	)	
	MUL
	(
	.result(exp_10),
	.man_x({2'b0, quotient}),
	.man_y(6'h03)
	);

//	FRA 10-radix base Calculate
	always_comb begin
		left_digit = 0;
		right_digit = 0;
		unique case(remainder)
		0:	
		begin
			left_digit = 1;
			right_digit = fp_man[22:0];
		end
		1:
		begin
			left_digit = fp_man[23:22];
			right_digit = {fp_man[21:0], 1'b0};		
		end
		2:
		begin
			left_digit = fp_man[23:21];
			right_digit = {fp_man[20:0], 2'b0};
		end
		3:
		begin
			left_digit = fp_man[23:20];
			right_digit = {fp_man[19:0], 3'b0};
		end		
		4:
		begin
			left_digit = fp_man[23:19];
			right_digit = {fp_man[18:0], 4'b0};
		end		
		5:
		begin
			left_digit = fp_man[23:18];
			right_digit = {fp_man[17:0], 5'b0};
		end		
		6:
		begin
			left_digit = fp_man[23:17];
			right_digit = {fp_man[16:0], 6'b0};
		end		
		7:
		begin
			left_digit = fp_man[23:16];
			right_digit = {fp_man[15:0], 7'b0};
		end		
		8:
		begin
			left_digit = fp_man[23:15];
			right_digit = {fp_man[14:0], 8'b0};
		end		
		9:
		begin
			left_digit = fp_man[23:14];
			right_digit = {fp_man[13:0], 9'b0};
		end
		endcase
	end

endmodule

//===================================================================
//===================================================================

module Modified_NRD_Division_CV
#(
parameter 	DIVIDEND_LENGTH = 8,
parameter 	DIVISOR_LENGTH = 5,
parameter 	QUOTIENT_LENGTH = 5
)
(
	output 	[QUOTIENT_LENGTH-1:0]		quotient,
	output 	[DIVISOR_LENGTH-1:0] 		remainder,
	input 	[DIVIDEND_LENGTH-1:0]		pre_dividend,
	input 	[DIVISOR_LENGTH-1:0]		pre_divisor	
);
	logic	[DIVIDEND_LENGTH-1:0][DIVISOR_LENGTH-1:0]		carry_out,
															sum_out;
	logic 	[DIVIDEND_LENGTH+DIVISOR_LENGTH-2:0]			dividend;
	logic 	[DIVISOR_LENGTH-1:0]							divisor,
															carry_res_out,
															sum_res;
	logic 	[DIVISOR_LENGTH:0]								carry_in;
	
	assign	dividend =	{3'b0, pre_dividend};
	assign 	divisor = pre_divisor;
	
	genvar a;
	generate
		for(a = 1; a < DIVISOR_LENGTH; a++)
		begin:	row_0
			assign 	sum_out[DIVIDEND_LENGTH-1][a] = !divisor[a] ^ dividend[a+DIVIDEND_LENGTH-1] ^ carry_out[DIVIDEND_LENGTH-1][a-1]; 
			assign 	carry_out[DIVIDEND_LENGTH-1][a] = !divisor[a] && dividend[a+DIVIDEND_LENGTH-1] || carry_out[DIVIDEND_LENGTH-1][a-1] && (!divisor[a] ^ dividend[a+DIVIDEND_LENGTH-1]); 
		end
	endgenerate

	assign 	sum_out[DIVIDEND_LENGTH-1][0] = !divisor[0] ^ dividend[DIVIDEND_LENGTH-1] ^ 1'b1; 
	assign 	carry_out[DIVIDEND_LENGTH-1][0] = !divisor[0] && dividend[DIVIDEND_LENGTH-1] || 1'b1 && (!divisor[0] ^ dividend[DIVIDEND_LENGTH-1]); 
	
	genvar b, c;
	generate
		for(b = DIVIDEND_LENGTH-2; b >= 0; b--)
		begin:	row_gen
			for(c = 1; c < DIVISOR_LENGTH; c++)
			begin: 	column_gen
				assign 	sum_out[b][c] = (!sum_out[b+1][DIVISOR_LENGTH-1] ^ divisor[c]) ^ sum_out[b+1][c-1] ^ carry_out[b][c-1]; 
				assign 	carry_out[b][c] = (!sum_out[b+1][DIVISOR_LENGTH-1] ^ divisor[c]) && sum_out[b+1][c-1] || carry_out[b][c-1] && ((!sum_out[b+1][DIVISOR_LENGTH-1] ^ divisor[c]) ^ sum_out[b+1][c-1]); 			
			end
		end
	endgenerate
	
	genvar d;
	generate
		for(d = 0; d < DIVIDEND_LENGTH-1; d++)
		begin:	column_0_gen
			assign 	sum_out[d][0] = (!sum_out[d+1][DIVISOR_LENGTH-1] ^ divisor[0]) ^ dividend[d] ^ !sum_out[d+1][DIVISOR_LENGTH-1]; 
			assign 	carry_out[d][0] = (!sum_out[d+1][DIVISOR_LENGTH-1] ^ divisor[0]) && dividend[d] || !sum_out[d+1][DIVISOR_LENGTH-1] && ((!sum_out[d+1][DIVISOR_LENGTH-1] ^ divisor[0]) ^ dividend[d]); 					
		end
	endgenerate
	
//	Final Row
	assign 	carry_in[0] = !sum_out[0][DIVISOR_LENGTH-1];	 

	genvar f;
	generate
		for(f = 0; f < DIVISOR_LENGTH; f++)
		begin:	final_row
			assign 	sum_res[f] = sum_out[0][f] ^ (divisor[f] ^ !sum_out[0][DIVISOR_LENGTH-1]) ^ carry_in[f];
			assign 	carry_res_out[f] =  sum_out[0][f] && (divisor[f] ^ !sum_out[0][DIVISOR_LENGTH-1]) || carry_in[f] && (sum_out[0][f] ^ (divisor[f] ^ !sum_out[0][DIVISOR_LENGTH-1]));
			assign 	carry_in[f+1] = carry_res_out[f];
		end
	endgenerate
	
	genvar e;
	generate
		for(e = 0; e < QUOTIENT_LENGTH; e++)
		begin: 	quotient_gen
			assign 	quotient[e] = !sum_out[e][DIVISOR_LENGTH-1];	
		end
	endgenerate
	
	assign	remainder = sum_res[DIVISOR_LENGTH-1] ? sum_out[0] : sum_res;
	
endmodule

//===================================================================
module Subtraction_CV
(
	output	[7:0] 	result, 
	input 	[7:0]	op1,
	input 	[7:0]	op2
);	
	logic 	[7:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	logic	[8:0]	cal_c_in;				
	
	assign	cal_c_in[0] = 1'b1;
	assign 	man_x = op1;
	assign 	man_y = op2;
	assign 	result = pre_result;
	
	genvar a;
	generate
		for(a = 0; a < 8; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ (1'b1 ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (1'b1 ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (1'b1 ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule

module Modified_Multiplication 
#(
parameter	BIT_LENGTH = 8
)
(
	output	logic	[BIT_LENGTH-1:0]			result,
	input	[BIT_LENGTH-1:0]				man_x,
	input 	[BIT_LENGTH-1:0]				man_y
);
	
	logic 	[BIT_LENGTH-1:0][BIT_LENGTH-1:0]	and_out		;
	logic	[BIT_LENGTH-1:0][BIT_LENGTH-2:0]	carry_out	;
	logic	[BIT_LENGTH-1:0][BIT_LENGTH-2:0]	sum_out		;
			
	genvar m, n;
	generate
		for(m = 0; m < BIT_LENGTH; m++)
		begin: 	and_row_gen
			for(n = 0; n < BIT_LENGTH; n++)
			begin:	and_column_gen
				assign 	and_out[m][n] = man_x[n] && man_y[m];
			end
		end
	endgenerate
///*		
	genvar i, j;
	generate
		for(i = 1; i < BIT_LENGTH-1; i++)
		begin: 	adder_row_gen
			for(j = 0; j < BIT_LENGTH-2; j++)
			begin: adder_column_gen
				assign 	sum_out[i][j] = sum_out[i-1][j+1] ^ carry_out[i-1][j] ^ and_out[i+1][j];
				assign 	carry_out[i][j] = sum_out[i-1][j+1] && carry_out[i-1][j] || and_out[i+1][j] && (sum_out[i-1][j+1] ^ carry_out[i-1][j]);
			end
		end
	endgenerate	
	
	genvar k;
	generate
		for(k = 0; k < BIT_LENGTH-1; k++)
		begin: gen1	
			assign	sum_out[0][k] = and_out[0][k+1] ^ 1'b0 ^ and_out[1][k];
			assign	carry_out[0][k] = and_out[0][k+1] && 1'b0 || and_out[1][k] && (and_out[0][k+1] ^ 1'b0);			
		end
	endgenerate

	genvar l;
	generate
		for(l = 1; l < BIT_LENGTH-1; l++)
		begin: gen2
			assign	sum_out[l][BIT_LENGTH-2] = and_out[l][BIT_LENGTH-1] ^ carry_out[l-1][BIT_LENGTH-2] ^ and_out[l+1][BIT_LENGTH-2];
			assign	carry_out[l][BIT_LENGTH-2] = and_out[l][BIT_LENGTH-1] && carry_out[l-1][BIT_LENGTH-2] || and_out[l+1][BIT_LENGTH-2] && (and_out[l][BIT_LENGTH-1] ^ carry_out[l-1][BIT_LENGTH-2]);		
		end
	endgenerate
	
	assign	sum_out[BIT_LENGTH-1][0] = sum_out[BIT_LENGTH-2][1] ^ carry_out[BIT_LENGTH-2][0] ^ 1'b0;
	assign	carry_out[BIT_LENGTH-1][0] = sum_out[BIT_LENGTH-2][1] && carry_out[BIT_LENGTH-2][0] ||  1'b0 && (sum_out[BIT_LENGTH-2][1] ^ carry_out[BIT_LENGTH-2][0]);					

	assign	sum_out[BIT_LENGTH-1][BIT_LENGTH-2] = and_out[BIT_LENGTH-1][BIT_LENGTH-1] ^ carry_out[BIT_LENGTH-2][BIT_LENGTH-2] ^ carry_out[BIT_LENGTH-1][BIT_LENGTH-3];
	assign	carry_out[BIT_LENGTH-1][BIT_LENGTH-2] = and_out[BIT_LENGTH-1][BIT_LENGTH-1] && carry_out[BIT_LENGTH-2][BIT_LENGTH-2] ||  carry_out[BIT_LENGTH-1][BIT_LENGTH-3] && (and_out[BIT_LENGTH-1][BIT_LENGTH-1] ^ carry_out[BIT_LENGTH-2][BIT_LENGTH-2]);	
	
	genvar u;	
	generate	
		for(u = 1; u < BIT_LENGTH-2; u++)
		begin: gen3		
			assign	sum_out[BIT_LENGTH-1][u] = sum_out[BIT_LENGTH-2][u+1] ^ carry_out[BIT_LENGTH-2][u] ^ carry_out[BIT_LENGTH-1][u-1];
			assign	carry_out[BIT_LENGTH-1][u] = sum_out[BIT_LENGTH-2][u+1] && carry_out[BIT_LENGTH-2][u] || carry_out[BIT_LENGTH-1][u-1] && (sum_out[BIT_LENGTH-2][u+1] ^ carry_out[BIT_LENGTH-2][u]);			
		end		
	endgenerate

	assign	result[0] = and_out[0][0];
//	assign 	result[8] = sum_out[BIT_LENGTH-1][0];
	
	genvar q;
	generate
		for(q = 0; q < BIT_LENGTH-1; q++)
		begin: gen5
			assign	result[q+1] = sum_out[q][0];
		end			
	endgenerate
	
endmodule	