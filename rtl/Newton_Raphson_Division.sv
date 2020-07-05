//===================================================================
// Design name:		Newton Raphson Division
// Note: 			More Level will give more exact result
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

module	Newton_Raphson_Division
#(
parameter 	DIVIDEND_LENGTH = 24,
parameter 	DIVISOR_LENGTH = 24,
parameter 	QUOTIENT_LENGTH = 24
)
(
	output 	[QUOTIENT_LENGTH-1:0]		quotient,
//	output 	[DIVISOR_LENGTH-1:0] 		remainder,
	input 	[DIVIDEND_LENGTH-1:0]		pre_dividend,
	input 	[DIVISOR_LENGTH-1:0]		pre_divisor,
	input 	[DIVIDEND_LENGTH-1:0]		initial_guess
);
//===================================================================
	logic	[DIVISOR_LENGTH:0]		TWO;
		
	logic 	[DIVIDEND_LENGTH-1:0]	sub_result_1,
									mul_result_1_1,
									mul_result_1_2,
									sub_result_2,
									mul_result_2_1,
									mul_result_2_2,
									sub_result_3,
									mul_result_3_1,
									mul_result_3_2,
									sub_result_4,
									mul_result_4_1,
									mul_result_4_2,
									sub_result_5,
									mul_result_5_1,
									mul_result_5_2,
									sub_result_6,
									mul_result_6_1,
									mul_result_6_2,
									sub_result_7,
									mul_result_7_1,
									mul_result_7_2,
									sub_result_8,
									mul_result_8_1,
									mul_result_8_2,
									sub_result_9,
									mul_result_9_1,
									mul_result_9_2,
									sub_result_10,
									mul_result_10_1,
									mul_result_10_2,
									sub_result_11,
									mul_result_11_1,
									mul_result_11_2,
									sub_result_12,
									mul_result_12_1,
									mul_result_12_2;

//===================================================================
`ifdef	SIMULATE
	include"Braun_Multiplication.sv";
`endif
//===================================================================

