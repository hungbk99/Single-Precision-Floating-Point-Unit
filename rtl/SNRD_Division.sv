//===================================================================
// Design name:		SNRD Division
// Note: 			Configurable Signed Non-Restoring Division
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

module SNRD_Division
#(
parameter 	DIVIDEND_LENGTH = 8,
parameter 	DIVISOR_LENGTH = 8,
parameter 	QUOTIENT_LENGTH = 8
)
(
	output 	[QUOTIENT_LENGTH-1:0]		quotient,
	output 	[DIVISOR_LENGTH-1:0] 		remainder,
	input 	[DIVIDEND_LENGTH-1:0]		pre_dividend,
	input 	[DIVISOR_LENGTH-1:0]		pre_divisor,
	input 								ge
);
	logic	[QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0]	carry_out,
														sum_out,
														xor_out;
														
	logic 	[QUOTIENT_LENGTH*2-2:0]						dividend;

	assign	dividend = {pre_dividend, {QUOTIENT_LENGTH-1{1'b0}}};
	
	genvar a, b;
	generate 
		for(a = QUOTIENT_LENGTH-2; a >= 0; a--)
		begin: xor_gen_row
			for(b = 0; b < QUOTIENT_LENGTH; b++)
			begin: xor_gen_column
				assign 	xor_out[a][b] = pre_divisor[b] ^ carry_out[a+1][QUOTIENT_LENGTH-1];
			end
		end
	endgenerate
	
	genvar c, d;
	generate 
		for(c = QUOTIENT_LENGTH-2; c >= 0; c--)
		begin: adder_gen_row
			for(d = 1; d < QUOTIENT_LENGTH; d++)
			begin: adder_gen_column
				assign 	sum_out[c][d] = xor_out[c][d] ^ sum_out[c+1][d-1] ^ carry_out[c][d-1];
				assign 	carry_out[c][d] = xor_out[c][d] && sum_out[c+1][d-1] || carry_out[c][d-1] && (xor_out[c][d] ^ sum_out[c+1][d-1]);
			end
		end
	endgenerate	
	
	genvar	e;
	generate
		for(e = 1; e < QUOTIENT_LENGTH; e++)
		begin: h_row_gen
			assign 	xor_out[QUOTIENT_LENGTH-1][e] = pre_divisor[e] ^ 1'b1;		
			assign 	sum_out[QUOTIENT_LENGTH-1][e] = xor_out[QUOTIENT_LENGTH-1][e] ^ dividend[QUOTIENT_LENGTH-1+e] ^ carry_out[QUOTIENT_LENGTH-1][e-1];
			assign 	carry_out[QUOTIENT_LENGTH-1][e] = xor_out[QUOTIENT_LENGTH-1][e] && dividend[QUOTIENT_LENGTH-1+e] || carry_out[QUOTIENT_LENGTH-1][e-1] && (xor_out[QUOTIENT_LENGTH-1][e] ^ dividend[QUOTIENT_LENGTH-1+e]);	
//			assign 	sum_out[QUOTIENT_LENGTH-1][e] = xor_out[QUOTIENT_LENGTH-1][e] ^ pre_dividend[e] ^ carry_out[QUOTIENT_LENGTH-1][e-1];
//			assign 	carry_out[QUOTIENT_LENGTH-1][e] = xor_out[QUOTIENT_LENGTH-1][e] && pre_dividend[e] || carry_out[QUOTIENT_LENGTH-1][e-1] && (xor_out[QUOTIENT_LENGTH-1][e] ^ pre_dividend[e]);					
		end
	endgenerate
	
	genvar	f;
	generate
		for(f = 0; f < QUOTIENT_LENGTH-1; f++)
		begin: column_0_gen	
			assign 	sum_out[f][0] = xor_out[f][0] ^ dividend[f] ^ carry_out[f][QUOTIENT_LENGTH-1];
			assign 	carry_out[f][0] = xor_out[f][0] && dividend[f] || carry_out[f][QUOTIENT_LENGTH-1] && (xor_out[f][0] ^ dividend[f]);			
		end
	endgenerate	
	
	assign 	xor_out[QUOTIENT_LENGTH-1][0] = pre_divisor[0] ^ 1'b1;
	assign 	sum_out[QUOTIENT_LENGTH-1][0] = xor_out[QUOTIENT_LENGTH-1][0] ^ dividend[QUOTIENT_LENGTH-1] ^ 1'b1;
	assign 	carry_out[QUOTIENT_LENGTH-1][0] = xor_out[QUOTIENT_LENGTH-1][0] && dividend[QUOTIENT_LENGTH-1] || 1'b1 && (xor_out[QUOTIENT_LENGTH-1][0]^ dividend[QUOTIENT_LENGTH-1]);		
//	assign 	sum_out[QUOTIENT_LENGTH-1][0] = xor_out[QUOTIENT_LENGTH-1][0] ^ pre_dividend[0] ^ 1'b1;
//	assign 	carry_out[QUOTIENT_LENGTH-1][0] = xor_out[QUOTIENT_LENGTH-1][0] && pre_dividend[0]  || 1'b1 && (xor_out[QUOTIENT_LENGTH-1][0]^ pre_dividend[0] );		
	genvar g;
	generate
		for(g = 0; g < QUOTIENT_LENGTH; g++)
		begin: result_gen
			assign 	quotient[g] =	carry_out[QUOTIENT_LENGTH-1][g];
		end
	endgenerate
	
	assign	remainder = sum_out[0];
	
endmodule	