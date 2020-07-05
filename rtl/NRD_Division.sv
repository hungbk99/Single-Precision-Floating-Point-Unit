//===================================================================
// Design name:		Non Restoring Division
// Note: 			Configurable Non Restoring Division
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

module NRD_Division
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
	assign 	divisor =  ge ? pre_divisor : {1'b0, pre_divisor[DIVISOR_LENGTH-1:1]};
	
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
			assign	new_dividend[QUOTIENT_LENGTH-2][j-1] = sum_out[QUOTIENT_LENGTH-1][j-1];	
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
	
	assign	quotient = ge ? pre_quotient : {1'b0, pre_quotient[QUOTIENT_LENGTH-1:1]};
	
endmodule