//	Level 1 => pre_divisor is used for initial value of 1/pre_divisor 		
	Braun_Multiplication	B_MUL_1_1
	(
	.result(mul_result_1_1),
	.man_x(initial_guess),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_1
	(
	.result(sub_result_1), 
	.op(mul_result_1_1)
	);

	Braun_Multiplication	B_MUL_1_2
	(
	.result(mul_result_1_2),
	.man_x(sub_result_1),
	.man_y(initial_guess),
	.redundant_mul()
	);	

//	Level 2
	Braun_Multiplication	B_MUL_2_1
	(
	.result(mul_result_2_1),
	.man_x(mul_result_1_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_2
	(
	.result(sub_result_2), 
	.op(mul_result_2_1)
	);

	Braun_Multiplication	B_MUL_2_2
	(
	.result(mul_result_2_2),
	.man_x(sub_result_2),
	.man_y(mul_result_1_2),
	.redundant_mul()
	);	

//	Level 3	
	Braun_Multiplication	B_MUL_3_1
	(
	.result(mul_result_3_1),
	.man_x(mul_result_2_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_3
	(
	.result(sub_result_3), 
	.op(mul_result_3_1)
	);

	Braun_Multiplication	B_MUL_3_2
	(
	.result(mul_result_3_2),
	.man_x(sub_result_3),
	.man_y(mul_result_2_2),
	.redundant_mul()
	);	

//	Level 4
	Braun_Multiplication	B_MUL_4_1
	(
	.result(mul_result_4_1),
	.man_x(mul_result_3_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_4
	(
	.result(sub_result_4), 
	.op(mul_result_4_1)
	);

	Braun_Multiplication	B_MUL_4_2
	(
	.result(mul_result_4_2),
	.man_x(sub_result_4),
	.man_y(mul_result_3_2),
	.redundant_mul()
	);	

//	Level 5
	Braun_Multiplication	B_MUL_5_1
	(
	.result(mul_result_5_1),
	.man_x(mul_result_4_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_5
	(
	.result(sub_result_5), 
	.op(mul_result_5_1)
	);

	Braun_Multiplication	B_MUL_5_2
	(
	.result(mul_result_5_2),
	.man_x(sub_result_5),
	.man_y(mul_result_4_2),
	.redundant_mul()
	);	

//	Level 6
	Braun_Multiplication	B_MUL_6_1
	(
	.result(mul_result_6_1),
	.man_x(mul_result_5_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_6
	(
	.result(sub_result_6), 
	.op(mul_result_6_1)
	);

	Braun_Multiplication	B_MUL_6_2
	(
	.result(mul_result_6_2),
	.man_x(sub_result_6),
	.man_y(mul_result_5_2),
	.redundant_mul()
	);	

//	Level 7
	Braun_Multiplication	B_MUL_7_1
	(
	.result(mul_result_7_1),
	.man_x(mul_result_6_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_7
	(
	.result(sub_result_7), 
	.op(mul_result_7_1)
	);

	Braun_Multiplication	B_MUL_7_2
	(
	.result(mul_result_7_2),
	.man_x(sub_result_7),
	.man_y(mul_result_6_2),
	.redundant_mul()
	);	

//	Level 8
	Braun_Multiplication	B_MUL_8_1
	(
	.result(mul_result_8_1),
	.man_x(mul_result_7_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_8
	(
	.result(sub_result_8), 
	.op(mul_result_8_1)
	);

	Braun_Multiplication	B_MUL_8_2
	(
	.result(mul_result_8_2),
	.man_x(sub_result_8),
	.man_y(mul_result_7_2),
	.redundant_mul()
	);	

//	Level 9
	Braun_Multiplication	B_MUL_9_1
	(
	.result(mul_result_9_1),
	.man_x(mul_result_8_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_9
	(
	.result(sub_result_9), 
	.op(mul_result_9_1)
	);

	Braun_Multiplication	B_MUL_9_2
	(
	.result(mul_result_9_2),
	.man_x(sub_result_9),
	.man_y(mul_result_8_2),
	.redundant_mul()
	);	

//	Level 10
	Braun_Multiplication	B_MUL_10_1
	(
	.result(mul_result_10_1),
	.man_x(mul_result_9_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_10
	(
	.result(sub_result_10), 
	.op(mul_result_10_1)
	);

	Braun_Multiplication	B_MUL_10_2
	(
	.result(mul_result_10_2),
	.man_x(sub_result_10),
	.man_y(mul_result_9_2),
	.redundant_mul()
	);	

//	Level 11
	Braun_Multiplication	B_MUL_11_1
	(
	.result(mul_result_11_1),
	.man_x(mul_result_10_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_11
	(
	.result(sub_result_11), 
	.op(mul_result_11_1)
	);

	Braun_Multiplication	B_MUL_11_2
	(
	.result(mul_result_11_2),
	.man_x(sub_result_11),
	.man_y(mul_result_10_2),
	.redundant_mul()
	);	
	
//	Level 12
	Braun_Multiplication	B_MUL_12_1
	(
	.result(mul_result_12_1),
	.man_x(mul_result_11_2),
	.man_y(pre_divisor),
	.redundant_mul()
	);		
	
	Subtraction_NR_D	SUB_12
	(
	.result(sub_result_12), 
	.op(mul_result_12_1)
	);

	Braun_Multiplication	B_MUL_12_2
	(
	.result(mul_result_12_2),
	.man_x(sub_result_12),
	.man_y(mul_result_11_2),
	.redundant_mul()
	);
	
//	Result
	Braun_Multiplication	B_MUL_FINAL
	(
	.result(quotient),
	.man_x(mul_result_12_2),
	.man_y(pre_dividend),
	.redundant_mul()
	);	
	
endmodule	

//===================================================================
module Subtraction_NR_D
(
	output	[23:0] 	result, 
	input 	[23:0]	op
);	
	logic 	[24:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	logic	[25:0]	cal_c_in;				
	
	assign	cal_c_in[0] = 1'b1;
	assign 	man_x = 25'h1000000;
	assign 	man_y = {1'b0, op};
	assign 	result = pre_result[23:0];
	
	genvar a;
	generate
		for(a = 0; a < 25; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ (1'b1 ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (1'b1 ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (1'b1 ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule