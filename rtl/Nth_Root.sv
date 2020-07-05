//===================================================================
// Design name:		Nth Root
// Note: 			Support from 2th to 5th root
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
module	Nth_Root
#(
	parameter 	BIT_LENGTH = 24
)
(
	output 	[31:0]		root_result,
	output 	logic 		error,
	input 	[23:0]		man,
	input 	[7:0]		exp,
	input 				sign,
	input 	[1:0]		n_th
);

//===================================================================
`ifdef SIMULATE
	include"Braun_Multiplication.sv";
	include"Newton_Raphson_Division.sv";
	include"SNRD_Division.sv";
`endif
//===================================================================
	logic 	[23:0]			guess_rr,
							mul_result_1_1,
							mul_result_1_2,
							mul_result_1_3,	
							mul_result_1_4,
							mul_result_1_5,
							mul_op_1,
							sub_op_1,
							pre_div_1,
							sub_result_1,
							comp_a,
							swap_a_1,
							swap_b_1,
							fr_eq_check,
							fr_g_check,
							fr_ge_check,
							fr_eq_check_2,
							fr_g_check_2,
							fr_ge_check_2,
							mul_result_2_1,
							mul_result_2_2,
							mul_result_2_3,	
							mul_result_2_4,
							mul_result_2_5,
							mul_op_2,
							sub_op_2,
							pre_div_2,
							sub_result_2,
							swap_a_2,
							swap_b_2,
							pre_man_root_result,
							man_root_result;
	
	logic 	[2:0]			co,
							exp_co;
							
	logic 					rd_1_2,
							rd_1_3,
							rd_1_4,
							rd_1_5,
							ge_1,
							rd_2_2,
							rd_2_3,
							rd_2_4,
							rd_2_5;
	
	logic 	[7:0]			pre_root_exp;

	logic 	[8:0]			exp_mul;

	logic 	[9:0]			exp_div,
							exp_dividend;

	assign 	guess_rr = 24'hb00000;	//	this number must less than or equal 1.4

