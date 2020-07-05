//===================================================================
// Design name:		Pre Normalization							
// Project name:	A 32 bit single precision Floating Point Unit DD192 
// Author:			hungbk99
//===================================================================

`include"FPU_define.h"
import FPU_192_Package::*;
module	Pre_Normalization(
	output 	[EXPONENT_LENGTH-1:0] 				exp,
	output	[NORMALIZE_MANTISSA_LENGTH-1:0] 	man_x,
	output 	[NORMALIZE_MANTISSA_LENGTH-1:0]	 	man_y,
	output 	logic								sign,
	output 										sign_x,
	output 										sign_y,
	output 										enable,
	output	logic [FORMAT_LENGTH-1:0] 			special_result,

	input	[EXPONENT_LENGTH-1:0] 				exp_a,
	input 	[EXPONENT_LENGTH-1:0] 				exp_b,
	input	[FRACTION_LENGTH-1:0] 				fra_a,
	input 	[FRACTION_LENGTH-1:0] 				fra_b,	
	input 										sign_a,
	input 										sign_b,
	input 										add_sub
);
	
//=============================Parameters=============================

	localparam 	ZERO = 2'b00;
	localparam 	NAN = 2'b01;
	localparam 	INFINITY = 2'b10;
	localparam 	NORMAL = 2'b11;
//====================================================================		
//Internal signals
	logic		[1:0] a_type;
	logic		[1:0] b_type;

	logic 	[EXPONENT_LENGTH-1:0] ex_eq_check;
	logic	[EXPONENT_LENGTH-1:0] ex_g_check;
	logic	[EXPONENT_LENGTH-1:0] ex_ge_check;	
	logic 	[FRACTION_LENGTH-1:0] fr_eq_check;
	logic	[FRACTION_LENGTH-1:0] fr_ge_check;
	logic	[FRACTION_LENGTH-1:0] fr_g_check;	
	logic 	exp_ge;
	logic 	exp_eq;
	logic 	fra_ge;
	logic 	swap;
	
	logic 	[FRACTION_LENGTH-1:0] shift_fra;
	logic 	[EXPONENT_LENGTH-1:0] minuend;
	logic 	[EXPONENT_LENGTH-1:0] subtrahend;

	logic	[EXPONENT_LENGTH-1:0] exp_cin;
	logic 	[EXPONENT_LENGTH-1:0] exp_s;
//	logic 	[EXPONENT_LENGTH-1:0] exp_cout;
	logic 	[EXPONENT_LENGTH-1:0] shift_count;
	logic 	[EXPONENT_LENGTH-1:0] exp_p;
	logic 	[EXPONENT_LENGTH-1:0] exp_g;
	logic 	p1_cin;
	logic 	G0;
	logic 	P0;
	
	logic	[NORMALIZE_MANTISSA_LENGTH-1:0]	shift_fra_1;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_2;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_3;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_4;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_5;
	logic 	[NORMALIZE_MANTISSA_LENGTH-1:0] shift_fra_6;
		
//====================================================================
//	Sign
	always @(*) begin
		case({swap, add_sub, sign_a, sign_b})
		4'b0000:	sign = 0;
		4'b0001:	sign = 0;
		4'b0010:	sign = 1;
		4'b0011:	sign = 1;
		4'b0100:	sign = 0;
		4'b0101:	sign = 0;
		4'b0110:	sign = 1;
		4'b0111:	sign = 1;
		4'b1000:	sign = 0;
		4'b1001:	sign = 1;
		4'b1010:	sign = 0;
		4'b1011:	sign = 1;
		4'b1100:	sign = 1;
		4'b1101:	sign = 0;
		4'b1110:	sign = 1;
		4'b1111:	sign = 0;
		endcase
	end
	
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
	assign	exp_eq = &ex_eq_check;
	
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
//	assign  swap = (exp_ge&&(!exp_eq)) ? 0 : ((fra_ge) ? 0 : 1);
	assign 	swap = (exp_eq) ? ((fra_ge) ? 0 : 1) : ((exp_ge) ? 0 : 1);
	
//	Special Case Handle
	always_comb begin
		special_result = '0;
		if(a_type == ZERO)												//ZERO + NUMBER
		begin
			if(!add_sub)
				special_result[FORMAT_LENGTH-1] = sign_b;
			else 
				special_result[FORMAT_LENGTH-1] = ~sign_b;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			special_result[FRACTION_LENGTH-1:0] = fra_b;
		end		
		else if(b_type == ZERO)											//NUMBER + ZERO				
		begin
			special_result[FORMAT_LENGTH-1] = sign_a;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_result[FRACTION_LENGTH-1:0] = fra_a;	
		end
		else if((a_type == NORMAL)&&(b_type == INFINITY))				//NORMAL + INFINITY
		begin
			if(!add_sub)
				special_result[FORMAT_LENGTH-1] = sign_b;
			else 
				special_result[FORMAT_LENGTH-1] = ~sign_b;		
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			special_result[FRACTION_LENGTH-1:0] = fra_b;
		end
		else if((b_type == NORMAL)&&(a_type == INFINITY))				//INFINITY + NORMAL
		begin	
			special_result[FORMAT_LENGTH-1] = sign_a;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_result[FRACTION_LENGTH-1:0] = fra_a;			
		end
		else if((a_type == INFINITY)&&(b_type == INFINITY)&&(sign_a == sign_b)) 	//INFINITY + INFINITY
		begin
			special_result[FORMAT_LENGTH-1] = sign_a;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_result[FRACTION_LENGTH-1:0] = fra_a;				
		end
		else if((a_type == INFINITY)&&(b_type == INFINITY)&&(sign_a != sign_b))
		begin
			if((sign_a == 1'b1)&&(sign_b == 1'b0)&&add_sub)
				special_result[FORMAT_LENGTH-1] = 1'b1;
			else
				special_result[FORMAT_LENGTH-1] = 1'b0;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_result[FRACTION_LENGTH-1:0] = fra_a;					
		end	
		else if(a_type == NAN)														// NAN + NUMBER
		begin
			special_result[FORMAT_LENGTH-1] = sign_a;
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_result[FRACTION_LENGTH-1:0] = fra_a;			
		end
		else if(b_type == NAN)
		begin
			special_result[FORMAT_LENGTH-1] = sign_b;		
			special_result[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			special_result[FRACTION_LENGTH-1:0] = fra_b;		
		end
	end

	assign	enable = ((a_type == NORMAL)&&(b_type == NORMAL)) ? 1 : 0;
	
//	NORMALIZATION
//	Arrange
	assign	sign_x = (swap) ? sign_b : sign_a;	
	assign	sign_y = (swap) ? sign_a : sign_b;
	assign	man_x = (swap) ? {1'b1, fra_b} : {1'b1, fra_a};		
	assign 	shift_fra = (swap) ? fra_a : fra_b;
	assign 	minuend = (swap) ? exp_b : exp_a;
	assign 	subtrahend = (swap) ? exp_a : exp_b;
	assign 	exp = (swap) ? exp_b : exp_a;

//	EXP difference
//	CLA difference = minuend - subtrahend
//	FA
	
	genvar p;
	generate
		for(p = 0; p < EXPONENT_LENGTH; p = p + 1)
		begin:	fa_exp
			assign exp_p[p] = minuend[p] ^ (~subtrahend[p]);
			assign exp_g[p] = minuend[p] && (~subtrahend[p]);
			assign shift_count[p] = exp_p[p] ^ exp_cin[p];
		end		
	endgenerate
	
//	CLA Block 0
	assign exp_cin[0] = 1;	
	assign exp_cin[1] = exp_g[0] || (exp_p[0]&&exp_cin[0]);
	assign exp_cin[2] = exp_g[1] || (exp_p[1]&&exp_g[0]) || (exp_p[1]&&exp_p[0]&&exp_cin[0]);
	assign exp_cin[3] = exp_g[2] || (exp_p[2]&&exp_g[1]) || (exp_p[2]&&exp_p[1]&&exp_g[0]) || (exp_p[2]&&exp_p[1]&&exp_p[0]&&exp_cin[0]);
	assign P0 = exp_p[0]&&exp_p[1]&&exp_p[2]&&exp_p[3];
	assign G0 = exp_g[3] || (exp_p[3]&&exp_g[2]) || (exp_p[3]&&exp_p[2]&&exp_g[1]) || (exp_p[3]&&exp_p[2]&&exp_p[1]&&exp_g[0]); 

//	CLA Block 1
	assign exp_cin[4] = (P0&&exp_cin[0]) || G0;
	assign exp_cin[5] = exp_g[4] || (exp_p[4]&&exp_cin[4]);
	assign exp_cin[6] = exp_g[5] || (exp_p[5]&&exp_g[4]) || (exp_p[5]&&exp_p[4]&&exp_cin[4]);
	assign exp_cin[7] = exp_g[6] || (exp_p[6]&&exp_g[5]) || (exp_p[6]&&exp_p[5]&&exp_g[4]) || (exp_p[6]&&exp_p[5]&&exp_p[4]&&exp_cin[0]);

//	Shift Right
	genvar a;
	generate
		for(a = 0; a < NORMALIZE_MANTISSA_LENGTH-1; a =  a + 1)
		begin:	sr_stage_1
			assign 	shift_fra_1[a] = (shift_count[0]) ? shift_fra_2[a+1] : shift_fra_2[a];
		end
		assign	shift_fra_1[NORMALIZE_MANTISSA_LENGTH-1] = (shift_count[0]) ? 1'b0 : shift_fra_2[NORMALIZE_MANTISSA_LENGTH-1];
	endgenerate

	genvar b;
	generate
		for(b = 0; b < NORMALIZE_MANTISSA_LENGTH-2; b = b + 1)
		begin: 	sr_stage_2
			assign 	shift_fra_2[b] = (shift_count[1]) ? shift_fra_3[b+2] : shift_fra_3[b];
		end
		assign 	shift_fra_2[NORMALIZE_MANTISSA_LENGTH-1] = (shift_count[1]) ? 1'b0 : shift_fra_3[NORMALIZE_MANTISSA_LENGTH-1];
		assign  shift_fra_2[NORMALIZE_MANTISSA_LENGTH-2] = (shift_count[1]) ? 1'b0 : shift_fra_3[NORMALIZE_MANTISSA_LENGTH-2];
	endgenerate
	
	genvar c;
	generate
		for(c = 0; c < NORMALIZE_MANTISSA_LENGTH-4; c = c + 1)
		begin: sr_stage_3
			assign shift_fra_3[c] = (shift_count[2]) ? shift_fra_4[c+4] : shift_fra_4[c];
		end
		assign 	shift_fra_3[NORMALIZE_MANTISSA_LENGTH-1] = (shift_count[2]) ? 1'b0 : shift_fra_4[NORMALIZE_MANTISSA_LENGTH-1];
		assign 	shift_fra_3[NORMALIZE_MANTISSA_LENGTH-2] = (shift_count[2]) ? 1'b0 : shift_fra_4[NORMALIZE_MANTISSA_LENGTH-2];
		assign 	shift_fra_3[NORMALIZE_MANTISSA_LENGTH-3] = (shift_count[2]) ? 1'b0 : shift_fra_4[NORMALIZE_MANTISSA_LENGTH-3];
		assign 	shift_fra_3[NORMALIZE_MANTISSA_LENGTH-4] = (shift_count[2]) ? 1'b0 : shift_fra_4[NORMALIZE_MANTISSA_LENGTH-4];			
	endgenerate
	
	genvar d;
	generate	
		for(d = 0; d < NORMALIZE_MANTISSA_LENGTH-8; d = d + 1)
		begin: 	sr_stage_4_1
			assign 	shift_fra_4[d] = (shift_count[3]) ? shift_fra_5[d+8] : shift_fra_5[d];
		end
	endgenerate
	
	genvar e;
	generate	
		for(e = NORMALIZE_MANTISSA_LENGTH-8; e < NORMALIZE_MANTISSA_LENGTH; e = e + 1)
		begin: 	sr_stage_4_2
			assign	shift_fra_4[e] = (shift_count[3]) ? 1'b0 : shift_fra_5[e];
		end
	endgenerate
	
	genvar f;
	generate 
		for(f = 0; f < NORMALIZE_MANTISSA_LENGTH-16; f = f + 1)
		begin: 	sr_stage_5_1
			assign shift_fra_5[f] = (shift_count[4]) ? shift_fra_6[f+16] : shift_fra_6[f];
		end
	endgenerate
	
	genvar g;
	generate 
		for(g = NORMALIZE_MANTISSA_LENGTH-16; g < NORMALIZE_MANTISSA_LENGTH; g = g + 1)
		begin: 	sr_stage_5_2
			assign 	shift_fra_5[g] = (shift_count[4]) ? 1'b0 : shift_fra_6[g];
		end
	endgenerate
	
	genvar h;
	generate
		for(h = 0; h < NORMALIZE_MANTISSA_LENGTH-1; h = h + 1)
		begin: 	sr_stage_6
			assign 	shift_fra_6[h] = (|shift_count[7:5]) ? 1'b0 : shift_fra[h];
		end
		assign	shift_fra_6[NORMALIZE_MANTISSA_LENGTH-1] = (|shift_count[7:5]) ? 1'b0 : 1'b1;
	endgenerate
	
	assign man_y = shift_fra_1;
	
endmodule






































/*
	localparam 	ZERO = 3'b000;
	localparam 	SUBNORMAL = 3'b100;
	localparam 	NORMAL = 3'b101;
	localparam 	INFINITY = 3'b001;
	localparam  NAN = 3'b011;
	logic 	[EXPONENT_LENGTH-1:0] exp_a;
	logic 	[EXPONENT_LENGTH-1:0] exp_b;
	logic 	[FRACTION_LENGTH-1:0] fra_a;
	logic 	[FRACTION_LENGTH-1:0] fra_b;	
	logic 	[EXPONENT_LENGTH-1:0] ex_eq_check;
	logic	[EXPONENT_LENGTH-1:0] ex_ge_pre_check;
	logic	[EXPONENT_LENGTH-1:0] ex_ge_check;	
	logic 	[FRACTION_LENGTH-1:0] fr_eq_check;
	logic	[FRACTION_LENGTH-1:0] fr_ge_check;
	logic	[FRACTION_LENGTH-1:0] fr_ge_pre_check;	
	logic 	exp_ge;
	logic 	fra_ge;
	logic		[2:0] a_type;
	logic		[2:0] b_type;
	
	logic		[NORMALIZE_MANTISSA_LENGTH:0] sub_man_a;
	logic 	[NORMALIZE_MANTISSA_LENGTH:0] sub_man_b;
	logic		[EXPONENT_LENGTH-1:0] sub_exp;
	logic		sub_sign_a;
	logic 	sub_sign_b;
	
	logic		[NORMALIZE_MANTISSA_LENGTH:0] mix_man_a;
	logic 	[NORMALIZE_MANTISSA_LENGTH:0] mix_man_b;	
	logic		[EXPONENT_LENGTH-1:0] mix_exp_a;
	logic		[EXPONENT_LENGTH-1:0] mix_exp_b;
	logic		[FRACTION_LENGTH-1:0] mix_sub;
	logic		mix_sign_a;
	logic 	mix_sign_b;
	logic		[4:0] mix_count;
	logic	[FRACTION_LENGTH-1:0] sr_stage_1;
	logic 	[FRACTION_LENGTH-1:0] sr_stage_2;
	logic 	[FRACTION_LENGTH-1:0] sr_stage_3;
	logic 	[FRACTION_LENGTH-1:0] sr_stage_4;
	logic 	[FRACTION_LENGTH-1:0] sr_stage_5;
	logic 	stage_2;
	
//====================================================================

//	Extracting Exp, Man, Sign	
	assign	exp_a = op_a[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	exp_b = op_b[FORMAT_LENGTH-2:FRACTION_LENGTH];
	assign 	fra_a = op_a[FRACTION_LENGTH-1:0];
	assign 	fra_b = op_b[FRACTION_LENGTH-1:0];
	assign 	sign_a = op_a[FORMAT_LENGTH];
	assign 	sign_b = op_b[FORMAT_LENGTH];

//	Compare
	genvar i;
	generate
//	always @(*) begin
		for(i = 0; i < EXPONENT_LENGTH; i = i + 1)
		begin: comp_exp_1
			assign 	ex_eq_check[i] = op_a[i+FRACTION_LENGTH]~^op_b[i+FRACTION_LENGTH];
			assign 	ex_ge_pre_check[i] = op_a[i+FRACTION_LENGTH]&&(~op_b[i+FRACTION_LENGTH]);
		end	
//	end
	endgenerate
	
	genvar j;
	generate
//	always @)(*) begin
		assign 	ex_ge_check[0] = ex_eq_check[0] || ex_ge_pre_check[0];
		for(j = 1; j < EXPONENT_LENGTH; j = j + 1)
		begin: comp_exp_2
			ex_ge_check[j] = (ex_eq_check[j]&&ex_ge_pre_check[j-1])||ex_ge_pre_check[j];
		end
	endgenerate

	assign	exp_ge = ex_ge_check[EXPONENT_LENGTH-1];
	
	genvar m;
//	always @(*) begin
	generate
		for(m = 0; m < FRACTION_LENGTH; m = m + 1)
		begin: comp_fra_1
			fr_eq_check[m] = op_a[m]~^op_b[m];
			fr_ge_pre_check[m] = op_a[m]&&(~op_b[m]);
		end
	endgenerate

	genvar n;
	generate
		fr_ge_check[0] = fr_eq_check[0] || fr_ge_pre_check[0];
		for(n = 1; n < FRACTION_LENGTH; n = n + 1)
		begin: comp_fra_2
			fr_ge_check[n] = (fr_eq_check[n]&&fr_ge_pre_check[n-1])||fr_ge_pre_check[n];
		end
	endgenerate
	
	assign	fra_ge = fr_ge_check[EXPONENT_LENGTH-1];
	
//	Check type of operands
//	Type check A	
	always @(*) begin
		if((~(|exp_a))&&(!(|man_a)))	//	zero
			a_type = ZERO;
		else if((~(|exp_a))&&(!man_a))	// 	subnormal
			a_type = SUBNORMAL;
		else if((|exp_a)&&(!(&exp_a)))	// 	normal
			a_type = NORMAL;
		else if((&exp_a)&&(!(|man_a)))	// 	infinity
			a_type = INFINITY;
		else if((&exp_a)&&((|man_a))) 	// 	NaN
			a_type = NAN;
	end	
	
//	Type check B	
	always @(*) begin
		if((~(|exp_b))&&(!(|man_b)))	//	zero
			b_type = ZERO;
		else if((~(|exp_b))&&(!man_b))	// 	subnormal
			b_type = SUBNORMAL;
		else if((|exp_b)&&(!(&exp_b)))	// 	normal
			b_type = NORMAL;
		else if((&exp_b)&&(!(|man_b)))	// 	infinity
			b_type = INFINITY;
		else if((&exp_b)&&((|man_b))) 	// 	NaN
			b_type = NAN;
	end	

//	Special Case Handle
	always @(*) begin
		if(a_type == ZERO)
		begin
			if(!add_sub)
				special_sum[FORMAT_LENGTH-1] = sign_b;
			else 
				special_sum[FORMAT_LENGTH-1] = ~sign_b;
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			special_sum[FRACTION_LENGTH-1:0] fra_b;
		end	
		else if(b_type == ZERO)	
		begin
			special_sum[FORMAT_LENGTH-1] = sign_a;
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_sum[FRACTION_LENGTH-1:0] fra_a;	
		end
		else if((a_type[2] == 1'b1)&&(b_type == INFINITY))
		begin
			if(!add_sub)
				special_sum[FORMAT_LENGTH-1] = sign_b;
			else 
				special_sum[FORMAT_LENGTH-1] = ~sign_b;		
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_b;
			special_sum[FRACTION_LENGTH-1:0] fra_b;
		end
		else if((b_type[2] == 1'b1)&&(a_type == INFINITY))
		begin	
			special_sum[FORMAT_LENGTH-1] = sign_a;
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_sum[FRACTION_LENGTH-1:0] fra_a;			
		end
		else if((a_type == INFINITY)&&(b_type == INFINITY)&&(sign_a == sign_b))
		begin
			special_sum[FORMAT_LENGTH-1] = sign_a;
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_sum[FRACTION_LENGTH-1:0] fra_a;				
		end
		else if((a_type == INFINITY)&&(b_type == INFINITY)&&(sign_a != sign_b))
		begin
			if((sign_a == 1'b1)&&(sign_b == 1'b0)&&add_sub)
				special_sum[FORMAT_LENGTH-1] = 1'b1;
			else
				special_sum[FORMAT_LENGTH-1] = 1'b0;
			special_sum[FORMAT_LENGTH-2:FRACTION_LENGTH] = exp_a;
			special_sum[FRACTION_LENGTH-1:0] fra_a;					
		end	
	end

	assign	enable = ((a_type[2] == 1'b1)&&(b_type[2] == 1'b1)) ? 1 : 0;

//	Subnormal Block
	always @(*) begin
		if(fra_ge)
		begin
			sub_man_a = {1'b0, fra_a, 8'b0};
			sub_man_b = {1'b0, fra_b, 8'b0};
			sub_sign_a = sign_a;
			sub_sign_b = sign_b;
		end
		else
		begin
			sub_man_a = {1'b0, fra_b, 8'b0};
			sub_man_b = {1'b0, fra_a, 8'b0};
			sub_sign_a = sign_b;
			sub_sign_b = sign_a;
		end	
		sub_exp = exp_a;
	end	
		
//	Mixed Block
//	Detect
	always @(*) begin
		if(a_type == SUBNORMAL)
		begin
			mix_sub = fra_a;
			mix_man_a = {1'b1, fra_b, 8'b0};	
			mix_sign_a = sign_a;
			mix_sign_b = sign_b;
			mix_exp_a = exp_a;
		end
		else if(b_type == SUBNORMAL)
		begin
			mix_sub = fra_b;
			mix_man_a = {1'b1, fra_a, 8'b0};		
			sub_sign_a = sign_b;
			sub_sign_b = sign_a;
			mix_exp_a = exp_b;			
		end	
		else
		begin
			mix_sub = 0;
			mix_man_b = 0;		
			sub_sign_a = 0;
			sub_sign_b = 0;
			mix_exp_a = 0;
		end		
	end

//	Zero Counter
//	Subnormalnumber = 0.xxx * 2^-126	
	always @(*) begin
		casez(mix_sub)
		23'b000_0000_0000_0000_0000_0001:	
		begin
			mix_count = 'h17;
			mix_exp = 'h18;
		end
		23'b000_0000_0000_0000_0000_001?:	
		begin
			mix_count = 'h16;
			mix_exp = 'h17;
		end
		23'b000_0000_0000_0000_0000_01??:	
		begin
			mix_count = 'h15;
			mix_exp = 'h16;
		end
		23'b000_0000_0000_0000_0000_1???:	
		begin
			mix_count = 'h14;		
			mix_exp = 'h15;
		end
		23'b000_0000_0000_0000_0001_????:	
		begin
			mix_count = 'h13;			
			mix_exp = 'h14;
		end
		23'b000_0000_0000_0000_001?_????:
		begin
			mix_count = 'h12;	
			mix_exp = 'h13;
		end
		23'b000_0000_0000_0000_01??_????:
		begin
			mix_count = 'h11;	
			mix_exp = 'h12;
		end
		23'b000_0000_0000_0000_1???_????:	
		begin
			mix_count = 'h10;	
			mix_exp = 'h11;
		end	
		23'b000_0000_0000_0001_????_????:
		begin
			mix_count = 'h0F;	
			mix_exp = 'h10;
		end
		23'b000_0000_0000_001?_????_????:	
		begin 
			mix_count = 'h0E;	
			mix_exp = 'h0F;
		end	
		23'b000_0000_0000_01??_????_????:	
		begin
			mix_count = 'h0D;	
			mix_exp = 'h0E;
		end
		23'b000_0000_0000_1???_????_????:	
		begin
			mix_count = 'h0C;	
			mix_exp = 'h0D;
		end
		23'b000_0000_0001_????_????_????:	
		begin
			mix_count = 'h0B;	
			mix_exp = 'h0C;
		end
		23'b000_0000_001?_????_????_????:	
		begin
			mix_count = 'h0A;	
			mix_exp = 'h0B;
		end
		23'b000_0000_01??_????_????_????:	
		begin
			mix_count = 'h09;	
			mix_exp = 'h0A;
		end
		23'b000_0000_1???_????_????_????:
		begin
			mix_count = 'h08;	
			mix_exp = 'h09;
		end
		23'b000_0001_????_????_????_????:	
		begin
			mix_count = 'h07;	
			mix_exp = 'h08;
		end
		23'b000_001?_????_????_????_????:
		begin
			mix_count = 'h06;	
			mix_exp = 'h07;
		end
		23'b000_01??_????_????_????_????:	
		begin
			mix_count = 'h05;	
			mix_exp = 'h06
		end
		23'b000_1???_????_????_????_????:
		begin
			mix_count = 'h04;	
			mix_exp = 'h05;
		end
		23'b001_????_????_????_????_????:
		begin
			mix_count = 'h03;	
			mix_exp = 'h04;
		end
		23'b01?_????_????_????_????_????:	
		begin
			mix_count = 'h02;	
			mix_exp = 'h03;
		end
		23'b1??_00??_????_????_????_????:	
		begin
			mix_count = 'h01;	
			mix_exp = 'h02;
		end
		default:	
		begin
			mix_count = 'h00;
			mix_exp = 'h00;
		end		
	end
	
//	Shift right
	genvar a;
	generate
		for(a = 1; a < FRACTION_LENGTH; a = a + 1)
		begin:	shift_right_1
		assign sr_stage_1[a] = (mix_count[0]) ? sr_stage_2[a-1] : sr_stage_2[a];
		end
		assign sr_stage_1[0] = (mix_count[0]) ? 0 : sr_stage_2[0];
	endgenerate
	
	genvar b;
	generate 
		for(b = 2; b < FRACTION_LENGTH; b = b + 1)
		begin:	shift_right_2
		assign sr_stage_2[b] = (mix_count[1]) ? sr_stage_3[b-2] : sr_stage_3[b];
		end
		assign sr_stage_2[0] = (mix_count[1]) ? 0 : sr_stage_3[0];
		assign sr_stage_2[1] = (mix_count[1]) ? 0 : sr_stage_3[0];
	endgenerate
	
	genvar c;
	generate
		for(c = 4; c < FRACTION_LENGTH; c = c + 1)
		begin:	shift_right_3
		assign 	sr_stage_3[c] = (mix_count[2]) ? sr_stage_4[c-4] : sr_stage_4[c];
		end
		assign 	sr_stage_3[0] = (mix_count[3]) ? 0 : sr_stage_4[0];
		assign 	sr_stage_3[1] = (mix_count[3]) ? 0 : sr_stage_4[1];		
		assign 	sr_stage_3[2] = (mix_count[3]) ? 0 : sr_stage_4[2];
		assign 	sr_stage_3[3] = (mix_count[3]) ? 0 : sr_stage_4[3];
	endgenerate
	
	genvar d;
	generate
		for(d = 8; d < FRACTION_LENGTH; d = d + 1)
		begin:	shift_right_4_1
		assign 	sr_stage_4[d] = (mix_count[4]) ? sr_stage_5[d-8] : sr_stage_5[d]
		end
	endgenerate
	
	genvar e;
	generate 
		for(e = 0; e < 8; e = e + 1)
		begin: 	shift_right_4_2
		assign	sr_stage_4[e] = (mix_count) ? 0 : sr_stage_5[e];
		end
	endgenerate

	genvar f;
	generate
		for(f = 16, f < FRACTION_LENGTH; f = f + 1)
		begin:	shift_right_5_1
		assign 	sr_stage_5[f] = (mix_count[5]) ? mix_sub[f-16] : mix_sub[f];
		end
	endgenerate

	genvar g;
	generate
		for(g = 0; g < 16; g = g + 1)
		begin:	shift_right_5_2
		assign 	sr_stage_5[g] = (mix_count[5]) ? 0 : mix_sub[g];	
		end
	endgenerate	
		
//	Join
	assign	mix_man_b = {sr_stage_1, 9'b0};

//	Normal Block
//
		
*/		
		