//===================================================================
//	Controller
//===================================================================
	always_comb begin
		error = 1'b0;
		unique case	(n_th)
		2'b00:	
		begin
			sub_op_1 = {2'b0, mul_result_1_1[23:2]};
			mul_op_1 = {2'b0, guess_rr[23:4]};
			sub_op_2 = {2'b0, mul_result_2_1[23:2]};
			mul_op_2 = {2'b0, pre_man_root_result[23:4]};		
			error = (sign) ? 1'b1 : 1'b0;
			co = 3'b010;
			exp_co = 3'b001;
		end
		2'b01:
		begin
			sub_op_1 = {1'b0, rd_1_2, mul_result_1_2[23:2]};
			mul_op_1 = {2'b0, mul_result_1_1[23:4]};		
			sub_op_2 = {1'b0, rd_2_2, mul_result_2_2[23:2]};
			mul_op_2 = {2'b0, mul_result_2_1[23:4]};				
			co = 3'b011;
			exp_co = 3'b010;
		end
		2'b10:	
		begin
			sub_op_1 = mul_result_1_3;
			mul_op_1 = {1'b0, rd_1_2, mul_result_1_2[23:4]};	
			sub_op_2 = mul_result_2_3;
			mul_op_2 = {1'b0, rd_2_2, mul_result_2_2[23:4]};			
			co = 3'b100;
			exp_co = 3'b011;
			error = (sign) ? 1'b1 : 1'b0;			
		end
		2'b11:
		begin
			sub_op_1 = mul_result_1_4;
			mul_op_1 = mul_result_1_3;	
			sub_op_2 = mul_result_2_4;
			mul_op_2 = mul_result_2_3;				
			co = 3'b101;
			exp_co = 3'b100;
		end
		endcase
	end	
	
//===================================================================
//	Fraction computing
//===================================================================
//	Level 1
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)	
	B_MUL_1_1
	(
	.result(mul_result_1_1),
	.man_x(guess_rr),
	.man_y(guess_rr),
	.redundant_mul()
	);		

	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)	
	B_MUL_1_2
	(
	.result(mul_result_1_2),
	.man_x(mul_result_1_1),
	.man_y(guess_rr),
	.redundant_mul(rd_1_2)
	);		
	
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_1_3
	(
	.result(mul_result_1_3),
	.man_x({rd_1_2, mul_result_1_2[23:1]}),
	.man_y({1'b0, guess_rr[23:1]}),				//	Ket qua lui 2 bit
	.redundant_mul(rd_1_3)
	);		
	
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_1_4
	(
	.result(mul_result_1_4),
	.man_x(mul_result_1_3),
	.man_y(guess_rr),				//	Ket qua lui 2 bit
	.redundant_mul(rd_1_4)
	);		

	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_1_5
	(
	.result(mul_result_1_5),
	.man_x(mul_op_1),
	.man_y({co, 21'b0}),
	.redundant_mul(rd_1_5)
	);	

	Subtraction_ROOT	SROOT_1
	(
	.result(sub_result_1), 
	.op1(swap_a_1),
	.op2(swap_b_1)
	);		
/*
	Newton_Raphson_Division
	#(
	.DIVIDEND_LENGTH(24),
	.DIVISOR_LENGTH(24),
	.QUOTIENT_LENGTH(24)
	)
	DROOT_1
	(
	.quotient(pre_div_1),
	.pre_dividend({4'b0, sub_result_1[23:4]}),
	.pre_divisor(mul_result_1_5),					// mul_result_1_5 bi lui 6 bit
	.initial_guess(24'h0fffff)	
	);	
*/
	Modified_NRD_Division_Ver2	DROOT_1
	(
	.remainder(),
	.quotient(pre_div_1),
	.pre_dividend({4'b0, sub_result_1[23:4]}),
	.pre_divisor(mul_result_1_5),					// mul_result_1_5 bi lui 6 bit
	.ge(1'b0)
	);

	Addition_ROOT	ROOT_1
	(
	.result(pre_man_root_result), 
	.error(pre_div_1),
	.guess_rr(guess_rr),
	.choose(!ge_1)
	);	


//	Compare
	assign	comp_a = {2'b0, man[23:2]};
	
	genvar m;
	generate
		for(m = 0; m < BIT_LENGTH; m = m + 1)
		begin: comp_fra_1
			assign fr_eq_check[m] = comp_a[m]~^sub_op_1[m];
			assign fr_g_check[m] = comp_a[m]&&(~sub_op_1[m]);
		end
	endgenerate

	genvar n;
	generate
		assign fr_ge_check[0] = fr_eq_check[0] || fr_g_check[0];
		for(n = 1; n < BIT_LENGTH; n = n + 1)
		begin: comp_fra_2
			assign fr_ge_check[n] = (fr_eq_check[n]&&fr_ge_check[n-1])||fr_g_check[n];
		end
	endgenerate
	
	assign	ge_1 = fr_ge_check[BIT_LENGTH-1];	
	
	assign 	swap_a_1 = ge_1 ? comp_a : sub_op_1;
	assign 	swap_b_1 = ge_1 ? sub_op_1 : comp_a;

//===================================================================
//	Level 2
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)	
	B_MUL_2_1
	(
	.result(mul_result_2_1),
	.man_x(pre_man_root_result),
	.man_y(pre_man_root_result),
	.redundant_mul()
	);		

	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)	
	B_MUL_2_2
	(
	.result(mul_result_2_2),
	.man_x(mul_result_2_1),
	.man_y(pre_man_root_result),
	.redundant_mul(rd_2_2)
	);		
	
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_2_3
	(
	.result(mul_result_2_3),
	.man_x({rd_2_2, mul_result_2_2[23:1]}),
	.man_y({1'b0, pre_man_root_result[23:1]}),				//	Ket qua lui 2 bit
	.redundant_mul(rd_2_3)
	);		
	
	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_2_4
	(
	.result(mul_result_2_4),
	.man_x(mul_result_2_3),
	.man_y(pre_man_root_result),				//	Ket qua lui  bit
	.redundant_mul(rd_2_4)
	);		

	Braun_Multiplication	
	#(
	.BIT_LENGTH(24)
	)		
	B_MUL_2_5
	(
	.result(mul_result_2_5),
	.man_x(mul_op_2),
	.man_y({co, 21'b0}),
	.redundant_mul(rd_2_5)
	);	

	Subtraction_ROOT	SROOT_2
	(
	.result(sub_result_2), 
	.op1(swap_a_2),
	.op2(swap_b_2)
	);		

/*
	Newton_Raphson_Division
	#(
	.DIVIDEND_LENGTH(24),
	.DIVISOR_LENGTH(24),
	.QUOTIENT_LENGTH(24)
	)
	DROOT_2
	(
	.quotient(pre_div_2),
	.pre_dividend({4'b0, sub_result_2[23:4]}),
	.pre_divisor(mul_result_2_5),				//	 mul_result_2_5 bi lui 6 bit
	.initial_guess(24'h0fffff)
	);	
*/
	Modified_NRD_Division_Ver2	DROOT_2
	(
	.remainder(),
	.quotient(pre_div_2),
	.pre_dividend({4'b0, sub_result_2[23:4]}),
	.pre_divisor(mul_result_2_5),				//	 mul_result_2_5 bi lui 6 bit
	.ge(1'b0)
	);

	Addition_ROOT	ROOT_2
	(
	.result(man_root_result), 
	.error(pre_div_2),
	.guess_rr(pre_man_root_result),
	.choose(!ge_2)
	);	


//	Compare
	
	genvar a;
	generate
		for(a = 0; a < BIT_LENGTH; a = a + 1)
		begin: comp_fra_3
			assign fr_eq_check_2[a] = comp_a[a]~^sub_op_1[a];
			assign fr_g_check_2[a] = comp_a[a]&&(~sub_op_1[a]);
		end
	endgenerate

	genvar b;
	generate
		assign fr_ge_check_2[0] = fr_eq_check_2[0] || fr_g_check_2[0];
		for(b = 1; b < BIT_LENGTH; b = b + 1)
		begin: comp_fra_4
			assign fr_ge_check_2[b] = (fr_eq_check_2[b]&&fr_ge_check_2[b-1])||fr_g_check_2[b];
		end
	endgenerate
	
	assign	ge_2 = fr_ge_check_2[BIT_LENGTH-1];	
	
	assign 	swap_a_2 = ge_2 ? comp_a : sub_op_2;
	assign 	swap_b_2 = ge_2 ? sub_op_2 : comp_a;	

//===================================================================
//	Exponent computing
//===================================================================
	Modified_Multiplication	EXP_MUL
	(
	.result(exp_mul),
	.man_x(8'h7f),
	.man_y({5'b0, exp_co})
	);

	Addition_ROOT
	#
	(
	.BIT_LENGTH(10)
	)
	EXP_ADD
	(
	.result(exp_dividend), 
	.error({1'b0, exp_mul}),
	.guess_rr({2'b0, exp}),
	.choose(1'b0)
	);		

	Modified_NRD_Division	EXP_DIV
	(
	.quotient(pre_root_exp),
	.remainder(),
	.pre_dividend(exp_dividend),
	.pre_divisor(co)
	);
	
	assign 	root_result = {sign, pre_root_exp, man_root_result[22:0]};
	
endmodule


//===================================================================
//###################################################################
//===================================================================
module Subtraction_ROOT
(
	output	[23:0] 	result, 
	input 	[23:0]	op1,
	input 	[23:0]	op2
);	
	logic 	[23:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	logic	[24:0]	cal_c_in;				
	
	assign	cal_c_in[0] = 1'b1;
	assign 	man_x = op1;
	assign 	man_y = op2;
	assign 	result = pre_result;
	
	genvar a;
	generate
		for(a = 0; a < 24; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ (1'b1 ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (1'b1 ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (1'b1 ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule

module Addition_ROOT
#
(
	parameter	BIT_LENGTH = 24
)
(
	output	[BIT_LENGTH-1:0] 	result, 
	input 	[BIT_LENGTH-1:0]	error,
	input 	[BIT_LENGTH-1:0]	guess_rr,
	input 	choose
);	
	logic 	[BIT_LENGTH-1:0]	man_x,
								man_y,
								pre_result,
								cal_c_out;
	
	logic	[BIT_LENGTH:0]		cal_c_in;				
	
	assign	cal_c_in[0] = choose;
	assign 	man_x = guess_rr;
	assign 	man_y = error;
	assign 	result = pre_result;
	
	genvar a;
	generate
		for(a = 0; a < BIT_LENGTH; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ (choose ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (choose ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (choose ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule

//===================================================================

module Modified_Multiplication 
#(
parameter	BIT_LENGTH = 8
)
(
	output	logic	[BIT_LENGTH:0]			result,
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
	assign 	result[8] = sum_out[BIT_LENGTH-1][0];
	
	genvar q;
	generate
		for(q = 0; q < BIT_LENGTH-1; q++)
		begin: gen5
			assign	result[q+1] = sum_out[q][0];
		end			
	endgenerate
	
endmodule	


//===================================================================

module Modified_NRD_Division
#(
parameter 	DIVIDEND_LENGTH = 10,
parameter 	DIVISOR_LENGTH = 3,
parameter 	QUOTIENT_LENGTH = 8
)
(
	output 	[QUOTIENT_LENGTH-1:0]		quotient,
	output 	[DIVISOR_LENGTH-1:0] 		remainder,
	input 	[DIVIDEND_LENGTH-1:0]		pre_dividend,
	input 	[DIVISOR_LENGTH-1:0]		pre_divisor
);
	logic	[QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0]	carry_out,
														sum_out;
	logic 	[QUOTIENT_LENGTH-2:0][DIVISOR_LENGTH-2:0]	new_dividend;
	logic 	[DIVIDEND_LENGTH-1:0]						dividend;
	logic 	[DIVISOR_LENGTH-1:0]						divisor,
														dividend_fix;
	logic 	[QUOTIENT_LENGTH-1:0]						pre_quotient;
	
	assign	dividend =	pre_dividend;
	assign 	divisor = pre_divisor;
	
//	matrix without row QUOTIENT_LENGTH-1, QUOTIENT_LENGTH-2, QUOTIENT_LENGTH-3 ; column 0,1
	genvar i, j;
	generate
		for(i = QUOTIENT_LENGTH-4; i >= 0; i--)
		begin:	fa_row_gen1
			for(j = 2; j < DIVISOR_LENGTH; j++)
			begin:	fa_column_gen2
				assign	new_dividend[i][j-1] = (!carry_out[i+1][DIVISOR_LENGTH-1] ? new_dividend[i+1][j-2] : sum_out[i+1][j-1]);
				assign 	sum_out[i][j] = !divisor[j] ^ new_dividend[i][j-1] ^ carry_out[i][j-1];
				assign 	carry_out[i][j] = !divisor[j] && new_dividend[i][j-1] || carry_out[i][j-1] && (!divisor[j] ^ new_dividend[i][j-1]);				
			end
		end
	endgenerate

//	row QUOTIENT_LENGTH-1 without index 0
	genvar k;
	generate
		for(k = 1; k < DIVISOR_LENGTH; k++)
		begin:	fa_row0_gen
			assign 	sum_out[QUOTIENT_LENGTH-1][k] = !divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1] ^ carry_out[QUOTIENT_LENGTH-1][k-1];
			assign 	carry_out[QUOTIENT_LENGTH-1][k] =  !divisor[k] && dividend[k+QUOTIENT_LENGTH-1] || carry_out[QUOTIENT_LENGTH-1][k-1] && (!divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1]);					
		end
	endgenerate

//	row QUOTIENT_LENGTH-2 without index 0
	genvar l;
	generate
		for(l = 1; l < DIVISOR_LENGTH; l++)
		begin:	fa_row1_gen
			assign	new_dividend[QUOTIENT_LENGTH-2][l-1] = (!carry_out[QUOTIENT_LENGTH-1][DIVISOR_LENGTH-1]) ? dividend[l+6] : sum_out[QUOTIENT_LENGTH-1][l-1];	
			assign 	sum_out[QUOTIENT_LENGTH-2][l] = !divisor[l] ^ new_dividend[QUOTIENT_LENGTH-2][l-1] ^ carry_out[QUOTIENT_LENGTH-2][l-1];
			assign 	carry_out[QUOTIENT_LENGTH-2][l] =  !divisor[l] && new_dividend[QUOTIENT_LENGTH-2][l-1] || carry_out[QUOTIENT_LENGTH-2][l-1] && (!divisor[l] ^ new_dividend[QUOTIENT_LENGTH-2][l-1]);					
		end		
	endgenerate
	
//	row QUOTIENT_LENGTH-3 without index 0

	assign	new_dividend[QUOTIENT_LENGTH-3][1] = (!carry_out[QUOTIENT_LENGTH-2][DIVISOR_LENGTH-1]) ? ((~(|dividend[8:6])&&dividend[9]) ? dividend_fix[1] : new_dividend[QUOTIENT_LENGTH-2][0]) : sum_out[QUOTIENT_LENGTH-2][1];	
	assign 	sum_out[QUOTIENT_LENGTH-3][2] = !divisor[2] ^ new_dividend[QUOTIENT_LENGTH-3][1] ^ carry_out[QUOTIENT_LENGTH-3][1];
	assign 	carry_out[QUOTIENT_LENGTH-3][2] =  !divisor[2] && new_dividend[QUOTIENT_LENGTH-3][1] || carry_out[QUOTIENT_LENGTH-3][1] && (!divisor[2] ^ new_dividend[QUOTIENT_LENGTH-3][1]);					

	assign	new_dividend[QUOTIENT_LENGTH-3][0]= ((!carry_out[QUOTIENT_LENGTH-2][DIVISOR_LENGTH-1]) ? ((~(|dividend[8:6])&&dividend[9]) ? dividend_fix[0] : dividend[QUOTIENT_LENGTH-2]) : sum_out[QUOTIENT_LENGTH-2][0]);
	assign 	sum_out[QUOTIENT_LENGTH-3][1] = !divisor[1] ^ new_dividend[QUOTIENT_LENGTH-3][0] ^ carry_out[QUOTIENT_LENGTH-3][0];
	assign 	carry_out[QUOTIENT_LENGTH-3][1] =  !divisor[1] && new_dividend[QUOTIENT_LENGTH-3][0] || carry_out[QUOTIENT_LENGTH-3][0] && (!divisor[1] ^ new_dividend[QUOTIENT_LENGTH-3][0]);		
	
 
//	Fix Subtractor
	logic 	[DIVISOR_LENGTH:0]		divisor_fix,
									carry_out_fix,
									sum_out_fix;

	logic 	[DIVISOR_LENGTH+1:0]	carry_in_fix;	
	
	assign 	carry_in_fix[0]	= 1'b1;
	assign 	divisor_fix = {1'b0, divisor};
	
	genvar h;
	generate
		for(h = 0; h < DIVISOR_LENGTH+1; h++)
		begin:	fix_gen
			assign 	sum_out_fix[h] = !divisor_fix[h] ^ dividend[h+DIVIDEND_LENGTH-4] ^ carry_in_fix[h];
			assign 	carry_out_fix[h] =  !divisor_fix[h] && dividend[h+DIVIDEND_LENGTH-4] || carry_in_fix[h] && (!divisor_fix[h] ^ dividend[h+DIVIDEND_LENGTH-4]);
			assign 	carry_in_fix[h+1]  = carry_out_fix[h];
		end
	endgenerate
	
	assign 	dividend_fix = sum_out_fix[DIVISOR_LENGTH-2:0];
	
//	column 0 
	genvar m;
	generate
		for(m = QUOTIENT_LENGTH-1; m >= 0; m--)
		begin:	fa_column0_gen
			assign 	sum_out[m][0] = !divisor[0] ^ dividend[m] ^ 1'b1;
			assign 	carry_out[m][0] =  !divisor[0] && dividend[m] || 1'b1 && (!divisor[0] ^ dividend[m]);			
		end
	endgenerate
	
// column 1 without index QUOTIENT_LENGTH-1, QUOTIENT_LENGTH-2, QUOTIENT_LENGTH-3
	genvar n;
	generate
		for(n = QUOTIENT_LENGTH-4; n >= 0; n--)
		begin:	fa_column1_gen
			assign	new_dividend[n][0]= (!carry_out[n+1][DIVISOR_LENGTH-1] ? dividend[n+1] : sum_out[n+1][0]);
			assign 	sum_out[n][1] = !divisor[1] ^ new_dividend[n][0] ^ carry_out[n][0];
			assign 	carry_out[n][1] =  !divisor[1] && new_dividend[n][0] || carry_out[n][0] && (!divisor[1] ^ new_dividend[n][0]);					
		end
	endgenerate
	
//	remainder output
	genvar p;
	generate
		for(p = 0; p < DIVISOR_LENGTH; p++)
		begin:	divisor_gen
			assign	remainder[p] = 	sum_out[0][p];
		end
	endgenerate
	
//	quotient output
	genvar q;
	generate
		for(q = 0; q < QUOTIENT_LENGTH; q++)
		begin:	quotient_gen
			assign	pre_quotient[q] = carry_out[q][DIVISOR_LENGTH-1] ;
		end
	endgenerate
	
	assign	quotient = ((!carry_out[QUOTIENT_LENGTH-2][DIVISOR_LENGTH-1])&&((~(|dividend[8:6])&&dividend[9]))) ? {pre_quotient[QUOTIENT_LENGTH-1], 1'b1, pre_quotient[QUOTIENT_LENGTH-3:0]} : pre_quotient;
	
endmodule

//===================================================================

module Modified_NRD_Division_Ver2
#(
parameter 	DIVIDEND_LENGTH = 24,
parameter 	DIVISOR_LENGTH = 24,
parameter 	QUOTIENT_LENGTH = 24
)
(
	output 	[QUOTIENT_LENGTH-1:0]		quotient,
	output 	[DIVISOR_LENGTH-1:0] 		remainder,
	input 	[DIVIDEND_LENGTH-1:0]		pre_dividend,
	input 	[DIVISOR_LENGTH-1:0]		pre_divisor,
	input 								ge
);
	logic	[QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0]	carry_out,
														sum_out;
	logic 	[QUOTIENT_LENGTH-2:0][DIVISOR_LENGTH-2:0]	new_dividend;
	logic 	[DIVIDEND_LENGTH+22:0]						dividend;
	logic 	[DIVISOR_LENGTH-1:0]						divisor;
	logic 	[QUOTIENT_LENGTH-1:0]						pre_quotient;
	
	assign	dividend = {pre_dividend, 23'b0};
//	assign 	divisor =  ge ? pre_divisor : {1'b0, pre_divisor[DIVISOR_LENGTH-1:1]};
	assign 	divisor = pre_divisor;
	
//	matrix without row QUOTIENT_LENGTH-1, QUOTIENT_LENGTH-2 ; column 0,1
	genvar i, j;
	generate
		for(i = QUOTIENT_LENGTH-3; i >= 0; i--)
		begin:	fa_row_gen1
			for(j = 2; j < DIVISOR_LENGTH; j++)
			begin:	fa_column_gen2
				assign	new_dividend[i][j-1] = (!carry_out[i+1][DIVISOR_LENGTH-1] ? new_dividend[i+1][j-2] : sum_out[i+1][j-1]);
				assign 	sum_out[i][j] = !divisor[j] ^ new_dividend[i][j-1] ^ carry_out[i][j-1];
				assign 	carry_out[i][j] = !divisor[j] && new_dividend[i][j-1] || carry_out[i][j-1] && (!divisor[j] ^ new_dividend[i][j-1]);				
			end
		end
	endgenerate

//	row QUOTIENT_LENGTH-1 without index 0
	genvar k;
	generate
		for(k = 1; k < DIVISOR_LENGTH; k++)
		begin:	fa_row0_gen
			assign 	sum_out[QUOTIENT_LENGTH-1][k] = !divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1] ^ carry_out[QUOTIENT_LENGTH-1][k-1];
			assign 	carry_out[QUOTIENT_LENGTH-1][k] =  !divisor[k] && dividend[k+QUOTIENT_LENGTH-1] || carry_out[QUOTIENT_LENGTH-1][k-1] && (!divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1]);					
		end
	endgenerate

//	row QUOTIENT_LENGTH-2 without index 0
	genvar l;
	generate
		for(j = 1; j < DIVISOR_LENGTH; j++)
		begin:	fa_row1_gen
			assign	new_dividend[QUOTIENT_LENGTH-2][j-1] = (!carry_out[QUOTIENT_LENGTH-1][DIVISOR_LENGTH-1]) ? dividend[l+22] : sum_out[QUOTIENT_LENGTH-1][j-1];
			assign 	sum_out[QUOTIENT_LENGTH-2][j] = !divisor[j] ^ new_dividend[QUOTIENT_LENGTH-2][j-1] ^ carry_out[QUOTIENT_LENGTH-2][j-1];
			assign 	carry_out[QUOTIENT_LENGTH-2][j] =  !divisor[j] && new_dividend[QUOTIENT_LENGTH-2][j-1] || carry_out[QUOTIENT_LENGTH-2][j-1] && (!divisor[j] ^ new_dividend[QUOTIENT_LENGTH-2][j-1]);					
		end		
	endgenerate

//	column 0 
	genvar m;
	generate
		for(m = QUOTIENT_LENGTH-1; m >= 0; m--)
		begin:	fa_column0_gen
			assign 	sum_out[m][0] = !divisor[0] ^ dividend[m] ^ 1'b1;
			assign 	carry_out[m][0] =  !divisor[0] && dividend[m] || 1'b1 && (!divisor[0] ^ dividend[m]);			
		end
	endgenerate
	
// column 1 without index QUOTIENT_LENGTH-1, QUOTIENT_LENGTH-2
	genvar n;
	generate
		for(n = QUOTIENT_LENGTH-3; n >= 0; n--)
		begin:	fa_column1_gen
			assign	new_dividend[n][0]= (sum_out[n+1][DIVISOR_LENGTH-1] ? dividend[n+1] : sum_out[n+1][0]);
			assign 	sum_out[n][1] = !divisor[1] ^ new_dividend[n][0] ^ carry_out[n][0];
			assign 	carry_out[n][1] =  !divisor[1] && new_dividend[n][0] || carry_out[n][0] && (!divisor[1] ^ new_dividend[n][0]);					
		end
	endgenerate
	
//	remainder output
	genvar p;
	generate
		for(p = 0; p < DIVISOR_LENGTH; p++)
		begin:	divisor_gen
			assign	remainder[p] = 	sum_out[0][p];
		end
	endgenerate
	
//	quotient output
	genvar q;
	generate
		for(q = 0; q < QUOTIENT_LENGTH; q++)
		begin:	quotient_gen
			assign	pre_quotient[q] = carry_out[q][DIVISOR_LENGTH-1] ;
		end
	endgenerate
	
//	assign	quotient = ge ? pre_quotient : {1'b0, pre_quotient[QUOTIENT_LENGTH-1:1]};
	assign	quotient = pre_quotient;
	
endmodule